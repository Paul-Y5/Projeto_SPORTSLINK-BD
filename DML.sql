USE SPORTSLINK;
GO

BEGIN TRANSACTION;

-- Apagar os dados existentes (comentado para evitar perda de dados, apenas descomentar se necessário)
-- ========================================
-- TRUNCATE TABLE Utilizador;
-- TRUNCATE TABLE Imagem;
-- TRUNCATE TABLE Mapa;
-- TRUNCATE TABLE Ponto;
-- TRUNCATE TABLE Campo;
-- TRUNCATE TABLE Campo_Priv;
-- TRUNCATE TABLE Campo_Pub;
-- TRUNCATE TABLE Dias_semana;
-- TRUNCATE TABLE Disponibilidade;
-- TRUNCATE TABLE Desporto;
-- TRUNCATE TABLE Desporto_Campo;
-- TRUNCATE TABLE Desporto_Jogador;
-- TRUNCATE TABLE Partida;
-- TRUNCATE TABLE Jogador_joga;
-- TRUNCATE TABLE Reserva;
-- TRUNCATE TABLE Rating;
-- TRUNCATE TABLE Rating_Campo;
-- TRUNCATE TABLE Rating_Jogador;
-- TRUNCATE TABLE Jogador_Amizade;
-- TRUNCATE TABLE Met_Paga_Arrendador;
-- TRUNCATE TABLE Chat_Live;
-- TRUNCATE TABLE IMG_Perfil;
-- TRUNCATE TABLE IMG_Campo;

-- Inserir Imagens
-- ========================================
INSERT INTO Imagem (URL) VALUES
('img/campo.png'),
('img/icon_def.png');

-- ========================================
-- 1. Inserir Utilizadores (with encryption)
-- ========================================
INSERT INTO Utilizador (Nome, Email, Num_Tele, [Password], Nacionalidade) VALUES
('João Silva', 'joao@gmail.com', '912345678', EncryptByPassPhrase('SportsLink2025', 'pass123'), 'Portugal'),
('Maria Costa', 'maria@gmail.com', '913333333', EncryptByPassPhrase('SportsLink2025', 'maria123'), 'Brasil'),
('Carlos Dias', 'carlos@gmail.com', '914444444', EncryptByPassPhrase('SportsLink2025', 'carlos321'), 'Portugal'),
('Ana Lima', 'ana@gmail.com', '915555555', EncryptByPassPhrase('SportsLink2025', 'ana456'), 'Espanha'),
('Pedro Alves', 'pedro@gmail.com', '916666666', EncryptByPassPhrase('SportsLink2025', 'pedro789'), 'Angola'),
('António Rocha', 'arocha@gmail.com', '917777777', EncryptByPassPhrase('SportsLink2025', 'luis000'), 'Portugal'),
('Rita Nunes', 'rita@gmail.com', '918888888', EncryptByPassPhrase('SportsLink2025', 'rita987'), 'Brasil'),
('Paulo Ferreira', 'pf@gmail.com', '919999999', EncryptByPassPhrase('SportsLink2025', 'tiago123'), 'Portugal'),
('Sofia Mendes', 'sofia@gmail.com', '920111222', EncryptByPassPhrase('SportsLink2025', 'sofia111'), 'Portugal'),
('Lucas Souza', 'lucas@gmail.com', '921222333', EncryptByPassPhrase('SportsLink2025', 'lucas222'), 'Brasil');

-- ========================================
-- 2. Jogadores
-- ========================================
INSERT INTO Jogador (ID, Data_Nascimento, Descricao, Peso, Altura)
SELECT ID, DATEADD(YEAR, -25, GETDATE()), 'Jogador ativo e competitivo.', 75.0, 1.80
FROM Utilizador
WHERE Nome IN ('João Silva', 'Pedro Alves', 'Carlos Dias', 'Lucas Souza');

INSERT INTO Jogador (ID, Data_Nascimento, Descricao, Peso, Altura)
SELECT ID, DATEADD(YEAR, -30, GETDATE()), 'Jogadora experiente.', 80.0, 1.85
FROM Utilizador
WHERE Nome IN ('Maria Costa', 'Ana Lima', 'Sofia Mendes');

