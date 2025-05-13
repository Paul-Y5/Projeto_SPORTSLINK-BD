-- CRUD para a tabela Utilizador

CREATE PROCEDURE sp_GetUtilizadorByEmail
  @Email VARCHAR(512)
AS
BEGIN
  SELECT * FROM Utilizador WHERE Email = @Email;
END;

CREATE PROCEDURE sp_CreateUtilizador
  @Nome VARCHAR(256),
  @Email VARCHAR(512),
  @Num_Tele VARCHAR(64),
  @Password VARCHAR(512),
  @Nacionalidade VARCHAR(128)
AS
BEGIN
  INSERT INTO Utilizador (Nome, Email, Num_Tele, [Password], Nacionalidade)
  VALUES (@Nome, @Email, @Num_Tele, @Password, @Nacionalidade);
END;
GO
Use SPORTSLINK;
go

CREATE PROCEDURE sp_UpdateUtilizador
  @ID INT,
  @Nome VARCHAR(256),
  @Email VARCHAR(512),
  @Num_Tele VARCHAR(64),
  @Password VARCHAR(512),
  @Nacionalidade VARCHAR(128)
AS
BEGIN
  UPDATE Utilizador
  SET Nome = @Nome, Email = @Email, Num_Tele = @Num_Tele, [Password] = @Password, Nacionalidade = @Nacionalidade
  WHERE ID = @ID;
END;
GO

CREATE PROCEDURE sp_DeleteUtilizador
  @ID INT
AS
BEGIN
  DELETE FROM Utilizador WHERE ID = @ID;
END;
GO

CREATE PROCEDURE sp_GetUserInfo
  @UserID INT
AS
BEGIN
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
  JOIN Jogador j ON u.ID = j.ID
  LEFT JOIN Arrendador a ON u.ID = a.ID_Arrendador
  WHERE u.ID = @UserID;
END;
GO

CREATE PROCEDURE sp_UpdateUserInfo
  @UserID INT,
  @Nome VARCHAR(256),
  @Email VARCHAR(256),
  @Num_Tele VARCHAR(15),
  @Nacionalidade VARCHAR(256)
AS
BEGIN
  UPDATE Utilizador
  SET Nome = @Nome, Email = @Email, Num_Tele = @Num_Tele, Nacionalidade = @Nacionalidade
  WHERE ID = @UserID;
END;
GO

CREATE PROCEDURE sp_GetAllUsers
  @OrderBy NVARCHAR(50),
  @Direction NVARCHAR(4),
  @Search NVARCHAR(256) = NULL,
  @TipoUtilizador NVARCHAR(20) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  SET @OrderBy = CASE 
                   WHEN @OrderBy IN ('U.ID', 'U.Nome', 'U.Email', 'U.Num_Tele', 'U.Nacionalidade',
                                     'J.Idade', 'J.Descricao', 'A.IBAN', 'A.No_Campos') 
                   THEN @OrderBy 
                   ELSE 'U.ID' 
                 END;

  SET @Direction = CASE 
                     WHEN @Direction IN ('ASC', 'DESC') 
                     THEN @Direction 
                     ELSE 'ASC' 
                   END;

  DECLARE @SQL NVARCHAR(MAX);

  SET @SQL = '
    SELECT 
      U.ID, 
      U.Nome, 
      U.Email, 
      U.Num_Tele, 
      U.Nacionalidade, 
      J.Idade, 
      J.Descricao, 
      A.IBAN, 
      A.No_Campos,
      CASE 
        WHEN A.ID_Arrendador IS NOT NULL THEN ''Arrendador''
        ELSE ''Jogador''
      END AS Tipo
    FROM Utilizador AS U
    JOIN Jogador AS J ON U.ID = J.ID
    LEFT JOIN Arrendador AS A ON U.ID = A.ID_Arrendador
    WHERE (@Search IS NULL OR 
           U.Nome LIKE @Search OR 
           U.Email LIKE @Search OR 
           U.Num_Tele LIKE @Search OR 
           U.Nacionalidade LIKE @Search)
      AND (@TipoUtilizador IS NULL OR 
           (@TipoUtilizador = ''Arrendador'' AND A.ID_Arrendador IS NOT NULL) OR 
           (@TipoUtilizador = ''Jogador'' AND A.ID_Arrendador IS NULL))
    ORDER BY ' + QUOTENAME(@OrderBy) + ' ' + @Direction;

  -- Executa a query dinâmica com parâmetros
  EXEC sp_executesql @SQL, 
       N'@Search NVARCHAR(256), @TipoUtilizador NVARCHAR(20)',
       @Search, @TipoUtilizador;
END;
GO
