from flask import session, redirect, url_for, flash, request
from controllers.user import get_user_info
from utils.db import create_connection
from models.campo import create_campo
from utils.general import get_siglas_dias, get_dias_semana

def excluir_campo():
    if "user_id" not in session:
        return redirect(url_for("index"))
    
    user_id = session["user_id"]

    campo_id = request.args.get("ID")

    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM Campo WHERE ID=?", (campo_id,))
            conn.commit()

            conn.execute("""
                UPDATE Arrendador
                SET No_Campos = No_Campos - 1
                WHERE ID_Arrendador = ?
            """, (user_id,))
            conn.commit()
        

        flash("Campo excluído com sucesso!", "success")
    except Exception as e:
        flash(f"Erro ao excluir campo: {str(e)}", "danger")

    return redirect(url_for("dashboard.arr_campos_list"))

def adicionar_campo_privado():
    user_id = session.get('user_id')
    if not user_id:
        return redirect(url_for('auth.login'))

    nome = request.form.get('nome')
    lat = request.form.get('latitude')
    long = request.form.get('longitude')
    endereco = request.form.get('endereco')
    comprimento = request.form.get('comprimento')
    largura = request.form.get('largura')
    descricao = request.form.get('descricao', '')
    preco = request.form.get('preco')
    dias = request.form.getlist('dias[]')

    id_campo = create_campo(nome, comprimento, largura, descricao, lat, long, endereco)

    try:
        with create_connection() as conn:
            cursor = conn.cursor()

            cursor.execute("""
                INSERT INTO Campo_Priv (ID_Campo, ID_Arrendador)
                VALUES (?, ?)
            """, (id_campo, user_id))

            for dia in dias:
                sigla = get_siglas_dias()[dia]
                id_dia = get_dias_semana()[sigla]
                hora_abertura = request.form.get(f'hora_abertura_{sigla}')
                hora_fecho = request.form.get(f'hora_fecho_{sigla}')

                cursor.execute("""
                    INSERT INTO Disponibilidade (ID_Campo, ID_dia, Preco, Hora_abertura, Hora_fecho)
                    VALUES (?, ?, ?, ?, ?)
                """, (id_campo, id_dia, preco, hora_abertura, hora_fecho))
            conn.commit()

            conn.execute("""
                UPDATE Arrendador
                SET No_Campos = No_Campos + 1
                WHERE ID_Arrendador = ?
            """, (user_id,))
            conn.commit()

        flash('Campo privado adicionado com sucesso!', 'success')
    except Exception as e:
        flash(f'Ocorreu um erro ao adicionar o campo: {e}', 'danger')

    user = get_user_info(user_id)
    return redirect(url_for('dashboard.arr_campos_list', user=user))
