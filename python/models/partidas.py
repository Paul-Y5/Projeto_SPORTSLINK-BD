from utils.db import create_connection

def get_partidas():
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT P.ID, P.Data_Hora, C.Nome AS Campo, P.no_jogadores, P.Resultado
            FROM Partida AS P
            JOIN Campo AS C ON P.ID_Campo = C.ID
        """)
        return cursor.fetchall()