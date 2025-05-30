from db import create_connection
from flask import flash, redirect, session, url_for
    
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
                "EXEC sp_CreatePartida ?, ?, ?, ?, ?",
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
            cursor.execute("EXEC sp_ObterPartida ?", (id_partida,))
            partida = cursor.fetchone()
        
        if partida:
            return partida
        else:
            flash("Partida não encontrada.", "warning")
            return redirect(url_for("dashboard.jog_dashboard"))  
    except Exception as e:
        flash(f"Erro ao obter partida: {str(e)}", "danger")
        return redirect(url_for("dashboard.jog_dashboard"))  