from flask import request
from utils.db import create_connection
from utils.general import gerar_id_reserva  # assume que tens função semelhante a gerar_id_campo

def create_reserva(id_campo, id_jogador, data, hora_inicio, hora_fim, descricao):
    id_reserva = gerar_id_reserva()
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO Reserva (ID, ID_Campo, ID_Jogador, [Data], Hora_Inicio, Hora_Fim, Descricao)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, (id_reserva, id_campo, id_jogador, data, hora_inicio, hora_fim, descricao))
        conn.commit()
    return id_reserva


def get_reservas(order, direction, search=None):
    if direction not in ["ASC", "DESC"]:
        direction = "ASC"

    if order not in ["r.ID", "r.Data", "r.Hora_Inicio", "r.Hora_Fim", "c.Nome", "u.Nome"]:
        order = "r.Data"

    where_clauses = []
    params = []

    if search:
        search = f"%{search}%"
        where_clauses.append(
            "(c.Nome LIKE ? OR u.Nome LIKE ? OR r.Descricao LIKE ?)"
        )
        params.extend([search, search, search])

    where_sql = "WHERE " + " AND ".join(where_clauses) if where_clauses else ""

    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute(f"""
            SELECT
                r.ID,
                r.[Data],
                r.Hora_Inicio,
                r.Hora_Fim,
                r.Descricao,
                c.Nome AS Nome_Campo,
                u.Nome AS Nome_Jogador
            FROM Reserva AS r
            JOIN Campo AS c ON r.ID_Campo = c.ID
            JOIN Jogador AS j ON r.ID_Jogador = j.ID
            JOIN Utilizador AS u ON j.ID = u.ID
            {where_sql}
            ORDER BY {order} {direction}
        """, params)
        return cursor.fetchall()


def get_reservas_by_user(user_id):
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT r.ID, r.Data, r.Hora_Inicio, r.Hora_Fim, r.Descricao,
                   c.Nome AS Nome_Campo
            FROM Reserva r
            JOIN Campo c ON r.ID_Campo = c.ID
            WHERE r.ID_Jogador = ?
            ORDER BY r.Data DESC, r.Hora_Inicio
        """, (user_id,))
        return cursor.fetchall()


def get_reserva_by_id(reserva_id):
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT r.ID, r.Data, r.Hora_Inicio, r.Hora_Fim, r.Descricao,
                   c.Nome AS Nome_Campo, u.Nome AS Nome_Jogador
            FROM Reserva r
            JOIN Campo c ON r.ID_Campo = c.ID
            JOIN Jogador j ON r.ID_Jogador = j.ID
            JOIN Utilizador u ON j.ID = u.ID
            WHERE r.ID = ?
        """, (reserva_id,))
        return cursor.fetchone()
