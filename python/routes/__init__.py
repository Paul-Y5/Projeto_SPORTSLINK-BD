from .auth import auth_bp
from .dashboard import dashboard_bp
from .admin import admin_bp

# Expondo os blueprints para facilitar o registro no app.py
__all__ = ["auth_bp", "dashboard_bp", "admin_bp"]