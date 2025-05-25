USE SPORTSLINK;
GO

-- View para obter os detalhes de uma partida
CREATE OR ALTER VIEW vw_PartidaDetalhes AS
SELECT 
  p.ID AS ID_Partida,
  p.ID_Campo,
  c.Nome AS Nome_Campo,
  p.Data_Hora,
  p.Duracao,
  p.Resultado,
  p.Estado,
  p.no_jogadores,
  (
    SELECT STRING_AGG(Nome, ', ') 
    FROM (
      SELECT DISTINCT u2.Nome
      FROM Jogador_joga jj2
      JOIN Jogador j2 ON jj2.ID_Jogador = j2.ID
      JOIN Utilizador u2 ON j2.ID = u2.ID
      WHERE jj2.ID_Partida = p.ID
    ) AS Sub
  ) AS Jogadores
FROM Partida p
LEFT JOIN Campo c ON p.ID_Campo = c.ID;
GO

-- View para obter os detalhes de um campo
CREATE OR ALTER VIEW vw_CampoPrivDetalhes AS
SELECT 
  c.ID AS ID_Campo,
  c.Nome AS Nome_Campo,
  c.Comprimento,
  c.Largura,
  c.Endereco,
  p.Latitude,
  p.Longitude,
  c.Descricao,
  
  -- Subquery agregada para Dias Disponíveis
  (SELECT STRING_AGG(DISTINCT di.Nome, ', ')
   FROM Disponibilidade dp2
   JOIN Dias_semana di ON dp2.ID_Dia = di.ID
   WHERE dp2.ID_Campo = c.ID) AS Dias_Disponiveis,

  -- Assume que o campo tem sempre uma linha de disponibilidade
  (SELECT TOP 1 dp.Preco
   FROM Disponibilidade dp
   WHERE dp.ID_Campo = c.ID) AS Preco,

  (SELECT TOP 1 dp.Hora_Abertura
   FROM Disponibilidade dp
   WHERE dp.ID_Campo = c.ID) AS Hora_Abertura,

  (SELECT TOP 1 dp.Hora_Fecho
   FROM Disponibilidade dp
   WHERE dp.ID_Campo = c.ID) AS Hora_Fecho,

  -- Subquery de imagens agregadas
  (SELECT STRING_AGG(DISTINCT img.URL, ', ')
   FROM IMG_Campo ic
   JOIN Imagem img ON img.ID = ic.ID_img
   WHERE ic.ID_Campo = c.ID) AS Imagens

FROM Campo c
LEFT JOIN Ponto p ON c.ID_Ponto = p.ID;
GO


-- View para obter os detalhes de um utilizador (Arrendador ou Jogador)
ALTER VIEW vw_InfoUtilizador AS
WITH Metodos_Pagamento_Unicos AS (
    SELECT DISTINCT ID_Arrendador, Met_pagamento
    FROM Met_Paga_Arrendador
),
Imagens_Unicas AS (
    SELECT DISTINCT ip.ID_Utilizador, i.URL
    FROM IMG_Perfil ip
    JOIN Imagem i ON ip.ID_img = i.ID
),
Desportos_Unicos AS (
    SELECT DISTINCT dj.ID_Jogador, d.Nome
    FROM Desporto_Jogador dj
    JOIN Desporto d ON dj.ID_Desporto = d.ID
)
SELECT 
  u.ID AS ID_Utilizador,
  u.Nome,
  u.Email,
  u.Num_Tele,
  u.Nacionalidade,
  j.Idade,
  j.Data_Nascimento,
  j.Descricao AS DescricaoJogador,
  j.Peso,
  j.Altura,
  a.IBAN,
  a.No_Campos,
  -- Aqui o STRING_AGG agora funciona com dados já distintos
  (SELECT STRING_AGG(mp.Met_pagamento, ', ') 
   FROM Metodos_Pagamento_Unicos mp 
   WHERE mp.ID_Arrendador = u.ID) AS Metodos_Pagamento,
  (SELECT STRING_AGG(img.URL, ', ') 
   FROM Imagens_Unicas img 
   WHERE img.ID_Utilizador = u.ID) AS Imagens_Perfil,
  (SELECT STRING_AGG(ds.Nome, ', ') 
   FROM Desportos_Unicos ds 
   WHERE ds.ID_Jogador = u.ID) AS Desportos_Favoritos,
  CASE 
    WHEN a.ID_Arrendador IS NOT NULL THEN 'Arrendador'
    ELSE 'Jogador'
  END AS Tipo
FROM Utilizador u
LEFT JOIN Jogador j ON u.ID = j.ID
LEFT JOIN Arrendador a ON u.ID = a.ID_Arrendador;

-- View para obter os detalhes das reservas
CREATE OR ALTER VIEW vw_ReservasDetalhadas AS
SELECT
  r.ID,
  r.ID_Campo,
  c.Nome AS Nome_Campo,
  r.ID_Jogador,
  u.Nome AS Nome_Jogador,
  u.Nacionalidade,
  u.Num_Tele,
  r.[Data],
  r.Hora_Inicio,
  r.Hora_Fim,
  r.Total_Pagamento,
  r.Estado,
  r.Descricao,
  di.Preco,
  di.ID_Dia
FROM Reserva r
JOIN Campo c ON r.ID_Campo = c.ID
JOIN Jogador j ON r.ID_Jogador = j.ID
JOIN Utilizador u ON j.ID = u.ID
JOIN Disponibilidade di ON r.ID_Campo = di.ID_Campo
  AND di.ID_Dia = DATEPART(WEEKDAY, r.[Data]);
GO

-- View para obter as reservas futuras
CREATE VIEW vw_ReservasFuturas AS
SELECT *
FROM vw_ReservasDetalhadas
WHERE [Data] >= CAST(GETDATE() AS DATE);
GO