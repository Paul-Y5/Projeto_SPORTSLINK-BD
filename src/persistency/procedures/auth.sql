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
CREATE PROCEDURE sp_CheckUtilizadorExists
  @Email VARCHAR(512)
AS
BEGIN
  SELECT COUNT(*) AS UtilizadorExists FROM Utilizador WHERE Email = @Email;
END;
GO