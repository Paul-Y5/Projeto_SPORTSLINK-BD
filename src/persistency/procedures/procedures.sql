USE SPORTSLINK;
GO

-- Autenticar Utilizador
CREATE PROCEDURE sp_AuthenticateUtilizador
  @Email VARCHAR(512),
  @Password VARCHAR(512)
AS
BEGIN
  SELECT * FROM Utilizador WHERE Email = @Email AND [Password] = @Password;
END;
GO

-- Verificar se o utilizador existe
CREATE PROCEDURE sp_UtilizadorExists
  @Email VARCHAR(512)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT CASE 
    WHEN COUNT(*) > 0 THEN 1
      ELSE 0
    END AS UtilizadorExists
  FROM Utilizador
  WHERE Email = @Email;
END;
GO

-- lista de desportos
CREATE PROCEDURE sp_GetDesportos
AS
BEGIN
  SET NOCOUNT ON;
  SELECT Nome FROM Desporto;
END;
GO

-- Cria Imagens
CREATE PROCEDURE sp_CreateImg
    @URL VARCHAR(1000),
    @ID_img INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Imagem WHERE URL = @URL)
    BEGIN
        INSERT INTO Imagem ([URL])
        VALUES (@URL);
        SET @ID_img = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        SELECT @ID_img = ID FROM Imagem WHERE URL = @URL;
    END
END;
GO

-- Ceate para a tabela Jogador
CREATE PROCEDURE sp_CreateJogador
  @ID INT,
  @Data_Nascimento DATE,
  @Peso DECIMAL(5,2),
  @Altura DECIMAL(5,2),
  @Descricao VARCHAR(2500)
AS
BEGIN
  INSERT INTO Jogador (ID, Data_Nascimento, Peso, Altura, Descricao)
  VALUES (@ID, @Data_Nascimento, @Peso, @Altura, @Descricao);
END;
GO


-- Cria Utilizador
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

-- Criar Pontos
CREATE PROCEDURE sp_CreatePonto
  @ID_Mapa INT = 1,
  @Latitude DECIMAL(9,6),
  @Longitude DECIMAL(9,6),
  @ID_Ponto INT OUTPUT
AS
BEGIN
  INSERT INTO Ponto (ID_Mapa, Latitude, Longitude)
  VALUES (@ID_Mapa, @Latitude, @Longitude);

  SET @ID_Ponto = SCOPE_IDENTITY();
END;
GO

-- Obter Ponto por ID
CREATE PROCEDURE sp_GetPonto
  @ID INT
AS
BEGIN
  SELECT * FROM Ponto WHERE ID = @ID;
END;
GO

-- Atualizar Ponto
CREATE PROCEDURE sp_UpdatePonto
  @ID INT,
  @Latitude DECIMAL(9,6),
  @Longitude DECIMAL(9,6)
AS
BEGIN
  UPDATE Ponto
  SET Latitude = @Latitude, Longitude = @Longitude
  where ID = (Select ID_Ponto from Campo where ID = @ID)
END;
GO

-- Criar Campo
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

-- Apagar Campo
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

-- Get campo by Ponto
CREATE PROCEDURE sp_GetCampoByPonto
  @ID_Ponto INT
AS
BEGIN
  SELECT * FROM Campo WHERE ID_Ponto = @ID_Ponto;
END;
GO

-- Associar Desporto a Campo
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

-- Criar uma nova partida
CREATE OR ALTER PROCEDURE sp_CreatePartida
    @ID_Campo INT,
    @Data_Hora DATETIME,
    @Duracao INT,
    @Desporto VARCHAR(50),
    @ID_Jogador INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ID_Partida INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Partida (ID_Campo, no_jogadores, Data_Hora, Duracao, Estado)
        VALUES (@ID_Campo, 0, @Data_Hora, @Duracao, 'Aguardando');

        SET @ID_Partida = SCOPE_IDENTITY();

        IF @ID_Jogador IS NOT NULL
        BEGIN
            EXECUTE sp_AddJogadorToPartida 
                @ID_Partida = @ID_Partida,
                @ID_Jogador = @ID_Jogador;
        END
        ELSE
        BEGIN
            RAISERROR ('ID do jogador não fornecido.', 16, 1);
        END

        COMMIT TRANSACTION;
        SELECT @ID_Partida AS PartidaID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO


CREATE OR ALTER PROCEDURE sp_GetPartidas
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM vw_PartidaDetalhes
    WHERE Estado = 'Andamento' 
       OR Estado = 'Aguardando';
END;
GO


-- Atualizar uma partida existente
CREATE PROCEDURE sp_UpdatePartida
  @ID INT,
  @ID_Campo INT,
  @Data_Hora DATETIME,
  @Duracao INT,
  @Resultado VARCHAR(50),
  @Estado VARCHAR(50)
