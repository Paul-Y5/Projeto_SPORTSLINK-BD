USE SPORTSLINK;
GO

-- ========================================
-- 1. Inserir Utilizadores
-- ========================================
INSERT INTO Utilizador (Nome, Email, Num_Tele, [Password], Nacionalidade) VALUES
('João Silva', 'joao@gmail.com', '912345678', 'pass123', 'Portugal'),
('Maria Costa', 'maria@gmail.com', '913333333', 'maria123', 'Brasil'),
('Carlos Dias', 'carlos@gmail.com', '914444444', 'carlos321', 'Portugal'),
('Ana Lima', 'ana@gmail.com', '915555555', 'ana456', 'Espanha'),
('Pedro Alves', 'pedro@gmail.com', '916666666', 'pedro789', 'Angola'),
('António Rocha', 'arocha@gmail.com', '917777777', 'luis000', 'Portugal'),
('Rita Nunes', 'rita@gmail.com', '918888888', 'rita987', 'Brasil'),
('Paulo Ferreira', 'pf@gmail.com', '919999999', 'tiago123', 'Portugal');

-- ========================================
-- 2. Jogadores
-- ========================================
INSERT INTO Jogador (ID, Data_Nascimento, Idade, Descricao, Peso, Altura)
SELECT ID, DATEADD(YEAR, -25, GETDATE()), 25, 'Jogador ativo e competitivo.', 75.0, 1.80
FROM Utilizador
WHERE Nome IN ('João Silva', 'Pedro Alves', 'Carlos Dias');

INSERT INTO Jogador (ID, Data_Nascimento, Idade, Descricao, Peso, Altura)
SELECT ID, DATEADD(YEAR, -30, GETDATE()), 30, 'Jogadora experiente.', 80.0, 1.85
FROM Utilizador
WHERE Nome IN ('Maria Costa', 'Ana Lima');

INSERT INTO Jogador (ID, Data_Nascimento, Idade, Descricao, Peso, Altura)
SELECT ID, DATEADD(YEAR, -22, GETDATE()), 22, 'Jogador amador.', 70.0, 1.75
FROM Utilizador
WHERE Nome IN ('António Rocha');

INSERT INTO Jogador (ID, Data_Nascimento, Idade, Descricao, Peso, Altura)
SELECT ID, DATEADD(YEAR, -28, GETDATE()), 28, 'Jogador de futsal.', 78.0, 1.82
FROM Utilizador
WHERE Nome IN ('Paulo Ferreira', 'Rita Nunes');

-- ========================================
-- 3. Arrendadores
-- ========================================
INSERT INTO Arrendador (ID_Arrendador, IBAN, No_Campos)
SELECT ID, 'PT500002012345678900' + RIGHT('00' + CAST(ID AS VARCHAR), 2), 3
FROM Utilizador
WHERE Nome IN ('Carlos Dias', 'António Rocha', 'Rita Nunes');

-- ========================================
-- 4. Imagens
-- ========================================
INSERT INTO Imagem ([URL]) VALUES
('.\src\static\img\campo.png'), ('.\src\static\img\icon_def.png');

-- ========================================
-- 5. Imagem Perfil
-- ========================================
INSERT INTO IMG_Perfil (ID_Utilizador, ID_img)
SELECT u.ID, i.ID
FROM Utilizador u
JOIN Imagem i ON i.URL = '.\src\static\img\icon_def.png';

-- ========================================
-- 6. Mapa + Pontos
-- ========================================

INSERT INTO Mapa DEFAULT VALUES;
DECLARE @MapaID INT = SCOPE_IDENTITY();

INSERT INTO Ponto (ID_Mapa, Latitude, Longitude) VALUES
(@MapaID, 38.7200, -9.1400),
(@MapaID, 38.7201, -9.1405),
(@MapaID, 38.7202, -9.1410),
(@MapaID, 38.7203, -9.1415);


-- ========================================
-- 7. Campos
-- ========================================
INSERT INTO Campo (ID_Ponto, ID_Mapa, Nome, Endereco, Comprimento, Largura, ocupado, Descricao)
VALUES
(1, @MapaID, 'Campo Central', 'Lisboa', 100.0, 60.0, 0, 'Futebol oficial'),
(2, @MapaID, 'Campo Bairro', 'Lisboa', 80.0, 50.0, 1, 'Futsal amador'),
(3, @MapaID, 'Quadra Sol', 'Porto', 50.0, 30.0, 0, 'Voleibol e ténis'),
(4, @MapaID, 'Arena Norte', 'Porto', 90.0, 55.0, 1, 'Campo multiusos');

-- ========================================
-- 8. Campos Privados / Públicos
-- ========================================
DECLARE @Arr1 INT = (SELECT ID_Arrendador FROM Arrendador WHERE ID_Arrendador = (SELECT ID FROM Utilizador WHERE Nome = 'Carlos Dias'));
DECLARE @Arr2 INT = (SELECT ID_Arrendador FROM Arrendador WHERE ID_Arrendador = (SELECT ID FROM Utilizador WHERE Nome = 'António Rocha'));

