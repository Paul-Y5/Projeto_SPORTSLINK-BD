USE SPORTSLINK;
GO

CREATE PROCEDURE sp_CreateCampo
  @Nome VARCHAR(256),
  @Endereco VARCHAR(512),
  @Comprimento DECIMAL(10,2),
  @Largura DECIMAL(10,2),
  @Ocupado BIT = 0,
  @Descricao VARCHAR(2500),
  @Latitude DECIMAL(9,6),
  @Longitude DECIMAL(9,6),
  @ID_Mapa INT = 1,
  @URL VARCHAR(1000) = NULL,
  @ID_Campo INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @ID_Ponto INT;
    EXEC sp_CreatePonto @ID_Mapa, @Latitude, @Longitude, @ID_Ponto OUTPUT;

    INSERT INTO Campo (ID_Ponto, ID_Mapa, Nome, Endereco, Comprimento, Largura, Ocupado, Descricao)
    VALUES (@ID_Ponto, @ID_Mapa, @Nome, @Endereco, @Comprimento, @Largura, @Ocupado, @Descricao);

    SET @ID_Campo = SCOPE_IDENTITY();

    -- Adicionar imagem se fornecida
    IF @URL IS NOT NULL
    BEGIN
      DECLARE @ID_img INT;
      EXEC sp_CreateImg @URL, @ID_img OUTPUT;

      INSERT INTO IMG_Campo (ID_Campo, ID_img)
      VALUES (@ID_Campo, @ID_img);
    END

    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrState INT = ERROR_STATE();
    RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);
  END CATCH
END;
GO


-- Procedure para obter campos com filtros e ordenação
CREATE OR ALTER PROCEDURE sp_GetCampos
    @ID_Campo INT = NULL,
    @ID_Arrendador INT = NULL,
    @Tipo VARCHAR(10) = NULL,
    @Pesquisa NVARCHAR(100) = NULL,
    @OrderBy NVARCHAR(50) = 'Nome',
    @OrderDir VARCHAR(4) = 'ASC',
    @UserLat FLOAT = NULL,
    @UserLon FLOAT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @EffectiveOrderBy NVARCHAR(50);

    -- Determina o campo de ordenação efetivo
    SET @EffectiveOrderBy = 
        CASE 
            WHEN @OrderBy = 'Distance' AND @UserLat IS NOT NULL AND @UserLon IS NOT NULL THEN 'Distance'
            ELSE COALESCE(@OrderBy, 'Nome')
        END;

    SET @SQL = '
        SELECT *, 
               dbo.fn_CalculateDistance(@UserLat, @UserLon, vw.LATITUDE, vw.LONGITUDE) AS Distance
        FROM vw_CamposDisponiveis AS vw
        WHERE 1 = 1' +
        -- Filtro por ID específico
        CASE 
            WHEN @ID_Campo IS NOT NULL THEN ' AND vw.ID = @ID_Campo'
            ELSE '' 
        END +
        -- Filtro por tipo de campo
        CASE 
            WHEN @Tipo IS NOT NULL THEN ' AND vw.Tipo = @Tipo'
            ELSE '' 
        END +
        -- Filtro por pesquisa em Nome, Endereço, Dias_Disponiveis, Desportos, NOME_ARRENDADOR
        CASE 
            WHEN @Pesquisa IS NOT NULL THEN 
                ' AND (vw.Nome LIKE ''%'' + @Pesquisa + ''%'' OR vw.Endereco LIKE ''%'' + @Pesquisa + ''%'' 
                       OR vw.Dias_Disponiveis LIKE ''%'' + @Pesquisa + ''%'' OR vw.Desportos LIKE ''%'' + @Pesquisa + ''%''
                       OR vw.NOME_ARRENDADOR LIKE ''%'' + @Pesquisa + ''%'' )'
            ELSE '' 
        END +
        -- Excluir campos privados do próprio arrendador
        CASE 
            WHEN @ID_Arrendador IS NOT NULL THEN 
                ' AND (vw.Tipo = ''Publico'' OR (vw.Tipo = ''Privado'' AND vw.ID_Arrendador <> @ID_Arrendador))'
            ELSE '' 
        END +
        ' ORDER BY ' + QUOTENAME(@EffectiveOrderBy) + ' ' + 
            CASE WHEN @OrderDir = 'DESC' THEN 'DESC' ELSE 'ASC' END + ';';

    -- Executa a SQL montada dinamicamente com os parâmetros
    EXEC sp_executesql 
        @SQL,
        N'@ID_Campo INT, @ID_Arrendador INT, @Tipo VARCHAR(10), @Pesquisa NVARCHAR(100), @OrderBy NVARCHAR(50), @OrderDir VARCHAR(4), @UserLat FLOAT, @UserLon FLOAT',
        @ID_Campo, @ID_Arrendador, @Tipo, @Pesquisa, @OrderBy, @OrderDir, @UserLat, @UserLon;
