from .auth import registration, log
from .campo import excluir_campo, adicionar_campo_privado, get_disponibilidade_por_campo, get_campo_by_id, get_All_campos
from .user import make_arrendador, update_user_info, delete_user_account, get_user_info, list_campos_arrendador, get_friends, add_friend, is_arrendador

# Expondo as funções para facilitar os imports
__all__ = ["registration", "log", "excluir_campo", "adicionar_campo_privado", 
           "update_user_info", "get_users", "get_campos", "get_partidas"
            "get_user_info", "tornar_arrendador", "update_user_info",
            "delete_user_account", "list_campos_arrendador", "get_user_info",
            "get_friends", "add_friend", "make_arrendador", "is_arrendador",
            "get_disponibilidade_por_campo", "get_campo_by_id","get_All_campos"
           ]