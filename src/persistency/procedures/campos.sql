-- CRUD para a tabela Campo
CREATE PROCEDURE sp_CreateCampo
  @ID_Ponto INT,
  @ID_Mapa INT,
  @Nome VARCHAR(256),
  @Endereco VARCHAR(512),
  @Comprimento DECIMAL(10,2),
  @Largura DECIMAL(10,2),
  @Ocupado BIT,
  @Descricao VARCHAR(2500)
AS
BEGIN
  INSERT INTO Campo (ID_Ponto, ID_Mapa, Nome, Endereco, Comprimento, Largura, Ocupado, Descricao)
  VALUES (@ID_Ponto, @ID_Mapa, @Nome, @Endereco, @Comprimento, @Largura, @Ocupado, @Descricao);
END;
GO

CREATE PROCEDURE sp_GetCampo
  @ID INT
AS
BEGIN
  SELECT * FROM Campo WHERE ID = @ID;
END;
GO

CREATE PROCEDURE sp_UpdateCampo
  @ID INT,
  @Nome VARCHAR(256),
  @Endereco VARCHAR(512),
  @Comprimento DECIMAL(10,2),
  @Largura DECIMAL(10,2),
  @Ocupado BIT,
  @Descricao VARCHAR(2500)
AS
BEGIN
  UPDATE Campo
  SET Nome = @Nome, Endereco = @Endereco, Comprimento = @Comprimento, Largura = @Largura, Ocupado = @Ocupado, Descricao = @Descricao
  WHERE ID = @ID;
END;
GO

CREATE PROCEDURE sp_DeleteCampo
  @ID INT
AS
BEGIN
  DELETE FROM Campo WHERE ID = @ID;
END;
GO

CREATE PROCEDURE sp_GetCampoByPonto
  @ID_Ponto INT
AS
BEGIN
  SELECT * FROM Campo WHERE ID_Ponto = @ID_Ponto;
END;
GO


-- Crud para tabela CampoPublico
CREATE PROCEDURE sp_CreateCampoPublico
  @ID_Ponto INT,
  @ID_Mapa INT,
  @Nome VARCHAR(256),
  @Endereco VARCHAR(512),
  @Comprimento DECIMAL(10,2),
  @Largura DECIMAL(10,2),
  @Ocupado BIT,
  @Descricao VARCHAR(2500)
AS
BEGIN
  INSERT INTO CampoPublico (ID_Ponto, ID_Mapa, Nome, Endereco, Comprimento, Largura, Ocupado, Descricao)
  VALUES (@ID_Ponto, @ID_Mapa, @Nome, @Endereco, @Comprimento, @Largura, @Ocupado, @Descricao);
END;
GO

CREATE PROCEDURE sp_GetCampoPublico
  @ID INT
AS
BEGIN
  SELECT * FROM CampoPublico WHERE ID = @ID;
END;
GO

CREATE PROCEDURE sp_UpdateCampoPublico
  @ID INT,
  @Nome VARCHAR(256),
  @Endereco VARCHAR(512),
  @Comprimento DECIMAL(10,2),
  @Largura DECIMAL(10,2),
  @Ocupado BIT,
  @Descricao VARCHAR(2500)
AS
BEGIN
  UPDATE CampoPublico
  SET Nome = @Nome, Endereco = @Endereco, Comprimento = @Comprimento, Largura = @Largura, Ocupado = @Ocupado, Descricao = @Descricao
  WHERE ID = @ID;
END;
GO

CREATE PROCEDURE sp_DeleteCampoPublico
  @ID INT
AS
BEGIN
  DELETE FROM CampoPublico WHERE ID = @ID;
END;
GO
CREATE PROCEDURE sp_GetCampoPublicoByPonto
  @ID_Ponto INT
AS
BEGIN
  SELECT * FROM CampoPublico WHERE ID_Ponto = @ID_Ponto;
END;
GO

-- CRUD para tabela CampoPrivado
CREATE PROCEDURE sp_CreateCampoPrivado
  @ID_Ponto INT,
  @ID_Mapa INT,
  @Nome VARCHAR(256),
  @Endereco VARCHAR(512),
  @Comprimento DECIMAL(10,2),
  @Largura DECIMAL(10,2),
  @Ocupado BIT,
  @Descricao VARCHAR(2500)
