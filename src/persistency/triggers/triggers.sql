USE SPORTSLINK;
GO

-- Trigger para calcular a idade do jogador
CREATE TRIGGER trg_CalculaIdade
ON Jogador
AFTER INSERT, UPDATE
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE j
  SET j.Idade = DATEDIFF(YEAR, i.Data_Nascimento, GETDATE()) 
    - CASE 
        WHEN MONTH(i.Data_Nascimento) > MONTH(GETDATE())
            OR (MONTH(i.Data_Nascimento) = MONTH(GETDATE()) AND DAY(i.Data_Nascimento) > DAY(GETDATE()))
        THEN 1 
        ELSE 0 
        END
  FROM Jogador j
  INNER JOIN inserted i ON j.ID = i.ID;
END;
GO

-- Trigger para verificar reservas sobrepostas
CREATE TRIGGER trg_PreventOverlappingReservations
ON Reserva
INSTEAD OF INSERT
AS
BEGIN
  IF EXISTS (
    SELECT 1
    FROM Reserva r
    JOIN inserted i ON r.ID_Campo = i.ID_Campo AND r.[Data] = i.[Data]
    WHERE
      (i.Hora_Inicio < r.Hora_Fim AND i.Hora_Fim > r.Hora_Inicio)
  )
  BEGIN
    RAISERROR('Já existe uma reserva para este campo neste horário.', 16, 1);
    ROLLBACK TRANSACTION;
    RETURN;
  END
  INSERT INTO Reserva (ID_Campo, ID_Jogador, [Data], Hora_Inicio, Hora_Fim, Total_Pagamento, Estado, Descricao)
  SELECT ID_Campo, ID_Jogador, [Data], Hora_Inicio, Hora_Fim, Total_Pagamento, Estado, Descricao
  FROM inserted;
END;
GO

-- Trigger para atualizar o estado do campo quando uma reserva é criada/cancelada
CREATE TRIGGER trg_UpdateCampoOcupadoOnReserva
ON Reserva
AFTER INSERT, DELETE
AS
BEGIN
  -- Se houver reservas ativas, marca o campo como ocupado
  UPDATE Campo
  SET Ocupado = 1
  WHERE ID IN (SELECT ID_Campo FROM inserted)
    AND EXISTS (SELECT 1 FROM Reserva WHERE ID_Campo = Campo.ID AND Estado = 'Ativa');

  -- Se não houver reservas ativas, marca como livre
  UPDATE Campo
  SET Ocupado = 0
  WHERE ID IN (SELECT ID_Campo FROM deleted)
    AND NOT EXISTS (SELECT 1 FROM Reserva WHERE ID_Campo = Campo.ID AND Estado = 'Ativa');
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


-- Calculo Imediato de Total_Pagamento
CREATE TRIGGER tr_CalcularTotalPagamento
ON Reserva
AFTER INSERT
AS
BEGIN
    -- Declaração das variáveis necessárias
    DECLARE @ID INT;
    DECLARE @ID_Campo INT;
    DECLARE @Data DATE;
    DECLARE @Hora_Inicio TIME;
    DECLARE @Hora_Fim TIME;
    DECLARE @Preco DECIMAL(10,2);
    DECLARE @Total DECIMAL(10,2);
    DECLARE @Inicio DATETIME;
    DECLARE @Fim DATETIME;
    DECLARE @Dia_Semana INT;

    -- Obter os valores da linha inserida
    SELECT 
        @ID = ID,
        @ID_Campo = ID_Campo,
        @Data = [Data],
        @Hora_Inicio = Hora_Inicio,
        @Hora_Fim = Hora_Fim
    FROM inserted;

    -- Determinar o dia da semana (1=Domingo, 2=Segunda, ..., 7=Sábado)
    SET @Dia_Semana = DATEPART(WEEKDAY, @Data);

    -- Procurar o preço do campo para esse dia da semana
    SELECT @Preco = Preco
    FROM Disponibilidade
    WHERE ID_Campo = @ID_Campo 
    AND ID_dia = @Dia_Semana;

    -- Verificar se o preço foi encontrado (campo disponível no dia)
    IF @Preco IS NULL
    BEGIN
        RAISERROR('Campo não disponível neste dia', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Criar valores DATETIME combinando Data com Hora_Inicio e Hora_Fim
    SET @Inicio = CAST(@Data AS DATETIME) + CAST(@Hora_Inicio AS DATETIME);
    SET @Fim = CAST(@Data AS DATETIME) + CAST(@Hora_Fim AS DATETIME);

    -- Calcular o total a pagar usando a UDF
    SET @Total = dbo.fn_TotalPagamento(@Inicio, @Fim, @Preco);

    -- Atualizar o campo Total_Pagamento na reserva
    UPDATE Reserva
    SET Total_Pagamento = @Total
    WHERE ID = @ID;
END;
GO