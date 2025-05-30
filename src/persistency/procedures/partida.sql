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