INSERT INTO Jogador (ID, Data_Nascimento, Descricao, Peso, Altura)
SELECT ID, DATEADD(YEAR, -22, GETDATE()), 'Jogador amador.', 70.0, 1.75
FROM Utilizador
WHERE Nome IN ('António Rocha');

INSERT INTO Jogador (ID, Data_Nascimento, Descricao, Peso, Altura)
SELECT ID, DATEADD(YEAR, -28, GETDATE()), 'Jogador de futsal.', 78.0, 1.82
FROM Utilizador
WHERE Nome IN ('Paulo Ferreira', 'Rita Nunes');

-- ========================================
-- 3. Arrendadores
-- ========================================
INSERT INTO Arrendador (ID_Arrendador, IBAN, No_Campos)
SELECT ID, 'PT500002012345678900' + RIGHT('00' + CAST(ID AS VARCHAR), 2), 0
FROM Utilizador
WHERE Nome IN ('Carlos Dias', 'António Rocha', 'Rita Nunes', 'Sofia Mendes');

-- ========================================
-- 4. Imagem Perfil
-- ========================================
INSERT INTO IMG_Perfil (ID_Utilizador, ID_img)
SELECT u.ID, i.ID
FROM Utilizador u
JOIN Imagem i ON i.URL = 'img/icon_def.png';

-- ========================================
-- 5. Mapa + Pontos
-- ========================================
-- Inserir ID 1 manualmente
SET IDENTITY_INSERT Mapa ON;
INSERT INTO Mapa (ID) VALUES (1);
SET IDENTITY_INSERT Mapa OFF;

INSERT INTO Ponto (ID_Mapa, Latitude, Longitude) VALUES
(1, 38.7200, -9.1400), -- Lisboa
(1, 38.7201, -9.1405), -- Lisboa
(1, 38.7202, -9.1410), -- Porto
(1, 38.7203, -9.1415), -- Porto
(1, 38.7204, -9.1420), -- Lisboa
(1, 38.7205, -9.1425), -- Lisboa
(1, 38.7206, -9.1430), -- Faro
(1, 38.7207, -9.1435), -- Faro
(1, 38.7208, -9.1440), -- Coimbra
(1, 38.7209, -9.1445); -- Coimbra

-- ========================================
-- 6. Campos
-- ========================================
INSERT INTO Campo (ID_Ponto, ID_Mapa, Nome, Endereco, Comprimento, Largura, ocupado, Descricao) VALUES
(1, 1, 'Campo Central', 'Rua Central 123, Lisboa', 100.0, 60.0, 0, 'Campo oficial para futebol'),
(2, 1, 'Campo Bairro', 'Av. Bairro Novo, Lisboa', 80.0, 50.0, 1, 'Futsal amador'),
(3, 1, 'basketball court Sol', 'Praça do Sol, Porto', 50.0, 30.0, 0, 'Voleibol e ténis'),
(4, 1, 'Arena Norte', 'Rua Norte 45, Porto', 90.0, 55.0, 1, 'Campo multiusos'),
(5, 1, 'Estádio Lisboa', 'Estrada Principal, Lisboa', 105.0, 68.0, 0, 'Estádio profissional de futebol'),
(6, 1, 'Parque Desportivo', 'Parque Verde, Lisboa', 60.0, 40.0, 0, 'Basquete e futsal'),
(7, 1, 'Campo Faro', 'Rua do Mar, Faro', 90.0, 50.0, 1, 'Campo de futebol ao ar livre'),
(8, 1, 'basketball court Faro', 'Av. da Praia, Faro', 40.0, 20.0, 0, 'Ténis e voleibol'),
(9, 1, 'Arena Coimbra', 'Rua Central, Coimbra', 95.0, 55.0, 0, 'Campo multiusos'),
(10, 1, 'Parque Coimbra', 'Parque da Cidade, Coimbra', 70.0, 45.0, 1, 'Futsal e basquete');

