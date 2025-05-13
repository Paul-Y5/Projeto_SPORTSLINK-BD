from flask import Flask, render_template, redirect, url_for, session
from config import Config
from routes.auth import auth_bp
from routes.dashboard import dashboard_bp
from routes.admin import admin_bp

# Inicialização do aplicativo Flask
app = Flask(__name__, template_folder='templates', static_folder='static')
app.config.from_object(Config)

# Registro dos blueprints
app.register_blueprint(auth_bp, url_prefix="/auth")
app.register_blueprint(dashboard_bp, url_prefix="/dashboard")
app.register_blueprint(admin_bp, url_prefix="/admin")

# Rota Inicial
@app.route("/")
def index():
    if "user_id" in session:
        return redirect(url_for("dashboard.dashboard_home"))
    return render_template("index.html")

# Ponto de entrada principal
if __name__ == "__main__":
    app.run(debug=True)