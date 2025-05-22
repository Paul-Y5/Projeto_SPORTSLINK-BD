
-- Calculo do número de horad fe uma reserva no formato HH:MM
CREATE FUNCTION dbo.CalculaHorasFormatado (
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
END

