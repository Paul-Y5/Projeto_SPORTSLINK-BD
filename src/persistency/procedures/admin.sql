USE SPORTSLINK;
GO

-- Para a página de Aministração da aplicação, onde o administrador pode ver todos os utilizadores, campos, partidas, reservas, etc.
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

-- Campos
CREATE PROCEDURE sp_GetAllCampos
  @OrderBy NVARCHAR(50) = NULL,
  @Direction NVARCHAR(4) = NULL,
  @Search NVARCHAR(256) = NULL,
  @Tipo NVARCHAR(20) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  SET @OrderBy = CASE 
                   WHEN @OrderBy IN ('Nome_Campo', 'Largura', 'Comprimento', 'Endereco', 'Ocupado', 'Tipo') 
                   THEN @OrderBy 
                   ELSE 'Nome_Campo' 
                 END;

  SET @Direction = CASE 
                     WHEN @Direction IN ('ASC', 'DESC') 
                     THEN @Direction 
                     ELSE 'ASC' 
                   END;

  DECLARE @SQL NVARCHAR(MAX);

  SET @SQL = '
    SELECT 
      c.ID, 
      c.Nome AS Nome_Campo, 
      c.Largura, 
      c.Comprimento, 
      c.Descricao, 
      c.Endereco, 
      p.Latitude, 
      p.Longitude, 
      c.Ocupado,
      STRING_AGG(di.Nome, '', '') AS Dias_Disponiveis,
      CASE WHEN c.Ocupado = 1 THEN ''Sim'' ELSE ''Não'' END AS OcupadoStr,
      CASE WHEN cp.ID IS NOT NULL THEN ''Privado'' ELSE ''Publico'' END AS Tipo
    FROM Campo AS c
    JOIN Ponto AS p ON c.ID_Ponto = p.ID
    LEFT JOIN Campo_Priv AS cp ON c.ID = cp.ID_Campo
    JOIN Disponibilidade AS d ON c.ID = d.ID_Campo
    JOIN Dias_semana AS di ON d.ID_Dia = di.ID
    WHERE (@Search IS NULL OR 
           c.Nome LIKE @Search OR 
           c.Endereco LIKE @Search OR 
           c.Descricao LIKE @Search)
      AND (@Tipo IS NULL OR 
           (@Tipo = ''Privado'' AND cp.ID IS NOT NULL) OR
           (@Tipo = ''Publico'' AND cp.ID IS NULL))
    GROUP BY c.ID, c.Nome, c.Largura, c.Comprimento, c.Descricao, c.Endereco, p.Latitude, 
      p.Longitude, c.Ocupado, cp.ID
    ORDER BY ' + QUOTENAME(@OrderBy) + ' ' + @Direction + ';
  ';

  EXEC sp_executesql @SQL, 
    N'@Search NVARCHAR(256), @Tipo NVARCHAR(20)', 
    @Search, @Tipo;
END;
GO
