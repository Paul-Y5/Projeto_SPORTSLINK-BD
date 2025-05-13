from flask import flash, redirect, render_template, request, session, url_for
from utils.db import create_connection
from utils.general import get_dias_semana, get_siglas_dias

def get_user_info(user_id):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            # Chama a stored procedure para obter informações do utilizador
            cursor.execute("EXEC sp_GetUserInfo ?", (user_id,))
            user_info = cursor.fetchone()
        if user_info:
            return user_info
        else:
            return None
    except Exception as e:
        print(f"Erro ao obter informações do usuário: {e}")
        return None
    
def get_users():
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            # Chama a stored procedure para obter todos os utilizadores
            cursor.execute("EXEC sp_GetAllUsers")
            users = cursor.fetchall()
        return users
    except Exception as e:
        print(f"Erro ao obter utilizadores: {e}")
        return []

def update_user_info(user_id, username, email, nationality, phone_number, age, description, iban):
    try:
        tipo_utilizador = "Arrendador" if is_arrendador(user_id) else "Jogador"
        with create_connection() as conn:
            cursor = conn.cursor()
            # Atualiza informações básicas do utilizador
            cursor.execute("EXEC sp_UpdateUserInfo ?, ?, ?, ?, ?", 
                           (user_id, username, email, phone_number, nationality))
            
            # Atualiza informações específicas do tipo de utilizador
            if tipo_utilizador == "Jogador":
                cursor.execute("EXEC sp_UpdateJogadorInfo ?, ?, ?", 
                               (user_id, age, description))
            else:
                cursor.execute("EXEC sp_UpdateJogadorInfo ?, ?, ?", 
                               (user_id, age, description))
                cursor.execute("EXEC sp_UpdateArrendadorInfo ?, ?", 
                               (user_id, iban))
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
            # Chama a stored procedure para excluir o utilizador
            cursor.execute("EXEC sp_DeleteUser ?", (user_id,))
            conn.commit()
        flash("Conta excluída com sucesso!", "success")
        session.clear()
        return redirect(url_for("index"))
    except Exception as e:
        flash(f"Erro ao excluir conta: {str(e)}", "danger")
        return redirect(url_for("account"))


# Arrendador
def make_arrendador():
    if "user_id" not in session:
        return redirect(url_for("index"))
    user_id = session["user_id"]
    iban = request.form["iban"]
    termos = request.form.get("termos")
    user = get_user_info(user_id)
    if not termos:
        flash("Deves aceitar os termos e condições para continuares.", "danger")
        return redirect(url_for("arrendador.arrendador_dashboard"))
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            # Chama a stored procedure para criar um arrendador
            cursor.execute("EXEC sp_CreateArrendador ?, ?", (user_id, iban))
            conn.commit()
        flash("Agora és um arrendador!", "success")
        return redirect(url_for("arrendador.arrendador_dashboard"))
    except Exception as e:
        flash(f"Erro ao tornar-se arrendador: {str(e)}", "danger")
        return redirect(url_for("arrendador.arrendador_dashboard"))

def list_campos_arrendador():
    user_id = session.get("user_id")
    if not user_id:
        return redirect(url_for("auth.login"))
    
    user = get_user_info(user_id)
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            # Chama a stored procedure para obter os campos do arrendador
            cursor.execute("EXEC sp_GetCamposByUser ?", (user_id,))
            campos = cursor.fetchall()
        return render_template(
            "arr_campos_list.html",
            user=user,
            campos=campos,
            siglas_dias=get_siglas_dias().items(),
            dias=get_dias_semana().items()
        )
    except Exception as e:
        flash(f"Erro ao listar campos: {str(e)}", "danger")
        return render_template(
            "arr_campos_list.html",
            user=user,
            campos=[],
            siglas_dias=get_siglas_dias().items(),
            dias=get_dias_semana().items()
        )
    
def listar_campos_arrendador():
    user_id = session.get("user_id")
    if not user_id:
        return redirect(url_for("auth.login"))
    
    user = get_user_info(user_id)
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            # Chama a stored procedure para obter os campos do arrendador
            cursor.execute("EXEC sp_GetCamposByUser ?", (user_id,))
            campos = cursor.fetchall()
        return render_template(
            "arr_campos_list.html",
            user=user,
            campos=campos,
            siglas_dias=get_siglas_dias().items(),
            dias=get_dias_semana().items()
        )
    except Exception as e:
        flash(f"Erro ao listar campos: {str(e)}", "danger")
        return render_template(
            "arr_campos_list.html",
            user=user,
            campos=[],
            siglas_dias=get_siglas_dias().items(),
            dias=get_dias_semana().items()
        )

def get_friends():
    user_id = session.get("user_id")
    if not user_id:
        flash("Utilizador não encontrado.", "danger")
        return redirect(url_for("index"))
    user = get_user_info(user_id)
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            # Chama a stored procedure para obter os amigos do utilizador
            cursor.execute("EXEC sp_GetFriends ?", (user_id,))
            amigos = cursor.fetchall()
        return render_template("lista_amigos.html", user=user, amigos=amigos)
    except Exception as e:
        print(f"Erro ao obter informações do utilizador: {e}")
        flash("Erro ao carregar os amigos.", "danger")
        return render_template("lista_amigos.html", user=user, amigos=[])

def add_friend():
    id_friend = request.form["ID_Amigo"]
    if not id_friend:
        flash("Deves escolher um amigo para adicionar.", "danger")
        return redirect(url_for("dashboard.list_friends", ID=session["user_id"]))
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            # Chama a stored procedure para adicionar um amigo
            cursor.execute("EXEC sp_AddFriend ?, ?", (session["user_id"], id_friend))
            conn.commit()
        flash("Amigo adicionado com sucesso!", "success")
        return redirect(url_for("dashboard.list_friends", ID=session["user_id"]))
    except Exception as e:
        print(f"Erro ao adicionar amigo: {e}")
        flash("Erro ao adicionar amigo.", "danger")
        return redirect(url_for("dashboard.list_friends", ID=session["user_id"]))
    
# Auxiiares
def is_arrendador(user_id):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC sp_IsArrendador ?", (user_id,))
            result = cursor.fetchone()
            return result[0] if result else False
    except Exception as e:
        print(f"Erro ao verificar se o usuário é arrendador: {e}")
        return False