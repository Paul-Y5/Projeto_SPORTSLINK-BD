from flask import Flask, render_template, redirect, request, url_for, session
from config import Config
from routes.auth import auth_bp
from routes.dashboard import dashboard_bp

# Inicialização do aplicativo Flask
app = Flask(__name__, template_folder='templates', static_folder='static')
# Configuração da chave secreta para sessões
app.config.from_object(Config)

# Registro dos blueprints
app.register_blueprint(auth_bp, url_prefix="/auth")
app.register_blueprint(dashboard_bp, url_prefix="/dashboard")

# Rota Inicial
@app.route("/")
def index():
    if "user_id" in session:
        return redirect(url_for("dashboard.jog_dashboard", name = session["username"]))
   
    return render_template("index.html")

# Ponto de entrada principal
if __name__ == "__main__":
    app.run(debug=True)