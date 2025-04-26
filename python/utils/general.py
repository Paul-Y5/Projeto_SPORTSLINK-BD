import random
import re
import time

def validate_email(email):
    return re.match(r"[^@]+@[^@]+\.[^@]+", email)

def validate_iban(iban):
    return len(iban) >= 15 and len(iban) <= 34

def validate_number(value):
    try:
        float(value)
        return True
    except ValueError:
        return False
    

# Funções para gerar IDs únicos	
def gerar_id_utilizador():
    timestamp = int(time.time() % 100000)
    random_number = random.randint(1000, 9999)
    return int(f"{timestamp}{random_number}")

def gerar_id_partida():
    timestamp = int(time.time() % 100000)
    random_number = random.randint(100, 999)
    return int(f"{timestamp}{random_number}")

def gerar_id_campo():
    timestamp = int(time.time() % 1000)
    random_number = random.randint(1000, 9999)
    return int(f"{random_number}{timestamp}")

def gerar_id_ponto():
    timestamp = int(time.time() % 1000)
    random_number = random.randint(1000, 9999)
    return int(f"{random_number}{timestamp}")


# Lógica de dias -> converter para BD as siglas TODO
def get_siglas_dias():
    return {
        "dom" : "Domingo",
        "seg" : "Segunda-feira",
        "ter" : "Terça-feira",
        "qua" : "Quarta-feira",
        "qui" : "Quinta-feira",
        "sex" : "Sexta-feira",
        "sab" : "Sábado",
    }

def get_dias_semana():
    return {
        "Domingo": 1,
        "Segunda-feira": 2,
        "Terça-feira": 3,
        "Quarta-feira": 4,
        "Quinta-feira": 5,
        "Sexta-feira": 6,
        "Sábado": 7
    }