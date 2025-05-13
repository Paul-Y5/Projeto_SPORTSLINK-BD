import pyodbc
from config import Config

def create_connection():
    return pyodbc.connect(Config.DB_URI)