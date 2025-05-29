from flask import Blueprint, abort, request, session, redirect, url_for, flash, render_template
from controllers.campo import adicionar_campo_privado, adicionar_campo_publico, editar_campo, excluir_campo, get_campo_by_id, get_campos, getReservasByCampo
from controllers.user import add_friend, cancelar_reserva, delete_user_account, get_InfoFriend, get_friends, getHistoricPartidas, get_reservas, make_arrendador, remove_friend, update_user_info, get_user_info, list_campos_arrendador
from utils.decorator_login import login_required
from utils.general import get_siglas_dias

dashboard_bp = Blueprint("dashboard", __name__)

@dashboard_bp.route("/user", methods=["GET", "POST"])
@login_required
def jog_dashboard():
    user_id = session["user_id"]
    user = get_user_info(user_id)
    tipo_utilizador = session.get("tipo_utilizador", "Jogador")
    reservas = get_reservas(user_id)
    
    action = request.args.get("action")
    if request.method == "POST":
        action = request.form.get("action")
        if action == "delete":
            return delete_user_account()
        elif action == "update":
            return update_user_info()
        elif action == "add_field":
            return adicionar_campo_publico()
        elif action == "cancel_reserva":
            reserva_id = request.form.get("reserva_id")
            if reserva_id:
                cancelar_reserva(reserva_id)
            else:
                print("Reserva ID não fornecido para cancelamento.")
    
    if action == "view_fields":
        return ver_campos()
    
    if tipo_utilizador == "Arrendador":
        return render_template("arr_dashboard.html", user=user, reservas=reservas)
    return render_template("jog_dashboard.html", user=user, reservas=reservas)


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
    
@dashboard_bp.route("/campos", methods=["GET"])
@login_required
def ver_campos():
    tipo = request.args.get("tipo")
    if tipo not in ["Publico", "Privado"]:
        flash("Tipo de campo inválido.", "danger")
        return redirect(url_for("dashboard.jog_dashboard"))

    campos = get_campos(tipo)
    print(tipo)
    if campos is None:
        flash("Erro ao carregar os campos.", "danger")
        return redirect(url_for("dashboard.jog_dashboard"))

    return render_template("list_campos.html", campos=campos, tipo=tipo)


@dashboard_bp.route("/info_field/<int:ID>", methods=["GET", "POST"])
@login_required
def campo_detail(ID):
    if request.method == "POST":
        editar_campo(ID)

    campo, disponibilidade = get_campo_by_id(ID)
    if not campo:
        print("Campo não encontrado")

    reservas = getReservasByCampo(ID)

    disponibilidade_dict = {item['dia'].lower(): item for item in disponibilidade}

    if not campo:
        abort(404)

    print(f"Campo encontrado: {campo}")

    if campo["ID_Arrendador"] == session["user_id"]:
        #print("Campo é do arrendador")
        template = 'campo_details.html'
    else:
        #print("Campo não é do arrendador")
        template = 'campo_details2.html'


    # Estas variáveis são locais e passadas ao template via render_template
    siglas_dias = get_siglas_dias().items()
    dias_ativos = [d['dia'] for d in disponibilidade]

    return render_template(
        template,
        campo=campo,
        disponibilidade=disponibilidade,
        disponibilidade_dict=disponibilidade_dict,
        reservas=reservas,
        siglas_dias=siglas_dias,
        dias_ativos=dias_ativos
    )

@dashboard_bp.route("/amigos", methods=["GET", "POST"])
@login_required
def list_friends():
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


@dashboard_bp.route("/historico/<int:ID>", methods=["GET"])
@login_required
def historic_partidas(ID):
    user_id = session["user_id"]
    try:
        HistoricPartidas = getHistoricPartidas(ID)
        print(HistoricPartidas)
        return render_template("historico_partidas.html", partidas=HistoricPartidas, user_id=user_id)
    except Exception as e:
        flash(f"Erro ao carregar o histórico de partidas{e}.", "danger")
        return redirect(url_for("dashboard.jog_dashboard"))

