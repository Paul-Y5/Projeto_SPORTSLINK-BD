-- CRUD para a tabela Partida

CREATE PROCEDURE sp_CreatePartida
  @ID_Campo INT,
  @No_Jogadores INT,
  @Data_Hora DATETIME,
  @Duracao INT,
  @Resultado VARCHAR(50)
AS
BEGIN
  INSERT INTO Partida (ID_Campo, No_Jogadores, Data_Hora, Duracao, Resultado)
  VALUES (@ID_Campo, @No_Jogadores, @Data_Hora, @Duracao, @Resultado);
END;
GO

CREATE PROCEDURE sp_GetPartida
  @ID INT
AS
BEGIN
  SELECT * FROM Partida WHERE ID = @ID;
END;
GO

CREATE PROCEDURE sp_UpdatePartida
  @ID INT,
  @No_Jogadores INT,
  @Data_Hora DATETIME,
  @Duracao INT,
  @Resultado VARCHAR(50)
AS
BEGIN
  UPDATE Partida
  SET No_Jogadores = @No_Jogadores, Data_Hora = @Data_Hora, Duracao = @Duracao, Resultado = @Resultado
  WHERE ID = @ID;
END;
GO

CREATE PROCEDURE sp_DeletePartida
  @ID INT
AS
BEGIN
  DELETE FROM Partida WHERE ID = @ID;
END;
GO