CREATE PROCEDURE sp_CreateImg
    @URL VARCHAR(1000),
    @ID_img INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Imagem WHERE URL = @URL)
    BEGIN
        INSERT INTO Imagem ([URL])
        VALUES (@URL);
        SET @ID_img = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        SELECT @ID_img = ID FROM Imagem WHERE URL = @URL;
    END
END;
GO
