import pydoc
from flask import session, redirect, url_for, flash, request
from controllers.user import get_user_info
from utils.db import create_connection
from utils.general import get_siglas_dias, get_dias_semana

def create_campo():
    if "user_id" not in session:
        return redirect(url_for("index"))
    
    user_id = session["user_id"]

    nome = request.form.get("nome")
    lat = request.form.get("latitude")
    long = request.form.get("longitude")
    endereco = request.form.get("endereco")
    comprimento = request.form.get("comprimento")
    largura = request.form.get("largura")
    descricao = request.form.get("descricao", "")
    preco = request.form.get("preco")

    try:
        with create_connection() as conn:
            cursor = conn.cursor()

            # Chama a stored procedure para criar o campo
            cursor.execute("""
                EXEC sp_CreateCampo 
                    @ID_Utilizador = ?, 
                    @Nome = ?, 
                    @Endereco = ?, 
                    @Comprimento = ?, 
                    @Largura = ?, 
                    @Ocupado = 0, 
                    @Descricao = ?, 
                    @Preco = ?
            """, (user_id, nome, endereco, comprimento, largura, descricao, preco))

            conn.commit()

        flash("Campo criado com sucesso!", "success")
    except Exception as e:
        flash(f"Erro ao criar campo: {str(e)}", "danger")

    return redirect(url_for("dashboard.arr_campos_list"))


def excluir_campo():
    if "user_id" not in session:
        return redirect(url_for("index"))

    campo_id = request.form.get("id_campo")
    print(f"Campo ID: {campo_id}")

    try:
        with create_connection() as conn:
            cursor = conn.cursor()

            # Chama a stored procedure para excluir o campo
            cursor.execute("EXEC sp_DeleteCampo ?", (campo_id,))

            conn.commit()

        flash("Campo excluído com sucesso!", "success")
    except Exception as e:
        flash(f"Erro ao excluir campo: {str(e)}", "danger")

    return redirect(url_for("dashboard.arr_campos_list"))

def adicionar_campo_privado():
    user_id = session["user_id"]
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

    try:
        with create_connection() as conn:
            cursor = conn.cursor()

            cursor.execute("""EXEC sp_addCampoPriv 
                @ID_Utilizador = ?, 
                @Latitude = ?, 
                @Longitude = ?, 
                @ID_Mapa = ?, 
                @Nome = ?, 
                @Endereco = ?, 
                @Comprimento = ?, 
                @Largura = ?, 
                @Ocupado = ?, 
                @Descricao = ?, 
                @Preco = ?""",
            (user_id, lat, long, 1, nome, endereco, comprimento, largura, 0, descricao, preco))

            campo_id = cursor.fetchone()[0]
            print(f"Campo criado com ID: {campo_id}")

            for dia in dias:
                sigla = get_siglas_dias()[dia]
                id_dia = get_dias_semana()[sigla]
                hora_abertura = request.form.get(f'hora_abertura_{sigla}')
                hora_fecho = request.form.get(f'hora_fecho_{sigla}')

                cursor.execute("""EXEC sp_SetDisponibilidadeCampo 
                    @ID_Campo = ?,
                    @ID_Dia = ?,
                    @Hora_Abertura = ?,
                    @Hora_Fecho = ?""", (campo_id, id_dia, hora_abertura, hora_fecho))

            conn.commit()

        flash('Campo privado adicionado com sucesso!', 'success')
    except Exception as e:
        flash(f'Ocorreu um erro ao adicionar o campo: {e}', 'danger')

    return redirect(url_for('dashboard.arr_campos_list'))

def get_disponibilidade_por_campo(campo_id):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC sp_GetDisponibilidadePorCampo ?", (campo_id,))
            disponibilidade = cursor.fetchall()
        return disponibilidade
    except Exception as e:
        print(f"Erro ao obter disponibilidade: {e}")
        return None

def get_campo_by_id(campo_id):
     with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute(""" EXEC sp_GetCampoByID ?""", (campo_id,))
        return cursor.fetchone()

def get_campos():
    user_id = session.get("user_id")
    if not user_id:
        return redirect(url_for("auth.login"))

    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC sp_GetCampos ? ", (user_id,))
            campos = cursor.fetchall()
        return campos
    except Exception as e:
        print(f"Erro ao obter campos: {e}")
        return None
    
def get_All_campos(field_order, field_direction, field_search, field_type):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC sp_GetAllCampos ?, ?, ?, ?", (field_order, field_direction, field_search, field_type))
            campos = cursor.fetchall()
        return campos
    except Exception as e:
        print(f"Erro ao obter campos: {e}")
        return None
