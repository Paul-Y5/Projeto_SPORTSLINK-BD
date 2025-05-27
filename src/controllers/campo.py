from decimal import Decimal
import os
from flask import session, redirect, url_for, flash, request
from db import create_connection
from utils.general import get_siglas_dias, get_dias_semana, parse_decimal


def create_CampoPub():
    ...

def editar_campo(ID):
    if "user_id" not in session:
        return redirect(url_for("index"))
    
    nome = request.form.get("nome")
    lat = parse_decimal(request.form.get("latitude"))
    long = parse_decimal(request.form.get("longitude"))
    endereco = request.form.get("endereco")
    comprimento = parse_decimal(request.form.get("comprimento"))
    largura = parse_decimal(request.form.get("largura"))
    descricao = request.form.get("descricao", '')
    preco_padrao = parse_decimal(request.form.get("preco"))

    img_file = request.files.get("img")

    if img_file and img_file.filename:
        img_url = f"img/{img_file.filename}"
        save_path = os.path.join("src", "static", "img", img_file.filename)
        img_file.save(save_path)
    else:
        img_url = None
    
    try:
        with create_connection() as conn:
            cursor = conn.cursor()

            # Atualiza campo
            cursor.execute("""
                EXEC sp_EditCampo 
                    @ID_Campo = ?, 
                    @Nome = ?, 
                    @Endereco = ?, 
                    @Comprimento = ?, 
                    @Largura = ?, 
                    @Descricao = ?, 
                    @URL = ?;
            """, (ID, nome, endereco, comprimento, largura, descricao, img_url))

            # Atualiza localização
            cursor.execute("""
                EXEC sp_UpdatePonto 
                    @ID = ?, 
                    @Latitude = ?, 
                    @Longitude = ?;
            """, (ID, lat, long))

            # Atualiza disponibilidade
            dias_selecionados = request.form.getlist('dias[]')
            siglas = get_siglas_dias()
            ids_dia = get_dias_semana()

            print("Dias selecionados:", dias_selecionados)

            for sigla, nome_dia in siglas.items():
                id_dia = ids_dia.get(nome_dia)
                """ print(f"Processando dia: {nome_dia} ({sigla}), ID: {id_dia}") """
                if not id_dia:
                    continue

                if nome_dia not in dias_selecionados:
                    continue

                hora_abertura = request.form.get(f'hora_abertura_{nome_dia}') or None
                hora_fecho = request.form.get(f'hora_fecho_{nome_dia}') or None
                preco_dia = request.form.get(f'preco_dia_{nome_dia}') or preco_padrao
                preco_dia = parse_decimal(preco_dia)

                """ print(f"Atualizando disponibilidade para {nome_dia} ({sigla}): "
                      f"Hora Abertura: {hora_abertura}, Hora Fecho: {hora_fecho}, Preço: {preco_dia}") """

                cursor.execute("""
                    EXEC sp_SetDisponibilidadeCampo 
                        @ID_Campo = ?, 
                        @ID_Dia = ?, 
                        @Hora_Abertura = ?, 
                        @Hora_Fecho = ?, 
                        @Preco = ?;
                """, (ID, id_dia, hora_abertura, hora_fecho, preco_dia))

            # Atualiza desportos associados
            desportos = request.form.getlist("desportos")
            query_get_ids = "SELECT ID, Nome FROM Desporto WHERE Nome IN ({})".format(
                ",".join("?" for _ in desportos))
            cursor.execute(query_get_ids, desportos)
            desporto_ids = cursor.fetchall()  # Lista de tuplos: (ID_Desporto, Nome)
            #print("IDs de desportos recuperados:", desporto_ids)
            for id_desporto, _ in desporto_ids:
                #print(f"A associar desporto ID {id_desporto} ao campo ID {ID}")
                cursor.execute("EXEC sp_AssociarDesportoCampo @ID_Campo = ?, @ID_Desporto = ?", (ID, int(id_desporto)))
            # Remove desportos não selecionados
            ids_selecionados = [id_desporto for id_desporto, _ in desporto_ids]
            if ids_selecionados:
                placeholders = ",".join("?" for _ in ids_selecionados)
                query_delete = f"""
                    DELETE FROM dbo.Desporto_Campo
                    WHERE ID_Campo = ?
                    AND ID_Desporto NOT IN ({placeholders})
                """
                cursor.execute(query_delete, (ID, *ids_selecionados))

            conn.commit()
            flash('Campo editado com sucesso!', 'success')
            
            return redirect(url_for('dashboard.campo_detail', ID=ID))

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
    user_id = session.get("user_id")
    if not user_id:
        return redirect(url_for('auth.login'))

    img_file = request.files.get("img")
    img_url = None

    if img_file and img_file.filename:
        img_url = f"img/{img_file.filename}"
        save_path = os.path.join("src", "static", "img", img_file.filename)
        img_file.save(save_path)
    else:
        img_url = 'img/campo.png'

    nome = request.form.get('nome')
    lat = request.form.get('latitude')
    long = request.form.get('longitude')
    endereco = request.form.get('endereco')
    comprimento = request.form.get('comprimento')
    largura = request.form.get('largura')
    descricao = request.form.get('descricao', '')
    preco_padrao = request.form.get('preco')
    dias = request.form.getlist('dias[]')
    desportos = request.form.getlist("desportos")

    try:
        with create_connection() as conn:
            cursor = conn.cursor()

            # Primeiro obter os IDs dos desportos
            query_get_ids = "SELECT ID, Nome FROM Desporto WHERE Nome IN ({})".format(
                ",".join("?" for _ in desportos)
            )
            cursor.execute(query_get_ids, desportos)
            desporto_ids = cursor.fetchall()

            # Criar campo
            cursor.execute("""
                DECLARE @ID_Campo INT;
                EXEC sp_CreateCampo 
                    @Nome = ?, 
                    @Endereco = ?, 
                    @Comprimento = ?, 
                    @Largura = ?, 
                    @Ocupado = 0,
                    @Descricao = ?, 
                    @Latitude = ?, 
                    @Longitude = ?, 
                    @ID_Mapa = 1, 
                    @URL = ?, 
                    @ID_Campo = @ID_Campo OUTPUT;
                SELECT @ID_Campo;
            """, (nome, endereco, comprimento, largura, descricao, lat, long, img_url))

            campo_id = cursor.fetchone()[0]

            cursor.execute("INSERT INTO Campo_Priv (ID_Campo, ID_Arrendador) VALUES (?, ?)", (campo_id, user_id))

            siglas = get_siglas_dias()
            ids_dia = get_dias_semana()

            for dia in dias:
                sigla = siglas.get(dia)
                id_dia = ids_dia.get(sigla)

                if not id_dia:
                    continue

                hora_abertura = request.form.get(f'hora_abertura_{sigla}') or None
                hora_fecho = request.form.get(f'hora_fecho_{sigla}') or None
                preco_dia = request.form.get(f'preco_dia_{sigla}') or preco_padrao

                cursor.execute("""
                    EXEC sp_SetDisponibilidadeCampo 
                        @ID_Campo = ?, 
                        @ID_Dia = ?, 
                        @Hora_Abertura = ?, 
                        @Hora_Fecho = ?, 
                        @Preco = ?;
                """, (campo_id, id_dia, hora_abertura, hora_fecho, preco_dia))

            for id_desporto, _ in desporto_ids:
                cursor.execute("EXEC sp_AssociarDesportoCampo @ID_Campo = ?, @ID_Desporto = ?", (campo_id, id_desporto))

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

        # Executa a primeira stored procedure (dados principais do campo)
        cursor.execute("EXEC sp_GetCampoByID ?", (campo_id,))
        campo_infos = cursor.fetchall()

        if not campo_infos:
            return None, []

        # Extrai dados do campo
        first_row = campo_infos[0]
        campo_dict = {
            "ID": first_row[0],
            "Nome": first_row[1],
            "Comprimento": first_row[2],
            "Largura": first_row[3],
            "Endereco": first_row[4],
            "Latitude": first_row[5],
            "Longitude": first_row[6],
            "Descricao": first_row[7],
            "URL": first_row[12],
            "Desportos": list(set([row[13] for row in campo_infos if row[13]]))  # remove duplicados
        }

        # Executa a segunda stored procedure (disponibilidade)
        cursor.execute("EXEC sp_GetDisponibilidadePorCampo ?", (campo_id,))
        disponibilidade_rows = cursor.fetchall()

        """ for row in disponibilidade_rows:
            print(f"Disponibilidade rows: {row}")
 """
        disponibilidade = [
            {
                "dia": row[0],
                "hora_abertura": row[1][:5] if row[1] else None,
                "hora_fecho": row[2][:5] if row[2] else None,
                "Preco": float(row[3]) if row[3] else None
            }
            for row in disponibilidade_rows
        ]

        return campo_dict, disponibilidade


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

def get_campo_details(campo_id):
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("EXEC sp_GetCampoDetails ?", (campo_id,))
        campo_data = cursor.fetchone()

        # Obter disponibilidade
        cursor.execute("EXEC sp_GetDisponibilidadeByCampo ?", (campo_id,))
        disponibilidade_data = cursor.fetchall()

    # Processar dados do campo
    campo = {
        "ID": campo_data[0],
        "Nome": campo_data[1],
        "Comprimento": campo_data[2],
        "Largura": campo_data[3],
        "Endereco": campo_data[4],
        "Latitude": campo_data[5],
        "Longitude": campo_data[6],
        "Descricao": campo_data[7],
        "URL": campo_data[8],
    }

    # Processar disponibilidade
    disponibilidade = []
    for row in disponibilidade_data:
        disponibilidade.append({
            "dia": row[0],  # Nome do dia
            "hora_abertura": row[1][:5] if row[1] else None,  # Truncar para HH:MM
            "hora_fecho": row[2][:5] if row[2] else None,     # Truncar para HH:MM
            "Preco": float(row[3]) if row[3] else None,       # Converter Decimal para float
        })

    return campo, disponibilidade
