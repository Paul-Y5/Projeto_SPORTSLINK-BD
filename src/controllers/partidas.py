from socket import create_connection
from flask import flash, redirect, render_template, session, url_for

from controllers.user import get_user_info



def get_partidas():
    user_id = session.get("user_id")
    if not user_id:
        return redirect(url_for("auth.login"))
    
    user = get_user_info(user_id)
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            # Chama a stored procedure para obter as partidas do utilizador
            cursor.execute("EXEC sp_GetPartidasByUser ?", (user_id,))
            partidas = cursor.fetchall()
        return render_template(
            "partidas_list.html",
            user=user,
            partidas=partidas
        )
    except Exception as e:
        flash(f"Erro ao listar partidas: {str(e)}", "danger")
        return render_template(
            "partidas_list.html",
            user=user,
            partidas=[]
        )