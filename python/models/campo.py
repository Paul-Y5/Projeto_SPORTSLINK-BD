from flask import request
import pyodbc
from models.ponto import create_ponto
from utils.general import gerar_id_campo
from utils.db import create_connection

def create_campo(nome, comprimento, largura, descricao, lat, long, endereco):
    id_campo = gerar_id_campo()
    id_ponto = create_ponto(lat, long)
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO Campo (ID, ID_Ponto, Nome, Comprimento, Largura, Ocupado, Descricao, Endereco)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (id_campo, id_ponto, nome, comprimento, largura, 0, descricao, endereco))
        conn.commit()
    return id_campo


def get_campos_by_user(user_id):
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT c.Nome AS Nome_Campo, c.Largura, c.Comprimento, c.Descricao, c.Endereco, p.Latitude, 
                p.Longitude, c.Ocupado,
                STRING_AGG(di.Nome, ', ') AS Dias_Disponiveis, c.ID
            FROM Campo AS c
			JOIN Ponto AS p ON c.ID_Ponto = p.ID
			JOIN Campo_Priv AS cp ON c.ID = cp.ID_Campo
			JOIN Disponibilidade AS d ON c.ID = d.ID_Campo
			JOIN Dias_semana AS di ON d.ID_Dia = di.ID
            WHERE cp.ID_Arrendador = ?
            GROUP BY c.ID, c.Nome, c.Largura, c.Comprimento, c.Descricao, c.Endereco, p.Latitude, 
                p.Longitude, c.Ocupado
        """, (user_id,))
        campos = cursor.fetchall()
    return campos


def get_campos(order, direction, search=None, tipo_campo=None):
    if direction not in ["ASC", "DESC"]:
        direction = "ASC"

    if order not in ["c.ID", "c.Nome", "c.Comprimento", "c.Largura", "c.ocupado", "u.Nome", "cpb.Entidade_publica_resp"]:
        order = "c.Nome"

    where_clauses = []
    params = []

    if search:
        search = f"%{search}%"
        where_clauses.append(
            "(c.Nome LIKE ? OR c.Descricao LIKE ? OR u.Nome LIKE ? OR cpb.Entidade_publica_resp LIKE ?)"
        )
        params.extend([search, search, search, search])

    if tipo_campo == "Priv":
        where_clauses.append("cp.ID_Campo IS NOT NULL")
    elif tipo_campo == "Pub":
        where_clauses.append("cpb.ID_Campo IS NOT NULL")

    where_sql = "WHERE " + " AND ".join(where_clauses) if where_clauses else ""

    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute(f"""
            SELECT
                c.ID,
                c.Nome, 
                c.Comprimento, 
                c.Largura, 
                c.ocupado, 
                c.Descricao,
                p.Latitude, 
                p.Longitude, 
                u.Nome as Nome_Responsavel, 
                cpb.Entidade_publica_resp
            FROM Campo AS c
            JOIN Ponto AS p ON c.ID_Ponto = p.ID
            LEFT JOIN Campo_Priv AS cp ON c.ID = cp.ID_Campo
            LEFT JOIN Utilizador AS u ON cp.ID_Arrendador = u.ID
            LEFT JOIN Campo_Pub AS cpb ON c.ID = cpb.ID_Campo
            {where_sql}
            ORDER BY {order} {direction}
        """, params)
        return cursor.fetchall()
    

def get_campo_by_id(campo_id):
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT c.Nome AS Nome_Campo, c.Largura, c.Comprimento, c.Descricao, c.Endereco, p.Latitude, 
                p.Longitude, c.Ocupado,
                STRING_AGG(di.Nome, ', ') AS Dias_Disponiveis, c.ID
            FROM Campo AS c
            JOIN Ponto AS p ON c.ID_Ponto = p.ID
            JOIN Campo_Priv AS cp ON c.ID = cp.ID_Campo
            JOIN Disponibilidade AS d ON c.ID = d.ID_Campo
            JOIN Dias_semana AS di ON d.ID_Dia = di.ID
            WHERE c.ID = ?
            GROUP BY c.ID, c.Nome, c.Largura, c.Comprimento, c.Descricao, c.Endereco, p.Latitude, 
                p.Longitude, c.Ocupado
        """, (campo_id,))
        return cursor.fetchone()

def get_disponibilidade_por_campo(campo_id):
    with create_connection() as conn:
        conn.row_factory = pyodbc.Row  
        cursor = conn.cursor()
        cursor.execute("""
            SELECT ds.Nome AS dia, d.Hora_Abertura, d.Hora_Fecho
            FROM Disponibilidade d
            JOIN Dias_semana ds ON ds.ID = d.ID_Dia
            WHERE d.ID_Campo = ?
        """, (campo_id,))
        results = cursor.fetchall()
        return {
            row.dia: {
                "hora_abertura": row.Hora_Abertura,
                "hora_fecho": row.Hora_Fecho
            }
            for row in results
        }