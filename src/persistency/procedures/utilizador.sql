-- CRUD para a tabela Utilizador
USE SPORTSLINK;
GO

CREATE PROCEDURE sp_CreateUtilizador
  @Nome VARCHAR(256),
  @Email VARCHAR(512),
  @Num_Tele VARCHAR(64),
  @Password VARCHAR(512),
  @Nacionalidade VARCHAR(128)
AS
BEGIN
  SET NOCOUNT ON;
  INSERT INTO Utilizador (Nome, Email, Num_Tele, [Password], Nacionalidade)
  VALUES (@Nome, @Email, @Num_Tele, @Password, @Nacionalidade);
END;
GO

CREATE PROCEDURE sp_GetUserInfo
  @UserID INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
    u.ID, 
    u.Nome, 
    u.Email, 
    u.Num_Tele, 
    u.Nacionalidade, 
    j.Idade, 
    a.IBAN, 
    a.No_Campos, 
    j.Descricao,
    CASE 
        WHEN a.ID_Arrendador IS NOT NULL THEN 'Arrendador'
        ELSE 'Jogador'
    END AS Tipo
  FROM Utilizador u
  LEFT JOIN Jogador j ON u.ID = j.ID
  LEFT JOIN Arrendador a ON u.ID = a.ID_Arrendador
  WHERE u.ID = @UserID;
END;
GO

CREATE PROCEDURE sp_UpdateUserInfo
  @UserID INT,
  @Nome VARCHAR(256) = NULL,
  @Email VARCHAR(512) = NULL,
  @Num_Tele VARCHAR(64) = NULL,
  @Nacionalidade VARCHAR(128) = NULL,
  @Password VARCHAR(512) = NULL,
  @Descricao VARCHAR(2500) = NULL,
  @Idade INT = NULL,
  @IBAN VARCHAR(34) = NULL,
  @No_Campos INT = NULL
AS
BEGIN
  SET NOCOUNT ON;
  -- Atualiza Utilizador
  UPDATE Utilizador
  SET 
    Nome = ISNULL(@Nome, Nome),
    Email = ISNULL(@Email, Email),
    Num_Tele = ISNULL(@Num_Tele, Num_Tele),
    Nacionalidade = ISNULL(@Nacionalidade, Nacionalidade),
    [Password] = ISNULL(@Password, [Password])
  WHERE ID = @UserID;

  -- Atualiza Jogador (se existir)
  UPDATE Jogador
  SET 
    Idade = ISNULL(@Idade, Idade),
    Descricao = ISNULL(@Descricao, Descricao)
  WHERE ID = @UserID;

  -- Atualiza Arrendador (se existir)
  UPDATE Arrendador
  SET 
    IBAN = ISNULL(@IBAN, IBAN),
    No_Campos = ISNULL(@No_Campos, No_Campos)
  WHERE ID_Arrendador = @UserID;
END;
GO


-- Apagar uma conta de utilizador
CREATE PROCEDURE sp_DeleteUtilizador
  @ID INT
AS
BEGIN
  SET NOCOUNT ON;
  DELETE FROM Utilizador WHERE ID = @ID;
END;
GO