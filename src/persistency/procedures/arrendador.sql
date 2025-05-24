USE SPORTSLINK;
GO

-- Criação de um arrendador
CREATE PROCEDURE sp_CreateArrendador
  @ID_Utilizador INT,
  @IBAN   VARCHAR(34),
  @MetodosPagamento NVARCHAR(MAX), -- JSON: '[{"Metodo":"paypal","Detalhes":"email"},{"Metodo":"mbway","Detalhes":"91234"}]'
  @No_Campos INT = 0
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    BEGIN TRANSACTION;
      -- Insere o novo arrendador
      INSERT INTO Arrendador (ID_Arrendador, IBAN, No_Campos)
      VALUES (@ID_Utilizador, @IBAN, @No_Campos);

      EXEC sp_CreateMetodosPagamento @ID_Utilizador = @ID_Utilizador, @Metodos = @MetodosPagamento;

    COMMIT TRANSACTION;
  END TRY 
  BEGIN CATCH
    ROLLBACK TRANSACTION;

    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrSeverity INT = ERROR_SEVERITY();
    RAISERROR(@ErrMsg, @ErrSeverity, 1);
  END CATCH
END;
GO

-- Eliminar um arrendador
CREATE PROCEDURE sp_DeleteArrendador
  @ID INT
AS
BEGIN
  DELETE FROM Arrendador WHERE ID_Arrendador = @ID;
END;
GO

-- Adicionar um campo privado (sem atualizar No_Campos manualmente)
CREATE PROCEDURE sp_addCampoPriv
  @ID_Utilizador INT,
  @Latitude DECIMAL(9,6),
  @Longitude DECIMAL(9,6),
  @ID_Mapa INT = 1,
  @Nome VARCHAR(256),
  @Endereco VARCHAR(512),
  @Comprimento DECIMAL(10,2),
  @Largura DECIMAL(10,2),
  @Ocupado BIT,
  @Descricao VARCHAR(2500)
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRANSACTION;

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
      @ID_Mapa,
      @ID_Campo OUTPUT;

    IF @ID_Campo IS NULL
    BEGIN
      RAISERROR('Erro ao criar o campo. ID_Campo é NULL.', 16, 1);
    END

    INSERT INTO Campo_Priv(ID_Campo, ID_Arrendador)
    VALUES (@ID_Campo, @ID_Utilizador);

    SELECT @ID_Campo AS ID_Campo;

    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;

    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrSeverity INT = ERROR_SEVERITY();
    RAISERROR(@ErrMsg, @ErrSeverity, 1);
  END CATCH
END;
GO

-- Obter campos de um utilizador (arrendador)
CREATE PROCEDURE sp_GetCamposByUser
  @UserID INT
AS
BEGIN
  SELECT 
    v.ID_Campo AS ID,
    v.Nome_Campo AS Nome,
    v.Largura,
    v.Comprimento,
    v.Descricao,
    v.Endereco,
    v.Latitude,
    v.Longitude,
    c.Ocupado,
    v.Dias_Disponiveis,
    v.Preco,
    v.Hora_Abertura,
    v.Hora_Fecho,
    v.Imagens,
    CASE WHEN c.Ocupado = 1 THEN 'Sim' ELSE 'Não' END AS OcupadoStr,
    CASE WHEN cp.ID_Arrendador IS NOT NULL THEN 'Privado' ELSE 'Publico' END AS Tipo
  FROM vw_CampoPrivDetalhes v
  JOIN Campo c ON v.ID_Campo = c.ID
  INNER JOIN Campo_Priv cp ON c.ID = cp.ID_Campo
  WHERE cp.ID_Arrendador = @UserID;
END;
GO

-- Obter reservas de um campo
CREATE OR ALTER PROCEDURE sp_GetReservasByCampo
  @ID_Campo INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT 
    Nome_Jogador AS Nome, 
    Nacionalidade, 
    Num_Tele, 
    [Data],
    Hora_Inicio,
    Descricao,
    Preco, 
    dbo.fn_CalculaHorasFormatado(Hora_Inicio, Hora_Fim) AS Duracao_Horas
  FROM vw_ReservasDetalhadas
  WHERE ID_Campo = @ID_Campo;
END;
GO

CREATE OR ALTER PROCEDURE sp_CreateMetodosPagamento
  @ID_Utilizador INT,
  @Metodos NVARCHAR(MAX) -- JSON: '[{"Metodo":"paypal","Detalhes":"email"},{"Metodo":"mbway","Detalhes":"91234"}]'
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    -- Inserir vários métodos usando OPENJSON
    INSERT INTO Met_Paga_Arrendador (ID_Arrendador, Met_pagamento, Detalhes)
    SELECT
      @ID_Utilizador,
      Metodo,
      Detalhes
    FROM OPENJSON(@Metodos)
    WITH (
      Metodo NVARCHAR(50),
      Detalhes NVARCHAR(500)
    );
  END TRY
  BEGIN CATCH
    -- Apenas relança o erro para ser tratado na procedure pai
    THROW;
  END CATCH
END;
GO