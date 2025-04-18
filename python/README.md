# Aula 1 Project

Simple Flask webapp project backed by SQL Server.

Distributed for learning purposes.

## Dependencies

- Python3.9+ and SQL Server.
  - Do not install python using the Windows Store.
- Poetry >=1.8.0 (for dependency management)
- Libraries
  - [Flask](https://flask.palletsprojects.com)
  - Pyodbc
  - [htmx](https://htmx.org) (included in index.html)

Dependencies can be managed using [Poetry](https://python-poetry.org/). 
To install Poetry, follow the [installation guide](https://python-poetry.org/docs/#installing-with-the-official-installer) or [install with pipx](https://python-poetry.org/docs/#installing-with-pipx).
Make sure you add Poetry to your path (section 3 of the guide).

Then install the project dependencies with: `poetry install`.

You can then use: `poetry run ....` or open `poetry shell` to run your project.
Some of the recent versions of *Windows Powershell* may block some poetry scripts,
please run the commands on *Windows CMD* or other conventional shell.

## Running

Some of the recent versions of *Windows Powershell* may block some poetry scripts,
please run the commands on *Windows CMD* or other conventional shell.

If not on a virtual environemnt open one with: `poetry shell`

To run the application, use the following command: `flask run --debug`

### Formatter and Linter

Ruff has been configured on the project.

Run linter with `poetry run ruff check`.

Run formatter with `poetry run ruff format`

## Recommended resources







