USE SPORTSLINK;
GO

CREATE OR ALTER FUNCTION dbo.fn_CalculaIdade (@DataNascimento DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Idade INT;

    SET @Idade = DATEDIFF(YEAR, @DataNascimento, GETDATE())
        - CASE 
            WHEN MONTH(@DataNascimento) > MONTH(GETDATE()) 
                 OR (MONTH(@DataNascimento) = MONTH(GETDATE()) AND DAY(@DataNascimento) > DAY(GETDATE()))
            THEN 1 
            ELSE 0 
          END;

    RETURN @Idade;
END;
GO

-- Utilizador já existe? (Verifica através do email que é único na tabela Utilizador)
CREATE OR ALTER FUNCTION dbo.UtilizadorExists (@Email VARCHAR(512))
RETURNS BIT
AS
BEGIN
    DECLARE @Exists BIT;

    SET @Exists = CASE 
        WHEN EXISTS (SELECT 1 FROM dbo.Utilizador WHERE Email = @Email) 
        THEN 1 
        ELSE 0 
    END;

    RETURN @Exists;
END;
GO

-- Verificar se é Arrendador
CREATE OR ALTER FUNCTION dbo.IsArrendador (@UserID INT)
RETURNS BIT
AS
BEGIN
  DECLARE @IsArrendador BIT;

  SELECT @IsArrendador = CASE WHEN EXISTS (SELECT 1 FROM Arrendador WHERE ID_Arrendador = @UserID) THEN 1 ELSE 0 END;

  RETURN @IsArrendador;
END;
GO

-- Calculo do número de horas de uma reserva no formato HH:MM
CREATE OR ALTER FUNCTION dbo.CalculaHorasFormatado (
    @HoraInicio DATETIME,
    @HoraFim DATETIME
)
RETURNS VARCHAR(5)
AS
BEGIN
    DECLARE @TotalMin INT = DATEDIFF(MINUTE, @HoraInicio, @HoraFim)
    DECLARE @Horas INT = @TotalMin / 60
    DECLARE @Minutos INT = @TotalMin % 60

    RETURN RIGHT('0' + CAST(@Horas AS VARCHAR), 2) + ':' + RIGHT('0' + CAST(@Minutos AS VARCHAR), 2)
END;
GO

-- CALCULO DO TEMPO DE JOGO
CREATE OR ALTER FUNCTION dbo.CalculaDuracaoMinutos
(
  @Hora_Inicio TIME,
  @Hora_Fim TIME
)
RETURNS INT
AS
BEGIN
  RETURN DATEDIFF(MINUTE, @Hora_Inicio, @Hora_Fim);
END;
GO

CREATE OR ALTER FUNCTION dbo.GetMetodosPagamentoDetalhes (@UserId INT)
RETURNS TABLE
AS
RETURN
(
SELECT 
      ump.Met_pagamento AS Metodo,
      ump.Detalhes
  FROM 
      Met_Paga_Arrendador AS ump
  WHERE 
      ump.ID_Arrendador = @UserId
);
GO

-- Cálculo da distância entre dois pontos geográficos (latitude e longitude)
CREATE OR ALTER FUNCTION dbo.CalculateDistance
(
    @lat1 FLOAT,
    @lon1 FLOAT,
    @lat2 FLOAT,
    @lon2 FLOAT
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @r FLOAT = 6371; -- Raio da Terra em km
    DECLARE @phi1 FLOAT = RADIANS(@lat1);
    DECLARE @phi2 FLOAT = RADIANS(@lat2);
    DECLARE @deltaPhi FLOAT = RADIANS(@lat2 - @lat1);
    DECLARE @deltaLambda FLOAT = RADIANS(@lon2 - @lon1);
    
    DECLARE @a FLOAT = SIN(@deltaPhi / 2) * SIN(@deltaPhi / 2) +
                       COS(@phi1) * COS(@phi2) *
                       SIN(@deltaLambda / 2) * SIN(@deltaLambda / 2);
    DECLARE @c FLOAT = 2 * ATN2(SQRT(@a), SQRT(1 - @a));
    DECLARE @d FLOAT = @r * @c;
    
    RETURN @d;
END;
GO

CREATE OR ALTER FUNCTION dbo.TotalPagamento (@Hora_inicio DATETIME, @Hora_fim DATETIME, @Preco DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalMin INT = DATEDIFF(MINUTE, @Hora_inicio, @Hora_fim);
    DECLARE @Total FLOAT = (@TotalMin / 60.0) * @Preco; -- Preço por hora

    RETURN @Total;
END;
GO

CREATE OR ALTER FUNCTION GetMaxJogadores
    (@ID_Campo INT)
RETURNS INT
AS
BEGIN
    DECLARE @MaxJogadores INT;

    SELECT @MaxJogadores = CASE 
        WHEN d.Nome = 'Futebol' THEN 22
        WHEN d.Nome = 'Basquetebol' THEN 10
        WHEN d.Nome = 'Ténis' THEN 2
        ELSE 10
    END
    FROM Desporto_Campo dc
    LEFT JOIN Desporto d ON dc.ID_Desporto = d.ID
    WHERE dc.ID_Campo = @ID_Campo;

    -- Se não houver desporto associado, retorna o valor padrão
    IF @MaxJogadores IS NULL
        SET @MaxJogadores = 10;

    RETURN @MaxJogadores;
END;
GO

CREATE OR ALTER FUNCTION IsPlayerOnMatch (@ID_Jogador INT)
RETURNS BIT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Jogador_joga jj
        JOIN Partida p ON jj.ID_Partida = p.ID
        WHERE jj.ID_Jogador = @ID_Jogador AND (p.Estado = 'Andamento' OR p.Estado = 'Aguardando')
    )
        RETURN 1;
    RETURN 0;
END;
GO