-- CRUD para a tabela Utilizador
USE SPORTSLINK;
GO

CREATE PROCEDURE sp_CreateUtilizador
  @Nome VARCHAR(256),
  @Email VARCHAR(512),
  @Num_Tele VARCHAR(64),
  @Password VARCHAR(512),
  @Nacionalidade VARCHAR(128),
  @Data_Nascimento DATE,
  @Descricao VARCHAR(2500),
  @Peso DECIMAL(5,2),
  @Altura DECIMAL(5,2),
  @IMG_URL VARCHAR(1000),
  @Desportos VARCHAR(1000)
AS
BEGIN
  SET NOCOUNT ON;

  IF EXISTS (SELECT 1 FROM Utilizador WHERE Email = @Email)
  BEGIN
    RAISERROR('Já existe um utilizador com este email.', 16, 1);
    RETURN;
  END;

  BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. Inserir Utilizador
    INSERT INTO Utilizador (Nome, Email, Num_Tele, [Password], Nacionalidade)
    VALUES (@Nome, @Email, @Num_Tele, @Password, @Nacionalidade);

    DECLARE @UserID INT = SCOPE_IDENTITY();

    -- 2. Criar Jogador
    EXEC sp_CreateJogador @UserID, @Data_Nascimento, @Peso, @Altura, @Descricao;

    -- 3. Inserir imagem (se fornecida)
    IF @IMG_URL IS NOT NULL
    BEGIN
      DECLARE @ID_img INT;
      EXEC sp_CreateImg @IMG_URL, @ID_img OUTPUT;

      INSERT INTO IMG_Perfil (ID_Utilizador, ID_img)
      VALUES (@UserID, @ID_img);
    END;

    -- 4. Associar desportos ao jogador
    IF @Desportos IS NOT NULL
    BEGIN
      INSERT INTO Desporto_Jogador (ID_Jogador, ID_Desporto)
      SELECT @UserID, d.ID
      FROM STRING_SPLIT(@Desportos, ',') AS s
      JOIN Desporto d ON LTRIM(RTRIM(s.value)) = d.Nome;
    END;

    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@ErrMsg, 16, 1);
  END CATCH
END;
GO

-- Obter informações do utilizador que fez login
CREATE OR ALTER PROCEDURE sp_GetUserInfo
  @UserID INT
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (SELECT 1 FROM Utilizador WHERE ID = @UserID)
  BEGIN
    RAISERROR('Utilizador não encontrado.', 16, 1);
    RETURN;
  END;

  SELECT *
  FROM vw_InfoUtilizador
  WHERE ID_Utilizador = @UserID;
END;
GO

-- Atualizar informações de um utilizador
CREATE OR ALTER PROCEDURE sp_UpdateUserInfo
  @UserID INT,
  @Nome VARCHAR(256) = NULL,
  @Email VARCHAR(512) = NULL,
  @Num_Tele VARCHAR(64) = NULL,
  @Nacionalidade VARCHAR(128) = NULL,
  @Password VARCHAR(512) = NULL,
  @Descricao VARCHAR(2500) = NULL,
  @Data_Nascimento DATE = NULL,
  @Peso DECIMAL(5,2) = NULL,
  @Altura DECIMAL(5,2) = NULL,
  @IBAN VARCHAR(34) = NULL,
  @No_Campos INT = NULL,
  @URL_Imagem VARCHAR(1000) = NULL,
  @MetodosPagamento VARCHAR(256) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (SELECT 1 FROM Utilizador WHERE ID = @UserID)
  BEGIN
    RAISERROR('Utilizador não encontrado.', 16, 1);
    RETURN;
  END;

  BEGIN TRY
    BEGIN TRANSACTION;

    -- Atualiza dados do utilizador
    UPDATE Utilizador
    SET 
      Nome = ISNULL(@Nome, Nome),
      Email = ISNULL(@Email, Email),
      Num_Tele = ISNULL(@Num_Tele, Num_Tele),
      Nacionalidade = ISNULL(@Nacionalidade, Nacionalidade),
      [Password] = ISNULL(@Password, [Password])
    WHERE ID = @UserID;

    -- Se for Jogador
    IF EXISTS (SELECT 1 FROM Jogador WHERE ID = @UserID)
    BEGIN
      UPDATE Jogador
      SET 
        Data_Nascimento = ISNULL(@Data_Nascimento, Data_Nascimento),
        Descricao = ISNULL(@Descricao, Descricao),
        Peso = ISNULL(@Peso, Peso),
        Altura = ISNULL(@Altura, Altura)
      WHERE ID = @UserID;
    END;

    -- Se for Arrendador
    IF EXISTS (SELECT 1 FROM Arrendador WHERE ID_Arrendador = @UserID)
    BEGIN
      UPDATE Arrendador
      SET 
        IBAN = ISNULL(@IBAN, IBAN),
        No_Campos = ISNULL(@No_Campos, No_Campos)
      WHERE ID_Arrendador = @UserID;

      IF @MetodosPagamento IS NOT NULL
      BEGIN
        EXEC sp_UpdateMetodosPagamento
          @ID_Utilizador = @UserID,
          @Metodos = @MetodosPagamento;
      END;
    END;

    -- Atualiza imagem se fornecida
    IF @URL_Imagem IS NOT NULL
    BEGIN
      DECLARE @ID_img INT;
      EXEC sp_CreateImg @URL_Imagem, @ID_img OUTPUT;

      INSERT INTO IMG_Perfil (ID_Utilizador, ID_img)
      VALUES (@UserID, @ID_img);
    END;

    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH
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