USE SPORTSLINK;
GO

-- View para obter os detalhes de uma partida
CREATE VIEW vw_PartidaDetalhes AS
SELECT 
  p.ID AS ID_Partida,
  p.ID_Campo,
  c.Nome AS Nome_Campo,
  p.Data_Hora,
  p.Duracao,
  p.Resultado,
  p.Estado,
  p.no_jogadores,
  STRING_AGG(u.Nome, ', ') AS Jogadores
FROM Partida p
LEFT JOIN Campo c ON p.ID_Campo = c.ID
LEFT JOIN Jogador_joga jj ON p.ID = jj.ID_Partida
LEFT JOIN Jogador j ON jj.ID_Jogador = j.ID
LEFT JOIN Utilizador u ON j.ID = u.ID
GROUP BY p.ID, p.ID_Campo, c.Nome, p.Data_Hora, p.Duracao, p.Resultado, p.Estado, p.no_jogadores;
GO

-- View para obter os detalhes de um campo
CREATE VIEW vw_CampoPrivDetalhes AS
SELECT 
  c.ID AS ID_Campo,
  c.Nome AS Nome_Campo,
  c.Comprimento,
  c.Largura,
  c.Endereco,
  p.Latitude,
  p.Longitude,
  c.Descricao,
  STRING_AGG(di.Nome, ', ') AS Dias_Disponiveis,
  dp.Preco,
    dp.Hora_Abertura,
    dp.Hora_Fecho,
    STRING_AGG(img.[URL], ', ') AS Imagens
FROM Campo c
LEFT JOIN Ponto p ON c.ID_Ponto = p.ID
LEFT JOIN Disponibilidade dp ON c.ID = dp.ID_Campo
LEFT JOIN Dias_semana di ON dp.ID_Dia = di.ID
LEFT JOIN IMG_Campo i ON c.ID = i.ID_Campo
INNER JOIN Imagem as img on img.ID = i.ID_img
GROUP BY c.ID, c.Nome, c.Comprimento, c.Largura, c.Endereco, p.Latitude, p.Longitude, c.Descricao, dp.Preco, dp.Hora_Abertura, dp.Hora_Fecho;
GO

-- View para obter os detalhes de um utilizador (Arrendador ou Jogador)
CREATE VIEW vw_InfoUtilizador AS
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
  STRING_AGG(mpa.Met_pagamento, ', ') AS Metodos_Pagamento,
  STRING_AGG(i.URL, ', ') AS Imagens_Perfil,
  STRING_AGG(d.Nome, ', ') AS Desportos_Favoritos,
  CASE 
    WHEN a.ID_Arrendador IS NOT NULL THEN 'Arrendador'
    ELSE 'Jogador'
  END AS Tipo
FROM Utilizador u
LEFT JOIN Jogador j ON u.ID = j.ID
LEFT JOIN Arrendador a ON u.ID = a.ID_Arrendador
LEFT JOIN Met_Paga_Arrendador mpa ON u.ID = mpa.ID_Arrendador
LEFT JOIN IMG_Perfil ip ON u.ID = ip.ID_Utilizador
LEFT JOIN Imagem i ON ip.ID_img = i.ID
LEFT JOIN Desporto_Jogador dj ON u.ID = dj.ID_Jogador
LEFT JOIN Desporto d ON dj.ID_Desporto = d.ID
GROUP BY 
  u.ID, u.Nome, u.Email, u.Num_Tele, u.Nacionalidade, 
  j.Idade, j.Data_Nascimento, j.Descricao, j.Peso, j.Altura, 
  a.IBAN, a.No_Campos, mpa.Met_pagamento, a.ID_Arrendador;
GO

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