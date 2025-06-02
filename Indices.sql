USE SPORTSLINK;
GO

-- Índices para Utilizador
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_utilizador_email' AND object_id = OBJECT_ID('Utilizador'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_utilizador_email ON Utilizador (Email) WITH (FILLFACTOR = 85);
END
GO

-- Índice para Arrendador
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_arrendador_iban' AND object_id = OBJECT_ID('Arrendador'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_arrendador_iban ON Arrendador (IBAN) WITH (FILLFACTOR = 85);
END
GO

-- Índices para Campo
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_campo_nome' AND object_id = OBJECT_ID('Campo'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_campo_nome ON Campo (Nome) WITH (FILLFACTOR = 85);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_campo_id_ponto' AND object_id = OBJECT_ID('Campo'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_campo_comprimento ON Campo (Comprimento) WITH (FILLFACTOR = 85);
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_campo_largura' AND object_id = OBJECT_ID('Campo'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_campo_largura ON Campo (Largura) WITH (FILLFACTOR = 85);
END

-- Índice para Campo_Priv
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_campo_priv_id_arrendador' AND object_id = OBJECT_ID('Campo_Priv'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_campo_priv_id_arrendador ON Campo_Priv (ID_Arrendador) WITH (FILLFACTOR = 85);
END
GO

-- Índices para Partida
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_partida_campo_data_hora' AND object_id = OBJECT_ID('Partida'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_partida_campo_data_hora ON Partida (ID_Campo, Data_Hora) WITH (FILLFACTOR = 85);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_partida_estado' AND object_id = OBJECT_ID('Partida'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_partida_estado ON Partida (Estado) WITH (FILLFACTOR = 85);
END
GO

-- Índice para Jogador_joga
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_jogador_joga_id_jogador' AND object_id = OBJECT_ID('Jogador_joga'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_jogador_joga_id_jogador ON Jogador_joga (ID_Jogador) WITH (FILLFACTOR = 85);
END
GO

-- Índices para Reserva
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_reserva_campo_data' AND object_id = OBJECT_ID('Reserva'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_reserva_campo_data ON Reserva (ID_Campo, [Data]) WITH (FILLFACTOR = 85);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_reserva_jogador' AND object_id = OBJECT_ID('Reserva'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_reserva_jogador ON Reserva (ID_Jogador) WITH (FILLFACTOR = 85);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_reserva_estado' AND object_id = OBJECT_ID('Reserva'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_reserva_estado ON Reserva (Estado) WITH (FILLFACTOR = 85);
END
GO

-- Índice para Desporto_Campo
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_desporto_campo_id_campo' AND object_id = OBJECT_ID('Desporto_Campo'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_desporto_campo_id_campo ON Desporto_Campo (ID_Campo) WITH (FILLFACTOR = 85);
END
GO

-- Índices para Desporto_Jogador
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_desporto_jogador_id_jogador' AND object_id = OBJECT_ID('Desporto_Jogador'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_desporto_jogador_id_jogador ON Desporto_Jogador (ID_Jogador) WITH (FILLFACTOR = 85);
END

-- Índices para Disponibilidade
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_disponibilidade_preco' AND object_id = OBJECT_ID('Disponibilidade'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_disponibilidade_preco ON Disponibilidade (Preco) WITH (FILLFACTOR = 85);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_disponibilidade_id_campo' AND object_id = OBJECT_ID('Disponibilidade'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_disponibilidade_id_campo ON Disponibilidade (ID_Campo) WITH (FILLFACTOR = 85);
END
GO