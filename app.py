from flask import Flask, render_template
import psycopg2
import pandas as pd
import plotly.express as px
import plotly.io as pio
from flask import Flask, render_template, request, redirect, url_for, session
import os
from werkzeug.utils import secure_filename
from werkzeug.security import generate_password_hash, check_password_hash  # Para contraseñas seguras
from functools import wraps


# Configuración de Flask
app = Flask(__name__)
app.secret_key = 'BBF_Investment'  # Cambia esto a una clave secreta segura

# Conexión a PostgreSQL
def get_db_connection():
    return psycopg2.connect(
        dbname="programa_inversiones",
        user="postgres",
        password="leo20022002",
        host="localhost",  
        port="5432"
    )

# Decorador para verificar si el usuario ha iniciado sesión
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user' not in session:  # Verifica si el usuario está en la sesión
            return redirect(url_for('login'))  # Redirige al login si no está autenticado
        return f(*args, **kwargs)
    return decorated_function

# Configuración básica
UPLOAD_FOLDER = 'static/uploads'  # Cambia si es necesario
ALLOWED_EXTENSIONS = {'pdf'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Crear la carpeta de carga si no existe
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Verificar que el archivo tiene una extensión permitida
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/')
@login_required
def index():
    # Código de la página principal
    conn = get_db_connection()
    query = """
        SELECT ti.Nombre AS TipoInversion, SUM(f.SubTotal) AS Total
        FROM Facturas f
        JOIN TipoInversion ti ON f.ID_TipoInversion = ti.ID
        GROUP BY ti.Nombre
        ORDER BY Total DESC;
    """
    df = pd.read_sql(query, conn)
    conn.close()

    # Crear un gráfico con Plotly
    fig = px.bar(df, x='tipoinversion', y='total', title='Total por Tipo de Inversión')
    graph_html = pio.to_html(fig, full_html=False)

    return render_template('index.html', graph=graph_html)


@app.route('/add_factura', methods=['GET', 'POST'])
@login_required
def add_factura():
    if request.method == 'POST':
        # Recibir datos del formulario
        numero_factura = request.form['numero_factura']
        rut_entidad = request.form['rut_entidad']

        # Validar que solo contengan números
        if not numero_factura.isdigit():
            return "Error: El número de factura debe contener solo dígitos.", 400
        if not rut_entidad.isdigit():
            return "Error: El RUT de la entidad debe contener solo dígitos.", 400

        # Continuar con el resto de la lógica
        nombre_entidad = request.form['nombre_entidad'].upper()
        tipo_entidad = request.form['tipo_entidad']
        fecha = request.form['fecha']
        tipo = request.form['tipo'].capitalize()
        cantidad = float(request.form['cantidad'])
        precio_unitario = float(request.form['precio_unitario'])
        subtotal = float(request.form['subtotal'])
        valor_total = float(request.form['valor_total'])
        nombre_activo = request.form['nombre_activo'].upper()
        comision = request.form.get('comision')
        gasto = request.form.get('gasto')


        # Manejar archivo adjunto
        if 'archivo_factura' not in request.files:
            return "Error: No se adjuntó un archivo.", 400

        archivo = request.files['archivo_factura']
        if archivo.filename == '':
            return "Error: No se seleccionó un archivo.", 400

        if archivo and allowed_file(archivo.filename):
            filename = secure_filename(archivo.filename)
            file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            file_path = file_path.replace("\\", "/")  # Convertir barras invertidas a barras normales
            archivo.save(file_path)  # Guardar el archivo
        else:
            return "Error: El archivo no es válido. Solo se aceptan PDFs.", 400

        # Determinar el ID de Tipo de Inversión según el tipo
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT ID FROM TipoInversion WHERE Nombre = %s", (tipo,))
        tipo_inversion_result = cursor.fetchone()
        if not tipo_inversion_result:
            cursor.close()
            conn.close()
            return "Error: Tipo de Inversión no encontrado.", 400
        id_tipo_inversion = tipo_inversion_result[0]

        # Verificar si la Entidad ya existe en la base de datos
        cursor.execute("SELECT ID_Entidad FROM Entidad WHERE Rut = %s", (rut_entidad,))
        entidad_result = cursor.fetchone()
        if not entidad_result:
            # Si la entidad no existe, crearla
            cursor.execute("""
                INSERT INTO Entidad (Rut, Nombre, TipoEntidad)
                VALUES (%s, %s, %s);
            """, (rut_entidad, nombre_entidad, tipo_entidad))
            conn.commit()
            cursor.execute("SELECT ID_Entidad FROM Entidad WHERE Rut = %s", (rut_entidad,))
            entidad_result = cursor.fetchone()

        id_corredora = entidad_result[0]  # Extraer la ID de la Entidad

        # Insertar la factura en la base de datos
        cursor.execute("""
            INSERT INTO Facturas 
            (NumeroFactura, ID_Corredora, Rut, Fecha, Tipo, Cantidad, PrecioUnitario, SubTotal, Valor, NombreActivo, Comision, Gasto, ID_TipoInversion, AdjuntoFactura)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
        """, (numero_factura, id_corredora, rut_entidad, fecha, tipo, cantidad, precio_unitario, subtotal, valor_total, nombre_activo, comision, gasto, id_tipo_inversion, file_path))
        conn.commit()
        cursor.close()
        conn.close()

        # Redirigir después de insertar
        return redirect(url_for('index'))
    else:
        return render_template('add_factura.html')

@app.route('/listado_facturas', methods=['GET'])
@login_required
def listado_facturas():
    # Obtener los parámetros de ordenación
    sort_by = request.args.get('sort_by', 'NumeroFactura')  # Ordenar por NumeroFactura por defecto
    order = request.args.get('order', 'asc')  # Orden ascendente por defecto

    # Validar las columnas permitidas para ordenar
    valid_columns = ['NumeroFactura', 'NombreEntidad', 'NombreActivo', 'Tipo', 'Fecha', 'Cantidad', 'PrecioUnitario', 'SubTotal', 'Valor']
    if sort_by not in valid_columns:
        sort_by = 'NumeroFactura'  # Valor por defecto si la columna no es válida

    # Validar la dirección del orden
    if order not in ['asc', 'desc']:
        order = 'asc'

    # Conexión a la base de datos
    conn = get_db_connection()
    cursor = conn.cursor()

    # Consulta principal para las facturas con orden dinámico
    query = f"""
        SELECT 
            f.NumeroFactura, 
            e.Nombre AS NombreEntidad, 
            f.NombreActivo, 
            f.Tipo,
            f.Fecha, 
            f.Cantidad, 
            f.PrecioUnitario, 
            f.SubTotal, 
            f.Valor, 
            f.AdjuntoFactura
        FROM Facturas f
        JOIN Entidad e ON f.ID_Corredora = e.ID_Entidad
        ORDER BY {sort_by} {order}
    """
    cursor.execute(query)
    facturas = cursor.fetchall()

    # Consulta para obtener el total de acciones por tipo
    cursor.execute("""
        SELECT Tipo, SUM(Cantidad) AS TotalAcciones
        FROM Facturas
        GROUP BY Tipo
    """)
    totales = cursor.fetchall()  # Esto devolverá una lista de tuplas [('Compra', total), ('Venta', total)]

    cursor.close()
    conn.close()

    return render_template('listado_facturas.html', facturas=facturas, totales=totales, sort_by=sort_by, order=order)


# @app.route('/create_user', methods=['GET'])
# def create_user():
#     conn = get_db_connection()
#     cursor = conn.cursor()

#     # Datos del usuario a crear
#     nombre_usuario = 'admin'
#     contraseña = 'admin123'
#     contraseña_cifrada = generate_password_hash(contraseña)

#     try:
#         cursor.execute("""
#             INSERT INTO Usuarios (NombreUsuario, Contraseña)
#             VALUES (%s, %s);
#         """, (nombre_usuario, contraseña_cifrada))
#         conn.commit()
#         mensaje = f"Usuario '{nombre_usuario}' creado con éxito."
#     except psycopg2.Error as e:
#         mensaje = f"Error al crear usuario: {e.pgerror}"
#     finally:
#         cursor.close()
#         conn.close()

#     return mensaje

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        # Conectar a la base de datos y verificar usuario
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT Contraseña FROM Usuarios WHERE NombreUsuario = %s", (username,))
        user = cursor.fetchone()
        cursor.close()
        conn.close()

        if user and check_password_hash(user[0], password):
            session['user'] = username  # Guardar usuario en la sesión
            return redirect(url_for('index'))  # Redirigir a la página principal
        else:
            return "Usuario o contraseña incorrectos", 401

    return render_template('login.html')


@app.route('/logout')
def logout():
    session.pop('user', None)  # Eliminar usuario de la sesión
    return redirect(url_for('login'))

@app.route('/deposito_a_plazo', methods=['GET'])
@login_required
def deposito_a_plazo():
    # Obtener los parámetros de ordenación
    sort_by = request.args.get('sort_by', 'ID_Deposito')  # Ordenar por ID_Deposito por defecto
    order = request.args.get('order', 'asc')  # Orden ascendente por defecto

    # Validar las columnas permitidas para ordenar
    valid_columns = ['ID_Deposito', 'Empresa', 'Banco', 'FechaInicio', 'FechaTermino', 'Moneda', 'MontoInicial', 'MontoFinal', 'TipoDeposito']
    if sort_by not in valid_columns:
        sort_by = 'ID_Deposito'  # Valor por defecto si la columna no es válida

    # Validar la dirección del orden
    if order not in ['asc', 'desc']:
        order = 'asc'

    # Conexión a la base de datos
    conn = get_db_connection()
    cursor = conn.cursor()

    # Consulta con orden dinámico
    query = f"""
        SELECT 
            d.ID_Deposito,
            e.Nombre AS Empresa,
            b.Nombre AS Banco,
            d.FechaInicio,
            d.FechaTermino,
            d.Moneda,
            d.MontoInicial,
            d.MontoFinal,
            d.Comprobante,
            d.TipoDeposito
        FROM DepositoAPlazo d
        JOIN EntidadComercial e ON d.ID_Empresa = e.ID_Entidad
        JOIN Entidad b ON d.ID_Banco = b.ID_Entidad
        ORDER BY {sort_by} {order}
    """
    cursor.execute(query)
    depositos = cursor.fetchall()

    cursor.close()
    conn.close()

    # Renderizar la plantilla
    return render_template('deposito_a_plazo.html', depositos=depositos, sort_by=sort_by, order=order)


from datetime import datetime

@app.route('/add_deposito', methods=['GET', 'POST'])
@login_required
def add_deposito():
    if request.method == 'POST':
        # Recibir datos del formulario
        numero_deposito = request.form['numero_deposito']
        tipo = request.form['tipo']  # Tipo de depósito
        banco_nombre = request.form['banco'].upper()
        empresa_nombre = request.form['empresa'].upper()
        tasa_interes = float(request.form['tasa_interes'])
        monto = float(request.form['monto'])
        valor_ganancia = float(request.form['valor_ganancia'])
        total_deposito = float(request.form['total_deposito'])
        fecha_toma = request.form['fecha_toma']
        fecha_termino = request.form['fecha_termino']
        fecha_renovacion = request.form.get('fecha_renovacion') if tipo == 'Renovable' else None
        fecha_abono = request.form.get('fecha_abono') if tipo == 'Fijo' else None

        # Conexión a la base de datos
        conn = get_db_connection()
        cursor = conn.cursor()

        # Buscar o crear el banco
        cursor.execute("SELECT ID_Entidad FROM Entidad WHERE Nombre = %s", (banco_nombre,))
        banco_result = cursor.fetchone()

        if not banco_result:
            # Generar un RUT temporal para el banco
            rut_temporal_banco = f"TEMP-{datetime.now().strftime('%Y%m%d%H%M%S')}"
            cursor.execute("""
                INSERT INTO Entidad (Rut, Nombre, TipoEntidad)
                VALUES (%s, %s, 'Banco')
                RETURNING ID_Entidad
            """, (rut_temporal_banco, banco_nombre))
            id_banco = cursor.fetchone()[0]
        else:
            id_banco = banco_result[0]

        # Buscar o crear la empresa
        cursor.execute("SELECT ID_Entidad FROM EntidadComercial WHERE Nombre = %s", (empresa_nombre,))
        empresa_result = cursor.fetchone()

        if not empresa_result:
            # Generar un RUT temporal para la empresa
            rut_temporal_empresa = f"TEMP-{datetime.now().strftime('%Y%m%d%H%M%S')}"
            # Insertar nueva empresa con TipoEntidad = 'Empresa'
            cursor.execute("""
                INSERT INTO EntidadComercial (Rut, Nombre, TipoEntidad)
                VALUES (%s, %s, 'Empresa')
                RETURNING ID_Entidad
            """, (rut_temporal_empresa, empresa_nombre))
            id_empresa = cursor.fetchone()[0]
        else:
            id_empresa = empresa_result[0]

        # Manejar archivo comprobante
        comprobante = None
        if 'comprobante' in request.files:
            file = request.files['comprobante']
            if file and allowed_file(file.filename):
                filename = secure_filename(file.filename)
                comprobante = os.path.join(app.config['UPLOAD_FOLDER'], filename).replace("\\", "/")
                file.save(comprobante)

        # Insertar el depósito a plazo en la base de datos
        cursor.execute("""
            INSERT INTO DepositoAPlazo 
            (ID_Deposito, ID_Banco, ID_Empresa, FechaInicio, FechaTermino, Moneda, MontoInicial, MontoFinal, Comprobante, TipoDeposito)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (numero_deposito, id_banco, id_empresa, fecha_toma, fecha_termino, 'CLP', monto, total_deposito, comprobante, tipo))
        conn.commit()
        cursor.close()
        conn.close()

        return redirect(url_for('deposito_a_plazo'))

    return render_template('add_deposito.html')

@app.route('/acciones', methods=['GET'])
@login_required
def acciones():
    # Obtener parámetros de búsqueda y ordenamiento
    search_factura = request.args.get('search_factura', '')  # Búsqueda por N° de factura
    search_ticker = request.args.get('search_ticker', '')    # Búsqueda por ticker
    sort_by = request.args.get('sort_by', 'Fecha')          # Ordenar por Fecha por defecto
    order = request.args.get('order', 'asc')                # Orden ascendente por defecto

    # Validar las columnas para evitar SQL injection
    valid_columns = ['NumeroFactura', 'Corredora', 'Fecha', 'Tipo', 'Ticker', 
                     'Cantidad', 'PrecioUnitario', 'Comision', 'CostoTotal']
    if sort_by not in valid_columns:
        sort_by = 'Fecha'
    if order not in ['asc', 'desc']:
        order = 'asc'

    # Conectar a la base de datos
    conn = get_db_connection()
    cursor = conn.cursor()

    # Construir la consulta SQL con filtros dinámicos
    query = f"""
        SELECT 
            f.NumeroFactura, 
            e.Nombre AS Corredora, 
            f.Fecha, 
            f.Tipo, 
            f.NombreActivo AS Ticker, 
            f.Cantidad, 
            f.PrecioUnitario, 
            f.Comision, 
            (f.Cantidad * f.PrecioUnitario + COALESCE(f.Comision, 0)) AS CostoTotal, 
            f.AdjuntoFactura
        FROM Facturas f
        JOIN Entidad e ON f.ID_Corredora = e.ID_Entidad
        WHERE 1=1
    """

    params = []
    if search_factura:
        query += " AND CAST(f.NumeroFactura AS TEXT) LIKE %s"
        params.append(f"%{search_factura}%")
    if search_ticker:
        query += " AND f.NombreActivo ILIKE %s"
        params.append(f"%{search_ticker}%")

    query += f" ORDER BY {sort_by} {order}"

    cursor.execute(query, params)
    acciones = cursor.fetchall()
    cursor.close()
    conn.close()

    return render_template('acciones.html', acciones=acciones, sort_by=sort_by, order=order, 
                           search_factura=search_factura, search_ticker=search_ticker)




# Ejecutar la aplicación
if __name__ == '__main__':
    app.run(debug=True)