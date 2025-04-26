from flask import flash, redirect, render_template, request, session, url_for
from models.campo import get_campos_by_user
from models.user import is_arrendador
from utils.db import create_connection
from utils.general import get_dias_semana, get_siglas_dias

def get_user_info(user_id):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT u.Nome, u.Email, u.Num_Tele, u.Nacionalidade, j.idade, a.IBAN, a.No_Campos, j.Descricao
                FROM Utilizador u
                JOIN Jogador j ON u.ID = j.ID
                LEFT JOIN Arrendador a ON u.ID = a.ID_Arrendador
                WHERE u.ID=?
            """, (user_id,))
            user_info = cursor.fetchone()

        if user_info:
            return user_info
        else:
            return None

    except Exception as e:
        print(f"Erro ao obter informações do usuário: {e}")
        return None
    


def update_user_info(user_id, username, email, nationality, phone_number, age, description, iban):
    try:
        tipo_utilizador = "Arrendador" if is_arrendador(user_id) else "Jogador"

        with create_connection() as conn:
            cursor = conn.cursor()

            # Atualizar informações básicas do utilizador
            cursor.execute("""
                UPDATE Utilizador
                SET Nome=?, Email=?, Num_Tele=?, Nacionalidade=?
                WHERE ID=?
            """, (username, email, phone_number, nationality, user_id))

            # Atualizar informações específicas do tipo de utilizador
            if tipo_utilizador == "Jogador":
                cursor.execute("""
                    UPDATE Jogador
                    SET Idade=?, Descricao=?
                    WHERE ID=?
                """, (age, description, user_id))
            else:
                cursor.execute("""
                    UPDATE Jogador
                    SET Idade=?, Descricao=?
                    WHERE ID=?
                """, (age, description, user_id))

                cursor.execute("""
                    UPDATE Arrendador
                    SET IBAN=?
                    WHERE ID_Arrendador=?
                """, (iban, user_id))

            conn.commit()

        # Obter informações atualizadas do utilizador
        user = get_user_info(user_id)
        return True, tipo_utilizador, user

    except Exception as e:
        print(f"Erro ao atualizar informações do usuário: {e}")
        return False, None, None
    
def delete_user_account():
    user_id = session["user_id"]
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM Utilizador WHERE ID=?", (user_id,))
            conn.commit()

        flash("Conta excluída com sucesso!", "success")
        session.clear()
        return redirect(url_for("index"))

    except Exception as e:
        flash(f"Erro ao excluir conta: {str(e)}", "danger")
        return redirect(url_for("account"))


# Arrendador
def tornar_arrendador():
    if "user_id" not in session:
        return redirect(url_for("index"))

    user_id = session["user_id"]
    iban = request.form["iban"]
    termos = request.form.get("termos")
    user = get_user_info(user_id)

    if not termos:
        flash("Deves aceitar os termos e condições para continuares.", "danger")
        return redirect(url_for("arrendador.arrendador_dashboard"))

    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO ARRENDADOR (ID_Arrendador, IBAN, No_Campos)
            VALUES (?, ?, ?)
        """, (user_id, iban, 0,))
        conn.commit()

    flash("Agora és um arrendador!", "success")
    return redirect(url_for("arrendador.arrendador_dashboard"))

def listar_campos_arrendador():
    user_id = session.get("user_id")
    if not user_id:
        return redirect(url_for("auth.login"))
    
    user = get_user_info(user_id)

    campos = get_campos_by_user(user_id)
    return render_template(
        "arr_campos_list.html",
        user=user,
        campos=campos,
        siglas_dias=get_siglas_dias().items(),
        dias=get_dias_semana().items()
    )