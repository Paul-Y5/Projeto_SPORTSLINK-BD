from db import create_connection
from flask import flash, redirect, render_template, session, url_for
    
from flask import request, session, redirect, url_for, flash
from datetime import datetime

def create_partida(campo_id):
    user_id = session.get("user_id")
    if not user_id:
        return redirect(url_for("auth.login"))

    data_partida = datetime.now().strftime("%Y-%m-%d")
    hora_inicio_partida = datetime.now().strftime("%H:%M")
    duracao_partida = request.form.get("duracao_partida")
    desporto_partida = request.form.get("desporto_partida")

    try:
        data_hora_str = f"{data_partida} {hora_inicio_partida}"
        data_hora = datetime.strptime(data_hora_str, "%Y-%m-%d %H:%M")

        duracao = int(duracao_partida)

        if duracao < 15 or duracao > 240:
            flash("A duração deve estar entre 15 e 240 minutos!", "danger")
            return redirect(url_for("dashboard.campo_detail", ID=campo_id))

        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute(
                "EXEC CreatePartida ?, ?, ?, ?, ?",
                (campo_id, data_hora, duracao, desporto_partida, user_id)
            )
            partida_id = cursor.fetchone()[0]
            conn.commit()

        return partida_id

    except ValueError as e:
        flash(f"Erro nos dados fornecidos: {str(e)}", "danger")
    except Exception as e:
        flash(f"Erro inesperado ao iniciar partida: {str(e)}", "danger")
    return redirect(url_for("dashboard.campo_detail", ID=campo_id))
    
def get_Partida(id_partida):
    user_id = session.get("user_id")
    if not user_id:
        return redirect(url_for("auth.login"))
    
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC ObterPartida ?", (id_partida,))
            partida = cursor.fetchone()
        
        if partida:
            flash("Partida encontrada com sucesso!", "success")
            jogadores_ids = partida[15].split(",") if partida[15] else []
            partida[15] = [int(id) for id in jogadores_ids if id.isdigit()]
            jogadores = []
            for id_jogador in partida[15]:
                cursor.execute("EXEC GetUserInfo ?", (id_jogador,))
                jogador = cursor.fetchone()
                if jogador:
                    jogadores.append({
                        "ID": jogador[0],
                        "Nome": jogador[1],
                        "Nacionalidade": jogador[4]
                    })
            partida[15] = jogadores
            partida = {
                "ID": partida[0],
                "CampoID": partida[1],
                "Campo": partida[2],
                "Comprimento": partida[3],
                "Largura": partida[4],
                "Latitude": partida[5],
                "Longitude": partida[6],
                "CampoLocalizacao": partida[7],
                "CampoDescricao": partida[8],
                "DataHora": partida[9],
                "Duracao": partida[10],
                "Resultado": partida[11],
                "Estado": partida[12],
                "NoJogadors": partida[13],
                "CampoImagemURL": partida[14],
                "Jogadores": partida[15],
                "MaxJogadores": partida[16],
            }
            return render_template(
                "partida_detail.html",
                partida=partida
            )
        else:
            flash("Partida não encontrada.", "warning")
            return redirect(url_for("dashboard.jog_dashboard"))  
    except Exception as e:
        flash(f"Erro ao obter partida: {str(e)}", "danger")
        return redirect(url_for("dashboard.jog_dashboard"))


# Com Filtros de Nome e ordenação por DataHora, Distancia, ou Número de Jogadores
def get_Partidas_Abertas(nome_campo=None, distancia=None, latitude=None, longitude=None, order_by='DataHora', order_direction='ASC'):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC GetPartidas @NomeCampo=?, @Distancia=?, @Latitude=?, @Longitude=?, @OrderBy=?, @OrderDirection=?",
                           (nome_campo, distancia, latitude, longitude, order_by, order_direction))
            partidas = cursor.fetchall()
            for partida in partidas:
                ids_jogadores = partida[15].split(",") if partida[15] else []
                partida[15] = [int(id) for id in ids_jogadores if id.isdigit()]

                jogadores = []
                for id_jogador in partida[15]:
                    cursor.execute("EXEC GetUserInfo ?", (id_jogador,))
                    jogador = cursor.fetchone()
                    if jogador:
                        jogadores.append({
                            "ID": jogador[0],
                            "Nome": jogador[1],
                            "Nacionalidade": jogador[4]
                        })
                partida[15] = jogadores
            partidas = [{
                "ID": partida[0],
                "CampoID": partida[1],
                "Campo": partida[2],
                "DataHora": partida[9],
                "Duracao": partida[10],
                "Comprimento": partida[3],
                "Largura": partida[4],
                "Desporto": partida[5] if len(partida) > 5 else 'Não especificado',
                "Resultado": partida[11],
                "Estado": partida[12],
                "CampoLocalizacao": partida[7],
                "CampoDescricao": partida[8],
                "CampoImagemURL": partida[14],
                "Jogadores": partida[15],
                "MaxJogadores": partida[16]
            } for partida in partidas]
        return partidas
    except Exception as e:
        flash(f"Erro ao carregar partidas abertas: {str(e)}", "danger")
        return []

def entrar_Partida(id_partida):
    user_id = session.get("user_id")
    if not user_id:
        return redirect(url_for("auth.login"))
    
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC AddJogadorToPartida ?, ?", (id_partida, user_id))
            result = cursor.fetchone()
            if result and result[0] == 1:
                flash("Entrou na partida com sucesso!", "success")
                return redirect(url_for("dashboard.partida_detail", ID=id_partida))
            else:
                flash("Erro ao entrar na partida.", "danger")
            return redirect(url_for("dashboard.list_partidas"))
    except Exception as e:
        flash(f"Erro ao entrar na partida: {str(e)}", "danger")
        return redirect(url_for("dashboard.jog_dashboard"))
    
def sair_Partida(id_partida):
    user_id = session.get("user_id")
    if not user_id:
        return redirect(url_for("auth.login"))
    
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC RemoveJogadorFromPartida ?, ?", (id_partida, user_id))
            result = cursor.fetchone()
            if result and result[0] == 1:
                flash("Saiu da partida com sucesso!", "success")
                return redirect(url_for("dashboard.partida_detail", ID=id_partida))
            else:
                flash("Erro ao sair da partida.", "danger")
            return redirect(url_for("dashboard.list_partidas"))
    except Exception as e:
        flash(f"Erro ao sair da partida: {str(e)}", "danger")
        return redirect(url_for("dashboard.jog_dashboard"))