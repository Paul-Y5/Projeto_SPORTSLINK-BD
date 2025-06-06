from datetime import datetime
from decimal import Decimal
from math import ceil
import os
from flask import session, redirect, url_for, flash, request
from db import create_connection
from utils.general import get_siglas_dias, get_dias_semana, parse_decimal


def adicionar_campo_publico():
    try:
        nome = request.form['nome']
        comprimento = float(request.form['comprimento'])
        largura = float(request.form['largura'])
        descricao = request.form.get('descricao', '')
        endereco = request.form['endereco']
        latitude = float(request.form['latitude'])
        longitude = float(request.form['longitude'])
        print(f"Latitude: {latitude}, Longitude: {longitude}")
        entidade_publica_resp = request.form['entidade_publica_resp']
        ocupado = 0  # Campo inicia como disponível
        desportos_selecionados = request.form.getlist('desportos[]')

        # Processa imagem
        img_file = request.files.get('img')
        print(f"Imagem recebida: {img_file}")
        if img_file and img_file.filename:
            print(f"Salvando imagem: {img_file.filename}")
            img_url = f"img/{img_file.filename}"
            save_path = os.path.join("static", "img", img_file.filename)
            img_file.save(save_path)
        else:
            img_url = 'img/campo.png'  # Imagem padrão se não for fornecida

        # Cria o campo e recupera o ID gerado
        conn = create_connection()
        with conn.cursor() as cursor:
            cursor.execute("""
                DECLARE @NewID INT;
                EXEC createCampoPub
                    @Latitude = ?, 
                    @Longitude = ?, 
                    @ID_Mapa = ?, 
                    @Nome = ?, 
                    @Endereco = ?, 
                    @Comprimento = ?, 
                    @Largura = ?, 
                    @Ocupado = ?, 
                    @Descricao = ?, 
                    @Entidade_publica_resp = ?, 
                    @URL = ?, 
                    @NewID = @NewID OUTPUT;
                SELECT @NewID;
            """, (
                latitude,
                longitude,
                1,
                nome,
                endereco,
                comprimento,
                largura,
                ocupado,
                descricao,
                entidade_publica_resp,
                img_url
            ))
            id_campo = cursor.fetchone()[0]

            # Associa desportos selecionados
            desportos_map = {}
            cursor.execute("SELECT ID, Nome FROM Desporto")
            desportos_rows = cursor.fetchall()
            for id_desporto, nome_desporto in desportos_rows:
                desportos_map[nome_desporto] = id_desporto

            if id_campo:
                for desporto_nome in desportos_selecionados:
                    id_desporto = desportos_map.get(desporto_nome)
                    if id_desporto:
                        cursor.execute("EXEC AssociarDesportoCampo @ID_Campo = ?, @ID_Desporto = ?;", (id_campo, id_desporto))

            conn.commit()

        flash('Campo público adicionado com sucesso!', 'success')
        return redirect(url_for('dashboard.jog_dashboard'))

    except Exception as e:
        flash(f'Ocorreu um erro ao adicionar o campo: {e}', 'danger')
        return redirect(url_for('dashboard.jog_dashboard'))


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
        save_path = os.path.join("static", "img", img_file.filename)
        img_file.save(save_path)
    else:
        img_url = None
    
    try:
        with create_connection() as conn:
            cursor = conn.cursor()

            # Atualiza campo
            cursor.execute("""
                EXEC EditCampo 
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
                EXEC UpdatePonto 
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
                    EXEC SetDisponibilidadeCampo 
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
                cursor.execute("EXEC AssociarDesportoCampo @ID_Campo = ?, @ID_Desporto = ?", (ID, int(id_desporto)))
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
            flash("Campo editado com sucesso!", "success")

    except Exception as e:
        print(f"Erro ao editar campo: {e}")

    return redirect(url_for('dashboard.campo_detail', ID=ID))


def excluir_campo():
    if "user_id" not in session:
        return redirect(url_for("index"))

    campo_id = request.form.get("id_campo")

    try:
        with create_connection() as conn:
            cursor = conn.cursor()

            # Chama a stored procedure para excluir o campo
            cursor.execute("EXEC DeleteCampo ?", (campo_id,))

            conn.commit()

        flash("Campo excluído com sucesso!", "success")
        return redirect(url_for('dashboard.arr_campos_list'))
    except Exception as e:
        flash(f"Erro ao excluir campo: {str(e)}", "danger")
        return redirect(url_for('dashboard.arr_campos_list'))


def adicionar_campo_privado():
    user_id = session.get("user_id")
    if not user_id:
        return redirect(url_for('auth.login'))

     # Processa imagem
    img_file = request.files.get('img')
    print(f"Imagem recebida: {img_file}")
    if img_file and img_file.filename:
        print(f"Salvando imagem: {img_file.filename}")
        img_url = f"img/{img_file.filename}"
        save_path = os.path.join("static", "img", img_file.filename)
        img_file.save(save_path)
    else:
        img_url = 'img/campo.png'  # Imagem padrão se não for fornecida

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
                EXEC CreateCampo 
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
                    EXEC SetDisponibilidadeCampo 
                        @ID_Campo = ?, 
                        @ID_Dia = ?, 
                        @Hora_Abertura = ?, 
                        @Hora_Fecho = ?, 
                        @Preco = ?;
                """, (campo_id, id_dia, hora_abertura, hora_fecho, preco_dia))

            for id_desporto, _ in desporto_ids:
                cursor.execute("EXEC AssociarDesportoCampo @ID_Campo = ?, @ID_Desporto = ?", (campo_id, id_desporto))

            conn.commit()
            flash('Campo privado adicionado com sucesso!', 'success')

    except Exception as e:
        flash(f'Ocorreu um erro ao adicionar o campo: {e}', 'danger')

    return redirect(url_for('dashboard.arr_campos_list'))


