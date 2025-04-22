from flask import Flask, flash, render_template, render_template_string, request, redirect, url_for, session
import pyodbc, os, time, random
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__, template_folder='templates') # Define o diretório de templates
app.secret_key = os.urandom(24) # Chave secreta para sessões e cookies mais seguros

# Configuração Base de Dados
def create_connection():
    conn = pyodbc.connect(
        "DRIVER={SQL Server};SERVER=PAUL_PC;DATABASE=SPORTSLINK;Trusted_Connection=yes;"
    )
    return conn

@app.route("/")
def index():
    return render_template("index.html")

# Caminho para forms registro e login
@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        return registration()
    return render_template("index.html")
    

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        return log()
    return render_template("index.html")


# Caminho para interface do utilizador
@app.route("/user/<name>", methods=["GET", "POST"])
def jog_dashboard(name):
    

    if "user_id" not in session:
        return redirect(url_for("index"))
    
    user_id = session["user_id"]
    user = get_user_info(user_id)

    tipo_utilizador = "Arrendador" if is_arrendador(user_id) else "Jogador"

    if tipo_utilizador == "Arrendador":
        return render_template("arr_dashboard.html", user=user)
    else:
        return render_template("jog_dashboard.html", user=user)
    
@app.route("/update_info", methods=["GET", "POST"])
def update_info():
    if "user_id" not in session:
        return redirect(url_for("index"))

    user_id = session["user_id"]

    if request.method == "POST":
        username = request.form["username"]
        email = request.form["email"]
        nationality = request.form["nacionalidade"]
        phone_number = request.form["numero_telemovel"]
        age = request.form.get("idade")
        description = request.form.get("descricao")
        iban = None
        no_campos = None

        tipo_utilizador = "Arrendador" if is_arrendador(user_id) else "Jogador"

        with create_connection() as conn:

            cursor = conn.cursor()
            if tipo_utilizador == "Jogador":
                cursor.execute("""
                    UPDATE Utilizador
                    SET Nome=?, Email=?, Num_Tele=?, Nacionalidade=?
                    WHERE ID=?
                """, (username, email, phone_number, nationality, user_id))
                
                cursor.execute("""
                    UPDATE Jogador
                    SET Idade=?, Descricao=?
                    WHERE ID=?
                """, (age, description, user_id))
            else:
                iban = request.form["iban"]
                no_campos = request.form["no_campos"]
                
                cursor.execute("""
                    UPDATE Utilizador
                    SET Nome=?, Email=?, Num_Tele=?, Nacionalidade=?
                    WHERE ID=?
                """, (username, email, phone_number, nationality, user_id))
                
                cursor.execute("""
                    UPDATE Jogador
                    SET Idade=?, Descricao=?
                    WHERE ID=?
                """, (age, description, user_id))
                
                cursor.execute("""
                    UPDATE Arrendador
                    SET IBAN=?, No_Campos=?
                    WHERE ID_Arrendador=?
                """, (iban, no_campos, user_id))
                
            conn.commit()

        flash("Informações atualizadas com sucesso!", "success")
        user = get_user_info(user_id)

        if tipo_utilizador == "Arrendador":
            return render_template("arr_dashboard.html", user=user)
        else:
            return render_template("jog_dashboard.html", user=user)

    
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Utilizador WHERE ID = ?", (user_id,))
        user = cursor.fetchone()

    return render_template("jog_dashboard.html", user=user)
    
@app.route("/excluir_conta", methods=["POST", "GET"])
def delete_account():
    if "user_id" not in session:
        return redirect(url_for("index"))

    user_id = session["user_id"]

    if request.method == "POST":
        try:
            with create_connection() as conn:
                cursor = conn.cursor()
                
                cursor.execute("DELETE FROM Jogador WHERE ID=?", (user_id,))
                cursor.execute("DELETE FROM Arrendador WHERE ID_Arrendador=?", (user_id,))
                cursor.execute("DELETE FROM Utilizador WHERE ID=?", (user_id,))
                conn.commit()

            flash("Conta excluída com sucesso!", "success")
            session.clear()
            return redirect(url_for("index"))

        except Exception as e:
            flash(f"Erro ao excluir conta: {str(e)}", "danger")
            return redirect(url_for("account"))

    return render_template("account_settings.html")

@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("index"))

