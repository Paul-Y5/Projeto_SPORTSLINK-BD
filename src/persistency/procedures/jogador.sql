-- CRUD para a tabela Jogador
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


CREATE PROCEDURE sp_AddFriend
  @UserID INT,
  @FriendID INT
AS
BEGIN
  INSERT INTO Jogador_Amizade (ID_J1, ID_J2)
  VALUES (@UserID, @FriendID);
END;
GO


CREATE PROCEDURE sp_RemoveFriend
  @UserID INT,
  @FriendID INT
AS
BEGIN
  DELETE FROM Jogador_Amizade 
  WHERE (ID_J1 = @UserID AND ID_J2 = @FriendID) OR (ID_J1 = @FriendID AND ID_J2 = @UserID);
END;
GO

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

CREATE PROCEDURE sp_GetHistoricPartidas
  @UserID INT
AS
BEGIN
  SELECT * from vw_PartidaDetalhes as v
  WHERE v.ID_Jogador = @UserID AND v.Estado = 'Finalizada';
END;