-- CRUD das Reservas

USE SPORTSLINK;
GO

-- Criar uma reserva
CREATE PROCEDURE sp_CreateReserva
  @ID_Campo INT,
  @ID_Jogador INT,
  @Data DATE,
  @Hora_Inicio TIME,
  @Hora_Fim TIME,
  @Total_Pagamento DECIMAL(10,2),
  @Estado VARCHAR(50),
  @Descricao VARCHAR(2500) = NULL
AS
BEGIN
  INSERT INTO Reserva (ID_Campo, ID_Jogador, [Data], Hora_Inicio, Hora_Fim, Total_Pagamento, Estado, Descricao)
  VALUES (@ID_Campo, @ID_Jogador, @Data, @Hora_Inicio, @Hora_Fim, @Total_Pagamento, @Estado, @Descricao);
END;
GO

-- Obter todas as reservas
CREATE PROCEDURE sp_GetAllReservas
AS
BEGIN
  SELECT * FROM Reserva;
END;
GO

-- Obter reserva por ID
CREATE PROCEDURE sp_GetReservaByID
  @ID INT
AS
BEGIN
  SELECT * FROM Reserva WHERE ID = @ID;
END;
GO

-- Obter reservas por jogador
CREATE PROCEDURE sp_GetReservasByUser
  @ID_Utilizador INT
AS
BEGIN
  SELECT * FROM vw_ReservasDetalhadas WHERE ID_Utilizador = @ID_Utilizador;
END;
GO

-- Obter reservas por campo
CREATE PROCEDURE sp_GetReservasByCampo
  @ID_Campo INT
AS
BEGIN
  SELECT * FROM vw_ReservasDetalhadas WHERE ID_Campo = @ID_Campo;
END;
GO

-- Atualizar uma reserva
CREATE PROCEDURE sp_UpdateReserva
  @ID INT,
  @ID_Campo INT = NULL,
  @ID_Jogador INT = NULL,
  @Data DATE = NULL,
  @Hora_Inicio TIME = NULL,
  @Hora_Fim TIME = NULL,
  @Total_Pagamento DECIMAL(10,2) = NULL,
  @Estado VARCHAR(50) = NULL,
  @Descricao VARCHAR(2500) = NULL
AS
BEGIN
  UPDATE Reserva
  SET
    ID_Campo = ISNULL(@ID_Campo, ID_Campo),
    ID_Jogador = ISNULL(@ID_Jogador, ID_Jogador),
    [Data] = ISNULL(@Data, [Data]),
    Hora_Inicio = ISNULL(@Hora_Inicio, Hora_Inicio),
    Hora_Fim = ISNULL(@Hora_Fim, Hora_Fim),
    Total_Pagamento = ISNULL(@Total_Pagamento, Total_Pagamento),
    Estado = ISNULL(@Estado, Estado),
    Descricao = ISNULL(@Descricao, Descricao)
  WHERE ID = @ID;
END;
GO

-- Eliminar uma reserva
CREATE PROCEDURE sp_DeleteReserva
  @ID INT
AS
BEGIN
  DELETE FROM Reserva WHERE ID = @ID;
END;
GO
