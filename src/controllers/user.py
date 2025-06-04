from datetime import datetime
import os
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

            # Obter avaliações de avaliadores que avaliaram o amigo
            cursor.execute("EXEC GetRatings ?", (user_id,))
            ratings_data = cursor.fetchall()

        # Mapear avaliações para lista de dicionários
        ratings = [
            {
                "Nome": rating.Nome,
                "Avaliacao": rating.Avaliacao,
                "Comentario": rating.Comentario,
                "DataAvaliacao": rating.Data_Hora if isinstance(rating.Data_Hora, datetime) else datetime.strptime(rating.Data_Hora, '%Y-%m-%d %H:%M:%S')
            }
            for rating in ratings_data
        ]
        return user_info, ratings
    except Exception as e:
        print(f"Erro ao obter informações do usuário: {e}")
        return None, []

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
    url_imagem = request.files.get("url_imagem")
    if url_imagem and url_imagem.filename:
        img_url = f"img/{url_imagem.filename}"
        save_path = os.path.join("static", "img", url_imagem.filename)
        url_imagem.save(save_path)
    else:
        img_url = None
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
                img_url,
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
            
            # Obter informações do amigo
            cursor.execute("EXEC GetFriendInfo ?", (friend_id,))
            friend_data = cursor.fetchone()
            
            if not friend_data:
                flash("Amigo não encontrado.", "warning")
                return redirect(url_for("dashboard.list_friends", ID=session["user_id"]))
            
            # Mapear colunas para dicionário
            friend_info = {
                "ID_Utilizador": friend_data.ID_Utilizador,
                "Nome": friend_data.Nome,
                "Nacionalidade": friend_data.Nacionalidade,
                "Imagem": friend_data.Imagens_Perfil,
                "Data_Nascimento": friend_data.Data_Nascimento if friend_data.Data_Nascimento else None,
                "Idade": friend_data.Idade,
                "Peso": friend_data.Peso,
                "Altura": friend_data.Altura,
                "Desportos_Favoritos": friend_data.Desportos_Favoritos,
                "DescricaoJogador": friend_data.DescricaoJogador
            }
            
            # Obter avaliações de avaliadores que avaliaram o amigo
            cursor.execute("EXEC GetRatings ?", (friend_id,))
            ratings_data = cursor.fetchall()
            
            # Mapear avaliações para lista de dicionários
            ratings = [
                {
                    "Nome": rating.Nome,
                    "Avaliacao": rating.Avaliacao,
                    "Comentario": rating.Comentario,
                    "DataAvaliacao": rating.Data_Hora if isinstance(rating.Data_Hora, datetime) else datetime.strptime(rating.Data_Hora, '%Y-%m-%d %H:%M:%S')
                }
                for rating in ratings_data
            ]

            print(f"Informações do amigo: {friend_info}")
            print(f"Avaliações do amigo: {ratings}")
            
            return render_template("amigo_details.html", user=friend_info, ratings=ratings)
            
    except Exception as e:
        flash(f"Erro ao carregar informações do amigo: {str(e)}", "danger")
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
            print(f"Reservas obtidas: {reservas}")
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
            cursor.execute("SELECT dbo.IsArrendador(?)", user_id)
            is_arrendador = cursor.fetchone()[0]
            return bool(is_arrendador)
    except Exception as e:
        print(f"Erro ao verificar se o usuário é arrendador: {e}")
        return False

def rate_friend(user_id, friend_id, rating, comment):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            
            # Data e hora atual
            current_datetime = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            
            # Chamar a stored procedure AddRating
            # @IsCampo = 0 porque é uma avaliação de jogador
            cursor.execute("EXEC AddRating ?, ?, ?, ?, ?, ?", 
                          (user_id, friend_id, rating, comment, current_datetime, 0))
            
            # Obter o resultado
            result = cursor.fetchone()
            if result and result[0] == 1:
                return True
            else:
                flash(result[1] if result else "Erro desconhecido ao avaliar jogador.", "danger")
                return False
                
    # Faltou implementar rating a campos, mas vamos manter o foco em jogadores (apenas para demonstrar a lógica)
    
    except Exception as e:
        flash(f"Erro ao avaliar jogador: {str(e)}", "danger")
        return False

def inGame(user_id):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()

            # Verificar se o jogador está em uma partida usando IsPlayerOnMatch
            cursor.execute("SELECT dbo.IsPlayerOnMatch(?) AS IsInMatch", (user_id,))
            is_in_match = cursor.fetchone()[0]

            if not is_in_match:
                cursor.close()
                return None

            cursor.close()
            cursor = conn.cursor()

            query = """
                SELECT p.ID, p.Data_Hora, c.Nome AS Campo
                FROM Partida p
                JOIN Campo c ON p.ID_Campo = c.ID
                JOIN Jogador_joga jj ON p.ID = jj.ID_Partida
                WHERE jj.ID_Jogador = ? AND (p.Estado = 'Andamento' OR p.Estado = 'Aguardando');
            """
            cursor.execute(query, (user_id,))
            row = cursor.fetchone()
            cursor.close()
            return {
                "ID": row.ID,
                "DataHora": row.Data_Hora,
                "Campo": row.Campo
            } if row else None
    except Exception as e:
        flash(f"Erro ao verificar partida em andamento: {e}", "danger")
        print(f"Erro ao verificar partida em andamento: {e}")
        return None
