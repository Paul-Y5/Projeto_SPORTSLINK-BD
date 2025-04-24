Use SPORTSLINK;
Go


SELECT U.ID, U.Nome, U.Email, U.Num_Tele, U.Nacionalidade, J.Idade, J.Descricao, A.IBAN, A.No_Campos,
    CASE WHEN A.ID_Arrendador IS NOT NULL THEN 'Arrendador'
        ELSE 'Jogador'
    END AS Tipo
FROM Utilizador AS U JOIN Jogador AS J ON U.ID = J.ID LEFT JOIN Arrendador AS A ON U.ID = A.ID_Arrendador


Select * from Campo_Pub

Select c.ID as Nome_Campo, c.Comprimento, c.Largura, c.ocupado, c.Descricao,
p.Latitude, p.Longitude, u.Nome as Nome_responsável, cpb.Entidade_publica_resp
from Campo as c join Ponto as p on c.ID_Ponto=p.ID
left join Campo_Priv as cp on c.ID=cp.ID_Campo
left join Utilizador as u on cp.ID_Arrendador=u.ID
left join Campo_Pub as cpb on c.ID=cpb.ID_Campo
