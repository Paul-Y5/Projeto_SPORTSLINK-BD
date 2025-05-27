from flask import Blueprint, abort, request, session, redirect, url_for, flash, render_template
from controllers.campo import adicionar_campo_privado, editar_campo, excluir_campo, get_campo_by_id, getReservasByCampo
from controllers.user import add_friend, delete_user_account, get_InfoFriend, get_friends, getHistoricPartidas, make_arrendador, remove_friend, update_user_info, get_user_info, list_campos_arrendador
from utils.decorator_login import login_required
from utils.decorator_login import login_required
from utils.general import get_siglas_dias

dashboard_bp = Blueprint("dashboard", __name__)

@dashboard_bp.route("/user", methods=["GET", "POST"])
@login_required
def jog_dashboard():
    user_id = session["user_id"]
    user = get_user_info(user_id)
    tipo_utilizador = session.get("tipo_utilizador", "Jogador")
    if request.method == "POST":
        action = request.form.get("action")
        if action == "delete":
            return delete_user_account()
        elif action == "update":
            return update_user_info()
    if tipo_utilizador == "Arrendador":
        return render_template("arr_dashboard.html", user=user)
    return render_template("jog_dashboard.html", user=user)


@dashboard_bp.route("/arrendador", methods=["GET", "POST"])
@login_required
def arrendador_form():
    return make_arrendador()

@dashboard_bp.route("/arr_campos_list", methods=["GET", "POST"])
@login_required
def arr_campos_list():
    if request.method == "GET":
        return list_campos_arrendador()
    
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
        editar_campo(ID)

    campo, disponibilidade = get_campo_by_id(ID)
    reservas = getReservasByCampo(ID)

    if not campo:
        abort(404)

    # Essas variáveis são locais e passadas ao template via render_template
    siglas_dias = get_siglas_dias().items()
    dias_ativos = [d['dia'] for d in disponibilidade]

    return render_template(
        'campo_details.html',
        campo=campo,
        disponibilidade=disponibilidade,
        reservas=reservas,
        siglas_dias=siglas_dias,
        dias_ativos=dias_ativos
    )

@dashboard_bp.route("/amigos/<int:ID>", methods=["GET", "POST"])
@login_required
def list_friends(ID):
    if "user_id" not in session:
        return redirect(url_for("index"))

    if request.method == "GET":
        action = request.args.get("action")
        friend_id = request.args.get("friend_id")

        if action == "delete" and friend_id:
            remove_friend(friend_id)

        if action == "detail":
            return get_InfoFriend()
        
        return get_friends()

    return add_friend()

@dashboard_bp.route("/historico<int:ID>", methods=["GET"])
@login_required
def historic_partidas(ID):
    if "user_id" not in session:
        return redirect(url_for("index"))

    user_id = session["user_id"]
    try:
        HistoricPartidas = getHistoricPartidas(ID)
        print(HistoricPartidas)
        return render_template("historico_partidas.html", partidas=HistoricPartidas, user_id=user_id)
    except Exception as e:
        flash(f"Erro ao carregar o histórico de partidas{e}.", "danger")
        return redirect(url_for("dashboard.jog_dashboard"))




    
