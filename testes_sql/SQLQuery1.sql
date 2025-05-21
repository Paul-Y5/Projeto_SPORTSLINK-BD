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

SELECT u.Nome, u.Nacionalidade, u.Num_Tele, di.Preco, (DATEDIFF(r.Hora_Fim, r.Hora_Inicio)
FROM Reserva as r
JOIN Disponibilidade as di on di.ID_Campo=r.ID_Campo 
JOIN Utilizador as u on u.ID=r.ID_Jogador