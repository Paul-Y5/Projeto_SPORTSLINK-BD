-- Índices para a tabela Reserva
-- Ajuda em consultas que filtram reservas por campo e data, como verificar disponibilidade
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_reserva_campo_data' AND object_id = OBJECT_ID('Reserva'))
BEGIN
    CREATE INDEX idx_reserva_campo_data ON Reserva (ID_Campo, Data);
END

-- Otimiza buscas por reservas de um jogador específico, comum em dashboards de usuário
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_reserva_jogador' AND object_id = OBJECT_ID('Reserva'))
BEGIN
    CREATE INDEX idx_reserva_jogador ON Reserva (ID_Jogador);
END

-- Índice para a tabela Partida
-- Facilita listar partidas de um campo ordenadas por data e hora, útil para agendamentos
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_partida_campo_data_hora' AND object_id = OBJECT_ID('Partida'))
BEGIN
    CREATE INDEX idx_partida_campo_data_hora ON Partida (ID_Campo, Data_Hora);
END

-- Índice para a tabela Campo
-- Facilita buscas por nome de campo, comum em interfaces de usuário
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_campo_nome' AND object_id = OBJECT_ID('Campo'))
BEGIN
    CREATE INDEX idx_campo_nome ON Campo (Nome);
END

-- Índice para a tabela Disponibilidade
-- Ajuda em consultas que listam disponibilidade por campo
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_disponibilidade_campo' AND object_id = OBJECT_ID('Disponibilidade'))
BEGIN
    CREATE INDEX idx_disponibilidade_campo ON Disponibilidade (ID_Campo);
END

-- Opcional: Índice para a tabela Utilizador
-- Útil para buscas por nome, se frequentes
-- IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_utilizador_nome' AND object_id = OBJECT_ID('Utilizador'))
-- BEGIN
--     CREATE INDEX idx_utilizador_nome ON Utilizador (Nome);
-- END

-- Opcional: Índice para a tabela Jogador
-- Para consultas que filtram por data de nascimento
-- IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_jogador_data_nascimento' AND object_id = OBJECT_ID('Jogador'))
-- BEGIN
--     CREATE INDEX idx_jogador_data_nascimento ON Jogador (Data_Nascimento);
-- END