-- ========================================
-- 7. Campos Privados / Públicos
-- ========================================
DECLARE @Arr1 INT = (SELECT ID FROM Utilizador WHERE Nome = 'Carlos Dias');
DECLARE @Arr2 INT = (SELECT ID FROM Utilizador WHERE Nome = 'António Rocha');
DECLARE @Arr3 INT = (SELECT ID FROM Utilizador WHERE Nome = 'Rita Nunes');
DECLARE @Arr4 INT = (SELECT ID FROM Utilizador WHERE Nome = 'Sofia Mendes');

INSERT INTO Campo_Priv (ID_Campo, ID_Arrendador) VALUES
(1, @Arr1),  -- Campo Central (Carlos Dias)
(3, @Arr1),  -- basketball court Sol (Carlos Dias)
(4, @Arr2),  -- Arena Norte (António Rocha)
(6, @Arr3),  -- Parque Desportivo (Rita Nunes)
(7, @Arr4),  -- Campo Faro (Sofia Mendes)
(9, @Arr2);  -- Arena Coimbra (António Rocha)

INSERT INTO Campo_Pub (ID_Campo, Entidade_publica_resp) VALUES
(2, 'Câmara Lisboa'),    -- Campo Bairro
(5, 'Câmara Lisboa'),    -- Estádio Lisboa
(8, 'Câmara Faro'),      -- basketball court Faro
(10, 'Câmara Coimbra');  -- Parque Coimbra

-- ========================================
-- 8. Dias da Semana
-- ========================================
INSERT INTO Dias_semana (ID, Nome) VALUES
(1, 'Domingo'), (2, 'Segunda'), (3, 'Terça'), (4, 'Quarta'),
(5, 'Quinta'), (6, 'Sexta'), (7, 'Sábado');

-- ========================================
-- 9. Disponibilidades
-- ========================================
INSERT INTO Disponibilidade (ID_Campo, ID_dia, Preco, Hora_abertura, Hora_fecho) VALUES
(1, 2, 25.00, '08:00', '17:00'),  -- Campo Central: Segunda
(1, 4, 30.00, '09:00', '18:00'),  -- Campo Central: Quarta
(3, 3, 20.00, '10:00', '19:00'),  -- basketball court Sol: Terça
(3, 5, 22.00, '10:00', '19:00'),  -- basketball court Sol: Quinta
(4, 5, 35.00, '12:00', '20:00'),  -- Arena Norte: Quinta
(4, 6, 35.00, '12:00', '20:00'),  -- Arena Norte: Sexta
(6, 1, 28.00, '09:00', '18:00'),  -- Parque Desportivo: Domingo
(6, 3, 28.00, '09:00', '18:00'),  -- Parque Desportivo: Terça
(7, 4, 30.00, '11:00', '20:00'),  -- Campo Faro: Quarta
(9, 2, 32.00, '10:00', '19:00');  -- Arena Coimbra: Segunda

-- ========================================
-- 10. Desportos
-- ========================================
INSERT INTO Desporto (Nome) VALUES
('Futebol'), ('Futsal'), ('Voleibol'), ('Ténis'), ('Basquetebol');

-- ========================================
-- 11. Desporto x Campo
-- ========================================
INSERT INTO Desporto_Campo (ID_Desporto, ID_Campo) VALUES
(1, 1),  -- Campo Central: Futebol
(1, 5),  -- Estádio Lisboa: Futebol
(1, 7),  -- Campo Faro: Futebol
(1, 9),  -- Arena Coimbra: Futebol
(2, 2),  -- Campo Bairro: Futsal
(2, 6),  -- Parque Desportivo: Futsal
(2, 10), -- Parque Coimbra: Futsal
(3, 3),  -- basketball court Sol: Voleibol
(3, 8),  -- basketball court Faro: Voleibol
(4, 3),  -- basketball court Sol: Ténis
(4, 8),  -- basketball court Faro: Ténis
(5, 4),  -- Arena Norte: Basquetebol
(5, 6),  -- Parque Desportivo: Basquetebol
(5, 10); -- Parque Coimbra: Basquetebol

