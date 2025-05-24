-- Criar uma nova partida
CREATE PROCEDURE sp_CreatePartida
  @ID_Campo INT,
  @Data_Hora DATETIME,
  @Duracao INT,
  @Resultado VARCHAR(50),
  @Estado VARCHAR(50) = 'Aguardando'
AS
BEGIN
  INSERT INTO Partida (ID_Campo, no_jogadores, Data_Hora, Duracao, Resultado, Estado)
  VALUES (@ID_Campo, 0, @Data_Hora, @Duracao, @Resultado, @Estado);
END;
GO

-- Obter os detalhes de uma partida
CREATE PROCEDURE sp_GetPartida
  @ID INT
AS
BEGIN
  SELECT 
    p.ID,
    p.ID_Campo,
    p.no_jogadores,
    p.Data_Hora,
    p.Duracao,
    p.Resultado,
    p.Estado,
    c.Nome AS Nome_Campo
  FROM Partida p
  LEFT JOIN Campo c ON p.ID_Campo = c.ID
  WHERE p.ID = @ID;
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
  -- Verifica se a partida está finalizada
  IF EXISTS (
    SELECT 1 FROM Partida
    WHERE ID = @ID_Partida AND Estado = 'Finalizada'
  )
  BEGIN
    RAISERROR('Não é possível adicionar jogadores a uma partida finalizada.', 16, 1);
    RETURN;
  END;

  -- Adiciona o jogador
  INSERT INTO Jogador_joga (ID_Partida, ID_Jogador)
  VALUES (@ID_Partida, @ID_Jogador);

  -- Atualiza o número de jogadores na partida
  UPDATE Partida
  SET no_jogadores = (
    SELECT COUNT(*) FROM Jogador_joga WHERE ID_Partida = @ID_Partida
  )
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