AS
BEGIN
  UPDATE Partida
  SET 
    ID_Campo = @ID_Campo,
    Data_Hora = @Data_Hora,
    Duracao = @Duracao,
    Resultado = @Resultado,
    Estado = @Estado
  WHERE ID = @ID;
END;
GO

-- Eliminar uma partida
CREATE PROCEDURE sp_DeletePartida
  @ID INT
AS
BEGIN
  DELETE FROM Partida WHERE ID = @ID;
END;
GO


-- Adicionar um jogador a uma partida
CREATE PROCEDURE sp_AddJogadorToPartida
    @ID_Partida INT,
    @ID_Jogador INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Estado VARCHAR(50);
    DECLARE @MaxJogadores INT;
    DECLARE @NoJogadoresAtual INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Get the current state, max_jogadores, and no_jogadores from Partida
        SELECT @Estado = Estado, @NoJogadoresAtual = no_jogadores
        FROM Partida
        WHERE ID = @ID_Partida;

        -- Check if the partida exists
        IF @Estado IS NULL
        BEGIN
            RAISERROR('Partida não encontrada.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Check if the partida is finalized
        IF @Estado = 'Finalizada'
        BEGIN
            RAISERROR('Não é possível adicionar jogadores a uma partida finalizada.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Check if the player exists
        IF NOT EXISTS (
            SELECT 1 FROM Jogador
            WHERE ID = @ID_Jogador
        )
        BEGIN
            RAISERROR('Jogador não encontrado.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Check if the player is already in the partida
        IF EXISTS (
            SELECT 1 FROM Jogador_joga
            WHERE ID_Partida = @ID_Partida AND ID_Jogador = @ID_Jogador
        )
        BEGIN
            RAISERROR('O jogador já está nesta partida.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Check if the maximum number of players has been reached
        IF @MaxJogadores IS NOT NULL AND @NoJogadoresAtual >= @MaxJogadores
        BEGIN
            RAISERROR('A partida já atingiu o número máximo de jogadores.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Insert the player into the Jogador_joga table
        INSERT INTO Jogador_joga (ID_Partida, ID_Jogador)
        VALUES (@ID_Partida, @ID_Jogador);

        -- Update the no_jogadores count in the Partida table
        UPDATE Partida
        SET no_jogadores = no_jogadores + 1
        WHERE ID = @ID_Partida;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

  -- Adiciona o jogador
  INSERT INTO Jogador_joga (ID_Partida, ID_Jogador)
  VALUES (@ID_Partida, @ID_Jogador);

  WHERE ID = @ID_Partida;
END;
GO


-- Remover um jogador de uma partida
CREATE PROCEDURE sp_RemoveJogadorFromPartida
  @ID_Partida INT,
  @ID_Jogador INT
AS
BEGIN
  DELETE FROM Jogador_joga
  WHERE ID_Partida = @ID_Partida AND ID_Jogador = @ID_Jogador;

  -- Atualiza o número de jogadores
  UPDATE Partida
  SET no_jogadores = (
    SELECT COUNT(*) FROM Jogador_joga WHERE ID_Partida = @ID_Partida
  )
  WHERE ID = @ID_Partida;
END;
GO

-- Obter todos os jogadores de uma partida
CREATE PROCEDURE sp_GetJogadoresByPartida
  @ID_Partida INT
AS
BEGIN
  SELECT 
    j.ID,
    u.Nome,
    u.Email,
    u.Num_Tele
  FROM Jogador_joga AS jj
  JOIN Jogador AS j ON jj.ID_Jogador = j.ID
  JOIN Utilizador AS u ON j.ID = u.ID
  WHERE jj.ID_Partida = @ID_Partida;
END;
GO

-- Atualizar Jogador
CREATE PROCEDURE sp_GetFriends
  @UserID INT
AS
BEGIN
  SELECT 
    j2.ID, 
    u.Nome, 
    AVG(r.Avaliacao) AS Rating,
    i.[URL] AS Imagens_Perfil
  FROM Jogador_Amizade AS ja
  JOIN Jogador AS j2 ON (ja.ID_J1 = j2.ID OR ja.ID_J2 = j2.ID)
  JOIN Utilizador AS u ON u.ID = j2.ID
  LEFT JOIN Rating_Jogador AS rj ON rj.ID_Jogador = j2.ID
  LEFT JOIN Rating AS r ON r.ID_Avaliador = rj.ID_Avaliador
  LEFT JOIN IMG_Perfil AS ipf ON ipf.ID_Utilizador = j2.ID
  LEFT JOIN Imagem as i ON i.ID = ipf.ID_img
  WHERE (ja.ID_J1 = @UserID OR ja.ID_J2 = @UserID) AND j2.ID <> @UserID
  GROUP BY j2.ID, u.Nome, i.[URL];
END;
GO

-- Adicionar um amigo
CREATE PROCEDURE sp_AddFriend
  @UserID INT,
  @FriendID INT
AS
BEGIN
  INSERT INTO Jogador_Amizade (ID_J1, ID_J2)
  VALUES (@UserID, @FriendID);
END;
GO

-- Remover um amigo
CREATE PROCEDURE sp_RemoveFriend
  @UserID INT,
  @FriendID INT
AS
BEGIN
  DELETE FROM Jogador_Amizade 
  WHERE (ID_J1 = @UserID AND ID_J2 = @FriendID) OR (ID_J1 = @FriendID AND ID_J2 = @UserID);
END;
GO

-- Obter informações de um amigo
CREATE PROCEDURE sp_GetFriendInfo
  @UserID INT
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM Utilizador WHERE ID = @UserID)
  BEGIN
    RAISERROR('Utilizador não encontrado.', 16, 1);
    RETURN;
  END;

  SELECT *
  FROM vw_InfoAmigo
  WHERE ID_Utilizador = @UserID;
END;
GO

CREATE PROCEDURE sp_GetHistoricPartidas
  @UserID INT
AS
BEGIN
  Select * from Jogador_joga as jj
  LEFT JOIN Partida as p on p.ID=jj.ID_Jogador
  WHERE jj.ID_Jogador = @UserID AND p.Estado = 'Finalizada';
END;
Go

-- Criar uma reserva
CREATE PROCEDURE sp_CreateReserva
  @ID_Campo INT,
  @ID_Jogador INT,
  @Data DATE,
  @Hora_Inicio TIME,
  @Hora_Fim TIME,
  @Total_Pagamento DECIMAL(10,2),
  @Estado VARCHAR(50),
  @Descricao VARCHAR(2500) = NULL
AS
BEGIN
  INSERT INTO Reserva (ID_Campo, ID_Jogador, [Data], Hora_Inicio, Hora_Fim, Total_Pagamento, Estado, Descricao)
  VALUES (@ID_Campo, @ID_Jogador, @Data, @Hora_Inicio, @Hora_Fim, @Total_Pagamento, @Estado, @Descricao);
END;
GO

-- Obter todas as reservas
CREATE PROCEDURE sp_GetAllReservas
AS
BEGIN
  SELECT * FROM Reserva;
END;
GO

-- Obter reserva por ID
CREATE PROCEDURE sp_GetReservaByID
  @ID INT
AS
BEGIN
  SELECT * FROM Reserva WHERE ID = @ID;
END;
GO

-- Obter reservas por jogador
CREATE PROCEDURE sp_GetReservasByUser
  @ID_Utilizador INT
AS
BEGIN
  SELECT * FROM vw_ReservasDetalhadas WHERE ID_Utilizador = @ID_Utilizador;
END;
GO

-- Obter reservas por campo
CREATE PROCEDURE sp_GetReservasByCampo
  @ID_Campo INT
AS
BEGIN
  SELECT * FROM vw_ReservasDetalhadas WHERE ID_Campo = @ID_Campo;
END;
GO

-- Atualizar uma reserva
CREATE PROCEDURE sp_UpdateReserva
  @ID INT,
  @ID_Campo INT = NULL,
  @ID_Jogador INT = NULL,
  @Data DATE = NULL,
  @Hora_Inicio TIME = NULL,
  @Hora_Fim TIME = NULL,
  @Total_Pagamento DECIMAL(10,2) = NULL,
  @Estado VARCHAR(50) = NULL,
  @Descricao VARCHAR(2500) = NULL
AS
BEGIN
  UPDATE Reserva
  SET
    ID_Campo = ISNULL(@ID_Campo, ID_Campo),
    ID_Jogador = ISNULL(@ID_Jogador, ID_Jogador),
    [Data] = ISNULL(@Data, [Data]),
    Hora_Inicio = ISNULL(@Hora_Inicio, Hora_Inicio),
    Hora_Fim = ISNULL(@Hora_Fim, Hora_Fim),
    Total_Pagamento = ISNULL(@Total_Pagamento, Total_Pagamento),
    Estado = ISNULL(@Estado, Estado),
    Descricao = ISNULL(@Descricao, Descricao)
  WHERE ID = @ID;
END;
GO

-- Eliminar uma reserva
CREATE PROCEDURE sp_DeleteReserva
  @ID INT
AS
BEGIN
  DELETE FROM Reserva WHERE ID = @ID;
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

-- CampoPub
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

-- Obter disponibilidade de um campo
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

-- Definir disponibilidade de um campo
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
	where cp.ID_Arrendador = @UserID
	GROUP BY c.ID,
    c.Nome,
    c.Endereco,
    c.Ocupado;
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

-- Atualizar métodos de pagamento de um arrendador
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


