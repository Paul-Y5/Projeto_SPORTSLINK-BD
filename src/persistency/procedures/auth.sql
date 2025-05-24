USE SPORTSLINK;
GO

-- Autenticar Utilizador
CREATE PROCEDURE sp_AuthenticateUtilizador
  @Email VARCHAR(512),
  @Password VARCHAR(512)
AS
BEGIN
  SELECT * FROM Utilizador WHERE Email = @Email AND [Password] = @Password;
END;
GO


-- Verificar se o utilizador existe
CREATE PROCEDURE sp_UtilizadorExists
  @Email VARCHAR(512)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT CASE 
    WHEN COUNT(*) > 0 THEN 1
      ELSE 0
    END AS UtilizadorExists
  FROM Utilizador
  WHERE Email = @Email;
END;
GO

-- lista de desportos
CREATE PROCEDURE sp_GetDesportos
AS
BEGIN
  SET NOCOUNT ON;
  SELECT Nome FROM Desporto;
END;