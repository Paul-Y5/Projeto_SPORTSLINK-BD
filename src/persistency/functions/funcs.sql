USE SPORTSLINK;
GO

-- Utilizador já existe? (Verifica através do email que é único na tabela Utilizador)
CREATE FUNCTION dbo.fn_UtilizadorExists (@Email VARCHAR(255))
RETURNS BIT
AS
BEGIN
  DECLARE @Exists BIT;

  SELECT @Exists = CASE WHEN EXISTS (SELECT 1 FROM Utilizador WHERE Email = @Email) THEN 1 ELSE 0 END;

  RETURN @Exists;
END;
GO

-- Verificar se é Arrendador
CREATE FUNCTION dbo.fn_IsArrendador (@UserID INT)
RETURNS BIT
AS
BEGIN
  DECLARE @IsArrendador BIT;

  SELECT @IsArrendador = CASE WHEN EXISTS (SELECT 1 FROM Arrendador WHERE ID_Arrendador = @UserID) THEN 1 ELSE 0 END;

  RETURN @IsArrendador;
END;
GO

-- Calculo do número de horas de uma reserva no formato HH:MM
CREATE FUNCTION dbo.fn_CalculaHorasFormatado (
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

-- ESTADO PARTIDA
CREATE FUNCTION dbo.fn_GetEstadoPartida
(
  @Estado VARCHAR(50)
)
RETURNS VARCHAR(100)
AS
BEGIN
  RETURN 
    CASE @Estado
      WHEN 'Aguardando' THEN 'Partida aguardando jogadores'
      WHEN 'Em Andamento' THEN 'Partida em progresso'
      WHEN 'Finalizada' THEN 'Partida finalizada'
      ELSE 'Estado desconhecido'
    END
END;
GO

-- CALCULO DO TEMPO DE JOGO
CREATE FUNCTION dbo.fn_CalculaDuracaoMinutos
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

CREATE FUNCTION dbo.fn_GetMetodosPagamentoDetalhes (@UserId INT)
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

-- Cálculo da distância entre dois pontos geográficos (latitude e longitude)
CREATE FUNCTION dbo.fn_CalculateDistance
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