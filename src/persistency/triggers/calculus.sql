CREATE TRIGGER trg_CalcularTotalPagar
ON Reserva
AFTER INSERT, UPDATE
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE R
  SET Total_Pagar = 
      ROUND(
        DATEDIFF(MINUTE, I.Hora_Inicio, I.Hora_Fim) / 60.0 * C.Preco_Hora,
        2
      )
  FROM Reserva R
  INNER JOIN inserted I ON R.ID = I.ID
  INNER JOIN Campo C ON I.ID_Campo = C.ID;
END;
GO

-- Trigger para INSERT com múltiplas linhas
CREATE TRIGGER trg_UpdateNoCampos_Insert
ON Campo_Priv
AFTER INSERT
AS
BEGIN
  UPDATE a
  SET No_Campos = No_Campos + ins.CountCampos
  FROM Arrendador a
  JOIN (
    SELECT ID_Arrendador, COUNT(*) AS CountCampos
    FROM inserted
    GROUP BY ID_Arrendador
  ) ins ON a.ID_Arrendador = ins.ID_Arrendador;
END;
GO

-- Trigger para DELETE com múltiplas linhas
CREATE TRIGGER trg_UpdateNoCampos_Delete
ON Campo_Priv
AFTER DELETE
AS
BEGIN
  UPDATE a
  SET No_Campos = No_Campos - del.CountCampos
  FROM Arrendador a
  JOIN (
    SELECT ID_Arrendador, COUNT(*) AS CountCampos
    FROM deleted
    GROUP BY ID_Arrendador
  ) del ON a.ID_Arrendador = del.ID_Arrendador;
END;
GO

-- Atualiza o número de jogadores após inserção
CREATE TRIGGER trg_UpdateNoJogadores_Insert
ON Jogador_joga
AFTER INSERT
AS
BEGIN
  UPDATE p
  SET no_jogadores = (
    SELECT COUNT(*) FROM Jogador_joga WHERE ID_Partida = i.ID_Partida
  )
  FROM Partida p
  JOIN inserted i ON p.ID = i.ID_Partida;
END;
GO

-- Atualiza o número de jogadores após remoção
CREATE TRIGGER trg_UpdateNoJogadores_Delete
ON Jogador_joga
AFTER DELETE
AS
BEGIN
  UPDATE p
  SET no_jogadores = (
    SELECT COUNT(*) FROM Jogador_joga WHERE ID_Partida = d.ID_Partida
  )
  FROM Partida p
  JOIN deleted d ON p.ID = d.ID_Partida;
END;
GO

-- Atualiza o número de jogadores após atualização
CREATE TRIGGER trg_UpdateCampoOcupadoOnPartidaInsert
ON Partida
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentTime DATETIME = GETDATE();  -- Current time: 03:42 AM WEST, May 30, 2025

    -- Update Campo.Ocupado based on newly inserted Partida
    UPDATE c
    SET c.Ocupado = 1
    FROM Campo c
    INNER JOIN inserted i ON c.ID = i.ID_Campo
    WHERE i.Data_Hora <= @CurrentTime
        AND DATEADD(MINUTE, i.Duracao, i.Data_Hora) > @CurrentTime
        AND i.Estado IN ('Aguardando', 'Andamento');  -- Only consider active matches
END;
GO

CREATE TRIGGER trg_UpdateCampoOcupadoOnPartidaUpdate
ON Partida
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentTime DATETIME = GETDATE();  -- Current time: 03:42 AM WEST, May 30, 2025

    -- Reset Ocupado status for Campos where the match has ended or been finalized
    UPDATE c
    SET c.Ocupado = 0
    FROM Campo c
    INNER JOIN inserted i ON c.ID = i.ID_Campo
    WHERE i.Estado = 'Finalizada'  -- Match has ended
        OR DATEADD(MINUTE, i.Duracao, i.Data_Hora) <= @CurrentTime;  -- Match duration has passed

    -- Set Ocupado status for Campos where a match is still ongoing after update
    UPDATE c
    SET c.Ocupado = 1
    FROM Campo c
    INNER JOIN inserted i ON c.ID = i.ID_Campo
    WHERE i.Data_Hora <= @CurrentTime
        AND DATEADD(MINUTE, i.Duracao, i.Data_Hora) > @CurrentTime
        AND i.Estado IN ('Aguardando', 'Andamento');
END;
GO