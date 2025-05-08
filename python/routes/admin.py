from flask import Blueprint
from flask import render_template, request, redirect, url_for, flash
from models.campo import create_campo, get_campos
from models.partidas import get_partidas
from models.user import get_users
from utils.db import create_connection
from utils.decorator_login import login_required
from controllers.user import get_user_info
from utils.decorator_login import login_required

from flask import Blueprint, render_template, request

admin_bp = Blueprint("admin", __name__)

@admin_bp.route("/dashboard", defaults={"section": "users"}, methods=["GET"], endpoint="admin_dashboard")
@admin_bp.route("/dashboard/<section>", methods=["GET"])
@login_required
def admin_dashboard(section):
    # Default values
    context = {}

    if section == "users":
        user_order = request.args.get("user_order", "U.ID")
        user_direction = request.args.get("user_direction", "ASC").upper()
        user_search = request.args.get("user_search", "")
        user_type = request.args.get("user_type", "")
        utilizadores = get_users(user_order, user_direction, user_search, user_type)
        context.update({
            "content": "partials/users_table.html",
            "utilizadores": utilizadores
        })

    elif section == "fields":
        field_order = request.args.get("field_order", "c.ID")
        field_direction = request.args.get("field_direction", "ASC").upper()
        field_search = request.args.get("field_search", "")
        field_type = request.args.get("field_type", "")
        campos = get_campos(field_order, field_direction, field_search, field_type)
        context.update({
            "content": "partials/fields_table.html",
            "campos": campos
        })

    elif section == "matches":
        match_order = request.args.get("match_order", "P.ID")
        match_direction = request.args.get("match_direction", "ASC").upper()
        partidas = get_partidas(match_order, match_direction)
        context.update({
            "content": "partials/matches_table.html",
            "matches": partidas
        })

    elif section == "reservations":
        #TODO: Implementar a lógica para obter as reservas
        reservas = ...
        context.update({
            "content": "partials/reservetions_table.html",
            "reservas": reservas
        })

    else:
        context["content"] = None  # UNKOWN SECTION

    context["section"] = section
    return render_template("admin.html", **context)

# Admin routes - Ações de admin

@admin_bp.route('/add_user', methods=['POST'])
def add_user():
    username = request.form.get('username')
    password = request.form.get('password')
    email = request.form.get('email')
    phone_number = request.form.get('numero_telemovel')
    tipo_utilizador = request.form.get('tipo_utilizador')

    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("INSERT INTO Utilizador (Username, Password, Email, Numero_Telemovel, Tipo_Utilizador) VALUES (?, ?, ?, ?, ?)", (username, password, email, phone_number, tipo_utilizador))
            conn.commit()
        flash("Utilizador adicionado com sucesso!", "success")
    except Exception as e:
        flash(f"Erro ao adicionar utilizador: {str(e)}", "danger")

    return redirect(url_for('admin_dashboard'))

@admin_bp.route('/add_field', methods=['POST'])
def add_field():
    #Informações do campo
    nome = request.form.get('nome')
    comprimento = request.form.get('comprimento')
    largura = request.form.get('largura')
    descricao = request.form.get('descricao', '')
    latitude = float(request.form.get('latitude'))
    longitude = float(request.form.get('longitude'))

    # Informações do campo publico
    entidade_publica = request.form.get('entR')
    id_campo = create_campo(nome, comprimento, largura, descricao, latitude, longitude)
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("INSERT INTO Campo_Pub (ID_Campo, Entidade_publica_resp) VALUES (?, ?)", (id_campo, entidade_publica,))
            conn.commit()
        flash("Campo público adicionado com sucesso!", "success")
    except Exception as e:
        flash(f"Erro ao adicionar campo: {str(e)}", "danger")

    return redirect(url_for('admin_dashboard'))

@admin_bp.route('/add_match', methods=['POST'])
def add_match():
    id_campo = request.form.get('id_campo')
    data_partida = request.form.get('data_partida')
    hora_inicio = request.form.get('hora_inicio')
    hora_fim = request.form.get('hora_fim')

    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("INSERT INTO Partida (ID_Campo, Data, Hora_inicio, Hora_fim) VALUES (?, ?, ?, ?)", (id_campo, data_partida, hora_inicio, hora_fim))
            conn.commit()
        flash("Partida adicionada com sucesso!", "success")
    except Exception as e:
        flash(f"Erro ao adicionar partida: {str(e)}", "danger")

    return redirect(url_for('admin_dashboard'))

@admin_bp.route('/add_reservation', methods=['POST'])
def add_reservation():
    id_partida = request.form.get('id_partida')
    id_utilizador = request.form.get('id_utilizador')

    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("INSERT INTO Reserva (ID_Partida, ID_Utilizador) VALUES (?, ?)", (id_partida, id_utilizador))
            conn.commit()
        flash("Reserva adicionada com sucesso!", "success")
    except Exception as e:
        flash(f"Erro ao adicionar reserva: {str(e)}", "danger")

    return redirect(url_for('admin_dashboard'))

