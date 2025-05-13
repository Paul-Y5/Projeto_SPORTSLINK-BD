from flask import Blueprint, render_template, request, redirect, url_for, flash, session
from controllers.auth import registration, log
from utils.decorator_login import login_required

auth_bp = Blueprint("auth", __name__)

@auth_bp.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        return registration()
    return render_template("index.html")

@auth_bp.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        return log()
    return render_template("index.html")

@auth_bp.route("/logout")
@login_required
def logout():
    session.clear()
    return redirect(url_for("auth.login"))