# Lógica de dias -> converter para BD as siglas
from decimal import Decimal, InvalidOperation


def get_siglas_dias():
    return {
        "dom" : "Domingo",
        "seg" : "Segunda",
        "ter" : "Terça",
        "qua" : "Quarta",
        "qui" : "Quinta",
        "sex" : "Sexta",
        "sab" : "Sábado",
    }

def get_dias_semana():
    return {
        "Domingo": 1,
        "Segunda": 2,
        "Terça": 3,
        "Quarta": 4,
        "Quinta": 5,
        "Sexta": 6,
        "Sábado": 7
    }

# Função auxiliar para converter valores para Decimal
def parse_decimal(value):
    try:
        return Decimal(value.replace(",", "."))
    except (InvalidOperation, AttributeError):
        return None