@app.route("/arrendador", methods=["POST"])
def arrendador_dashboard():
    if "user_id" not in session:
        return redirect(url_for("index"))

    user_id = session["user_id"]
    iban = request.form["iban"]
    termos = request.form.get("termos")
    user = get_user_info(user_id)
    if not termos:
        flash("Deves aceitar os termos e condições para continuares.", "danger")
        return redirect(url_for("arr_dashboard", user=user))

    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO ARRENDADOR (ID_Arrendador, IBAN, No_Campos)
            VALUES (?, ?, ?)
        """, (user_id, iban, 0,))
        conn.commit()

    flash("Agora és um arrendador!", "success")
    return redirect(url_for("arr_dashboard", user=user))
    

# Caminho para o painel de administração
@app.route("/admin")
def admin_dashboard():
    utilizadores = get_all_users()
    campos = get_campos()
    partidas = get_partidas()
    return render_template("admin.html", utilizadores=utilizadores, campos=campos, partidas=partidas)

### Funções AUXILIARES ###
#-----------------------------------------------------------------------#

# Função para gerar um ID único para o utilizador
def gerar_id():
    timestamp = int(time.time() % 100000)
    random_number = random.randint(1000, 9999)
    return int(f"{timestamp}{random_number}")

def is_arrendador(user_id):
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM Arrendador WHERE ID_Arrendador=?", user_id)
        return cursor.fetchone()[0] == 1

def registration():
    id_utilizador = gerar_id()
    username = request.form["username"]
    email = request.form["reg_email"]
    nationality = request.form["nacionalidade"]
    phone_number = request.form["numero_telemovel"]
    password = request.form["reg_password"]

    # Gera o hash da senha
    h_password = generate_password_hash(password)
        
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Utilizador WHERE Email=?", email)
        user = cursor.fetchone()
        if user:
            flash("Email já registado. Tente novamente.", "danger")
            return render_template("index.html")

        try:
            cursor.execute("INSERT INTO Utilizador (ID, Nome, Email, Num_Tele, Password, Nacionalidade) VALUES (?, ?, ?, ?, ?, ?)", 
                (id_utilizador, username, email, phone_number, h_password, nationality)) # Comando SQL para inserir o utilizador na tabela Utilizador
            
            cursor.execute("INSERT INTO Jogador (ID, Idade, Descricao) VALUES (?, ?, ?)",
                (id_utilizador, 0, '')) # Comando SQL para inserir o jogador na tabela Jogador

            conn.commit()

            flash("Registo realizado com sucesso!", "success")
            return redirect(url_for("index"))
        except pyodbc.IntegrityError:
            flash("Erro ao registar o utilizador. Tente novamente.", "danger")
            return render_template("index.html")

def log():
    email = request.form["login_email"]
    password = request.form["login_password"]

    if email == "admin@admin.pt" and password == "admin":
        session["user_id"] = 0
        session["user_nome"] = "Admin"
        return redirect(url_for("admin_dashboard"))

    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Utilizador WHERE Email=?", email)
        user = cursor.fetchone()

    if user and check_password_hash(user[4], password):
        session["user_id"] = user[0]
        session["user_nome"] = user[1]

        tipo_utilizador = "Arrendador" if is_arrendador(user[0]) else "Jogador"

        flash(f"Login realizado com sucesso! Tipo de utilizador: {tipo_utilizador}", "success")
        # Redireciona para a página dashboard
        return redirect(url_for("jog_dashboard", name=user[1]))
    else:
        flash("Email ou password incorretos.", "danger")
        return render_template("index.html")


def get_user_info(user_id):
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Utilizador WHERE ID=?", user_id)
        user = cursor.fetchone()
        tipo_utilizador = "Arrendador" if is_arrendador(user_id) else "Jogador"
        if tipo_utilizador == "Arrendador":
            cursor.execute("""Select U.ID, U.Nome, U.Email, U.Num_Tele, U.Password, U.Nacionalidade, J.Idade, J.Descricao, A.IBAN, A.No_Campos 
                FROM Utilizador AS U JOIN Jogador AS J ON U.ID = J.ID JOIN Arrendador AS A ON U.ID = A.ID_Arrendador
                WHERE U.ID=?""", (user_id,))
        else:
            cursor.execute("""SELECT U.ID, U.Nome, U.Email, U.Num_Tele, U.Password, U.Nacionalidade, J.Idade, J.Descricao 
                FROM Utilizador AS U JOIN Jogador AS J ON U.ID = J.ID WHERE U.ID=?""", (user_id,))
        user = cursor.fetchone()
    return user

def get_all_users():
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT 
                U.ID, 
                U.Nome, 
                U.Email, 
                U.Num_Tele, 
                U.Nacionalidade, 
                J.Idade, 
                J.Descricao, 
                A.IBAN, 
                A.No_Campos,
                CASE 
                    WHEN A.ID_Arrendador IS NOT NULL THEN 'Arrendador'
                    ELSE 'Jogador'
                END AS Tipo
            FROM Utilizador AS U
            JOIN Jogador AS J ON U.ID = J.ID
            LEFT JOIN Arrendador AS A ON U.ID = A.ID_Arrendador
        """)
        utilizadores = cursor.fetchall()
    return utilizadores

def get_campos():
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT C.ID, C.Nome, C.Comprimento, C.Largura, C.ocupado, C.Descricao
            FROM Campo AS C
        """)
        return cursor.fetchall()

def get_partidas():
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT P.ID, P.Data_Hora, C.Nome AS Campo, P.no_jogadores, P.Resultado
            FROM Partida AS P
            JOIN Campo AS C ON P.ID_Campo = C.ID
        """)
        return cursor.fetchall()



# Pode ser necessário
def get_jogadores():
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT J.ID, U.Nome, U.Email, J.Idade, J.Descricao
            FROM Jogador AS J
            JOIN Utilizador AS U ON J.ID = U.ID
        """)
        return cursor.fetchall()

def get_arrendadores():
    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT A.ID_Arrendador, U.Nome, U.Email, A.IBAN, A.No_Campos
            FROM Arrendador AS A
            JOIN Utilizador AS U ON A.ID_Arrendador = U.ID
        """)
        return cursor.fetchall()
######################




# Main
if __name__ == "__main__":
    app.run(debug=True)