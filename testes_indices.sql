USE SPORTSLINK;
GO

-- Ativar estatísticas de tempo e I/O
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

-- 1. Teste para idx_utilizador_email
PRINT 'Teste idx_utilizador_email';
-- Com índice
SELECT * FROM Utilizador WHERE Email = 'exemplo@dominio.com';
GO
-- Desativar índice
ALTER INDEX idx_utilizador_email ON Utilizador DISABLE;
GO
-- Sem índice
SELECT * FROM Utilizador WHERE Email = 'exemplo@dominio.com';
GO
-- Reativar índice
ALTER INDEX idx_utilizador_email ON Utilizador REBUILD;
GO

-- 2. Teste para idx_utilizador_num_tele
PRINT 'Teste idx_utilizador_num_tele';
SELECT * FROM Utilizador WHERE Num_Tele = '123456789';
GO
ALTER INDEX idx_utilizador_num_tele ON Utilizador DISABLE;
GO
SELECT * FROM Utilizador WHERE Num_Tele = '123456789';
GO
ALTER INDEX idx_utilizador_num_tele ON Utilizador REBUILD;
GO

-- 3. Teste para idx_jogador_data_nascimento
PRINT 'Teste idx_jogador_data_nascimento';
SELECT * FROM Jogador WHERE Data_Nascimento BETWEEN '1990-01-01' AND '2000-12-31';
GO
ALTER INDEX idx_jogador_data_nascimento ON Jogador DISABLE;
GO
SELECT * FROM Jogador WHERE Data_Nascimento BETWEEN '1990-01-01' AND '2000-12-31';
GO
ALTER INDEX idx_jogador_data_nascimento ON Jogador REBUILD;
GO

-- 4. Teste para idx_arrendador_iban
PRINT 'Teste idx_arrendador_iban';
SELECT * FROM Arrendador WHERE IBAN = 'PT50XXXXXXXXXXXXXXXXXXXX';
GO
ALTER INDEX idx_arrendador_iban ON Arrendador DISABLE;
GO
SELECT * FROM Arrendador WHERE IBAN = 'PT50XXXXXXXXXXXXXXXXXXXX';
GO
ALTER INDEX idx_arrendador_iban ON Arrendador REBUILD;
GO

-- 5. Teste para idx_campo_nome
PRINT 'Teste idx_campo_nome';
SELECT * FROM Campo WHERE Nome LIKE 'Campo%';
GO
ALTER INDEX idx_campo_nome ON Campo DISABLE;
GO
SELECT * FROM Campo WHERE Nome LIKE 'Campo%';
GO
ALTER INDEX idx_campo_nome ON Campo REBUILD;
GO

-- 6. Teste para idx_campo_id_ponto_mapa
PRINT 'Teste idx_campo_id_ponto_mapa';
SELECT * FROM Campo WHERE ID_Ponto = 123 AND ID_Mapa = 456;
GO
ALTER INDEX idx_campo_id_ponto_mapa ON Campo DISABLE;
GO
SELECT * FROM Campo WHERE ID_Ponto = 123 AND ID_Mapa = 456;
GO
ALTER INDEX idx_campo_id_ponto_mapa ON Campo REBUILD;
GO

-- 7. Teste para idx_campo_ocupado
PRINT 'Teste idx_campo_ocupado';
SELECT * FROM Campo WHERE ocupado = 1;
GO
ALTER INDEX idx_campo_ocupado ON Campo DISABLE;
GO
SELECT * FROM Campo WHERE ocupado = 1;
GO
ALTER INDEX idx_campo_ocupado ON Campo REBUILD;
GO

-- 8. Teste para idx_campo_priv_id_arrendador
PRINT 'Teste idx_campo_priv_id_arrendador';
SELECT cp.* FROM Campo_Priv cp
JOIN Arrendador a ON cp.ID_Arrendador = a.ID_Arrendador
WHERE a.ID_Arrendador = 789;
GO
ALTER INDEX idx_campo_priv_id_arrendador ON Campo_Priv DISABLE;
GO
SELECT cp.* FROM Campo_Priv cp
JOIN Arrendador a ON cp.ID_Arrendador = a.ID_Arrendador
WHERE a.ID_Arrendador = 789;
GO
ALTER INDEX idx_campo_priv_id_arrendador ON Campo_Priv REBUILD;
GO

-- 9. Teste para idx_partida_campo_data_hora
PRINT 'Teste idx_partida_campo_data_hora';
SELECT * FROM Partida
WHERE ID_Campo = 123
AND Data_Hora BETWEEN '2025-06-01 00:00:00' AND '2025-06-30 23:59:59';
GO
ALTER INDEX idx_partida_campo_data_hora ON Partida DISABLE;
GO
SELECT * FROM Partida
WHERE ID_Campo = 123
AND Data_Hora BETWEEN '2025-06-01 00:00:00' AND '2025-06-30 23:59:59';
GO
ALTER INDEX idx_partida_campo_data_hora ON Partida REBUILD;
GO

-- 10. Teste para idx_partida_estado
PRINT 'Teste idx_partida_estado';
SELECT * FROM Partida WHERE Estado = 'Agendada';
GO
ALTER INDEX idx_partida_estado ON Partida DISABLE;
GO
SELECT * FROM Partida WHERE Estado = 'Agendada';
GO
ALTER INDEX idx_partida_estado ON Partida REBUILD;
GO

