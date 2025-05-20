USE SPORTSLINK;
GO

-- CRUD para a tabela Campo
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
  @ID_Campo INT OUTPUT
AS
BEGIN
  DECLARE @ID_Ponto INT;
  EXEC sp_CreatePonto @ID_Mapa, @Latitude, @Longitude, @ID_Ponto OUTPUT;

  INSERT INTO Campo (ID_Ponto, ID_Mapa, Nome, Endereco, Comprimento, Largura, Ocupado, Descricao)
  VALUES (@ID_Ponto, @ID_Mapa, @Nome, @Endereco, @Comprimento, @Largura, @Ocupado, @Descricao);

  SET @ID_Campo = SCOPE_IDENTITY();
END;
GO

-- Get Campos
CREATE PROCEDURE sp_GetCampos
  @ID_Campo INT
AS
BEGIN
  SELECT IMG.[URL], c.Nome AS Nome_Campo, c.Largura, c.Comprimento, c.Endereco, c.Ocupado,
      STRING_AGG(di.Nome, ', ') AS Dias_Disponiveis,
      CASE WHEN c.Ocupado = 1 THEN 'Sim' ELSE 'Não' END AS Ocupado,
	    CASE WHEN cp.ID_Campo IS NOT NULL THEN 'Privado' ELSE 'Publico' END AS Tipo
    FROM Campo AS c
    JOIN Ponto AS p ON c.ID_Ponto = p.ID
    LEFT JOIN Campo_Priv AS cp ON c.ID = cp.ID_Campo
    JOIN Disponibilidade AS d ON c.ID = d.ID_Campo
    JOIN Dias_semana AS di ON d.ID_Dia = di.ID
	  LEFT JOIN IMG_Campo AS IMG on IMG.ID_Campo = c.ID
    GROUP BY IMG.[URL], c.Nome, c.Largura, c.Comprimento, c.Endereco, c.Ocupado, cp.ID_Campo;
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

-- CampoPublico
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
  @Entidade_publica_resp VARCHAR(256)
AS
BEGIN
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
    @ID_Mapa;
  SET @ID_Campo = SCOPE_IDENTITY();

  -- Inserir o campo público
  INSERT INTO Campo_Pub (ID_Campo, Entidade_publica_resp)
  VALUES (@ID_Campo, @Entidade_publica_resp);
END;
GO

CREATE PROCEDURE sp_GetCamposPub
  -- TODO

-- CampoPrivado
CREATE PROCEDURE sp_GetCampoByID
  @ID_Campo INT
AS
BEGIN
  SELECT c.ID, c.Nome, c.Comprimento, c.Largura, c.Endereco, p.Latitude, p.Longitude, c.Descricao, 
  dp.Preco, dp.Hora_abertura, dp.Hora_fecho, STRING_AGG(di.Nome, ', ') AS Dias_Disponiveis
FROM Campo as c
LEFT JOIN Campo_Priv as cp on c.ID = cp.ID_Campo
JOIN Ponto as p on p.ID = c.ID_Ponto
JOIN Utilizador as U on U.ID = cp.ID_Arrendador
LEFT JOIN Disponibilidade as dp on dp.ID_Campo = cp.ID_Campo
JOIN Dias_semana as di on di.ID = dp.ID_dia
group by c.ID, c.Nome, c.Comprimento, c.Largura, c.Endereco, p.Latitude, p.Longitude, c.Descricao, dp.Preco, dp.Hora_abertura, dp.Hora_fecho
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

CREATE OR ALTER PROCEDURE sp_SetDisponibilidadeCampo
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
