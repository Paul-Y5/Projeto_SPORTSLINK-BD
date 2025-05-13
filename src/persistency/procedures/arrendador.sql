-- CRUD Tabela Arrendador

CREATE PROCEDURE sp_CreateArrendador
  @ID_Utilizador INT,
  @IBAN   VARCHAR(34),
  @No_Campos INT,
AS
BEGIN
  INSERT INTO Arrendador (ID_Utilizador, IBAN, No_Campos)
  VALUES (@ID_Utilizador, @IBAN, @No_Campos);
END;
GO

CREATE PROCEDURE sp_GetArrendador
  @ID INT
AS
BEGIN
  SELECT * FROM Arrendador WHERE ID = @ID;
END;
GO

CREATE PROCEDURE sp_UpdateArrendador
  @ID INT,
  @IBAN   VARCHAR(34),
  @No_Campos INT,
AS
BEGIN
  UPDATE Arrendador
  SET IBAN = @IBAN, No_Campos = @No_Campos
  WHERE ID = @ID;
END;
GO

CREATE PROCEDURE sp_DeleteArrendador
  @ID INT
AS
BEGIN
  DELETE FROM Arrendador WHERE ID = @ID;
END;
GO

CREATE PROCEDURE sp_GetArrendadorByID
  @ID_Utilizador INT
AS
BEGIN
  SELECT * FROM Arrendador WHERE ID_Utilizador = @ID_Utilizador;
END;
GO

CREATE PROCEDURE sp_UpdateNoCamposArrendador
  @ID_Utilizador INT,
AS
BEGIN
  UPDATE Arrendador
  SET No_Campos = No_Campos - 1
  WHERE ID_Arrendador = @ID_Utilizador;
END;

CREATE PROCEDURE sp_GetCamposByUser
  @UserID INT
AS
BEGIN
  SELECT *
  FROM Campo
  WHERE ID_Arrendador = @UserID;
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

CREATE PROCEDURE sp_adicionar_campo_privado
  @ID_Utilizador INT,
  @Nome VARCHAR(256),
  @Endereco VARCHAR(512),
  @Comprimento DECIMAL(10,2),
  @Largura DECIMAL(10,2),
  @Ocupado BIT,
  @Descricao VARCHAR(2500),
  @Preco DECIMAL(10,2),
  @ID_Dia INT,
  @Hora_Abertura TIME,
  @Hora_Fecho TIME
AS
BEGIN
  DECLARE @ID_Campo INT;

  -- Inserir o campo privado
  INSERT INTO CampoPrivado (ID_Ponto, ID_Mapa, Nome, Endereco, Comprimento, Largura, Ocupado, Descricao)
  VALUES (@ID_Ponto, @ID_Mapa, @Nome, @Endereco, @Comprimento, @Largura, @Ocupado, @Descricao);

  SET @ID_Campo = SCOPE_IDENTITY();

  -- Inserir a disponibilidade
  INSERT INTO Disponibilidade (ID_Campo, ID_Dia, Preco, Hora_Abertura, Hora_Fecho)
  VALUES (@ID_Campo, @ID_Dia, @Preco, @Hora_Abertura, @Hora_Fecho);
END;