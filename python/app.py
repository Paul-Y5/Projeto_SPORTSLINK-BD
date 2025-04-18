from flask import Flask, flash, render_template, render_template_string, request, redirect, url_for, session
import pyodbc
import os

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

@app.route("/admin")
def admin_dashboard():
    return render_template("admin.html")

# Rota para forms registro e login
@app.route("/register", methods=["POST"])
def register():
    id_utilizador = gerar_id()
    username = request.form["username"]
    email = request.form["reg_email"]
    nationality = request.form["nacionalidade"]
    phone_number = request.form["numero_telemovel"]
    password = request.form["reg_password"]

    with create_connection() as conn:
        cursor = conn.cursor()
        try:
            cursor.execute("INSERT INTO Utilizador (ID, Nome, Email, Num_Tele, Password, Nacionalidade) VALUES (?, ?, ?, ?, ?, ?)", 
                (id_utilizador, username, email, phone_number, password, nationality)) # Comando SQL para inserir o utilizador na tabela Utilizador
            
            cursor.execute("INSERT INTO Jogador (ID, Idade, Descricao) VALUES (?, ?, ?)",
                (id_utilizador, 0, '')) # Comando SQL para inserir o jogador na tabela Jogador

            conn.commit()

            return '''
            <div class="alert alert-success" role="alert">
                Utilizador registado com sucesso!
            </div>
            '''
        except pyodbc.IntegrityError:
            return '''
            <div class="alert alert-danger" role="alert">
                O email já está em uso. Por favor, escolha outro.
            </div>
            '''


@app.route("/login", methods=["POST"])
def login():
    email = request.form["login_email"]
    password = request.form["login_password"]

    if email == "admin@admin.pt" and password == "admin":
        session["user_id"] = "admin"
        session["user_nome"] = "Administrador"
        return redirect(url_for("admin_dashboard"))


    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Utilizador WHERE Email=? AND Password=?", email, password) # Comando SQL para verificar se o utilizador existe
        user = cursor.fetchone()

    if user:
        session["user_id"] = user[0]
        session["user_nome"] = user[1]

        # Verifica se é arrendador
        with create_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT COUNT(*) FROM Arrendador WHERE ID_Arrendador = ?", user[0])  # Verifica se o utilizador é arrendador
            is_arrendador = cursor.fetchone()[0] == 1

        tipo_utilizador = "Arrendador" if is_arrendador else "Jogador"

        return f'''
        <div class="alert alert-success" role="alert">
            Bem-vindo, {user[1]}! Perfil: {tipo_utilizador}.
        </div>
        '''
    else:
        return '''
        <div class="alert alert-danger" role="alert">
            Credenciais inválidas.
        </div>
        '''
    
# Contador para gerar IDs únicos simples
contador = 0

def gerar_id():
    global contador
    contador += 1
    return contador


if __name__ == "__main__":
    app.run(debug=True)