Use SPORTSLINK;
Go

SELECT U.ID, U.Nome, U.Email, U.Num_Tele, U.Nacionalidade, J.Idade, J.Descricao, A.IBAN, A.No_Campos,
    CASE WHEN A.ID_Arrendador IS NOT NULL THEN 'Arrendador'
        ELSE 'Jogador'
    END AS Tipo
FROM Utilizador AS U JOIN Jogador AS J ON U.ID = J.ID LEFT JOIN Arrendador AS A ON U.ID = A.ID_Arrendador

Select * from Jogador join Utilizador on Jogador.ID = Utilizador.ID join Arrendador on Utilizador.ID = Arrendador.ID_Arrendador

Select c.ID as Nome_Campo, c.Comprimento, c.Largura, c.ocupado, c.Descricao,
p.Latitude, p.Longitude, u.Nome as Nome_responsavel, cpb.Entidade_publica_resp
from Campo as c join Ponto as p on c.ID_Ponto=p.ID
left join Campo_Priv as cp on c.ID=cp.ID_Campo
left join Utilizador as u on cp.ID_Arrendador=u.ID
left join Campo_Pub as cpb on c.ID=cpb.ID_Campo
order by c.ID DESC

Select * from Dias_semana
order by ID

Select * from Disponibilidade

Select r.ID, r.ID_Campo, r.ID_Jogador, r.Hora_Inicio, r.Hora_Fim, d.ID_dia, d.preco
from Disponibilidade as d join Reserva as r on d.ID_Campo=r.ID_Campo

Select c.Nome, c.Largura, c.Comprimento, c.Descricao, p.Latitude, p.Longitude, d.Preco, d.Hora_abertura, d.Hora_fecho, d.ID_dia
from Campo as c join Campo_Priv as cp on c.ID=cp.ID_Campo join Disponibilidade as d on cp.ID_Campo=d.ID_Campo 
join Ponto as p on c.ID_Ponto=p.ID

Select count(ID_Campo) as No_Campos
from Campo_Priv where ID_Arrendador = 1

Select * from Campo
Select * from Disponibilidade

 SELECT c.Nome AS Nome_Campo, c.Largura, c.Comprimento, c.Descricao, c.Endereco, p.Latitude, 
                p.Longitude, c.Ocupado,
                STRING_AGG(di.Nome, ', ') AS Dias_Disponiveis
            FROM Campo AS c
			JOIN Ponto AS p ON c.ID_Ponto = p.ID
			JOIN Campo_Priv AS cp ON c.ID = cp.ID_Campo
			JOIN Disponibilidade AS d ON c.ID = d.ID_Campo
			JOIN Dias_semana AS di ON d.ID_Dia = di.ID
            WHERE cp.ID_Arrendador = 3
            GROUP BY c.ID, c.Nome, c.Largura, c.Comprimento, c.Descricao, c.Endereco, p.Latitude, 
                p.Longitude, c.Ocupado


Select * from Utilizador as u join Jogador as j on u.ID=j.ID left join Arrendador on u.ID=ID_Arrendador

SELECT j2.ID, u.Nome, AVG(r.Avaliacao) AS Rating
FROM Jogador_Amizade as ja JOIN Jogador as j2 ON (ja.ID_J1=j2.ID OR ja.ID_J2=j2.ID)
JOIN Utilizador as u ON u.ID=j2.ID
LEFT JOIN Rating_Jogador as rj ON rj.ID_Jogador=j2.ID
LEFT JOIN Rating as r ON r.ID_Avaliador=rj.ID_Avaliador
WHERE (ja.ID_J1 = 511126546 OR ja.ID_J2 = 511126546) AND j2.ID <> 511126546
GROUP BY j2.ID, u.Nome


SELECT c.ID, c.Nome, c.Comprimento, c.Largura, c.Endereco, p.Latitude, p.Longitude, c.Descricao, dp.Preco, dp.Hora_abertura, dp.Hora_fecho, STRING_AGG(di.Nome, ', ') AS Dias_Disponiveis
FROM Campo as c
LEFT JOIN Campo_Priv as cp on c.ID = cp.ID_Campo
JOIN Ponto as p on p.ID = c.ID_Ponto
JOIN Utilizador as U on U.ID = cp.ID_Arrendador
LEFT JOIN Disponibilidade as dp on dp.ID_Campo = cp.ID_Campo
JOIN Dias_semana as di on di.ID = dp.ID_dia
group by c.ID, c.Nome, c.Comprimento, c.Largura, c.Endereco, p.Latitude, p.Longitude, c.Descricao, dp.Preco, dp.Hora_abertura, dp.Hora_fecho


Select * from Ponto where ID = (Select ID_Ponto from Campo where ID = 1 )

SELECT u.Nome, u.Nacionalidade, u.Num_Tele, di.Preco, DATEDIFF(HOUR, r.Hora_Fim, r.Hora_Inicio) as Duracao
FROM Reserva as r
JOIN Disponibilidade as di on di.ID_Campo=r.ID_Campo 
JOIN Utilizador as u on u.ID=r.ID_Jogador

SELECT d.ID, d.Nome
FROM STRING_SPLIT('Futebol, Basquetebol', ',') AS s
JOIN Desporto d ON LTRIM(RTRIM(s.value)) = d.Nome

