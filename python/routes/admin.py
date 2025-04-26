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

@admin_bp.route("/admin", methods=["GET", "POST"])
@login_required
def admin_dashboard():
    utilizadores = get_users()
    campos = get_campos()
    partidas = get_partidas()
    return render_template("admin.html", utilizadores=utilizadores, campos=campos, matches=partidas)


@admin_bp.route('/admin/add_field', methods=['POST'])
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

@admin_bp.route('/admin/delete_field', methods=['POST'])
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

@admin_bp.route('/admin/delete_user', methods=['POST'])
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

@admin_bp.route('/admin/edit_user', methods=['POST'])
def edit_user():
    id_utilizador = request.form.get('id_utilizador')
    username = request.form.get('username')
    email = request.form.get('email')
    phone_number = request.form.get('numero_telemovel')