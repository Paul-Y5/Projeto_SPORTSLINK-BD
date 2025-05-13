# Lógica de dias -> converter para BD as siglas
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
