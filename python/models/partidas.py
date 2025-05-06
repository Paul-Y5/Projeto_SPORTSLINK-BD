from utils.db import create_connection

def get_partidas(order, direction):
    with create_connection() as conn:
        if direction not in ["ASC", "DESC"]:
            direction = "ASC"
        if order not in ["P.ID, P.Data_Hora", "C.Nome", "P.no_jogadores", "P.Resultado"]:
            order = "P.Data_Hora"

        cursor = conn.cursor()
        cursor.execute(f"""
            SELECT P.ID, P.Data_Hora, C.Nome, P.no_jogadores, P.Resultado
            FROM Partida AS P
            JOIN Campo AS C ON P.ID_Campo = C.ID
            ORDER BY {order} {direction}
        """)
        return cursor.fetchall()