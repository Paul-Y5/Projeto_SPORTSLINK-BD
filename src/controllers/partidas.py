from db import create_connection
from flask import flash, redirect, render_template, session, url_for
    
from flask import request, session, redirect, url_for, flash
from datetime import datetime

def create_partida(campo_id):
    user_id = session.get("user_id")
    if not user_id:
        return redirect(url_for("auth.login"))

    # Obter dados do formulário
    duracao_partida = request.form.get("duracao_partida")

    try:
        # Validar data e hora
        data_hora = datetime.now()
        duracao = int(duracao_partida)

        # Validações
        if duracao < 15 or duracao > 240:
            flash("A duração deve estar entre 15 e 240 minutos!", "danger")
            return redirect(url_for("dashboard.campo_detail", ID=campo_id))

        # Executar a stored procedure
        with create_connection() as conn:
            cursor = conn.cursor()
            
            # SQL com OUTPUT
            cursor.execute("""
                DECLARE @OutputID INT;
                EXEC CreatePartida ?, ?, ?, ?, ?, ?, @OutputID OUTPUT;
                SELECT @OutputID;
            """, (campo_id, 1, data_hora, duracao, "Aguardando", user_id))
            
            result = cursor.fetchone()
            if result is None or result[0] is None:
                flash("Erro ao criar partida: Nenhuma resposta da base de dados.", "danger")
                return redirect(url_for("dashboard.campo_detail", ID=campo_id))

            partida_id = result[0]

            return partida_id
    except Exception as e:
        error_msg = str(e)
        print(f"Erro ao criar partida: {error_msg}")
    return redirect(url_for("dashboard.campo_detail", ID=campo_id))
    
def get_Partida(id_partida):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC ObterPartida ?", (id_partida,))
            raw_partida = cursor.fetchone()

        if not raw_partida:
            return None

        jogadores_ids = raw_partida[15].split(", ") if raw_partida[15] else []
        jogadores = []
        for id_jogador in [int(id) for id in jogadores_ids if id.isdigit()]:
            cursor.execute("EXEC GetUserInfo ?", (id_jogador,))
            jogador = cursor.fetchone()
            if jogador:
                jogadores.append({
                    "ID": jogador[0],
                    "Nome": jogador[1],
                    "Nacionalidade": jogador[4]
                })

        partida_detalhes = {
            "ID": raw_partida[0],
            "CampoID": raw_partida[1],
            "Campo": raw_partida[2],
            "Comprimento": float(raw_partida[3]),
            "Largura": float(raw_partida[4]),
            "Latitude": float(raw_partida[5]),
            "Longitude": float(raw_partida[6]),
            "CampoLocalizacao": raw_partida[7],
            "CampoDescricao": raw_partida[8],
            "DataHora": raw_partida[9].isoformat(),
            "Duracao": raw_partida[10],
            "Resultado": raw_partida[11],
            "Estado": raw_partida[12],
            "NoJogadores": raw_partida[13],
            "CampoImagemURL": raw_partida[14],
            "Jogadores": jogadores,
            "MaxJogadores": raw_partida[16]
        }

        print(f"Partida obtida com sucesso: {partida_detalhes}")
        return partida_detalhes

    
    except Exception as e:
        print(f"Erro ao obter partida: {str(e)}")
        return None

# Com Filtros de Nome e ordenação por DataHora, Distancia, ou Número de Jogadores
def get_Partidas_Abertas(nome_campo=None, distancia=None, latitude=None, longitude=None, order_by='DataHora', order_direction='ASC'):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC GetPartidas @NomeCampo=?, @Distancia=?, @Latitude=?, @Longitude=?, @OrderBy=?, @OrderDirection=?",
                           (nome_campo, distancia, latitude, longitude, order_by, order_direction))
            partidas = cursor.fetchall()
            for partida in partidas:
                ids_jogadores = partida[15].split(", ") if partida[15] else []
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
        flash("Sessão inválida. Faça login novamente.", "danger")
        return redirect(url_for("auth.login"))
    
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC addJogadorToPartida ?, ?", (id_partida, user_id))
            result = cursor.fetchone()
            conn.commit()  # Garantir que a transação é confirmada
            if result and result[0] == 1:
                flash("Entrou na partida com sucesso!", "success")
                return redirect(url_for("dashboard.get_partida", partida_id=id_partida))
            else:
                flash("Erro ao entrar na partida: Jogador já inscrito ou outro problema.", "danger")
                return redirect(url_for("dashboard.list_partidas"))
    except Exception as e:
        print(f"Erro detalhado ao entrar na partida: {str(e)}")  # Log para depuração
        return redirect(url_for("dashboard.list_partidas"))  # Redireciona para list_partidas em vez de jog_dashboard
    
def sair_Partida(id_partida):
    user_id = session.get("user_id")
    if not user_id:
        return redirect(url_for("auth.login"))
    
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC removeJogadorFromPartida ?, ?", (id_partida, user_id))
            conn.commit()

            flash("Saiu da partida com sucesso!", "success")
            return redirect(url_for("dashboard.get_partida", partida_id=id_partida))

    except Exception as e:
        flash(f"Erro ao sair da partida: {str(e)}", "danger")
        return redirect(url_for("dashboard.jog_dashboard"))
