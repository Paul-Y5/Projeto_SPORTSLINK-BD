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


# Caminho para forms registro e login
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
            cursor.execute("SELECT COUNT(*) FROM Arrendador WHERE ID_Arrendador=?", user[0])  # Verifica se o utilizador é arrendador
            is_arrendador = cursor.fetchone()[0] == 1

        tipo_utilizador = "Arrendador" if is_arrendador else "Jogador"

        flash(f'''
        <div class="alert alert-success" role="alert">
            Bem-vindo, {user[1]}! Perfil: {tipo_utilizador}.
        </div>
        ''')
        
        return redirect(url_for("user_dashboard"))
    else:
        flash('<div class="alert alert-danger" role="alert">Credenciais inválidas.</div>')
        return redirect(url_for('index'))
    
# Caminho para interface de utilizador
@app.route("/user", methods=["GET"])
def user_dashboard():
    if "user_id" not in session:
        return redirect(url_for("index"))

    user_id = session["user_id"]

    with create_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Utilizador WHERE ID=?", user_id)
        user = cursor.fetchone()

    # Retorna a página do dashboard
    return render_template("user_dashboard.html", user=user)

@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("index"))
    

# Caminho para o painel de administração
@app.route("/admin")
def admin_dashboard():
    return render_template("admin.html")

@app.route("/admin/gestao_utilizadores", methods=["GET", "POST"])
def view_utilizadores():
    tipo_utilizador = request.args.get("tipo_utilizador", "todos")  # "todos" é o valor padrão
    
    with create_connection() as conn:
        cursor = conn.cursor()
        
        # Construir a consulta SQL com base no tipo de utilizador selecionado
        if tipo_utilizador == "todos":
            cursor.execute("Select * from Utilizador as u Join Jogador as j on u.ID = j.ID Left Join Arrendador as a on u.ID = a.ID_Arrendador")
        elif tipo_utilizador == "jogador":
            cursor.execute("Select * from Utilizador as u Join Jogador as j on u.ID = j.ID Left Join Arrendador as a on u.ID = a.ID_Arrendador Where a.ID_Arrendador is null")
        elif tipo_utilizador == "arrendador":
            cursor.execute("Select * from Utilizador as u Join Jogador as j on u.ID = j.ID Left Join Arrendador as a on u.ID = a.ID_Arrendador where a.ID_Arrendador is not null")
        
        utilizadores = cursor.fetchall()
    
    return render_template("gestao_utilizadores.html", utilizadores=utilizadores)



# Contador para gerar IDs únicos simples
contador = 0

def gerar_id():
    global contador
    contador += 1
    return contador


if __name__ == "__main__":
    app.run(debug=True)