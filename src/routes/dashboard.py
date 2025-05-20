from flask import Blueprint, abort, request, session, redirect, url_for, flash, render_template
from controllers.campo import adicionar_campo_privado, editar_campo, excluir_campo, get_campo_by_id, get_disponibilidade_por_campo
from controllers.user import add_friend, delete_user_account, get_friends, make_arrendador, update_user_info, get_user_info, listar_campos_arrendador
from utils.decorator_login import login_required
from utils.decorator_login import login_required

dashboard_bp = Blueprint("dashboard", __name__)

@dashboard_bp.route("/user", methods=["GET", "POST"])
@login_required
def jog_dashboard():
    user_id = session["user_id"]
    user = get_user_info(user_id)
    tipo_utilizador = session.get("tipo_utilizador", "Jogador")
    if tipo_utilizador == "Arrendador":
        return render_template("arr_dashboard.html", user=user)
    return render_template("jog_dashboard.html", user=user)

@dashboard_bp.route("/update_info", methods=["GET", "POST"])
@login_required
def update_info():
    user_id = session["user_id"]

    if request.method == "POST":
        # Dados do formulário
        username = request.form["username"]
        email = request.form["email"]
        nationality = request.form["nacionalidade"]
        phone_number = request.form["numero_telemovel"]
        age = request.form.get("idade")
        description = request.form.get("descricao")
        iban = request.form.get("iban", None)

        # Atualizar informações do utilizador
        success, tipo_utilizador, user = update_user_info(
            user_id, username, email, nationality, phone_number, age, description, iban
        )

        if success:
            if tipo_utilizador == "Arrendador":
                return render_template("arr_dashboard.html", user=user)
            else:
                return render_template("jog_dashboard.html", user=user)
        else:
            flash("Erro ao atualizar informações.", "danger")

    user = get_user_info(user_id)
    tipo_utilizador = session.get("tipo_utilizador", "Jogador")
    if tipo_utilizador == "Arrendador":
        return render_template("arr_dashboard.html", user=user)
    else:
        return render_template("jog_dashboard.html", user=user)


@dashboard_bp.route("/delete_account", methods=["GET", "POST"])
@login_required
def delete_account():
    if "user_id" not in session:
        return redirect(url_for("index"))

    if request.method == "POST":
        return delete_user_account()

    return render_template("account_settings.html")


@dashboard_bp.route("/arrendador", methods=["GET", "POST"])
@login_required
def arrendador_form():
    return make_arrendador()

@dashboard_bp.route("/arr_campos_list", methods=["GET", "POST"])
@login_required
def arr_campos_list():
    if request.method == "GET":
        return listar_campos_arrendador()
    
    action = request.form.get("action")

    if action == "add":
        return adicionar_campo_privado()
    elif action == "delete":
        return excluir_campo()
    else:
        flash("Ação inválida.", "danger")
        return redirect(url_for("dashboard.arr_campos_list"))


@dashboard_bp.route("/info_field<ID>", methods=["GET", "POST"])
@login_required
def campo_detail(ID):
    if request.method == "POST":
        editar_campo()
    campo, disponibilidade = get_campo_by_id(ID)
    if not campo:
        abort(404)
    return render_template('campo_details.html', campo=campo, disponibilidade=disponibilidade)
        
@dashboard_bp.route("/amigos/<int:ID>" , methods=["GET", "POST"])
@login_required
def list_friends(ID):
    if "user_id" not in session:
        return redirect(url_for("index"))
    
    if request.method == "GET":
        return get_friends()
    return add_friend()
    