AS
BEGIN
  INSERT INTO CampoPrivado (ID_Ponto, ID_Mapa, Nome, Endereco, Comprimento, Largura, Ocupado, Descricao)
  VALUES (@ID_Ponto, @ID_Mapa, @Nome, @Endereco, @Comprimento, @Largura, @Ocupado, @Descricao);
END;
GO

CREATE PROCEDURE sp_GetCampoPrivado
  @ID INT
AS
BEGIN
  SELECT * FROM CampoPrivado WHERE ID = @ID;
END;
GO

CREATE PROCEDURE sp_UpdateCampoPrivado
  @ID INT,
  @Nome VARCHAR(256),
  @Endereco VARCHAR(512),
  @Comprimento DECIMAL(10,2),
  @Largura DECIMAL(10,2),
  @Ocupado BIT,
  @Descricao VARCHAR(2500)
AS
BEGIN
  UPDATE CampoPrivado
  SET Nome = @Nome, Endereco = @Endereco, Comprimento = @Comprimento, Largura = @Largura, Ocupado = @Ocupado, Descricao = @Descricao
  WHERE ID = @ID;
END;
GO

CREATE PROCEDURE sp_DeleteCampoPrivado
  @ID INT
AS
BEGIN
  DELETE FROM CampoPrivado WHERE ID = @ID;
END;
GO

CREATE PROCEDURE sp_GetCampoPrivadoByPonto
  @ID_Ponto INT
AS
BEGIN
  SELECT * FROM CampoPrivado WHERE ID_Ponto = @ID_Ponto;
END;
GO

CREATE PROCEDURE sp_GetDisponibilidadePorCampo
  @ID_Campo INT
AS
BEGIN
  SELECT 
    ds.Nome AS Dia,
    d.Hora_Abertura,
    d.Hora_Fecho
  FROM Disponibilidade d
  JOIN Dias_semana ds ON ds.ID = d.ID_Dia
  WHERE d.ID_Campo = @ID_Campo;
END;
GO

CREATE PROCEDURE sp_GetCampoByID
  @ID INT
AS
BEGIN
  SELECT c.Nome AS Nome_Campo, c.Largura, c.Comprimento, c.Descricao, c.Endereco, p.Latitude, 
    p.Longitude, c.Ocupado,
    STRING_AGG(di.Nome, ', ') AS Dias_Disponiveis
  FROM Campo AS c
  JOIN Ponto AS p ON c.ID_Ponto = p.ID
  JOIN Campo_Priv AS cp ON c.ID = cp.ID_Campo
  JOIN Disponibilidade AS d ON c.ID = d.ID_Campo
  JOIN Dias_semana AS di ON d.ID_Dia = di.ID
  WHERE c.ID = @ID
  GROUP BY c.ID, c.Nome, c.Largura, c.Comprimento, c.Descricao, c.Endereco, p.Latitude, 
    p.Longitude, c.Ocupado;
END;
GO

CREATE PROCEDURE sp_GetCampos
  @ID_Campo INT
AS
BEGIN
  SELECT c.ID, c.Nome AS Nome_Campo, c.Largura, c.Comprimento, c.Descricao, c.Endereco, p.Latitude, 
    p.Longitude, c.Ocupado,
    STRING_AGG(di.Nome, ', ') AS Dias_Disponiveis
    CASE WHEN c.Ocupado = 1 THEN 'Sim' ELSE 'Não' END AS Ocupado
    CASE WHEN cp.ID IS NOT NULL THEN 'Privado' ELSE 'Publico' END AS Tipo
  FROM Campo AS c
  JOIN Ponto AS p ON c.ID_Ponto = p.ID
  JOIN Campo_Priv AS cp ON c.ID = cp.ID_Campo
  JOIN Disponibilidade AS d ON c.ID = d.ID_Campo
  JOIN Dias_semana AS di ON d.ID_Dia = di.ID
  WHERE (@ID_Campo IS NULL OR c.ID = @ID_Campo)
  GROUP BY c.ID, c.Nome, c.Largura, c.Comprimento, c.Descricao, c.Endereco, p.Latitude, 
    p.Longitude, c.Ocupado;
END;