def get_disponibilidade_por_campo(campo_id):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("EXEC GetDisponibilidadePorCampo ?", (campo_id,))
            disponibilidade = cursor.fetchall()
        return disponibilidade
    except Exception as e:
        print(f"Erro ao obter disponibilidade: {e}")
        return None


# Função para obter os detalhes do campo por ID
def get_campo_by_id(campo_id):
    with create_connection() as conn:
        cursor = conn.cursor()

        # Executa a stored procedure para obter os dados principais do campo
        cursor.execute("EXEC GetCampoByID ?", (campo_id,))
        campo_infos = cursor.fetchall()

        if not campo_infos:
            return None, []

        # Extrai os dados do campo da primeira linha
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
            "ID_Arrendador": first_row[8],
            "URL": first_row[13],
            "Desportos": list(set([row[14] for row in campo_infos if row[14]]))  # Remove duplicados
        }

        # Executa a stored procedure para obter a disponibilidade do campo
        cursor.execute("EXEC GetDisponibilidadePorCampo ?", (campo_id,))
        disponibilidade_rows = cursor.fetchall()

        # Formata a disponibilidade em uma lista de dicionários
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


# Função para obter as reservas de um campo privado
def getReservasByCampo(campo_id):
    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            query = """
                SELECT 
                    v.ID, v.Nome_Campo, v.Nome_Jogador, v.Data, v.Hora_Inicio, v.Hora_Fim, 
                    v.Total_Pagamento, v.Estado, v.Descricao, 
                    u.Nacionalidade, u.Num_Tele
                FROM vw_ReservasDetalhadas v
                JOIN Utilizador u ON v.ID_Jogador = u.ID
                WHERE v.ID_Campo = ? AND v.Estado = 'Confirmada';
            """
            cursor.execute(query, (campo_id,))
            reservas_rows = cursor.fetchall()

        if not reservas_rows:
            return []

        reservas = []
        for row in reservas_rows:
            print(f"Processando reserva: {row}")

            hora_inicio_str = row[4].split('.')[0]  # e.g., "10:00:00"
            hora_fim_str = row[5].split('.')[0]      # e.g., "12:00:00"

            # Calculo de duração em horas
            hora_inicio_parts = hora_inicio_str.split(':')
            hora_fim_parts = hora_fim_str.split(':')
            hora_inicio_minutes = int(hora_inicio_parts[0]) * 60 + int(hora_inicio_parts[1])
            hora_fim_minutes = int(hora_fim_parts[0]) * 60 + int(hora_fim_parts[1])
            duracao = (hora_fim_minutes - hora_inicio_minutes) / 60  # Duration in hours
            if duracao < 0:
                duracao += 24

            data = row[3]
            if isinstance(data, datetime):
                data = data.strftime('%Y-%m-%d')

            reservas.append({
                "ID": row[0],
                "Nome_Campo": row[1],
                "Nome": row[2],           # Nome_Jogador
                "Nacionalidade": row[9],
                "Num_Tele": row[10],
                "Data": data,
                "Hora_Inicio": hora_inicio_str,  # Keep as string "HH:MM:SS"
                "Duracao": duracao,
                "Estado": row[7],
                "TotalPago": float(row[6]) if row[6] else None,
                "Descricao": row[8]
            })

        return reservas
    except Exception as e:
        print(f"Erro ao obter reservas: {e}")
        return []
    

def get_campos(tipo):
    user_id = session.get("user_id")
    if not user_id:
        return redirect(url_for("auth.login"))

    # Get query parameters
    pesquisa = request.args.get("pesquisa")
    order_by = request.args.get("order_by", "Nome")
    order_dir = request.args.get("order_dir", "ASC").upper()
    user_lat = request.args.get("user_lat", type=float)
    user_lon = request.args.get("user_lon", type=float)
    dia_semana = request.args.get("dia_semana", type=int)
    page = request.args.get("page", 1, type=int)
    per_page = request.args.get("per_page", 10, type=int)

    print(f"A obter campos com tipo: {tipo}, pesquisa: {pesquisa}, order_by: {order_by}, order_dir: {order_dir}, user_lat: {user_lat}, user_lon: {user_lon}, dia_semana: {dia_semana}, page: {page}, per_page: {per_page}")

    if order_dir not in ("ASC", "DESC"):
        order_dir = "ASC"

    try:
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute(
                "EXEC GetCampos @ID_Campo=?, @ID_Arrendador=?, @Tipo=?, @Pesquisa=?, @OrderBy=?, @OrderDir=?, @UserLat=?, @UserLon=?, @DiaSemana=?, @PageNumber=?, @PageSize=?",
                (None, user_id, tipo, pesquisa, order_by, order_dir, user_lat, user_lon, dia_semana, page, per_page)
            )
            campos = cursor.fetchall()

            # Extract total records, handling case sensitivity
            total_records = campos[0].TotalRecords if campos else 0
            # Calculate total pages
            total_pages = ceil(total_records / per_page) if total_records > 0 else 0

        return {
            'campos': campos,
            'total_records': total_records,
            'page': page,
            'per_page': per_page,
            'total_pages': total_pages
        }
    except Exception as e:
        print(f"Erro ao obter campos: {e}")
        return None
    
# obter detalhes de um campo específico, incluindo disponibilidade
def get_campo_details(campo_id):
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("EXEC GetCampoDetails ?", (campo_id,))
        campo_data = cursor.fetchone()

        # Obter disponibilidade
        cursor.execute("EXEC GetDisponibilidadeByCampo ?", (campo_id,))
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