-- ========================================
-- 12. Desporto x Jogador
-- ========================================
INSERT INTO Desporto_Jogador (ID_Jogador, ID_Desporto) VALUES
(1, 1), (1, 2),  -- João Silva: Futebol, Futsal
(2, 1), (2, 3),  -- Maria Costa: Futebol, Voleibol
(3, 1), (3, 5),  -- Carlos Dias: Futebol, Basquetebol
(4, 1), (4, 2),  -- Ana Lima: Futebol, Futsal
(5, 1), (5, 5),  -- Pedro Alves: Futebol, Basquetebol
(6, 2), (6, 3),  -- António Rocha: Futsal, Voleibol
(7, 2), (7, 4),  -- Rita Nunes: Futsal, Ténis
(8, 2), (8, 5),  -- Paulo Ferreira: Futsal, Basquetebol
(9, 1), (9, 3),  -- Sofia Mendes: Futebol, Voleibol
(10, 1), (10, 5); -- Lucas Souza: Futebol, Basquetebol

-- ========================================
-- 13. Partidas
-- ========================================
INSERT INTO Partida (ID_Campo, no_jogadores, Data_Hora, Duracao, Resultado, Estado) VALUES
(1, 0, '2025-06-01 15:00', 90, NULL, 'Aguardando'),  -- Campo Central
(2, 0, '2025-06-02 18:00', 60, NULL, 'Aguardando'),  -- Campo Bairro
(3, 0, '2025-06-03 16:00', 60, NULL, 'Aguardando'),  -- basketball court Sol
(4, 0, '2025-06-04 14:00', 90, NULL, 'Aguardando'),  -- Arena Norte
(5, 0, '2025-06-05 17:00', 90, NULL, 'Aguardando'),  -- Estádio Lisboa
(6, 0, '2025-06-06 10:00', 60, NULL, 'Aguardando'); -- Parque Desportivo

-- ========================================
-- 14. Jogadores nas Partidas
-- ========================================
INSERT INTO Jogador_joga (ID_Partida, ID_Jogador) VALUES
(1, 1), (1, 3), (1, 5), (1, 10),  -- Campo Central: João, Carlos, Pedro, Lucas
(2, 1), (2, 4), (2, 6), (2, 8),   -- Campo Bairro: João, Ana, António, Paulo
(3, 2), (3, 7), (3, 9),            -- basketball court Sol: Maria, Rita, Sofia
(4, 3), (4, 5), (4, 8), (4, 10),  -- Arena Norte: Carlos, Pedro, Paulo, Lucas
(5, 1), (5, 3), (5, 9), (5, 10),  -- Estádio Lisboa: João, Carlos, Sofia, Lucas
(6, 2), (6, 4), (6, 8);           -- Parque Desportivo: Maria, Ana, Paulo

-- Atualizar no_jogadores em Partida
UPDATE p
SET p.no_jogadores = (SELECT COUNT(*) FROM Jogador_joga jj WHERE jj.ID_Partida = p.ID)
FROM Partida p;

-- ========================================
-- 15. Reservas
-- ========================================
INSERT INTO Reserva (ID_Campo, ID_Jogador, [Data], Hora_Inicio, Hora_Fim, Total_Pagamento, Estado, Descricao) VALUES
(1, 1, '2025-06-02', '14:00', '15:00', NULL, 'Confirmada', 'Treino semanal'),  -- João no Campo Central
(2, 2, '2025-06-03', '10:00', '11:00', NULL, 'Confirmada', 'Partida de futsal'), -- Maria no Campo Bairro
(3, 3, '2025-06-04', '11:00', '12:00', NULL, 'Pendente', 'Voleibol'),          -- Carlos na basketball court Sol
(4, 5, '2025-06-05', '13:00', '14:00', NULL, 'Confirmada', 'Basquete'),         -- Pedro na Arena Norte
(5, 9, '2025-06-06', '15:00', '16:00', NULL, 'Confirmada', 'Futebol'),          -- Sofia no Estádio Lisboa
(6, 4, '2025-06-07', '09:00', '10:00', NULL, 'Confirmada', 'Futsal');           -- Ana no Parque Desportivo

