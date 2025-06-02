import configparser
from pathlib import Path
import pyodbc
import functools

@functools.cache
def conn_string() -> str:
    config_file = Path("conf.ini")
    print(f"path: {config_file.resolve()}")
    assert config_file.exists(), "conf.ini file not found"

    config = configparser.ConfigParser()
    config.read(config_file)

    server = config["database"]["server"]
    db_name = config["database"]["name"]
    trusted = config["database"].get("trusted_connection", "no").lower()

    if trusted == "yes":
        # Usa autenticação integrada do Windows
        return f"DRIVER={{SQL Server}};SERVER={server};DATABASE={db_name};Trusted_Connection={trusted};"
    else:
        # Usa username e password
        username = config["database"]["username"]
        password = config["database"]["password"]
        return (
            f"DRIVER={{SQL Server}};"
            f"SERVER={server};"
            f"DATABASE={db_name};"
            f"UID={username};"
            f"PWD={password};"
        )

def create_connection():
    connection_string = conn_string()
    return pyodbc.connect(connection_string)