END;
GO


CREATE PROCEDURE sp_DeleteCampo
  @ID INT
AS
BEGIN
  SET NOCOUNT ON;
  -- Atualização feita por trigger

  -- Apagar o campo
  DELETE FROM Campo WHERE ID = @ID;
END
GO


CREATE PROCEDURE sp_GetCampoByPonto
  @ID_Ponto INT
AS
BEGIN
  SELECT * FROM Campo WHERE ID_Ponto = @ID_Ponto;
END;
GO

CREATE PROCEDURE sp_createCampoPub
  @Latitude DECIMAL(9,6),
  @Longitude DECIMAL(9,6),
  @ID_Mapa INT = 1,
  @Nome VARCHAR(256),
  @Endereco VARCHAR(512),
  @Comprimento DECIMAL(10,2),
  @Largura DECIMAL(10,2),
  @Ocupado BIT,
  @Descricao VARCHAR(2500),
  @Entidade_publica_resp VARCHAR(256),
  @URL VARCHAR(1000) = NULL,
  @NewID INT OUTPUT -- Adiciona isso
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @ID_Campo INT;

    -- Cria o campo base (inclui imagem, se @URL fornecido)
    EXEC sp_CreateCampo
      @Nome = @Nome,
      @Endereco = @Endereco,
      @Comprimento = @Comprimento,
      @Largura = @Largura,
      @Ocupado = @Ocupado,
      @Descricao = @Descricao,
      @Latitude = @Latitude,
      @Longitude = @Longitude,
      @ID_Mapa = @ID_Mapa,
      @URL = @URL,
      @ID_Campo = @ID_Campo OUTPUT;

    -- Insere na tabela de campos públicos
    INSERT INTO Campo_Pub (ID_Campo, Entidade_publica_resp)
    VALUES (@ID_Campo, @Entidade_publica_resp);

    -- Retorna ID final
    SET @NewID = @ID_Campo;

    COMMIT TRANSACTION;
  END TRY

  BEGIN CATCH
    ROLLBACK TRANSACTION;

    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrState INT = ERROR_STATE();
    RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);
  END CATCH
END;
GO

-- CampoPrivado / CampoPub
CREATE OR ALTER PROCEDURE sp_GetCampoByID
  @ID_Campo INT
AS
BEGIN
SELECT c.ID, c.Nome, c.Comprimento, c.Largura, c.Endereco, p.Latitude, p.Longitude, c.Descricao, U.ID as ID_Arrendador,
  dp.Preco, dp.Hora_abertura, dp.Hora_fecho, STRING_AGG(di.Nome, ', ') AS Dias_Disponiveis, i.[URL], STRING_AGG(desp.Nome, ',') as Desportos, cpub.Entidade_publica_resp
  FROM Campo as c
  LEFT JOIN Campo_Priv as cp on c.ID = cp.ID_Campo
  JOIN Ponto as p on p.ID = c.ID_Ponto
  LEFT JOIN Utilizador as U on U.ID = cp.ID_Arrendador
  LEFT JOIN Campo_Pub as cpub on cpub.ID_Campo=c.ID
  LEFT JOIN Disponibilidade as dp on dp.ID_Campo = cp.ID_Campo
  LEFT JOIN IMG_Campo as IMG on IMG.ID_Campo = c.ID
  JOIN Imagem as i on i.ID = IMG.ID_img
  LEFT JOIN Dias_semana as di on di.ID = dp.ID_dia
  LEFT JOIN Desporto_Campo as dc on dc.ID_Campo=c.ID
  LEFT JOIN  Desporto as desp on desp.ID=dc.ID_Desporto
  group by c.ID, c.Nome, c.Comprimento, c.Largura, c.Endereco, p.Latitude, p.Longitude,
  c.Descricao, dp.Preco, dp.Hora_abertura, dp.Hora_fecho, i.[URL], U.ID, cpub.Entidade_publica_resp
  HAVING c.ID = @ID_Campo;
