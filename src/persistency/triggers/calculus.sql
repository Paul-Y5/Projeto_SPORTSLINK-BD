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

-- Trigger para atualizar o número de campos de um arrendador
CREATE TRIGGER trg_UpdateNoCampos_Insert
ON Campo_Priv
AFTER INSERT
AS
BEGIN
  UPDATE a
  SET No_Campos = No_Campos + 1
  FROM Arrendador a
  JOIN inserted i ON a.ID_Arrendador = i.ID_Arrendador;
END;
GO

-- Trigger para atualizar o número de campos de um arrendador
CREATE TRIGGER trg_UpdateNoCampos_Delete
ON Campo_Priv
AFTER DELETE
AS
BEGIN
  UPDATE a
  SET No_Campos = No_Campos - 1
  FROM Arrendador a
  JOIN deleted d ON a.ID_Arrendador = d.ID_Arrendador;
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
