USE SPORTSLINK;
GO

CREATE PROCEDURE sp_CreatePonto
  @ID_Mapa INT = 1,
  @Latitude DECIMAL(9,6),
  @Longitude DECIMAL(9,6),
  @ID_Ponto INT OUTPUT
AS
BEGIN
  INSERT INTO Ponto (ID_Mapa, Latitude, Longitude)
  VALUES (@ID_Mapa, @Latitude, @Longitude);

  SET @ID_Ponto = SCOPE_IDENTITY();
END;
GO

CREATE PROCEDURE sp_GetPonto
  @ID INT
AS
BEGIN
  SELECT * FROM Ponto WHERE ID = @ID;
END;
GO

CREATE PROCEDURE sp_UpdatePonto
  @ID INT,
  @Latitude DECIMAL(9,6),
  @Longitude DECIMAL(9,6)
AS
BEGIN
  UPDATE Ponto
  SET Latitude = @Latitude, Longitude = @Longitude
  where ID = (Select ID_Ponto from Campo where ID = @ID)
END;
GO