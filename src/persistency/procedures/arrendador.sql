-- CRUD Tabela Arrendador
USE SPORTSLINK;
GO

CREATE PROCEDURE sp_CreateArrendador
  @ID_Utilizador INT,
  @IBAN   VARCHAR(34),
  @No_Campos INT = 0
AS
BEGIN
  INSERT INTO Arrendador (ID_Arrendador, IBAN, No_Campos)
  VALUES (@ID_Utilizador, @IBAN, @No_Campos);
END;
GO

CREATE PROCEDURE sp_DeleteArrendador
  @ID INT
AS
BEGIN
  DELETE FROM Arrendador WHERE ID_Arrendador = @ID;
END;
GO

CREATE PROCEDURE sp_UpdateNoCamposArrendador
  @ID_Utilizador INT
AS
BEGIN
  UPDATE Arrendador
  SET No_Campos = No_Campos - 1
  WHERE ID_Arrendador = @ID_Utilizador;
END;
GO

CREATE PROCEDURE sp_GetCamposByUser
  @UserID INT
AS
BEGIN
 SELECT 
    c.ID, 
    c.Nome, 
    c.Largura, 
    c.Comprimento, 
    c.Descricao, 
    c.Endereco, 
    p.Latitude, 
    p.Longitude, 
    c.Ocupado,
    STRING_AGG(di.Nome, ', ') AS Dias_Disponiveis,
    CASE WHEN c.Ocupado = 1 THEN 'Sim' ELSE 'Não' END AS OcupadoStr,
    CASE WHEN cp.ID_Arrendador IS NOT NULL THEN 'Privado' ELSE 'Publico' END AS Tipo
  FROM Campo AS c
  JOIN Ponto AS p ON c.ID_Ponto = p.ID
  LEFT JOIN Campo_Priv AS cp ON c.ID = cp.ID_Campo
  JOIN Disponibilidade AS d ON c.ID = d.ID_Campo
  JOIN Dias_semana AS di ON d.ID_Dia = di.ID

	Where ID_Arrendador = @UserID
    GROUP BY c.ID, c.Nome, c.Largura, c.Comprimento, c.Descricao, c.Endereco, p.Latitude, 
      p.Longitude, c.Ocupado, cp.ID_Arrendador
END;
GO

CREATE PROCEDURE sp_IsArrendador
  @UserID INT
AS
BEGIN
  SELECT CASE 
    WHEN COUNT(*) > 0 THEN 1
      ELSE 0
    END AS IsArrendador
  FROM Arrendador
  WHERE ID_Arrendador = @UserID;
END;
GO

CREATE PROCEDURE sp_addCampoPriv
  @ID_Utilizador INT,
  @Latitude DECIMAL(9,6),
  @Longitude DECIMAL(9,6),
  @ID_Mapa INT = 1,
  @Nome VARCHAR(256),
  @Endereco VARCHAR(512),
  @Comprimento DECIMAL(10,2),
  @Largura DECIMAL(10,2),
  @Ocupado BIT,
  @Descricao VARCHAR(2500)
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @ID_Campo INT;

    EXEC sp_CreateCampo
      @Nome, 
      @Endereco, 
      @Comprimento, 
      @Largura, 
      @Ocupado, 
      @Descricao,
      @Latitude, 
      @Longitude,
      @ID_Mapa,
      @ID_Campo OUTPUT;

    IF @ID_Campo IS NULL
    BEGIN
      RAISERROR('Erro ao criar o campo. ID_Campo é NULL.', 16, 1);
    END

    INSERT INTO Campo_Priv(ID_Campo, ID_Arrendador)
    VALUES (@ID_Campo, @ID_Utilizador);

    UPDATE Arrendador
    SET No_Campos = No_Campos + 1
    WHERE ID_Arrendador = @ID_Utilizador;

    SELECT @ID_Campo AS ID_Campo;

    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;

    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrSeverity INT = ERROR_SEVERITY();
    RAISERROR(@ErrMsg, @ErrSeverity, 1);
  END CATCH
END;
GO

CREATE PROCEDURE sp_GetReservasByCampo
  @ID_Campo INT
AS
BEGIN
SELECT 
  u.Nome, 
  u.Nacionalidade, 
  u.Num_Tele, 
  r.[Data],
  r.Hora_Inicio,
  r.Descricao,
  di.Preco, 
  dbo.CalculaHorasFormatado(r.Hora_Inicio, r.Hora_Fim) AS Duracao_Horas
  FROM Reserva AS r
  JOIN Disponibilidade AS di ON di.ID_Campo = r.ID_Campo 
  JOIN Utilizador AS u ON u.ID = r.ID_Jogador
  WHERE r.ID_Campo = @ID_Campo
  AND di.ID_Dia = DATEPART(WEEKDAY, r.Data)
END;
GO
