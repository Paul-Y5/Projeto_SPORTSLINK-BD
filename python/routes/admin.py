from flask import Blueprint
from flask import render_template, request, redirect, url_for, flash
from models.campo import create_campo, get_campos
from models.partidas import get_partidas
from models.user import get_users
from utils.db import create_connection
from utils.decorator_login import login_required
from controllers.user import get_user_info
from utils.decorator_login import login_required

admin_bp = Blueprint("admin", __name__)
@admin_bp.route("/dashboard", defaults={"section": "users"}, methods=["GET"], endpoint="admin_dashboard")
@admin_bp.route("/dashboard/<section>", methods=["GET"])
@login_required
def admin_dashboard(section):
    is_htmx = "HX-Request" in request.headers

    if section == "users":
        user_order = request.args.get("user_order", "U.ID")
        user_direction = request.args.get("user_direction", "ASC").upper()
        user_search = request.args.get("user_search", "")
        user_type = request.args.get("user_type", "")
        utilizadores = get_users(user_order, user_direction, user_search, user_type)

        if is_htmx:
            return render_template("partials/users_table.html", utilizadores=utilizadores)
        else:
            return render_template("admin.html", content="partials/users_table.html", utilizadores=utilizadores)

    elif section == "fields":
        field_order = request.args.get("field_order", "c.ID")
        field_direction = request.args.get("field_direction", "ASC").upper()
        field_search = request.args.get("field_search", "")
        field_type = request.args.get("field_type", "")
        campos = get_campos(field_order, field_direction, field_search, field_type)

        if is_htmx:
            return render_template("partials/fields_table.html", campos=campos)
        else:
            return render_template("admin.html", content="partials/fields_table.html", campos=campos)

    elif section == "matches":
        match_order = request.args.get("match_order", "P.ID")
        match_direction = request.args.get("match_direction", "ASC").upper()
        partidas = get_partidas(match_order, match_direction)

        if is_htmx:
            return render_template("partials/matches_table.html", matches=partidas)
        else:
            return render_template("admin.html", content="partials/matches_table.html", matches=partidas)

    return render_template("admin.html", content=None)


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

@admin_bp.route('/edit_user', methods=['POST'])
def edit_user():
    id_utilizador = request.form.get('id_utilizador')
    username = request.form.get('username')
    email = request.form.get('email')
    phone_number = request.form.get('numero_telemovel')