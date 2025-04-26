from flask import session, flash, redirect, url_for, request, render_template
import pyodbc
from werkzeug.security import generate_password_hash, check_password_hash
from models.user import is_arrendador
from utils import create_connection, gerar_id_utilizador

def registration():
    id_utilizador = gerar_id_utilizador()
    username = request.form["username"]
    email = request.form["reg_email"]
    nationality = request.form["nacionalidade"]
    phone_number = request.form["numero_telemovel"]
    password = request.form["reg_password"]

    # Gera o hash da senha
    h_password = generate_password_hash(password)
        
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Utilizador WHERE Email=?", email)
        user = cursor.fetchone()
        if user:
            flash("Email já registado. Tente novamente.", "danger")
            return render_template("index.html")

        try:
            cursor.execute("INSERT INTO Utilizador (ID, Nome, Email, Num_Tele, Password, Nacionalidade) VALUES (?, ?, ?, ?, ?, ?)", 
                (id_utilizador, username, email, phone_number, h_password, nationality)) # Comando SQL para inserir o utilizador na tabela Utilizador
            
            cursor.execute("INSERT INTO Jogador (ID, Idade, Descricao) VALUES (?, ?, ?)",
                (id_utilizador, 0, '')) # Comando SQL para inserir o jogador na tabela Jogador

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
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Utilizador WHERE Email=?", email)
        user = cursor.fetchone()

    if user and check_password_hash(user[4], password):
        session["user_id"] = user[0]
        session["user_nome"] = user[1]

        tipo_utilizador = "Arrendador" if is_arrendador(user[0]) else "Jogador"
        session["tipo_utilizador"] = tipo_utilizador

        flash(f"Login realizado com sucesso! Tipo de utilizador: {tipo_utilizador}", "success")
        # Redireciona para a página dashboard
        return redirect(url_for("dashboard.jog_dashboard", name=user[1]))
    else:
        flash("Email ou password incorretos.", "danger")
        return render_template("index.html")