@admin_bp.route('/delete_match', methods=['POST'])
def delete_match():
    id_partida = request.form.get('id_partida')
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM Partida WHERE ID=?", (id_partida,))
            conn.commit()
        flash("Partida excluída com sucesso!", "success")
    except Exception as e:
        flash(f"Erro ao excluir partida: {str(e)}", "danger")

    return redirect(url_for('admin_dashboard'))

@admin_bp.route('/delete_field', methods=['POST'])
def delete_field():
    id_campo = request.form.get('id_campo')
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM Campo WHERE ID_Campo=?", (id_campo,))
            conn.commit()
        flash("Campo excluído com sucesso!", "success")
    except Exception as e:
        flash(f"Erro ao excluir campo: {str(e)}", "danger")

    return redirect(url_for('admin_dashboard'))

@admin_bp.route('/delete_user', methods=['POST'])
def delete_user():
    id_utilizador = request.form.get('id_utilizador')
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM Utilizador WHERE ID=?", (id_utilizador,))
            conn.commit()
        flash("Utilizador excluído com sucesso!", "success")
    except Exception as e:
        flash(f"Erro ao excluir utilizador: {str(e)}", "danger")

    return redirect(url_for('admin_dashboard'))

@admin_bp.route('/delete_reservation', methods=['POST'])
def delete_reservation():
    id_reserva = request.form.get('id_reserva')
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM Reserva WHERE ID=?", (id_reserva,))
            conn.commit()
        flash("Reserva excluída com sucesso!", "success")
    except Exception as e:
        flash(f"Erro ao excluir reserva: {str(e)}", "danger")

    return redirect(url_for('admin_dashboard'))

@admin_bp.route('/edit_matches', methods=['POST'])
def edit_match():
    id_partida = request.form.get('id_partida')
    id_campo = request.form.get('id_campo')
    data_partida = request.form.get('data_partida')
    hora_inicio = request.form.get('hora_inicio')
    hora_fim = request.form.get('hora_fim')

    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("UPDATE Partida SET ID_Campo=?, Data=?, Hora_inicio=?, Hora_fim=? WHERE ID=?", (id_campo, data_partida, hora_inicio, hora_fim, id_partida))
            conn.commit()
        flash("Partida editada com sucesso!", "success")
    except Exception as e:
        flash(f"Erro ao editar partida: {str(e)}", "danger")

    return redirect(url_for('admin_dashboard'))

@admin_bp.route('/edit_fields', methods=['POST'])
def edit_field():
    id_campo = request.form.get('id_campo')
    nome = request.form.get('nome')
    comprimento = request.form.get('comprimento')
    largura = request.form.get('largura')
    descricao = request.form.get('descricao', '')
    latitude = float(request.form.get('latitude'))
    longitude = float(request.form.get('longitude'))

    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("UPDATE Campo SET Nome=?, Comprimento=?, Largura=?, Descricao=?, Latitude=?, Longitude=? WHERE ID_Campo=?", (nome, comprimento, largura, descricao, latitude, longitude, id_campo))
            conn.commit()
        flash("Campo editado com sucesso!", "success")
    except Exception as e:
        flash(f"Erro ao editar campo: {str(e)}", "danger")

    return redirect(url_for('admin_dashboard'))

@admin_bp.route('/edit_reservation', methods=['POST'])
def edit_reservation():
    id_reserva = request.form.get('id_reserva')
    id_partida = request.form.get('id_partida')
    id_utilizador = request.form.get('id_utilizador')

    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("UPDATE Reserva SET ID_Partida=?, ID_Utilizador=? WHERE ID=?", (id_partida, id_utilizador, id_reserva))
            conn.commit()
        flash("Reserva editada com sucesso!", "success")
    except Exception as e:
        flash(f"Erro ao editar reserva: {str(e)}", "danger")

    return redirect(url_for('admin_dashboard'))

@admin_bp.route('/edit_user', methods=['POST'])
def edit_user():
    id_utilizador = request.form.get('id_utilizador')
    username = request.form.get('username')
    password = request.form.get('password')
    email = request.form.get('email')
    phone_number = request.form.get('numero_telemovel')
    tipo_utilizador = request.form.get('tipo_utilizador')

    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("UPDATE Utilizador SET Username=?, Password=?, Email=?, Numero_Telemovel=?, Tipo_Utilizador=? WHERE ID=?", (username, password, email, phone_number, tipo_utilizador, id_utilizador))
            conn.commit()
        flash("Utilizador editado com sucesso!", "success")
    except Exception as e:
        flash(f"Erro ao editar utilizador: {str(e)}", "danger")

    return redirect(url_for('admin_dashboard'))