INSERT INTO Campo_Priv (ID_Campo, ID_Arrendador) VALUES
(1, @Arr1), (3, @Arr1), (4, @Arr2);

INSERT INTO Campo_Pub (ID_Campo, Entidade_publica_resp) VALUES
(2, 'Câmara Lisboa');

-- ========================================
-- 9. Dias da Semana
-- ========================================
INSERT INTO Dias_semana (ID, Nome) VALUES
(1, 'Domingo'), (2, 'Segunda'), (3, 'Terça'), (4, 'Quarta'),
(5, 'Quinta'), (6, 'Sexta'), (7, 'Sábado');

-- ========================================
-- 10. Disponibilidades
-- ========================================
INSERT INTO Disponibilidade (ID_Campo, ID_dia, Preco, Hora_abertura, Hora_fecho)
VALUES
(1, 2, 25.00, '08:00', '17:00'),
(1, 4, 30.00, '09:00', '18:00'),
(3, 3, 20.00, '10:00', '19:00'),
(4, 5, 35.00, '12:00', '20:00');

-- ========================================
-- 11. Desportos
-- ========================================
INSERT INTO Desporto (Nome) VALUES
('Futebol'), ('Futsal'), ('Voleibol'), ('Ténis'), ('Basquetebol');

-- ========================================
-- 12. Desporto x Campo
-- ========================================
INSERT INTO Desporto_Campo (ID_Desporto, ID_Campo) VALUES
(1, 1), (2, 2), (3, 3), (4, 3), (5, 4);

-- ========================================
-- 13. Desporto x Jogador
-- ========================================
INSERT INTO Desporto_Jogador (ID_Jogador, ID_Desporto)
SELECT ID, 1 FROM Jogador
UNION
SELECT ID, 2 FROM Jogador WHERE ID % 2 = 0
UNION
SELECT ID, 3 FROM Jogador WHERE ID % 2 <> 0;

-- ========================================
-- 14. Partidas
-- ========================================
INSERT INTO Partida (ID_Campo, no_jogadores, Data_Hora, Duracao, Resultado, Estado)
VALUES
(1, 10, '2025-05-11 15:00', 90, '3-2', 'Finalizada'),
(2, 8, '2025-05-12 18:00', 60, '1-1', 'Finalizada'),
(3, 6, '2025-05-13 16:00', 60, NULL, 'Aguardando');

-- ========================================
-- 15. Jogadores nas Partidas
-- ========================================
INSERT INTO Jogador_joga (ID_Partida, ID_Jogador)
SELECT p.ID, j.ID FROM Partida p, Jogador j WHERE p.ID <= 2 AND j.ID <= 3;

-- ========================================
-- 16. Reservas
-- ========================================
INSERT INTO Reserva (ID_Campo, ID_Jogador, [Data], Hora_Inicio, Hora_Fim, Total_Pagamento, Estado, Descricao)
SELECT 1, ID, '2025-05-15', '14:00', '15:30', 25.00, 'Confirmada', 'Treino semanal'
FROM Jogador WHERE ID <= 3;

INSERT INTO Reserva (ID_Campo, ID_Jogador, [Data], Hora_Inicio, Hora_Fim, Total_Pagamento, Estado, Descricao)
SELECT 2, ID, '2025-05-16', '10:00', '11:30', 20.00, 'Confirmada', 'Partida de futsal'
FROM Jogador WHERE ID <= 3;

-- ========================================
-- 17. Ratings
-- ========================================
INSERT INTO Rating (ID_Avaliador, Data_Hora, Comentario, Avaliacao)
SELECT ID, GETDATE(), 'Muito bom!', 5 FROM Jogador WHERE ID <= 3;

INSERT INTO Rating_Campo (ID_Campo, ID_Avaliador) VALUES
(1, 1), (2, 2), (3, 3);

INSERT INTO Rating_Jogador (ID_Jogador, ID_Avaliador) VALUES
(2, 1), (3, 2), (1, 3);

-- ========================================
-- 18. Amizades
-- ========================================
INSERT INTO Jogador_Amizade (ID_J1, ID_J2) VALUES
(1, 2), (1, 3), (2, 3), (4, 5);

-- ========================================
-- 19. Métodos Pagamento Arrendador
-- ========================================
INSERT INTO Met_Paga_Arrendador (ID_Arrendador, Met_pagamento) VALUES
(@Arr1, 'MBWay'), (@Arr1, 'PayPal'), (@Arr2, 'Transferência Bancária');

-- ========================================
-- 20. Chat Live
-- ========================================
INSERT INTO Chat_Live (ID_Partida, Titulo) VALUES
(1, 'Futebol Domingo'), (2, 'Treino Futsal'), (3, 'Voleibol Girls');

-- ========================================
-- 21. Imagens Campos
-- ========================================
INSERT INTO IMG_Campo (ID_Campo, ID_img)
VALUES (1, 1), (2, 1), (3, 1), (4, 1);