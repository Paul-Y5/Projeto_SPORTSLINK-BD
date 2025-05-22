from decimal import Decimal
from flask import session, redirect, url_for, flash, request
from utils.db import create_connection
from utils.general import get_siglas_dias, get_dias_semana


def create_CampoPub():
    ...

def editar_campo(ID):
    if "user_id" not in session:
        return redirect(url_for("index"))

    nome = request.form.get("nome")
    lat = request.form.get("latitude")
    long = request.form.get("longitude")
    endereco = request.form.get("endereco")
    comprimento = request.form.get("comprimento")
    largura = request.form.get("largura")
    descricao = request.form.get("descricao", '')
    preco = request.form.get("preco")

    try:
        with create_connection() as conn:
            cursor = conn.cursor()

            # Atualiza dados do campo
            cursor.execute("""
                EXEC sp_EditCampo 
                    @ID_Campo = ?, 
                    @Nome = ?, 
                    @Descricao = ?, 
                    @Comprimento = ?, 
                    @Largura = ?, 
                    @Endereco = ?, 
                    @URL = ?
            """, (ID, nome, descricao, comprimento, largura, endereco, None))

            # Atualiza a localização do campo
            cursor.execute("""
                EXEC sp_UpdatePonto
                    @ID = ?,
                    @Latitude = ?,
                    @Longitude = ?
                """, (ID, lat, long))

            # Atualiza a disponibilidade por dia executando sp_SetDisponibilidadeCampo
            dias = request.form.getlist('dias[]')
            siglas = get_siglas_dias() 
            ids_dia = get_dias_semana()

            for dia in dias:
                sigla = siglas.get(dia)
                if not sigla:
                    continue

                id_dia = ids_dia.get(sigla)
                if not id_dia:
                    continue

                hora_abertura = request.form.get(f'hora_abertura_{sigla}') or None
                hora_fecho = request.form.get(f'hora_fecho_{sigla}') or None

                cursor.execute("""
                    EXEC sp_SetDisponibilidadeCampo 
                        @ID_Campo = ?,
                        @ID_Dia = ?,
                        @Hora_Abertura = ?,
                        @Hora_Fecho = ?,
                        @Preco = ?
                """, (ID, id_dia, hora_abertura, hora_fecho, preco))

            conn.commit()

        flash('Campo editado com sucesso!', 'success')

    except Exception as e:
        flash(f'Ocorreu um erro ao editar o campo: {e}', 'danger')

    return redirect(url_for('dashboard.campo_detail', ID=ID))

def excluir_campo():
    if "user_id" not in session:
        return redirect(url_for("index"))

    campo_id = request.form.get("id_campo")

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
                @Descricao = ?""",
            (user_id, lat, long, 1, nome, endereco, comprimento, largura, 0, descricao))

            campo_id = cursor.fetchone()[0]

            for dia in dias:
                sigla = get_siglas_dias()[dia]
                id_dia = get_dias_semana()[sigla]
                hora_abertura = request.form.get(f'hora_abertura_{sigla}')
                hora_fecho = request.form.get(f'hora_fecho_{sigla}')

                print(f"Valores: {campo_id=}, {id_dia=}, {hora_abertura=}, {hora_fecho=}, {preco=}")

                cursor.execute("""EXEC sp_SetDisponibilidadeCampo 
                    @ID_Campo = ?,
                    @ID_Dia = ?,
                    @Hora_Abertura = ?,
                    @Hora_Fecho = ?,
                    @Preco = ?""", (campo_id, id_dia, hora_abertura, hora_fecho, preco))

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
        cursor.execute("EXEC sp_GetCampoByID ?", (campo_id,))
        campo_infos = cursor.fetchall()

    if campo_infos:
        first_row = campo_infos[0]
        campo_dict = {
            "Nome": first_row[1],
            "Comprimento": first_row[2],
            "Largura": first_row[3],
            "Endereco": first_row[4],
            "Latitude": first_row[5],
            "Longitude": first_row[6],
            "Descricao": first_row[7],
            "Preco": first_row[8],
        }

        disponibilidade = []
        for row in campo_infos:
            disponibilidade.append({
                "dia": row[11],
                "hora_abertura": row[9],
                "hora_fecho": row[10],
            })

        return campo_dict, disponibilidade

    return None, None

def getReservasByCampo(ID):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC sp_GetReservasByCampo ?", (ID,))
            reservas = cursor.fetchall()
        if reservas:
            reservas = [
                {
                    "Nome": row[0],
                    "Nacionalidade": row[1],
                    "Num_Tele": row[2],
                    "Data": row[3],
                    "Hora_Inicio": row[4],
                    "Descricao": row[5],
                    "Duracao": row[7],
                    "TotalPago": Decimal(float(row[6])) * Decimal(str(int(row[7].split(':')[0]) + int(row[7].split(':')[1]) / 60)),
                }
                for row in reservas
            ]
            print(f"Reservas: {reservas}")
        return reservas
    except Exception as e:
        print(f"Erro ao obter reservas: {e}")
        return None

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
