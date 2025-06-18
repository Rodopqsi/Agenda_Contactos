import cx_Oracle

# Configuración de conexión
username = "system"  # Reemplaza con tu usuario de la base de datos
password = "oracle"  # Reemplaza con tu contraseña
dsn = "localhost:1521/xepdb1"  # Reemplaza con tu cadena de conexión (host/servicio)

try:
    # Conexión a la base de datos
    connection = cx_Oracle.connect(user=username, password=password, dsn=dsn)
    print("Conexión exitosa a la base de datos")

    # Crear un cursor
    cursor = connection.cursor()

    # Definir los parámetros
    p_nombre = "NuevaCategoria"  # Reemplaza con el nombre de la categoría
    p_resultado = cursor.var(cx_Oracle.NUMBER)  # Variable para el parámetro OUT

    # Ejecutar el procedimiento con los parámetros
    cursor.callproc("agregar_categoria", [p_nombre, p_resultado])

    # Imprimir el resultado del parámetro OUT
    print(f"Resultado del procedimiento: {p_resultado.getvalue()}")

except cx_Oracle.DatabaseError as e:
    error, = e.args
    print(f"Error al conectar o ejecutar el procedimiento: {error.message}")

finally:
    # Cerrar la conexión
    if 'connection' in locals():
        connection.close()
        print("Conexión cerrada")