-- 11. Teste para idx_jogador_joga_id_jogador
PRINT 'Teste idx_jogador_joga_id_jogador';
SELECT jj.* FROM Jogador_joga jj
JOIN Partida p ON jj.ID_Partida = p.ID_Partida
WHERE jj.ID_Jogador = 456;
GO
ALTER INDEX idx_jogador_joga_id_jogador ON Jogador_joga DISABLE;
GO
SELECT jj.* FROM Jogador_joga jj
JOIN Partida p ON jj.ID_Partida = p.ID_Partida
WHERE jj.ID_Jogador = 456;
GO
ALTER INDEX idx_jogador_joga_id_jogador ON Jogador_joga REBUILD;
GO

-- 12. Teste para idx_reserva_campo_data
PRINT 'Teste idx_reserva_campo_data';
SELECT * FROM Reserva
WHERE ID_Campo = 123 AND Data = '2025-06-01';
GO
ALTER INDEX idx_reserva_campo_data ON Reserva DISABLE;
GO
SELECT * FROM Reserva
WHERE ID_Campo = 123 AND Data = '2025-06-01';
GO
ALTER INDEX idx_reserva_campo_data ON Reserva REBUILD;
GO

-- 13. Teste para idx_reserva_jogador
PRINT 'Teste idx_reserva_jogador';
SELECT * FROM Reserva WHERE ID_Jogador = 456;
GO
ALTER INDEX idx_reserva_jogador ON Reserva DISABLE;
GO
SELECT * FROM Reserva WHERE ID_Jogador = 456;
GO
ALTER INDEX idx_reserva_jogador ON Reserva REBUILD;
GO

-- 14. Teste para idx_reserva_estado
PRINT 'Teste idx_reserva_estado';
SELECT * FROM Reserva WHERE Estado = 'Confirmada';
GO
ALTER INDEX idx_reserva_estado ON Reserva DISABLE;
GO
SELECT * FROM Reserva WHERE Estado = 'Confirmada';
GO
ALTER INDEX idx_reserva_estado ON Reserva REBUILD;
GO

-- 15. Teste para idx_desporto_nome
PRINT 'Teste idx_desporto_nome';
SELECT * FROM Desporto WHERE Nome = 'Futebol';
GO
ALTER INDEX idx_desporto_nome ON Desporto DISABLE;
GO
SELECT * FROM Desporto WHERE Nome = 'Futebol';
GO
ALTER INDEX idx_desporto_nome ON Desporto REBUILD;
GO

-- 16. Teste para idx_desporto_campo_id_campo
PRINT 'Teste idx_desporto_campo_id_campo';
SELECT dc.* FROM Desporto_Campo dc
JOIN Campo c ON dc.ID_Campo = c.ID_Campo
WHERE dc.ID_Campo = 123;
GO
ALTER INDEX idx_desporto_campo_id_campo ON Desporto_Campo DISABLE;
GO
SELECT dc.* FROM Desporto_Campo dc
JOIN Campo c ON dc.ID_Campo = c.ID_Campo
WHERE dc.ID_Campo = 123;
GO
ALTER INDEX idx_desporto_campo_id_campo ON Desporto_Campo REBUILD;
GO

-- Teste de Inserção (para avaliar overhead dos índices)
PRINT 'Teste de Inserção em Utilizador';
-- Com índices
INSERT INTO Utilizador (Email, Num_Tele, Nome) VALUES ('teste@dominio.com', '987654321', 'Teste User');
GO
-- Desativar índices
ALTER INDEX idx_utilizador_email ON Utilizador DISABLE;
ALTER INDEX idx_utilizador_num_tele ON Utilizador DISABLE;
GO
-- Sem índices
INSERT INTO Utilizador (Email, Num_Tele, Nome) VALUES ('teste2@dominio.com', '987654322', 'Teste User 2');
GO
-- Reativar índices
ALTER INDEX idx_utilizador_email ON Utilizador REBUILD;
ALTER INDEX idx_utilizador_num_tele ON Utilizador REBUILD;
GO

-- Verificar fragmentação dos índices
PRINT 'Fragmentação dos Índices';
SELECT 
    index_id,
    index_type_desc,
    avg_fragmentation_in_percent,
    page_count,
    avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID('SPORTSLINK'), NULL, NULL, NULL, 'DETAILED');
GO

-- Verificar seletividade dos índices
PRINT 'Seletividade idx_utilizador_email';
DBCC SHOW_STATISTICS (Utilizador, idx_utilizador_email);
GO
PRINT 'Seletividade idx_partida_campo_data_hora';
DBCC SHOW_STATISTICS (Partida, idx_partida_campo_data_hora);
GO
PRINT 'Seletividade idx_reserva_campo_data';
DBCC SHOW_STATISTICS (Reserva, idx_reserva_campo_data);
GO

-- Desfragmentar índices (se necessário)
PRINT 'Desfragmentação de Índices';
ALTER INDEX ALL ON Utilizador REORGANIZE;
ALTER INDEX ALL ON Partida REORGANIZE;
ALTER INDEX ALL ON Reserva REORGANIZE;
GO