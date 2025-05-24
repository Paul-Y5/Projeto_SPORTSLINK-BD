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


-- Get Campos
CREATE PROCEDURE sp_GetCampos
  @ID_Campo INT
AS
BEGIN
  SELECT i.[URL], c.Nome AS Nome_Campo, c.Largura, c.Comprimento, c.Endereco, c.Ocupado,
      STRING_AGG(di.Nome, ', ') AS Dias_Disponiveis,
      CASE WHEN c.Ocupado = 1 THEN 'Sim' ELSE 'Não' END AS Ocupado,
	    CASE WHEN cp.ID_Campo IS NOT NULL THEN 'Privado' ELSE 'Publico' END AS Tipo
    FROM Campo AS c
    JOIN Ponto AS p ON c.ID_Ponto = p.ID
    LEFT JOIN Campo_Priv AS cp ON c.ID = cp.ID_Campo
    JOIN Disponibilidade AS d ON c.ID = d.ID_Campo
    JOIN Dias_semana AS di ON d.ID_Dia = di.ID
	LEFT JOIN IMG_Campo AS IMG on IMG.ID_Campo = c.ID
	INNER JOIN Imagem as i on i.ID = IMG.ID_img
    GROUP BY i.[URL], c.Nome, c.Largura, c.Comprimento, c.Endereco, c.Ocupado, cp.ID_Campo;
END;
GO

CREATE PROCEDURE sp_DeleteCampo
  @ID INT
AS
BEGIN
  -- Se o campo for privado, atualizar o número de campos do arrendador
  IF EXISTS (SELECT 1 FROM Campo_Priv WHERE ID_Campo = @ID)
  BEGIN
    UPDATE Arrendador
    SET No_Campos = No_Campos - 1
    WHERE ID_Arrendador = (
      SELECT ID_Arrendador FROM Campo_Priv WHERE ID_Campo = @ID
    );
  END

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
  @URL VARCHAR(1000) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRANSACTION;

      DECLARE @ID_Campo INT;

      -- Cria o campo base
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

      -- Adiciona imagem se fornecida
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



-- CampoPrivado
CREATE PROCEDURE sp_GetCampoByID
  @ID_Campo INT
AS
BEGIN
  SELECT c.ID, c.Nome, c.Comprimento, c.Largura, c.Endereco, p.Latitude, p.Longitude, c.Descricao, 
  dp.Preco, dp.Hora_abertura, dp.Hora_fecho, STRING_AGG(di.Nome, ', ') AS Dias_Disponiveis, i.[URL]
  FROM Campo as c
  LEFT JOIN Campo_Priv as cp on c.ID = cp.ID_Campo
  JOIN Ponto as p on p.ID = c.ID_Ponto
  JOIN Utilizador as U on U.ID = cp.ID_Arrendador
  LEFT JOIN Disponibilidade as dp on dp.ID_Campo = cp.ID_Campo
  LEFT JOIN IMG_Campo as IMG on IMG.ID_Campo = c.ID
  INNER JOIN Imagem as i on i.ID = IMG.ID_img
  JOIN Dias_semana as di on di.ID = dp.ID_dia
  group by c.ID, c.Nome, c.Comprimento, c.Largura, c.Endereco, p.Latitude, p.Longitude,
  c.Descricao, dp.Preco, dp.Hora_abertura, dp.Hora_fecho, i.[URL]
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
  INSERT INTO Disponibilidade(ID_Campo, ID_Dia, Hora_Abertura, Hora_Fecho, Preco)
  VALUES (@ID_Campo, @ID_Dia, @Hora_Abertura, @Hora_Fecho, @Preco);
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