-- ========================================
-- 16. Ratings
-- ========================================
-- Inserir em Rating (sem alterações, está correto)
INSERT INTO Rating (ID_Avaliador, Data_Hora, Comentario, Avaliacao) VALUES
(1, '2025-05-30 20:00', 'Muito bom!', 5),
(2, '2025-05-30 21:00', 'Bom campo.', 4),
(3, '2025-05-30 22:00', 'Excelente!', 5),
(4, '2025-05-30 22:30', 'Piso escorregadio.', 3),
(5, '2025-05-30 23:00', 'Ótima experiência.', 4);

-- Inserir em Rating_Campo (usar ID_Avaliacao em vez de ID_Avaliador)
INSERT INTO Rating_Campo (ID_Campo, ID_Avaliacao) VALUES
(1, 1), -- ID_Avaliacao 1 (corresponde a ID_Avaliador 1)
(2, 2), -- ID_Avaliacao 2 (corresponde a ID_Avaliador 2)
(3, 3), -- ID_Avaliacao 3 (corresponde a ID_Avaliador 3)
(4, 4), -- ID_Avaliacao 4 (corresponde a ID_Avaliador 4)
(5, 5); -- ID_Avaliacao 5 (corresponde a ID_Avaliador 5)

-- Inserir em Rating_Jogador (usar ID_Avaliacao em vez de ID_Avaliador)
INSERT INTO Rating_Jogador (ID_Jogador, ID_Avaliacao) VALUES
(2, 1), -- ID_Avaliacao 1 (corresponde a ID_Avaliador 1)
(3, 2), -- ID_Avaliacao 2 (corresponde a ID_Avaliador 2)
(1, 3), -- ID_Avaliacao 3 (corresponde a ID_Avaliador 3)
(4, 5), -- ID_Avaliacao 5 (corresponde a ID_Avaliador 5)
(5, 4); -- ID_Avaliacao 4 (corresponde a ID_Avaliador 4)

-- ========================================
-- 17. Amizades
-- ========================================
INSERT INTO Jogador_Amizade (ID_J1, ID_J2) VALUES
(1, 2), (1, 3), (1, 5), (2, 3), (2, 4), (3, 5), (4, 5), (6, 7), (8, 9), (9, 10);

-- ========================================
-- 18. Métodos Pagamento Arrendador
-- ========================================
INSERT INTO Met_Paga_Arrendador (ID_Arrendador, Met_pagamento, Detalhes) VALUES
(@Arr1, 'MBWay', '912345678'),
(@Arr1, 'PayPal', 'carlos@gmail.com'),
(@Arr2, 'Transferência Bancária', 'PT50000201234567890006'),
(@Arr3, 'MBWay', '918888888'),
(@Arr4, 'PayPal', 'sofia@gmail.com');

-- ========================================
-- 19. Chat Live
-- ========================================
INSERT INTO Chat_Live (ID_Partida, Titulo) VALUES
(1, 'Futebol Domingo'),
(2, 'Treino Futsal'),
(3, 'Voleibol Girls'),
(4, 'Basquete Amigável'),
(5, 'Futebol Pro'),
(6, 'Futsal Matinal');

-- ========================================
-- 20. Imagens Campos
-- ========================================
INSERT INTO IMG_Campo (ID_Campo, ID_img) VALUES
(1, 1),  -- Campo Central: Futebol
(2, 1),  -- Campo Bairro: Futsal
(3, 1),  -- basketball court Sol: Ténis
(4, 1),  -- Arena Norte: Basquete
(5, 1),  -- Estádio Lisboa: Futebol
(6, 1),  -- Parque Desportivo: Basquete
(7, 1),  -- Campo Faro: Futebol
(8, 1),  -- basketball court Faro: Ténis
(9, 1),  -- Arena Coimbra: Futebol
(10, 1); -- Parque Coimbra: Futsal

