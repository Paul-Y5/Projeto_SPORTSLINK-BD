from decimal import Decimal
import os
from flask import session, flash, redirect, url_for, request, render_template
import pyodbc
from controllers.user import is_arrendador
from db import create_connection

def registration():
    img_file = request.files.get("img")
    img_url = None

    if img_file and img_file.filename:
        img_url = f"img/{img_file.filename}"
        save_path = os.path.join("static", "img", img_file.filename)
        img_file.save(save_path)
    else:
        img_url = 'img/icon_def.png'

    nome = request.form["username"]
    email = request.form["reg_email"]
    nacionalidade = request.form["nacionalidade"]
    numero_tele = request.form["numero_telemovel"]
    password = request.form["reg_password"]
    data_nascimento = request.form["data_nascimento"]
    descricao = request.form["descricao"] or None
    peso_str = request.form.get("peso")
    peso = float(peso_str) if peso_str else None
    altura_str = request.form.get("altura")
    altura = float(altura_str) if altura_str else None
    desportos_selecionados = [d for d in request.form.getlist("desportos") if d.strip()]
    desportos_fav = ",".join(desportos_selecionados) if desportos_selecionados else None

    print(f"Nome: {nome}, Email: {email}, Nacionalidade: {nacionalidade}, "
          f"Numero Telefone: {numero_tele}, Password: {password}, "
            f"Data Nascimento: {data_nascimento}, Descricao: {descricao}, "
            f"Peso: {peso}, Altura: {altura}, Desportos Favoritos: {desportos_fav}, "
            f"Imagem URL: {img_url}")

    with create_connection() as conn:
        cursor = conn.cursor()
        existe = cursor.execute("SELECT dbo.UtilizadorExists(?)", (email,)).fetchone()

        # Verifica se o email já existe na base de dados
        try:
            if existe and existe[0] == 1:
                flash("Email já registado. Tente novamente.", "danger")
                return render_template("index.html")
            else:
                # Insere o utilizador na tabela Utilizador usando a stored procedure
                cursor.execute("EXEC CreateUtilizador ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?", 
                (nome, email, numero_tele, password, nacionalidade,
                data_nascimento, descricao, peso, altura, img_url, desportos_fav))
                conn.commit()

                flash("Registo realizado com sucesso!", "success")
                return redirect(url_for("index"))
        except pyodbc.IntegrityError:
            flash("Erro ao registar o utilizador. Tente novamente.", "danger")
            return render_template("index.html")

def log():
    email = request.form["login_email"]
    password = request.form["login_password"]

    """ if email == "admin@admin.pt" and password == "admin":
        session["user_id"] = 0
        session["user_nome"] = "Admin"
        return redirect(url_for("admin.admin_dashboard")) """

    with create_connection() as conn:
        cursor = conn.cursor()
        try:
            cursor.execute("EXEC AuthenticateUtilizador ?, ?", email, password)
            columns = [column[0] for column in cursor.description]  # Pega os nomes das colunas
            row = cursor.fetchone()
            user = dict(zip(columns, row)) if row else None
        except pyodbc.ProgrammingError as e:
            user = None  # Nenhum resultado retornado

    if user and user.get("Success") == 1:
        session["user_id"] = user["ID"]  # Ajusta para o nome da tua coluna de ID
        session["username"] = user["Nome"]  # Ajusta conforme necessário

        tipo_utilizador = "Arrendador" if is_arrendador(user["ID"]) else "Jogador"
        session["tipo_utilizador"] = tipo_utilizador
        print(f"Tipo de utilizador: {tipo_utilizador}")

        flash(f"Login realizado com sucesso! Tipo de utilizador: {tipo_utilizador}", "success")
        return redirect(url_for("dashboard.jog_dashboard", name=user["Nome"]))
    else:
        flash("Email ou password incorretos.", "danger")
        return render_template("index.html")