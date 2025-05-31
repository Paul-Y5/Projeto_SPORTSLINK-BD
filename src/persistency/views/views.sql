USE SPORTSLINK;
GO


-- View para Campo Publico
CREATE OR ALTER VIEW vw_CampoPublico AS
SELECT 
  c.ID AS ID_Campo,
  c.Nome AS Nome_Campo,
  c.Comprimento,
  c.Largura,
  c.Endereco,
  p.Latitude,
  p.Longitude,
  c.Descricao,

  -- Desportos com DISTINCT
  des.Desportos,

  -- Imagens com DISTINCT
  img.Imagens

FROM Campo c
LEFT JOIN Campo_Pub cp ON c.ID = cp.ID_Campo
JOIN Ponto p ON p.ID = c.ID_Ponto

CROSS APPLY (
  SELECT STRING_AGG(d.Nome, ', ') AS Desportos
  FROM (
    SELECT DISTINCT d.Nome
    FROM Desporto_Campo dc
    JOIN Desporto d ON d.ID = dc.ID_Desporto
    WHERE dc.ID_Campo = c.ID
  ) AS d
) des

CROSS APPLY (
  SELECT STRING_AGG(img.URL, ', ') AS Imagens
  FROM (
    SELECT DISTINCT img.URL
    FROM IMG_Campo ic
    JOIN Imagem img ON img.ID = ic.ID_img
    WHERE ic.ID_Campo = c.ID
  ) AS img
) img
WHERE c.ID=cp.ID_Campo
GO

-- View para obter os detalhes de um campo, incluindo disponibilidade e imagens
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

  -- Dias Disponíveis (sem DISTINCT no STRING_AGG)
  (
    SELECT STRING_AGG(Nome, ', ')
    FROM (
      SELECT DISTINCT di.Nome
      FROM Disponibilidade dp2
      JOIN Dias_semana di ON dp2.ID_Dia = di.ID
      WHERE dp2.ID_Campo = c.ID
    ) AS Dias_Distintos
  ) AS Dias_Disponiveis,

  -- Preço
  (SELECT TOP 1 dp.Preco
   FROM Disponibilidade dp
   WHERE dp.ID_Campo = c.ID) AS Preco,

  -- Hora Abertura
  (SELECT TOP 1 dp.Hora_Abertura
   FROM Disponibilidade dp
   WHERE dp.ID_Campo = c.ID) AS Hora_Abertura,

  -- Hora Fecho
  (SELECT TOP 1 dp.Hora_Fecho
   FROM Disponibilidade dp
   WHERE dp.ID_Campo = c.ID) AS Hora_Fecho,

  -- Imagens (sem DISTINCT no STRING_AGG)
  (
    SELECT STRING_AGG(URL, ', ')
    FROM (
      SELECT DISTINCT img.URL
      FROM IMG_Campo ic
      JOIN Imagem img ON img.ID = ic.ID_img
      WHERE ic.ID_Campo = c.ID
    ) AS Imagens_Distintas
  ) AS Imagens

FROM Campo c
LEFT JOIN Ponto p ON c.ID_Ponto = p.ID;
GO


-- View para obter os detalhes de um utilizador (Arrendador ou Jogador)
CREATE VIEW vw_InfoUtilizador AS
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

  -- Métodos de Pagamento com Detalhes (apenas para arrendadores)
  (
    SELECT STRING_AGG(mp.Metodo + ': ' + mp.Detalhes, CHAR(10))
    FROM dbo.fn_GetMetodosPagamentoDetalhes(u.ID) mp
    WHERE EXISTS (
        SELECT 1 FROM Arrendador as a2 WHERE a2.ID_Arrendador = u.ID
    )
  ) AS Metodos_Pagamento,

  -- Imagens de Perfil
  (
    SELECT STRING_AGG(img.URL, ', ') 
    FROM Imagens_Unicas as img 
    WHERE img.ID_Utilizador = u.ID
  ) AS Imagens_Perfil,

  -- Desportos Favoritos
  (
    SELECT STRING_AGG(ds.Nome, ', ') 
    FROM Desportos_Unicos as ds 
    WHERE ds.ID_Jogador = u.ID
  ) AS Desportos_Favoritos,

  -- Tipo de Utilizador
  CASE 
    WHEN a.ID_Arrendador IS NOT NULL THEN 'Arrendador'
    ELSE 'Jogador'
  END AS Tipo

FROM Utilizador u
LEFT JOIN Jogador j ON u.ID = j.ID
LEFT JOIN Arrendador a ON u.ID = a.ID_Arrendador;
GO


