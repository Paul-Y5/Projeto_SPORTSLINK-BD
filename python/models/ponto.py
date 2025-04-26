from utils.db import create_connection
from utils.general import gerar_id_ponto


def create_ponto(lat, long):
    id_map = 1
    id_ponto = gerar_id_ponto()
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO Ponto (ID, ID_Mapa, Latitude, Longitude)
            VALUES (?, ?, ?, ?)
        """, (id_ponto, id_map, lat, long))
        conn.commit()
    return id_ponto