SELECT d.ID, d.Nome
FROM STRING_SPLIT('Futebol, Basquetebol', ',') AS s
JOIN Desporto d ON LTRIM(RTRIM(s.value)) = d.Nome
JOIN Desporto_Jogador dj ON dj.ID_Desporto = d.ID
WHERE dj.ID_Jogador = 1;


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

SELECT 
    c.ID,
    c.Nome,
    c.Endereco,
    c.Ocupado,
    STRING_AGG(d.Nome, ', ') AS Dias,
    STRING_AGG(I.[URL], ', '),
    CASE WHEN c.Ocupado = 1 THEN 'Sim' ELSE 'Não' END AS Ocupado
	FROM Campo as c
	INNER JOIN Disponibilidade as di on di.ID_Campo=c.ID
	LEFT JOIN Dias_semana as d on d.ID=di.ID_dia
	INNER JOIN IMG_Campo as ic on ic.ID_Campo=c.ID
	LEFT JOIN Imagem as i on i.ID=ic.ID_img
	LEFT JOIN Campo_Priv as cp on cp.ID_Campo=c.ID
	where cp.ID_Arrendador = 3
	GROUP BY c.ID,
    c.Nome,
    c.Endereco,
    c.Ocupado;


SELECT c.ID, c.Nome, c.Comprimento, c.Largura, c.Endereco, p.Latitude, p.Longitude, c.Descricao, 
  dp.Preco, dp.Hora_abertura, dp.Hora_fecho, STRING_AGG(di.Nome, ', ') AS Dias_Disponiveis, i.[URL], STRING_AGG(desp.Nome, ',') as Desportos
  FROM Campo as c
  LEFT JOIN Campo_Priv as cp on c.ID = cp.ID_Campo
  JOIN Ponto as p on p.ID = c.ID_Ponto
  JOIN Utilizador as U on U.ID = cp.ID_Arrendador
  LEFT JOIN Disponibilidade as dp on dp.ID_Campo = cp.ID_Campo
  LEFT JOIN IMG_Campo as IMG on IMG.ID_Campo = c.ID
  INNER JOIN Imagem as i on i.ID = IMG.ID_img
  JOIN Dias_semana as di on di.ID = dp.ID_dia
  LEFT JOIN Desporto_Campo as dC on dc.ID_Campo=c.ID
  LEFT JOIN  Desporto as desp on desp.ID=dc.ID_Desporto
  group by c.ID, c.Nome, c.Comprimento, c.Largura, c.Endereco, p.Latitude, p.Longitude,
  c.Descricao, dp.Preco, dp.Hora_abertura, dp.Hora_fecho, i.[URL]
  HAVING c.ID = 1;

  SELECT * FROM Desporto_Campo

  SELECT 
  p.ID AS ID_Partida,
  p.ID_Campo,
  c.Nome AS Nome_Campo,
  p.Data_Hora,
  p.Duracao,
  p.Resultado,
  p.Estado,
  p.no_jogadores,
  ju.ID_Jogador,
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
FROM Partida p JOIN Jogador_joga as ju on ju.ID_Partida=p.ID
LEFT JOIN Campo c ON p.ID_Campo = c.ID
WHERE ju.ID_Jogador=1 AND p.Estado = 'Finalizada'
GO


SELECT 
      ump.Met_pagamento AS Metodo,
      ump.Detalhes
  FROM 
      Met_Paga_Arrendador AS ump
  WHERE 
      ump.ID_Arrendador = 28


SELECT * from Disponibilidade DI
INNER JOIN Dias_semana AS DIS ON DIS.ID=DI.ID_dia
where ID_Campo = 6

SELECT * FROM IMG_Campo

SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Desporto_Campo';


SELECT c.ID, c.Nome, c.Comprimento, c.Largura, c.Endereco, p.Latitude, p.Longitude, c.Descricao, 
  dp.Preco, dp.Hora_abertura, dp.Hora_fecho, STRING_AGG(di.Nome, ', ') AS Dias_Disponiveis, i.[URL], STRING_AGG(desp.Nome, ',') as Desportos
  FROM Campo as c
  LEFT JOIN Campo_Priv as cp on c.ID = cp.ID_Campo
  JOIN Ponto as p on p.ID = c.ID_Ponto
  JOIN Utilizador as U on U.ID = cp.ID_Arrendador
  LEFT JOIN Disponibilidade as dp on dp.ID_Campo = cp.ID_Campo
  LEFT JOIN IMG_Campo as IMG on IMG.ID_Campo = c.ID
  INNER JOIN Imagem as i on i.ID = IMG.ID_img
  JOIN Dias_semana as di on di.ID = dp.ID_dia
  LEFT JOIN Desporto_Campo as dc on dc.ID_Campo=c.ID
  LEFT JOIN  Desporto as desp on desp.ID=dc.ID_Desporto
  group by c.ID, c.Nome, c.Comprimento, c.Largura, c.Endereco, p.Latitude, p.Longitude,
  c.Descricao, dp.Preco, dp.Hora_abertura, dp.Hora_fecho, i.[URL]
  HAVING c.ID = 7;


  SELECT * FROM Campo JOIN Campo_Pub on ID=ID_Campo

  