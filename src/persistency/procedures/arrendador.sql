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
  SET NOCOUNT ON;
  SELECT 
    c.ID,
    c.Nome,
    c.Endereco,
    c.Ocupado,
    STRING_AGG(d.Nome, ', ') AS Dias,
    STRING_AGG(I.[URL], ', '),
    CASE WHEN c.Ocupado = 1 THEN 'Sim' ELSE 'Não' END AS Ocupado
	FROM Campo as c
	INNER JOIN Disponibilidade as di on di.ID_Campo=c.ID
	LEFT JOIN Dias_semana as d on d.ID=di.ID_dia
	INNER JOIN IMG_Campo as ic on ic.ID_Campo=c.ID
	LEFT JOIN Imagem as i on i.ID=ic.ID_img
	LEFT JOIN Campo_Priv as cp on cp.ID_Campo=c.ID
	where cp.ID_Arrendador = 27
	GROUP BY c.ID,
    c.Nome,
    c.Endereco,
    c.Ocupado;
END;
GO

-- Obter reservas de um campo
CREATE PROCEDURE sp_GetReservasByCampo
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

CREATE OR ALTER PROCEDURE sp_UpdateMetodosPagamento
  @ID_Utilizador INT,
  @Metodos NVARCHAR(MAX) -- JSON: '[{"Metodo":"paypal","Detalhes":"email"},{"Metodo":"mbway","Detalhes":"91234"}]'
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRANSACTION;

    -- Tabela temporária para carregar os métodos enviados
    DECLARE @TempMetodos TABLE (
      Met_pagamento NVARCHAR(256),
      Detalhes NVARCHAR(500)
    );

    INSERT INTO @TempMetodos (Met_pagamento, Detalhes)
    SELECT Metodo, Detalhes
    FROM OPENJSON(@Metodos)
    WITH (
      Metodo NVARCHAR(256) '$.Metodo',
      Detalhes NVARCHAR(500) '$.Detalhes'
    );

    -- MERGE para atualizar/inserir os métodos de pagamento
    MERGE Met_Paga_Arrendador AS Target
    USING @TempMetodos AS Source
      ON Target.ID_Arrendador = @ID_Utilizador
     AND Target.Met_pagamento = Source.Met_pagamento
    WHEN MATCHED THEN
      UPDATE SET Detalhes = Source.Detalhes
    WHEN NOT MATCHED BY TARGET THEN
      INSERT (ID_Arrendador, Met_pagamento, Detalhes)
      VALUES (@ID_Utilizador, Source.Met_pagamento, Source.Detalhes)
      WHEN NOT MATCHED BY SOURCE THEN DELETE;

    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH
END;
GO
