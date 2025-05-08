USE SPORTSLINK;
GO

-- ========================
-- UTILIZADORES
-- ========================
INSERT INTO Utilizador (ID, Nome, Email, Num_Tele, [Password], Nacionalidade) VALUES
(456781234, 'João Silva', 'joao@gmail.com', '912345678', 'pass123', 'Portugal'),
(456782345, 'Maria Costa', 'maria@gmail.com', '913333333', 'maria123', 'Brasil'),
(456783456, 'Carlos Dias', 'carlos@gmail.com', '914444444', 'carlos321', 'Portugal'),
(456784567, 'Ana Lima', 'ana.lima@gmail.com', '915555555', 'ana456', 'Espanha'),
(456785678, 'Pedro Alves', 'pedro.alves@gmail.com', '916666666', 'pedro789', 'Angola');

-- ========================
-- JOGADORES
-- ========================
INSERT INTO Jogador (ID, Idade, Descricao) VALUES
(456781234, 25, 'Jogador amador de futebol'),
(456782345, 30, 'Apaixonada por voleibol'),
(456784567, 22, 'Estudante universitária, joga futsal'),
(456785678, 27, 'Jogador de padel aos fins de semana');

-- ========================
-- ARRENDADORES
-- ========================
INSERT INTO Arrendador (ID_Arrendador, IBAN, No_Campos) VALUES
(456783456, 'PT500002012334567890154', 2);

-- ========================
-- IMAGENS E PERFIL
-- ========================
INSERT INTO Imagem ([URL]) VALUES
('https://cdn-icons-png.flaticon.com/512/2906/2906401.png'),
('https://cdn-icons-png.flaticon.com/128/2000/2000176.png'),
('https://cdn-icons-png.flaticon.com/128/3000/3000981.png');

INSERT INTO IMG_Perfil (ID_Utilizador, [URL]) VALUES
(456781234, 'https://cdn-icons-png.flaticon.com/512/2906/2906401.png'),
(456782345, 'https://cdn-icons-png.flaticon.com/128/2000/2000176.png'),
(456783456, 'https://cdn-icons-png.flaticon.com/512/2906/2906401.png'),
(456784567, 'https://cdn-icons-png.flaticon.com/128/3000/3000981.png');

-- ========================
-- MAPA E PONTO
-- ========================
INSERT INTO Mapa (ID) VALUES (1);

INSERT INTO Ponto (ID, ID_Mapa, Latitude, Longitude) VALUES
(890112345, 1, 38.7169, -9.1399),
(890112346, 1, 38.7133, -9.1370);

-- ========================
-- CAMPOS
-- ========================
INSERT INTO Campo (ID, ID_Ponto, ID_Mapa, Nome, Endereco, Comprimento, Largura, ocupado, Descricao) VALUES
(789012345, 890112345, 1, 'Campo Futebol Central', 'Rua do Campo, Lisboa', 100.0, 60.0, 0, 'Campo em excelentes condições'),
(789012346, 890112346, 1, 'Campo Voleibol LX', 'Av. das Quadras, Lisboa', 50.0, 30.0, 0, 'Ideal para voleibol amador');

INSERT INTO Campo_Priv (ID_Campo, ID_Arrendador) VALUES
(789012345, 456783456),
(789012346, 456783456);

-- ========================
-- DIAS DA SEMANA
-- ========================
INSERT INTO Dias_semana (ID, Nome) VALUES
(1, 'Domingo'),
(2, 'Segunda'),
(3, 'Terça'),
(4, 'Quarta'),
(5, 'Quinta'),
(6, 'Sexta'),
(7, 'Sábado');

-- ========================
-- DISPONIBILIDADE
-- ========================
INSERT INTO Disponibilidade (ID_Campo, ID_dia, Preco, Hora_abertura, Hora_fecho) VALUES
(789012345, 2, 30.00, '09:00', '18:00'),
(789012346, 3, 20.00, '10:00', '17:00');

-- ========================
-- DESPORTOS E ASSOCIAÇÕES
-- ========================

INSERT INTO Desporto (ID, Nome) VALUES
(1, 'Futebol'),
(2, 'Fustal'),
(3, 'Basquetebol'),
(4, 'Voleibol'),
(5, 'Ténis'),
(6, 'Andebol');

INSERT INTO Desporto_Jogador (ID_Jogador, ID_Desporto) VALUES
(456781234, 1),
(456782345, 2),
(456784567, 1),
(456785678, 3);

INSERT INTO Desporto_Campo (ID_Desporto, ID_Campo) VALUES
(1, 789012345),
(2, 789012346);

-- ========================
-- PARTIDAS E JOGADORES
-- ========================
INSERT INTO Partida (ID, ID_Campo, no_jogadores, Data_Hora, Duracao, Resultado) VALUES
(678901234, 789012345, 10, '2025-05-07 15:00', 90, '5-3'),
(678901235, 789012346, 6, '2025-05-09 16:30', 60, '2-2');

INSERT INTO Jogador_joga (ID_Partida, ID_Jogador) VALUES
(678901234, 456781234),
(678901234, 456782345),
(678901234, 456784567),
(678901235, 456782345),
(678901235, 456785678);

-- ========================
-- RESERVAS
-- ========================
INSERT INTO Reserva (ID, ID_Campo, ID_Jogador, [Data], Hora_Inicio, Hora_Fim, Descricao) VALUES
(1, 789012345, 456781234, '2025-05-08', '10:00', '11:30', 'Reserva treino semanal'),
(2, 789012346, 456785678, '2025-05-09', '16:00', '17:30', 'Jogo com amigos');

-- ========================
-- RATINGS
-- ========================
INSERT INTO Rating (ID_Avaliador, Data_Hora, Comentario, Avaliacao) VALUES
(456781234, '2025-05-06 12:00', 'Muito bom campo!', 5),
(456782345, '2025-05-06 14:00', 'Campo em boas condições.', 4),
(456785678, '2025-05-07 18:00', 'Espaço limpo e bem localizado.', 5);

INSERT INTO Rating_Campo (ID_Avaliador, ID_Campo) VALUES
(456781234, 789012345),
(456782345, 789012345),
(456785678, 789012346);

-- ========================
-- RATING ENTRE JOGADORES
-- ========================
INSERT INTO Rating_Jogador (ID_Jogador, ID_Avaliador) VALUES
(456782345, 456781234),
(456785678, 456782345);

-- ========================
-- AMIZADES
-- ========================
INSERT INTO Jogador_Amizade (ID_J1, ID_J2) VALUES
(456781234, 456782345),
(456784567, 456785678);

-- ========================
-- MÉTODOS DE PAGAMENTO
-- ========================
INSERT INTO Met_Paga_Arrendador (ID_Arrendador, Met_pagamento) VALUES
(456783456, 'MBWay'),
(456783456, 'PayPal'),
(456783456, 'Transferência Bancária');

-- ========================
-- CHAT LIVE
-- ========================
INSERT INTO Chat_Live (ID_Partida, Titulo) VALUES
(678901234, 'Futebol de Quinta à Tarde'),
(678901235, 'Voleibol Sexta no LX');