COMMIT TRANSACTION;

-- Para Testar Indices (Adicionar muitos dados para se perceber a diferença de performance)

/* -- Populate Utilizador table
DECLARE @i INT = 30;

WHILE @i <= 1000
BEGIN
    INSERT INTO Utilizador (Nome, Email, Num_Tele, [Password], Nacionalidade)
    VALUES (
        CONCAT('User Name ', @i),
        CONCAT('user', @i, '@example.com'),
        CONCAT('912345', RIGHT('000' + CAST(@i AS VARCHAR), 3)),
        CONVERT(VARBINARY(512), HASHBYTES('SHA2_256', 'password' + CAST(@i AS VARCHAR))),
        CASE WHEN @i % 4 = 0 THEN 'Portugal' 
             WHEN @i % 4 = 1 THEN 'Brasil' 
             WHEN @i % 4 = 2 THEN 'Espanha' 
             ELSE 'França' END
    );

    SET @i = @i + 1;
END;

-- Populate Jogador table
SET @i = 30;

WHILE @i <= 1000
BEGIN
    INSERT INTO Jogador (ID, Data_Nascimento, Descricao, Peso, Altura)
    VALUES (
        @i,
        DATEADD(YEAR, -1 * (18 + (@i % 22)), GETDATE()), -- Random age between 18 and 40
        CONCAT('Biography for player ', @i, '...'),
        ROUND(50 + (RAND() * 50), 2), -- Weight between 50 and 100 kg
        ROUND(150 + (RAND() * 50), 2) -- Height between 150 and 200 cm
    );

    SET @i = @i + 1;
END;

-- Populate Arrendador table (using subset of Utilizador IDs)
SET @i = 30;

WHILE @i <= 500
BEGIN
    INSERT INTO Arrendador (ID_Arrendador, IBAN, No_Campos)
    VALUES (
        @i,
        CONCAT('PT50', RIGHT('0000000000000000000000' + CAST(@i AS VARCHAR), 21)),
        1 + (@i % 5) -- Between 1 and 5 fields
    );

    SET @i = @i + 1;
END;

-- Populate Ponto table
SET @i = 1;

WHILE @i <= 471
BEGIN
    INSERT INTO Ponto (ID_Mapa, Latitude, Longitude)
    VALUES (
        1,
        ROUND(38.5 + (RAND() * 5), 6), -- Random latitude around Portugal
        ROUND(-9.5 + (RAND() * 5), 6)  -- Random longitude around Portugal
    );

    SET @i = @i + 1;
END;

-- Populate Campo table (limited to match Ponto records)
SET @i = 30;

WHILE @i <= 500
BEGIN
    INSERT INTO Campo (ID_Ponto, ID_Mapa, Nome, Endereco, Comprimento, Largura, ocupado, Descricao)
    VALUES (
        @i - 29, -- Align with Ponto IDs (1 to 471)
        1,
        CONCAT('Field ', @i),
        CONCAT('Address ', @i, ', City'),
        ROUND(90 + (RAND() * 30), 2), -- Length between 90 and 120 meters
        ROUND(45 + (RAND() * 25), 2), -- Width between 45 and 70 meters
        CASE WHEN @i % 2 = 0 THEN 0 ELSE 1 END,
        CONCAT('Description for field ', @i, '...')
    );

    SET @i = @i + 1;
END;

-- Populate Campo_Pub table (first 235 fields)
SET @i = 30;

WHILE @i <= 264
BEGIN
    INSERT INTO Campo_Pub (ID_Campo, Entidade_publica_resp)
    VALUES (
        @i,
        CONCAT('Municipality ', @i)
    );

    SET @i = @i + 1;
END;

-- Populate Campo_Priv table (next 236 fields, linked to Arrendadores)
SET @i = 265;

WHILE @i <= 500
BEGIN
    INSERT INTO Campo_Priv (ID_Campo, ID_Arrendador)
    VALUES (
        @i,
        30 + ((@i - 265) % 471) -- Link to Arrendador IDs 30 to 500
    );

    SET @i = @i + 1;
END; */