-- View para obter informações detalhadas de um utilizador, incluindo desportos favoritos e imagens de perfil
CREATE OR ALTER VIEW vw_InfoAmigo AS
WITH Imagens_Unicas AS (
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
  u.Nacionalidade,
  j.Idade,
  j.Data_Nascimento,
  j.Descricao AS DescricaoJogador,
  j.Peso,
  j.Altura,
  (SELECT STRING_AGG(ds.Nome, ', ')
   FROM Desportos_Unicos ds 
   WHERE ds.ID_Jogador = u.ID) AS Desportos_Favoritos,
  (SELECT STRING_AGG(img.URL, ', ') 
   FROM Imagens_Unicas img 
   WHERE img.ID_Utilizador = u.ID) AS Imagens_Perfil
FROM Utilizador u
LEFT JOIN Jogador j ON u.ID = j.ID;
GO

-- View para obter os detalhes das reservas
CREATE OR ALTER VIEW vw_ReservasDetalhadas AS
SELECT
  r.ID,
  u.ID AS ID_Utilizador,
  r.ID_Campo,
  c.Nome AS Nome_Campo,
  r.ID_Jogador,
  u.Nome AS Nome_Jogador,
  r.[Data],
  r.Hora_Inicio,
  r.Hora_Fim,
  r.Total_Pagamento,
  r.Estado,
  r.Descricao
FROM Reserva r
JOIN Campo c ON r.ID_Campo = c.ID
JOIN Jogador j ON r.ID_Jogador = j.ID
JOIN Utilizador u ON j.ID = u.ID
LEFT JOIN Disponibilidade di ON r.ID_Campo = di.ID_Campo
  AND di.ID_Dia = DATEPART(WEEKDAY, r.[Data]);
GO

-- View para obter as reservas futuras
CREATE VIEW vw_ReservasFuturas AS
SELECT *
FROM vw_ReservasDetalhadas
WHERE [Data] >= CAST(GETDATE() AS DATE);
GO

-- View para ver campos disponíveis
CREATE OR ALTER VIEW vw_CamposDisponiveis AS
SELECT 
    c.ID, 
    i.[URL], 
    c.Nome, 
    c.Largura, 
    c.Comprimento, 
    c.Endereco, 
    p.Latitude, 
    p.Longitude,
    dias.Dias_Disponiveis, 
    desportos.Desportos,
    part_agg.Partidas_Ativas,
	  cp.ID_Arrendador,
    u.Nome AS Nome_Arrendador,
    CASE 
        WHEN c.Ocupado = 1 THEN 'Sim' 
        ELSE 'Não' 
    END AS Ocupado,
    CASE 
        WHEN cp.ID_Campo IS NOT NULL THEN 'Privado' 
        ELSE 'Publico' 
    END AS Tipo
FROM Campo AS c
JOIN Ponto AS p ON c.ID_Ponto = p.ID
LEFT JOIN Campo_Priv AS cp ON c.ID = cp.ID_Campo
LEFT JOIN Utilizador AS u ON u.ID = cp.ID_Arrendador
LEFT JOIN (
    SELECT 
        d.ID_Campo, 
        STRING_AGG(di.Nome, ', ') AS Dias_Disponiveis
    FROM Disponibilidade AS d
    JOIN Dias_semana AS di ON d.ID_Dia = di.ID
    GROUP BY d.ID_Campo
) AS dias ON dias.ID_Campo = c.ID
LEFT JOIN (
    SELECT 
        dc.ID_Campo, 
        STRING_AGG(desp.Nome, ', ') AS Desportos
    FROM Desporto_Campo AS dc
    JOIN Desporto AS desp ON desp.ID = dc.ID_Desporto
    GROUP BY dc.ID_Campo
) AS desportos ON desportos.ID_Campo = c.ID
LEFT JOIN IMG_Campo AS img ON img.ID_Campo = c.ID
LEFT JOIN Imagem AS i ON i.ID = img.ID_Img
LEFT JOIN (
    SELECT 
        ID_Campo, 
        STRING_AGG(CAST(ID AS VARCHAR), ',') AS Partidas_Ativas
    FROM Partida
    WHERE Estado IN ('Aguardando', 'Decorrer')
    GROUP BY ID_Campo
) AS part_agg ON part_agg.ID_Campo = c.ID;
GO


-- View para obter os detalhes das partidas, incluindo id de jogadores
CREATE OR ALTER VIEW vw_PartidaDetalhes AS
SELECT 
	p.ID AS ID_Partida,
	p.ID_Campo,
	c.Nome_Campo,
	c.Comprimento,
	c.Largura,
	c.Latitude,
	c.Longitude,
	c.Endereco,
	c.Descricao,
	p.Data_Hora,
	p.Duracao,
	p.Resultado,
	p.Estado,
	p.no_jogadores,
	i.[URL],
	(SELECT STRING_AGG(CAST(jj.ID_Jogador AS VARCHAR(10)), ', ')
    FROM Jogador_joga jj
	WHERE jj.ID_Partida = p.ID) AS Jogadores_IDs,
  dbo.udf_GetMaxJogadores(p.ID_Campo) AS Max_Jogadores
FROM Partida p
LEFT JOIN vw_CampoPublico as c ON p.ID_Campo = c.ID_Campo
LEFT JOIN IMG_Campo as ci on ci.ID_Campo=c.ID_Campo
JOIN Imagem as i on i.ID=ci.ID_img
WHERE p.ID_Campo = c.ID_Campo
GO