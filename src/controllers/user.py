from datetime import datetime
from flask import flash, redirect, render_template, request, session, url_for
from db import create_connection
from utils.general import get_dias_semana, get_siglas_dias
import json


def get_user_info(user_id):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("GetUserInfo ?", (user_id,))
            user_info = cursor.fetchone()
        return user_info if user_info else None
    except Exception as e:
        print(f"Erro ao obter informações do usuário: {e}")
        return None

def update_user_info():
    """Atualiza informações do utilizador, jogador e arrendador via UpdateUserInfo."""
    import json  # garantir que json está importado

    username = request.form["username"]
    email = request.form["email"]
    nationality = request.form["nacionalidade"]
    phone_number = request.form["numero_telemovel"]
    description = request.form.get("descricao")
    iban = request.form.get("iban")
    no_campos = request.form.get("no_campos")
    password = request.form.get("password")
    data_nascimento = request.form.get("data_nascimento")
    peso = request.form.get("peso")
    altura = request.form.get("altura")
    url_imagem = request.form.get("url_imagem")
    met_pagamento_list = request.form.getlist("metodos_pagamento")

    # Detalhes enviados pelo formulário
    detalhe_map = {
        "CC": request.form.get("detalhe_CC"),
        "MBWay": request.form.get("detalhe_MBWay"),
        "PayPal": request.form.get("detalhe_PayPal"),
        "Transferência Bancária": iban  # o detalhe de Transferência Bancária é o próprio IBAN
    }

    map_metodos = {
        "CartaoCredito": "CC",
        "CC": "CC",
        "PayPal": "PayPal",
        "MBWay": "MBWay",
        "Transferência Bancária": "Transferência Bancária",
        "Transferencia Bancaria": "Transferência Bancária"
    }

    metodos_pagamento_json = []

    # Adiciona todos os métodos do form
    for m in met_pagamento_list:
        mapped = map_metodos.get(m)
        if mapped:
            detalhes = detalhe_map.get(mapped)
            if detalhes:
                metodos_pagamento_json.append({
                    "Metodo": mapped,
                    "Detalhes": detalhes
                })
        else:
            print(f"Método de pagamento inesperado: {m}")

    # Garante que "Transferência Bancária" entra sempre que houver IBAN
    if iban:
        if not any(m["Metodo"] == "Transferência Bancária" for m in metodos_pagamento_json):
            metodos_pagamento_json.append({
                "Metodo": "Transferência Bancária",
                "Detalhes": iban
            })

    metodos_pagamento_str = json.dumps(metodos_pagamento_json)
    user_id = session.get("user_id")

    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                EXEC UpdateUserInfo 
                    @UserID = ?, 
                    @Nome = ?, 
                    @Email = ?, 
                    @Num_Tele = ?, 
                    @Nacionalidade = ?, 
                    @Password = ?, 
                    @Descricao = ?, 
                    @IBAN = ?, 
                    @No_Campos = ?,
                    @Data_Nascimento = ?,
                    @Peso = ?,
                    @Altura = ?,
                    @URL_Imagem = ?,
                    @MetodosPagamento = ?
            """, (
                user_id,
                username,
                email,
                phone_number,
                nationality,
                password,
                description,
                iban,
                no_campos,
                data_nascimento,
                peso,
                altura,
                url_imagem,
                metodos_pagamento_str
            ))
            conn.commit()
            flash("Dados atualizados com sucesso!", "success")
            return redirect(url_for("dashboard.jog_dashboard", name=username))
    except Exception as e:
        print(f"Erro ao atualizar dados: {e}")
        flash(f"Erro ao atualizar dados: {str(e)}", "danger")
        return redirect(url_for("dashboard.jog_dashboard", name=session.get("username")))
    
def delete_user_account():
    user_id = session["user_id"]
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC DeleteUtilizador ?", (user_id,))
            conn.commit()
        session.clear()
        return redirect(url_for("index"))
    except Exception as e:
        flash(f"Erro ao excluir conta: {str(e)}", "danger")
        return redirect(url_for("dashboard.jog_dashboard"))


def make_arrendador():
    if "user_id" not in session:
        flash("ERROR: Utilizador não encontrado.", "danger")
        return redirect(url_for("index"))

    user_id = session["user_id"]
    iban = request.form["iban"]

    metodos = request.form.getlist("metodo")
    detalhes_json = []

    for metodo in metodos:
        detalhe = request.form.get(f"detalhe_{metodo}", "")
        detalhes_json.append({
            "Metodo": metodo,
            "Detalhes": detalhe
        })

    #(Por default tem sempre o metodo de pagamento por IBAN)
    detalhes_json.append({
        "Metodo": "Transferência Bancária",
        "Detalhes": iban
    })

    json_final = json.dumps(detalhes_json)
    print(f"JSON Final: {json_final}")

    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute(
                "EXEC CreateArrendador @ID_Utilizador = ?, @IBAN = ?, @MetodosPagamento = ?",
                (user_id, iban, json_final)
            )
            conn.commit()

        session["tipo_utilizador"] = "Arrendador"
        flash("Agora és um arrendador!", "success")
        return redirect(url_for("dashboard.jog_dashboard", name=session["username"]))
    except Exception as e:
        flash(f"Erro ao tornar-se arrendador: {str(e)}", "danger")
        return redirect(url_for("dashboard.jog_dashboard", name=session["username"]))


def list_campos_arrendador():
    user_id = session.get("user_id")
    if not user_id:
        return redirect(url_for("auth.login"))
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC GetCamposByUser ?", (user_id,))
            campos = cursor.fetchall()

        return render_template(
            "arr_campos_list.html",
            user_id=user_id,
            campos=campos,
            siglas_dias=get_siglas_dias().items(),
            dias=get_dias_semana().items()
        )
    except Exception as e:
        flash(f"Erro ao listar campos: {str(e)}", "danger")
        return render_template(
            "arr_campos_list.html",
            user_id=user_id,
            campos=[],
            siglas_dias=get_siglas_dias().items(),
            dias=get_dias_semana().items()
        )

def get_friends():
    user_id = session.get("user_id")
    if not user_id:
        flash("Utilizador não encontrado.", "danger")
        return redirect(url_for("index"))
    
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            # Chama a stored procedure para obter os amigos do utilizador
            cursor.execute("EXEC GetFriends ?", (user_id,))
            amigos = cursor.fetchall()
        return render_template("lista_amigos.html", user_id=user_id, amigos=amigos)
    except Exception as e:
        print(f"Erro ao obter informações do utilizador: {e}")
        flash("Erro ao carregar os amigos.", "danger")
        return render_template("lista_amigos.html", user_id=user_id, amigos=[])

def add_friend():
    id_friend = request.form["ID_Amigo"]
    if not id_friend:
        flash("Deves escolher um amigo para adicionar.", "danger")
        return redirect(url_for("dashboard.list_friends", ID=session["user_id"]))
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            # Chama a stored procedure para adicionar um amigo
            cursor.execute("EXEC AddFriend ?, ?", (session["user_id"], id_friend))
            conn.commit()
        flash("Amigo adicionado com sucesso!", "success")
        return redirect(url_for("dashboard.list_friends", ID=session["user_id"]))
    except Exception as e:
        print(f"Erro ao adicionar amigo: {e}")
        flash("Erro ao adicionar amigo.", "danger")
        return redirect(url_for("dashboard.list_friends", ID=session["user_id"]))
    

def remove_friend(friend_id):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC RemoveFriend @UserID = ?, @FriendID = ?", (session.get("user_id"), int(friend_id)))
            conn.commit()
        flash("Amigo removido com sucesso!", "success")
    except Exception as e:
        flash(f"Erro ao remover amigo: {str(e)}", "danger")


def get_InfoFriend():
    friend_id = request.args.get("friend_id")
    if not friend_id:
        flash("ID do amigo não fornecido.", "danger")
        return redirect(url_for("dashboard.list_friends", ID=session["user_id"]))
    
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC GetFriendInfo ?", (friend_id,))
            friend_info = cursor.fetchone()
        if not friend_info:
            flash("Amigo não encontrado.", "warning")
            return redirect(url_for("dashboard.list_friends", ID=session["user_id"]))
        return render_template("amigo_details.html", user=friend_info)
    except Exception as e:
        flash(f"Erro ao carregar informações do amigo. [{e}]", "danger")
        return redirect(url_for("dashboard.list_friends", ID=session["user_id"]))


def getHistoricPartidas(user_id):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC GetHistoricPartidas ?", (user_id,))
            partidas = cursor.fetchall()
        return partidas
    except Exception as e:
        flash("Erro ao carregar o histórico de partidas.", "danger")
        return []
    

def agendar_reserva(campo_id):
    """Cria uma reserva de campo para o jogador."""
    id_jogador = session["user_id"]
    if request.method == "POST":
        try:
            data = request.form.get("data")
            hora_inicio = request.form.get("hora_inicio")
            hora_fim = request.form.get("hora_fim")
            estado = "Confirmada"  # Estado inicial da reserva deveria ser "Pendente" e depois alterado pelo arrendador, mas para simplificar, vamos deixar como "Confirmada"
            descricao = request.form.get("descricao", None)

            print(f"Dados da reserva: {data}, {hora_inicio}, {hora_fim}, {estado}, {descricao}")

            # Estabelecer conexão com o banco de dados e executar o procedimento
            with create_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(
                    "EXEC CreateReserva @ID_Campo=?, @ID_Jogador=?, @Data=?, @Hora_Inicio=?, @Hora_Fim=?, @Estado=?, @Descricao=?",
                    (campo_id, id_jogador, data, hora_inicio, hora_fim, estado, descricao)
                )
                conn.commit()

            flash("Reserva realizada com sucesso!", "success")
            return redirect(url_for("dashboard.jog_dashboard"))

        except Exception as e:
            flash(f"Erro ao criar reserva: {str(e)}", "danger")
            return redirect(url_for("dashboard.campo_detail", ID=campo_id))

def get_reservas(user_id):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC GetReservasByUser ?", (user_id,))
            reservas = cursor.fetchall()
        return reservas
    except Exception as e:
        flash(f"Erro ao obter reservas: {str(e)}", "danger")
        return []
    
def cancelar_reserva(reserva_id):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC DeleteReserva ?", (reserva_id,))
            conn.commit()
        return True
    except Exception as e:
        return False
    
    
# Auxiiares
def is_arrendador(user_id):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT dbo.fn_IsArrendador(?)", user_id)
            is_arrendador = cursor.fetchone()[0]
            return bool(is_arrendador)
    except Exception as e:
        print(f"Erro ao verificar se o usuário é arrendador: {e}")
        return False

