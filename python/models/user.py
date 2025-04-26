from utils.db import create_connection


# Funções Auxiliares para o utilizadores
def is_arrendador(user_id):
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM Arrendador WHERE ID_Arrendador=?", user_id)
        return cursor.fetchone()[0] == 1

def get_user_info(user_id):
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Utilizador WHERE ID=?", user_id)
        user = cursor.fetchone()
        tipo_utilizador = "Arrendador" if is_arrendador(user_id) else "Jogador"
        if tipo_utilizador == "Arrendador":
            cursor.execute("""Select U.ID, U.Nome, U.Email, U.Num_Tele, U.Password, U.Nacionalidade, J.Idade, J.Descricao, A.IBAN, A.No_Campos, IMG.URL AS FotoPerfil
                FROM Utilizador AS U JOIN Jogador AS J ON U.ID = J.ID JOIN Arrendador AS A ON U.ID = A.ID_Arrendador LEFT JOIN IMG_Perfil AS IMG ON U.ID = IMG.ID_Utilizador
                WHERE U.ID=?""", (user_id,))
        else:
            cursor.execute("""SELECT U.ID, U.Nome, U.Email, U.Num_Tele, U.Password, U.Nacionalidade, J.Idade, J.Descricao, IMG.URL AS FotoPerfil
                FROM Utilizador AS U JOIN Jogador AS J ON U.ID = J.ID LEFT JOIN IMG_Perfil AS IMG ON U.ID = IMG.ID_Utilizador 
                WHERE U.ID=?""", (user_id,))
        user = cursor.fetchone()
    return user

def get_users():
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT 
                U.ID, 
                U.Nome, 
                U.Email, 
                U.Num_Tele, 
                U.Nacionalidade, 
                J.Idade, 
                J.Descricao, 
                A.IBAN, 
                A.No_Campos,
                CASE 
                    WHEN A.ID_Arrendador IS NOT NULL THEN 'Arrendador'
                    ELSE 'Jogador'
                END AS Tipo
            FROM Utilizador AS U
            JOIN Jogador AS J ON U.ID = J.ID
            LEFT JOIN Arrendador AS A ON U.ID = A.ID_Arrendador
        """)
        utilizadores = cursor.fetchall()
    return utilizadores

# Podem ser necessárias
def get_jogadores():
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT J.ID, U.Nome, U.Email, J.Idade, J.Descricao
            FROM Jogador AS J
            JOIN Utilizador AS U ON J.ID = U.ID
        """)
        return cursor.fetchall()

def get_arrendadores():
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT A.ID_Arrendador, U.Nome, U.Email, A.IBAN, A.No_Campos
            FROM Arrendador AS A
            JOIN Utilizador AS U ON A.ID_Arrendador = U.ID
        """)
        return cursor.fetchall()
    

