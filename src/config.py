# config.py
import os

class Config:
    SECRET_KEY = os.urandom(24)  # chave secreta para sessions
    DB_URI = "DRIVER={SQL Server};SERVER=PAUL_PC;DATABASE=SPORTSLINK;Trusted_Connection=yes;" # URI de conexão com a BD
    TEMPLATES_AUTO_RELOAD = True  # recarregar templates automaticamente