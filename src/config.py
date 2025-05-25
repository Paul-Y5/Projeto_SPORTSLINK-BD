from random import randbytes


class Config:
    SECRET_KEY = randbytes(16)  # Chave secreta para sessões