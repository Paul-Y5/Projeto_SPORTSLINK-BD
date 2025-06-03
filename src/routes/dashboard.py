from flask import Blueprint, abort, request, session, redirect, url_for, flash, render_template
from controllers.campo import adicionar_campo_privado, adicionar_campo_publico, editar_campo, excluir_campo, get_campo_by_id, get_campos, getReservasByCampo
from controllers.partidas import create_partida, entrar_Partida, get_Partida, get_Partidas_Abertas, sair_Partida
from controllers.user import add_friend, agendar_reserva, cancelar_reserva, delete_user_account, get_InfoFriend, get_friends, getHistoricPartidas, get_reservas, inGame, make_arrendador, rate_friend, remove_friend, update_user_info, get_user_info, list_campos_arrendador
from utils.decorator_login import login_required
from utils.general import get_siglas_dias

dashboard_bp = Blueprint("dashboard", __name__)

@dashboard_bp.route("/user", methods=["GET", "POST"])
@login_required
def jog_dashboard():
    user_id = session["user_id"]
    user, ratings = get_user_info(user_id)
    print(f"User info: {user}")
    tipo_utilizador = session.get("tipo_utilizador", "Jogador")
    reservas = get_reservas(user_id)
    ongoing_match = inGame(user_id)

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
            reserva_id = request.form.get("reserva_id", type=int)
            if reserva_id:
                result = cancelar_reserva(reserva_id)
                if result:
                    flash("Reserva cancelada com sucesso.", "success")
                else:
                    flash("Erro ao cancelar a reserva.", "danger")
                return redirect(url_for("dashboard.jog_dashboard"))
            else:
                flash("ID da reserva não fornecido.", "danger")
                return redirect(url_for("dashboard.jog_dashboard"))
    
    if action == "view_fields":
        return ver_campos()
    
    if tipo_utilizador == "Arrendador":
        return render_template("arr_dashboard.html", user=user, reservas=reservas, ongoing_match=ongoing_match, ratings=ratings)
    return render_template("jog_dashboard.html", user=user, reservas=reservas, ongoing_match=ongoing_match, ratings=ratings)


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
    """     print(f"Campos obtidos: {campos}")
        print(tipo) """
    if campos is None:
        flash("Erro ao carregar os campos.", "danger")
        return redirect(url_for("dashboard.jog_dashboard"))

    return render_template("list_campos.html", campos=campos, tipo=tipo)


@dashboard_bp.route("/info_field/<int:ID>", methods=["GET", "POST"])
@login_required
def campo_detail(ID):
     # Obtém os dados do campo e sua disponibilidade
    campo, disponibilidade = get_campo_by_id(ID)
    if campo is None:
        flash("Campo não encontrado.", "danger")
        return redirect(url_for("dashboard.jog_dashboard"))

    # Se o campo é privado (tem arrendador), procura as reservas
    reservas = getReservasByCampo(ID) if campo['ID_Arrendador'] else []

    # Cria um dicionário de disponibilidade para acesso fácil no template
    disponibilidade_dict = {item['dia'].lower(): item for item in disponibilidade}

    # Define as variáveis adicionais para o template
    siglas_dias = get_siglas_dias().items()
    dias_ativos = [d['dia'] for d in disponibilidade]

    if not campo:
        abort(404)

    if campo["ID_Arrendador"] == session["user_id"]:
        if request.method == "POST":
            editar_campo(ID)
            campo, disponibilidade = get_campo_by_id(ID)
        #print("Campo é do arrendador")
        template = 'campo_details.html'
    else:
        if request.method == "POST":
            action = request.form.get("action")
            if action == "agendar_reserva":
                return agendar_reserva(ID)
        #print("Campo não é do arrendador")
        template = 'campo_details2.html'

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


@dashboard_bp.route("/list_partidas", methods=["GET", "POST"])
@login_required
def list_partidas():
    try:
        if request.method == "POST":
            action = request.form.get("action")
            if action == "entrar_partida":
                partida_id = request.form.get("partida_id")
                return entrar_Partida(partida_id)  # Retorna o resultado diretamente
        
        nome_campo = request.form.get('nome_campo')
        distancia = request.form.get('distancia', type=float) if request.form.get('distancia') else None
        latitude = request.form.get('user_lat', type=float) if request.form.get('user_lat') else None
        longitude = request.form.get('user_lon', type=float) if request.form.get('user_lon') else None
        order_by = request.form.get('order_by', 'Distancia')
        order_direction = request.form.get('order_direction', 'ASC')

        partidas = get_Partidas_Abertas(nome_campo, distancia, latitude, longitude, order_by, order_direction)
        #print(f"Partidas encontradas: {partidas}")
        if not partidas:
            flash("Nenhuma partida encontrada.", "info")
            return render_template("list_partidas.html", partidas=[])
        return render_template("list_partidas.html", partidas=partidas)
    except Exception as e:
        flash(f"Erro ao carregar partidas: {e}", "danger")
        return redirect(url_for("dashboard.jog_dashboard"))

# Rota para iniciar uma nova partida
@dashboard_bp.route("/partida/<int:campo_id>/nova", methods=["POST"])
@login_required
def start_new_partida(campo_id):
    try:
        partida_id = create_partida(campo_id)
        return redirect(url_for('dashboard.get_partida', partida_id=partida_id))
    except Exception as e:
        flash(f"Erro ao iniciar partida: {str(e)}", "danger")
        return redirect(url_for("dashboard.jog_dashboard"))

@dashboard_bp.route("/partida/<int:partida_id>", methods=["GET", "POST"])
@login_required
def get_partida(partida_id):
    try:
        partida = get_Partida(partida_id)
        if not partida:
            flash("Partida não encontrada.", "danger")
            return redirect(url_for("dashboard.list_partidas"))

        if request.method == "POST":
            action = request.form.get("action")
            if action == "sair_partida":
                return sair_Partida(partida_id)

        return render_template("partida_details.html", partida=partida)

    except Exception as e:
        print(f"Erro ao carregar partida: {str(e)}")  # Log para depuração
        flash(f"Erro ao carregar a partida: {str(e)}", "danger")
        return redirect(url_for("dashboard.list_partidas"))
    

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

@dashboard_bp.route("/rate_friend", methods=["POST"])
@login_required
def rate_friend_route():
    if "user_id" not in session:
        flash("Sessão expirada. Faça login novamente.", "danger")
        return redirect(url_for("index"))
    
    friend_id = request.form.get("friend_id")
    rating = request.form.get("rating")
    comment = request.form.get("comment", "")
    
    user_id = session["user_id"]
    
    if rate_friend(user_id, friend_id, rating, comment):
        flash("Avaliação enviada com sucesso!", "success")
    else:
        flash("Erro ao enviar avaliação. Tente novamente.", "danger")
    
    return redirect(url_for("dashboard.list_friends", action="detail", friend_id=friend_id))