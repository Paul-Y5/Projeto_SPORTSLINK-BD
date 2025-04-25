import pyodbc

arr_days = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado']

def create_connection():
    conn = pyodbc.connect(
        "DRIVER={SQL Server};SERVER=PAUL_PC;DATABASE=SPORTSLINK;Trusted_Connection=yes;"
    )
    return conn

def insert_days():
    conn = create_connection()
    cursor = conn.cursor()

    for i in range(7):
        day = arr_days[i]
        cursor.execute(
            "INSERT INTO Dias_semana (ID, Nome) VALUES (?, ?)", (i+1, day)
        )
        print(f"Inserted {day} into Dias_semana table")

    conn.commit()
    cursor.close()
    conn.close()


if __name__ == "__main__":
    insert_days()
    print("All days inserted successfully.")