END;
GO


CREATE PROCEDURE sp_GetDisponibilidadePorCampo
  @ID_Campo INT
AS
BEGIN
  SELECT 
    ds.Nome AS Dia,
    d.Hora_Abertura,
    d.Hora_Fecho,
    d.Preco
  FROM Disponibilidade d
  JOIN Dias_semana ds ON ds.ID = d.ID_Dia
  WHERE d.ID_Campo = @ID_Campo;
END;
GO

CREATE PROCEDURE sp_SetDisponibilidadeCampo
  @ID_Campo INT,
  @ID_Dia INT,
  @Hora_Abertura TIME,
  @Hora_Fecho TIME,
  @Preco DECIMAL(10,2)
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRANSACTION;

    IF EXISTS (
      SELECT 1 
      FROM Disponibilidade 
      WHERE ID_Campo = @ID_Campo AND ID_Dia = @ID_Dia
    )
    BEGIN
      -- Atualiza se já existir
      UPDATE Disponibilidade
      SET Hora_Abertura = @Hora_Abertura,
          Hora_Fecho = @Hora_Fecho,
          Preco = @Preco
      WHERE ID_Campo = @ID_Campo AND ID_Dia = @ID_Dia;
    END
    ELSE
    BEGIN
      -- Insere se não existir
      INSERT INTO Disponibilidade (ID_Campo, ID_Dia, Hora_Abertura, Hora_Fecho, Preco)
      VALUES (@ID_Campo, @ID_Dia, @Hora_Abertura, @Hora_Fecho, @Preco);
    END

    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;

    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrState INT = ERROR_STATE();

    RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);
  END CATCH
END;
GO


CREATE PROCEDURE sp_AssociarDesportoCampo
  @ID_Campo INT,
  @ID_Desporto INT
AS
BEGIN
  SET NOCOUNT ON;
    IF NOT EXISTS (
      SELECT 1 
      FROM Desporto_Campo 
      WHERE ID_Campo = @ID_Campo AND ID_Desporto = @ID_Desporto
    )
    BEGIN
      INSERT INTO Desporto_Campo (ID_Campo, ID_Desporto)
      VALUES (@ID_Campo, @ID_Desporto);
    END
END;
GO


CREATE PROCEDURE sp_EditCampo
  @ID_Campo INT,
  @Nome VARCHAR(256),
  @Endereco VARCHAR(512),
  @Comprimento DECIMAL(10,2),
  @Largura DECIMAL(10,2),
  @Descricao VARCHAR(2500),
  @URL VARCHAR(1000) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE Campo
    SET Nome = @Nome,
        Descricao = @Descricao,
        Comprimento = @Comprimento,
        Largura = @Largura,
        Endereco = @Endereco
    WHERE ID = @ID_Campo;

    IF @URL IS NOT NULL
    BEGIN
      DECLARE @ID_img INT;
      EXEC sp_CreateImg @URL, @ID_img OUTPUT;

      IF EXISTS (SELECT 1 FROM IMG_Campo WHERE ID_Campo = @ID_Campo)
      BEGIN
        UPDATE IMG_Campo SET ID_img = @ID_img WHERE ID_Campo = @ID_Campo;
      END
      ELSE
      BEGIN
        INSERT INTO IMG_Campo (ID_Campo, ID_img) VALUES (@ID_Campo, @ID_img);
      END
    END

    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrState INT = ERROR_STATE();
    RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);
  END CATCH
END;
GO


