from flask import session, flash, redirect, url_for, request, render_template
import pyodbc
from controllers.user import is_arrendador
from utils import create_connection

def registration():
    username = request.form["username"]
    email = request.form["reg_email"]
    nationality = request.form["nacionalidade"]
    phone_number = request.form["numero_telemovel"]
    password = request.form["reg_password"]
        
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Utilizador WHERE Email=?", email)
        user = cursor.fetchone()
        if user:
            flash("Email já registado. Tente novamente.", "danger")
            return render_template("index.html")

        try:
            # Verifica se o utilizador já existe
            existe = cursor.execute("EXEC sp_UtilizadorExists ?", email).fetchone()
            if existe[0] == 1:
                flash("Email já registado. Tente novamente.", "danger")
                return render_template("index.html")
            
            # Insere o utilizador na tabela Utilizador usando a stored procedure
            cursor.execute("EXEC sp_CreateUtilizador ?, ?, ?, ?, ?", 
                username, email, phone_number, password, nationality)
            # Obtém o ID do último utilizador inserido
            cursor.execute("SELECT @@IDENTITY")
            new_id = cursor.fetchone()[0]
            # Insere o jogador na tabela Jogador usando a stored procedure
            cursor.execute("EXEC sp_CreateJogador ?, ?, ?", new_id, 0, '')

            conn.commit()

            flash("Registo realizado com sucesso!", "success")
            return redirect(url_for("index"))
        except pyodbc.IntegrityError:
            flash("Erro ao registar o utilizador. Tente novamente.", "danger")
            return render_template("index.html")

def log():
    email = request.form["login_email"]
    password = request.form["login_password"]

    if email == "admin@admin.pt" and password == "admin":
        session["user_id"] = 0
        session["user_nome"] = "Admin"
        return redirect(url_for("admin.admin_dashboard"))

    with create_connection() as conn:
        # Verifica se o utilizador existe
        cursor = conn.cursor()
        cursor.execute("EXEC sp_AuthenticateUtilizador ?, ?", email, password)
        user = cursor.fetchone()

    if user:
        session["user_id"] = user[0]
        session["username"] = user[1]

        tipo_utilizador = "Arrendador" if is_arrendador(user[0]) == 1 else "Jogador"
        session["tipo_utilizador"] = tipo_utilizador

        flash(f"Login realizado com sucesso! Tipo de utilizador: {tipo_utilizador}", "success")
        return redirect(url_for("dashboard.jog_dashboard", name=user[1]))
    else:
        flash("Email ou password incorretos.", "danger")
        return render_template("index.html")