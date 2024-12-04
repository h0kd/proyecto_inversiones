from flask import Flask, render_template
import psycopg2
import pandas as pd
import plotly.express as px
import plotly.io as pio
from flask import Flask, render_template, request, redirect, url_for, session, flash
import os
from werkzeug.utils import secure_filename
from werkzeug.security import generate_password_hash, check_password_hash  # Para contraseñas seguras
from functools import wraps
from dotenv import load_dotenv  # Importar dotenv

# Cargar variables de entorno
load_dotenv()


# Configuración de Flask
app = Flask(__name__)
app.secret_key = os.getenv('FLASK_SECRET_KEY')  # Clave secreta desde .env

# Conexión a PostgreSQL
def get_db_connection():
    return psycopg2.connect(
        dbname=os.getenv('DB_NAME'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
        host=os.getenv('DB_HOST'),
        port=os.getenv('DB_PORT')
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

# desde aca debo cambiar todo de lugar

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

    return render_template('listado_facturas.html', facturas=facturas, sort_by=sort_by, order=order)

@app.route('/edit_factura/<int:numero_factura>', methods=['GET', 'POST'])
@login_required
def editar_factura(numero_factura):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        if request.method == 'POST':
            try:
                # Obtener datos del formulario
                print("Datos recibidos del formulario:", request.form)  # Debug
                nuevo_numero_factura = request.form['nuevo_numero']
                nombre_entidad = request.form['nombre_entidad']
                nombre_activo = request.form['nombre_activo']

                # Validar si el nuevo número de factura ya existe
                if str(numero_factura) != nuevo_numero_factura:
                    cursor.execute("SELECT 1 FROM Facturas WHERE NumeroFactura = %s", (nuevo_numero_factura,))
                    if cursor.fetchone():
                        flash("El nuevo número de factura ya existe. Por favor, elige otro.", "error")
                        return redirect(url_for('editar_factura', numero_factura=numero_factura))

                # Actualizar entidad o entidad comercial
                cursor.execute("SELECT ID_Corredora FROM Facturas WHERE NumeroFactura = %s", (numero_factura,))
                id_entidad = cursor.fetchone()[0]

                cursor.execute("""
                    UPDATE Entidad
                    SET Nombre = %s
                    WHERE ID_Entidad = %s
                """, (nombre_entidad, id_entidad))

                # Actualizar la factura (incluyendo Nombre Activo)
                cursor.execute("""
                    UPDATE Facturas
                    SET NumeroFactura = %s, NombreActivo = %s
                    WHERE NumeroFactura = %s
                """, (nuevo_numero_factura, nombre_activo, numero_factura))

                if cursor.rowcount == 0:
                    flash("No se pudo actualizar la factura. Verifica los datos.", "error")
                    conn.rollback()
                    return redirect(url_for('editar_factura', numero_factura=numero_factura))

                conn.commit()
                flash("Factura actualizada exitosamente.", "success")
                return redirect(url_for('listado_facturas'))
            except Exception as e:
                conn.rollback()
                flash(f"Error al actualizar la factura: {e}", "error")
        else:
            # Obtener información de la factura
            cursor.execute("SELECT NumeroFactura, NombreActivo FROM Facturas WHERE NumeroFactura = %s", (numero_factura,))
            factura = cursor.fetchone()

            cursor.execute("""
                SELECT e.Rut, e.Nombre, e.TipoEntidad
                FROM Facturas f
                JOIN Entidad e ON f.ID_Corredora = e.ID_Entidad
                WHERE f.NumeroFactura = %s
            """, (numero_factura,))
            entidad = cursor.fetchone()

            if not entidad:
                cursor.execute("""
                    SELECT ec.Rut, ec.Nombre, ec.TipoEntidad
                    FROM Facturas f
                    JOIN EntidadComercial ec ON f.ID_Corredora = ec.ID_Entidad
                    WHERE f.NumeroFactura = %s
                """, (numero_factura,))
                entidad = cursor.fetchone()

            return render_template('edit_factura.html', factura=factura, entidad=entidad)

    finally:
        # Asegurar el cierre de conexión
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()











@app.route('/eliminar_factura/<int:numero_factura>', methods=['POST', 'GET'])
@login_required
def eliminar_factura(numero_factura):
    conn = get_db_connection()
    cursor = conn.cursor()

    # Eliminar la factura
    cursor.execute("DELETE FROM Facturas WHERE NumeroFactura = %s", (numero_factura,))
    conn.commit()
    conn.close()

    return redirect(url_for('listado_facturas'))


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
        cursor.execute("SELECT ID, Contraseña FROM Usuarios WHERE NombreUsuario = %s", (username,))
        user = cursor.fetchone()
        cursor.close()
        conn.close()

        if user and check_password_hash(user[1], password):  # Verifica la contraseña
            session['user'] = username  # Guardar nombre de usuario en la sesión
            session['user_id'] = user[0]  # Guardar ID del usuario en la sesión
            return redirect(url_for('index'))  # Redirigir a la página principal
        else:
            return "Usuario o contraseña incorrectos", 401

    return render_template('login.html')


@app.route('/logout')
def logout():
    session.pop('user', None)  # Eliminar usuario de la sesión
    return redirect(url_for('login'))

@app.route('/cambiar_contrasena', methods=['GET', 'POST'])
@login_required
def cambiar_contrasena():
    if 'user_id' not in session:
        flash("Debe iniciar sesión para cambiar la contraseña.", "error")
        return redirect(url_for('login'))

    conn = get_db_connection()
    cursor = conn.cursor()

    if request.method == 'POST':
        try:
            contrasena_actual = request.form['contrasena_actual']
            nueva_contrasena = request.form['nueva_contrasena']
            confirmar_contrasena = request.form['confirmar_contrasena']

            # Verificar la contraseña actual
            cursor.execute("SELECT Contraseña FROM Usuarios WHERE ID = %s", (session['user_id'],))
            resultado = cursor.fetchone()

            if not resultado:
                flash("Usuario no encontrado.", "error")
                return redirect(url_for('cambiar_contrasena'))

            contrasena_hash = resultado[0]
            if not check_password_hash(contrasena_hash, contrasena_actual):
                flash("La contraseña actual es incorrecta.", "error")
                return redirect(url_for('cambiar_contrasena'))

            if nueva_contrasena != confirmar_contrasena:
                flash("Las nuevas contraseñas no coinciden.", "error")
                return redirect(url_for('cambiar_contrasena'))

            # Actualizar la nueva contraseña
            nuevo_hash = generate_password_hash(nueva_contrasena)
            cursor.execute("UPDATE Usuarios SET Contraseña = %s WHERE ID = %s", (nuevo_hash, session['user_id']))
            conn.commit()

            flash("Contraseña cambiada con éxito.", "success")
            return redirect(url_for('inicio'))
        except Exception as e:
            print(f"Error al cambiar la contraseña: {e}")
            flash("Hubo un error al cambiar la contraseña.", "error")
            return redirect(url_for('cambiar_contrasena'))
        finally:
            cursor.close()
            conn.close()

    return render_template('cambiar_contrasena.html')

@app.route('/test_password', methods=['GET'])
def test_password():
    contraseña_original = 'admin123'
    contraseña_hash = generate_password_hash(contraseña_original)

    # Probar verificación
    resultado = check_password_hash(contraseña_hash, contraseña_original)
    return f"Hash generado: {contraseña_hash}, Verificación: {resultado}"

@app.route('/deposito_a_plazo', methods=['GET'])
@login_required
def deposito_a_plazo():
    # Obtener los parámetros de ordenación
    sort_by = request.args.get('sort_by', 'ID_Deposito')  # Ordenar por ID_Deposito por defecto
    order = request.args.get('order', 'asc')  # Orden ascendente por defecto

    # Validar las columnas permitidas para ordenar
    valid_columns = [
        'ID_Deposito', 'Empresa', 'Banco', 'FechaEmision', 'FechaVencimiento', 'Moneda',
        'MontoInicial', 'MontoFinal', 'TipoDeposito', 'CapitalRenovacion', 'PlazoRenovacion'
    ]
    if sort_by not in valid_columns:
        sort_by = 'ID_Deposito'  # Valor por defecto si la columna no es válida

    # Validar la dirección del orden
    if order not in ['asc', 'desc']:
        order = 'asc'

    # Conexión a la base de datos
    conn = get_db_connection()
    cursor = conn.cursor()

    # Consulta SQL
    query = f"""
        SELECT 
            d.ID_Deposito,
            ec.Nombre AS Empresa,
            b.Nombre AS Banco,
            d.FechaEmision,
            d.FechaVencimiento,
            d.Moneda,
            d.MontoInicial,
            d.MontoFinal,
            d.TipoDeposito,
            d.CapitalRenovacion,
            d.PlazoRenovacion,
            d.Comprobante
        FROM DepositoAPlazo d
        JOIN EntidadComercial ec ON d.ID_EntidadComercial = ec.ID_Entidad
        JOIN Entidad b ON d.ID_Banco = b.ID_Entidad
        ORDER BY {sort_by} {order}
    """
    cursor.execute(query)
    depositos = cursor.fetchall()

    cursor.close()
    conn.close()

    # Renderizar la plantilla con los datos recuperados
    return render_template('deposito_a_plazo.html', depositos=depositos, sort_by=sort_by, order=order)

from datetime import datetime

@app.route('/add_deposito', methods=['GET', 'POST'])
@login_required
def add_deposito():
    if request.method == 'POST':
        # Conexión a la base de datos
        conn = get_db_connection()
        cursor = conn.cursor()

        try:
            # Capturar datos del formulario
            id_deposito = request.form['numero_deposito']  # Número de Depósito
            tipo = request.form['tipo']
            monto = float(request.form['monto'])
            fecha_emision = request.form['fecha_emision']
            tasa_interes = float(request.form['tasa_interes'])
            fecha_vencimiento = request.form['fecha_vencimiento']
            moneda = request.form.get('moneda', 'CLP')
            interes_ganado = float(request.form.get('interes_ganado', 0))  # Valor opcional con default 0
            tipo_beneficiario = request.form['tipo_beneficiario']  # Cliente o Empresa
            nombre_beneficiario = request.form.get('nombre_beneficiario', '').upper()
            rut_beneficiario = request.form.get('rut_beneficiario', '')

            # Manejo de errores
            if not nombre_beneficiario:
                return "Error: Nombre del beneficiario no proporcionado", 400

            # Validar campos de renovación (solo si tipo es "Renovable")
            capital_renovacion = float(request.form.get('capital_renovacion', 0))
            fecha_emision_renovacion = request.form.get('fecha_emision_renovacion')
            tasa_interes_renovacion = float(request.form.get('tasa_interes_renovacion', 0))
            plazo_renovacion = int(request.form.get('plazo_renovacion', 0))
            tasa_periodo = float(request.form.get('tasa_periodo', 0))
            fecha_vencimiento_renovacion = request.form.get('fecha_vencimiento_renovacion')
            total_pagar_renovacion = float(request.form.get('total_pagar_renovacion', 0))

            # Manejo del archivo comprobante
            comprobante = None
            if 'comprobante' in request.files:
                file = request.files['comprobante']
                if file and file.filename != '':
                    filename = secure_filename(file.filename)
                    comprobante_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
                    file.save(comprobante_path)
                    comprobante = comprobante_path.replace("\\", "/")

            # Manejo del beneficiario
            cursor.execute(
                "SELECT ID_Entidad FROM EntidadComercial WHERE Rut = %s AND TipoEntidad = %s",
                (rut_beneficiario, tipo_beneficiario)
            )
            entidad_result = cursor.fetchone()

            if not entidad_result:
                # Crear beneficiario si no existe
                cursor.execute(
                    """
                    INSERT INTO EntidadComercial (Rut, Nombre, TipoEntidad)
                    VALUES (%s, %s, %s) RETURNING ID_Entidad
                    """,
                    (rut_beneficiario, nombre_beneficiario, tipo_beneficiario)
                )
                id_entidadcomercial = cursor.fetchone()[0]
            else:
                id_entidadcomercial = entidad_result[0]

            # Manejo del banco
            banco_nombre = request.form['banco'].upper()
            cursor.execute("SELECT ID_Entidad FROM Entidad WHERE Nombre = %s", (banco_nombre,))
            banco_result = cursor.fetchone()

            if not banco_result:
                # Crear el banco si no existe
                rut_temporal = f"TEMP-{datetime.now().strftime('%Y%m%d%H%M%S')}"
                cursor.execute(
                    """
                    INSERT INTO Entidad (Rut, Nombre, TipoEntidad)
                    VALUES (%s, %s, 'Banco') RETURNING ID_Entidad
                    """,
                    (rut_temporal, banco_nombre)
                )
                id_banco = cursor.fetchone()[0]
            else:
                id_banco = banco_result[0]

            # Insertar el depósito en la base de datos
            cursor.execute("""
                INSERT INTO DepositoAPlazo 
                (ID_Deposito, ID_Banco, ID_EntidadComercial, FechaEmision, FechaVencimiento, Moneda, MontoInicial, TipoDeposito, 
                InteresGanado, TasaInteres, CapitalRenovacion, FechaEmisionRenovacion, TasaInteresRenovacion, 
                PlazoRenovacion, TasaPeriodo, FechaVencimientoRenovacion, TotalPagarRenovacion, Comprobante)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                id_deposito, id_banco, id_entidadcomercial, fecha_emision, fecha_vencimiento, moneda, monto, tipo, 
                interes_ganado, tasa_interes, 
                capital_renovacion if tipo == "Renovable" else None, 
                fecha_emision_renovacion if tipo == "Renovable" else None, 
                tasa_interes_renovacion if tipo == "Renovable" else None, 
                plazo_renovacion if tipo == "Renovable" else None, 
                tasa_periodo if tipo == "Renovable" else None, 
                fecha_vencimiento_renovacion if tipo == "Renovable" else None, 
                total_pagar_renovacion if tipo == "Renovable" else None,
                comprobante
            ))

            conn.commit()

        except Exception as e:
            conn.rollback()
            print(f"Error al insertar el depósito: {e}")
            raise e

        finally:
            cursor.close()
            conn.close()

        return redirect(url_for('deposito_a_plazo'))

    return render_template('add_deposito.html')


@app.route('/edit_deposito/<int:id_deposito>', methods=['GET', 'POST'])
@login_required
def edit_deposito(id_deposito):
    # Conexión a la base de datos
    conn = get_db_connection()
    cursor = conn.cursor()

    if request.method == 'POST':
        try:
            # Capturar datos del formulario
            id_deposito_new = request.form['id_deposito']
            tipo = request.form['tipo']
            monto = float(request.form['monto'])
            fecha_emision = request.form['fecha_emision']
            tasa_interes = float(request.form['tasa_interes'])
            fecha_vencimiento = request.form['fecha_vencimiento']
            interes_ganado = float(request.form.get('interes_ganado', 0))  # Valor por defecto: 0
            reajuste_ganado = request.form.get('reajuste_ganado', None)

            print(request.form)
            # Manejo del comprobante
            comprobante = None
            if 'comprobante' in request.files:
                file = request.files['comprobante']
                if file and allowed_file(file.filename):  # Verifica extensión válida
                    filename = secure_filename(file.filename)
                    comprobante = os.path.join(app.config['UPLOAD_FOLDER'], filename).replace("\\", "/")
                    file.save(comprobante)  # Guarda el archivo en el servidor

            # Construir consulta SQL para actualización
            update_query = """
                UPDATE DepositoAPlazo
                SET ID_Deposito = %s,
                    TipoDeposito = %s,
                    MontoInicial = %s,
                    FechaEmision = %s,
                    FechaVencimiento = %s,
                    InteresGanado = %s,
                    ReajusteGanado = %s,
                    Comprobante = %s
                WHERE ID_Deposito = %s
            """
            cursor.execute(update_query, (
                id_deposito_new,
                tipo,
                monto,
                fecha_emision,
                fecha_vencimiento,
                interes_ganado,
                reajuste_ganado,
                comprobante,
                id_deposito
            ))

            # Confirmar cambios
            conn.commit()

        except Exception as e:
            conn.rollback()
            print(f"Error al actualizar el depósito: {e}")
            raise e

        finally:
            cursor.close()
            conn.close()

        return redirect(url_for('deposito_a_plazo'))

    # Cargar datos existentes para el formulario
    cursor.execute("SELECT * FROM DepositoAPlazo WHERE ID_Deposito = %s", (id_deposito,))
    deposito = cursor.fetchone()

    cursor.close()
    conn.close()

    return render_template('edit_deposito.html', deposito=deposito)

@app.route('/delete_deposito/<int:id_deposito>', methods=['POST'])
@login_required
def delete_deposito(id_deposito):
    # Conexión a la base de datos
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        # Eliminar el depósito por su ID
        cursor.execute("DELETE FROM DepositoAPlazo WHERE ID_Deposito = %s", (id_deposito,))
        conn.commit()
        flash('Depósito eliminado exitosamente.', 'success')
    except Exception as e:
        conn.rollback()
        flash(f'Error al eliminar el depósito: {e}', 'error')
    finally:
        cursor.close()
        conn.close()

    return redirect(url_for('deposito_a_plazo'))


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

    # Consulta para obtener el total de acciones por tipo
    cursor.execute("""
        SELECT Tipo, SUM(Cantidad) AS TotalAcciones
        FROM Facturas
        GROUP BY Tipo
    """)
    totales = cursor.fetchall()  # Esto devolverá una lista de tuplas [('Compra', total), ('Venta', total)]

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
                           search_factura=search_factura, search_ticker=search_ticker, totales=totales)

@app.route('/acciones_rendimiento', methods=['GET'])
@login_required
def acciones_rendimiento():
    # Conectar a la base de datos
    conn = get_db_connection()
    cursor = conn.cursor()

    # Consulta para obtener datos necesarios
    cursor.execute("""
        SELECT 
            f.Fecha, 
            f.NombreActivo AS Ticker, 
            f.PrecioUnitario AS Precio, 
            f.Tipo, 
            f.Cantidad
        FROM Facturas f
        WHERE f.Tipo IN ('Compra', 'Venta')
        ORDER BY f.Fecha;
    """)
    datos = cursor.fetchall()
    cursor.close()
    conn.close()

    # Imprimir datos para verificar
    print("Datos recuperados:", datos)

    # Preparar los datos para el gráfico
    import pandas as pd
    df = pd.DataFrame(datos, columns=['Fecha', 'Ticker', 'Precio', 'Tipo', 'Cantidad'])

    # Calcular rendimientos
    rendimientos = []
    for ticker in df['Ticker'].unique():
        df_ticker = df[df['Ticker'] == ticker].sort_values('Fecha')
        precio_inicial = df_ticker.iloc[0]['Precio'] if not df_ticker.empty else 0
        df_ticker['Rendimiento (%)'] = ((df_ticker['Precio'] - precio_inicial) / precio_inicial) * 100
        rendimientos.append(df_ticker)

    df_rendimientos = pd.concat(rendimientos)

    # Crear gráfico con Plotly
    import plotly.express as px
    fig = px.line(
        df_rendimientos,
        x='Fecha',
        y='Rendimiento (%)',
        color='Ticker',
        title='Rendimiento Total de Acciones por Ticker',
        labels={'Rendimiento (%)': 'Rendimiento (%)', 'Fecha': 'Fecha'}
    )

    graph_html = pio.to_html(fig, full_html=False)

    # Renderizar el gráfico en una nueva plantilla
    return render_template('acciones_rendimiento.html', graph=graph_html)

@app.route('/fondos_mutuos', methods=['GET'])
@login_required
def fondos_mutuos():
    # Capturar parámetros de ordenamiento y búsqueda
    sort_by = request.args.get('sort_by', 'f.ID_Fondo')  # Ordenar por ID_Fondo por defecto
    order = request.args.get('order', 'asc')  # Orden ascendente por defecto
    search_query = request.args.get('search', '').strip()  # Capturar la búsqueda

    # Validar columnas permitidas para evitar SQL injection
    valid_columns = {
        'ID_Fondo': 'f.ID_Fondo',
        'Nombre': 'f.Nombre',
        'Empresa': 'e.Nombre',
        'Banco': 'b.Nombre',
        'TipoRiesgo': 'f.TipoRiesgo',
        'MontoInvertido': 'f.MontoInvertido',
        'MontoFinal': 'f.MontoFinal',
        'FechaInicio': 'f.FechaInicio',
        'FechaTermino': 'f.FechaTermino',
        'Rentabilidad': 'Rentabilidad'
    }

    sort_column = valid_columns.get(sort_by, 'f.ID_Fondo')
    if order not in ['asc', 'desc']:
        order = 'asc'

    # Conexión y consulta
    conn = get_db_connection()
    cursor = conn.cursor()

    # Consulta base
    query = f"""
    SELECT 
        f.ID_Fondo, 
        f.Nombre, 
        e.Nombre AS Empresa, 
        b.Nombre AS Banco, 
        f.TipoRiesgo, 
        f.MontoInvertido, 
        f.MontoFinal, 
        f.FechaInicio, 
        f.FechaTermino, 
        CASE 
            WHEN f.MontoFinal IS NOT NULL THEN 
                ROUND(((f.MontoFinal - f.MontoInvertido) / f.MontoInvertido) * 100, 2)
            ELSE NULL
        END AS Rentabilidad,
        f.Comprobante
    FROM FondosMutuos f
    JOIN EntidadComercial e ON f.ID_Entidad = e.ID_Entidad
    JOIN Entidad b ON f.ID_Banco = b.ID_Entidad
    """

    # Agregar filtro de búsqueda si se proporciona un término
    if search_query:
        query += " WHERE e.Nombre ILIKE %s"

    # Ordenar por la columna especificada
    query += f" ORDER BY {sort_column} {order};"

    # Ejecutar la consulta
    if search_query:
        cursor.execute(query, (f"%{search_query}%",))
    else:
        cursor.execute(query)

    fondos = cursor.fetchall()
    cursor.close()
    conn.close()

    return render_template('fondos_mutuos.html', fondos=fondos, sort_by=sort_by, order=order, search_query=search_query)


@app.route('/add_fondo_mutuo', methods=['GET', 'POST'])
@login_required
def add_fondo_mutuo():
    if request.method == 'POST':
        print(request.form)  # Imprime todos los datos enviados por el formulario
        # Capturar datos del formulario
        nombre_fondo = request.form['nombre_fondo'].upper()
        monto_invertido = float(request.form.get('monto_invertido'))
        monto_final = request.form.get('monto_final')
        if monto_final:
            monto_final = float(monto_final)
        else:
            monto_final = None  # Usar None para valores nulos en SQL
        riesgo = request.form['riesgo']
        fecha_inicio = request.form['fecha_inicio']
        fecha_termino = request.form.get('fecha_termino')
        if not fecha_termino:  # Si está vacío o None
            fecha_termino = None
        empresa_nombre = request.form['empresa'].upper()
        banco_nombre = request.form['banco'].upper()

        # Manejar archivo comprobante
        comprobante = None
        if 'comprobante' in request.files:
            file = request.files['comprobante']
            if file and allowed_file(file.filename):
                filename = secure_filename(file.filename)
                comprobante = os.path.join(app.config['UPLOAD_FOLDER'], filename).replace("\\", "/")
                file.save(comprobante)

        # Conectar a la base de datos
        conn = get_db_connection()
        cursor = conn.cursor()

        # Buscar o crear banco
        cursor.execute("SELECT ID_Entidad FROM Entidad WHERE Nombre = %s", (banco_nombre,))
        banco_result = cursor.fetchone()
        if not banco_result:
            rut_temporal = f"TEMP-{datetime.now().strftime('%Y%m%d%H%M%S')}"
            cursor.execute("""
                INSERT INTO Entidad (Rut, Nombre, TipoEntidad)
                VALUES (%s, %s, 'Banco') RETURNING ID_Entidad
            """, (rut_temporal, banco_nombre))
            id_banco = cursor.fetchone()[0]
        else:
            id_banco = banco_result[0]

        # Buscar o crear empresa
        cursor.execute("SELECT ID_Entidad FROM EntidadComercial WHERE Nombre = %s", (empresa_nombre,))
        empresa_result = cursor.fetchone()
        if not empresa_result:
            rut_temporal = f"TEMP-{datetime.now().strftime('%Y%m%d%H%M%S')}"
            cursor.execute("""
                INSERT INTO EntidadComercial (Rut, Nombre, TipoEntidad)
                VALUES (%s, %s, 'Empresa') RETURNING ID_Entidad
            """, (rut_temporal, empresa_nombre))
            id_empresa = cursor.fetchone()[0]
        else:
            id_empresa = empresa_result[0]

        # Insertar fondo mutuo
        cursor.execute("""
            INSERT INTO FondosMutuos 
            (Nombre, MontoInvertido, MontoFinal, Rentabilidad, TipoRiesgo, FechaInicio, FechaTermino, ID_Entidad, ID_Banco, Comprobante)
            VALUES (%s, %s, %s, NULL, %s, %s, %s, %s, %s, %s)
        """, (nombre_fondo, monto_invertido, monto_final, riesgo, fecha_inicio, fecha_termino, id_empresa, id_banco, comprobante))
        conn.commit()
        cursor.close()
        conn.close()

        return redirect(url_for('fondos_mutuos'))

    return render_template('add_fondo_mutuo.html')

@app.route('/edit_fondo_mutuo/<int:id_fondo>', methods=['GET', 'POST'])
@login_required
def edit_fondo_mutuo(id_fondo):
    conn = get_db_connection()
    cursor = conn.cursor()

    if request.method == 'POST':
        # Capturar los datos enviados desde el formulario
        monto_final = request.form.get('monto_final')
        fecha_termino = request.form.get('fecha_termino')

        # Validar y convertir los valores
        monto_final = float(monto_final) if monto_final else None
        fecha_termino = fecha_termino if fecha_termino else None

        # Actualizar la tabla FondosMutuos
        cursor.execute("""
            UPDATE FondosMutuos
            SET MontoFinal = %s, FechaTermino = %s
            WHERE ID_Fondo = %s
        """, (monto_final, fecha_termino, id_fondo))

        conn.commit()
        cursor.close()
        conn.close()

        # Redirigir al listado después de guardar
        return redirect(url_for('fondos_mutuos'))

    # Si es GET, obtener los datos del fondo actual para mostrar en el formulario
    cursor.execute("""
        SELECT ID_Fondo, Nombre, MontoFinal, FechaTermino
        FROM FondosMutuos
        WHERE ID_Fondo = %s
    """, (id_fondo,))
    fondo = cursor.fetchone()
    cursor.close()
    conn.close()

    return render_template('edit_fondo_mutuo.html', fondo=fondo)

@app.route('/boletas_garantia', methods=['GET'])
@login_required
def boletas_garantia():
    # Obtener parámetros de ordenamiento
    sort_by = request.args.get('sort_by', 'Numero')  # Ordenar por 'Numero' por defecto
    order = request.args.get('order', 'asc')  # Orden ascendente por defecto

    # Validar las columnas permitidas
    valid_columns = ['Numero', 'Banco', 'Beneficiario', 'Vencimiento', 'FechaEmision', 'Moneda', 'Monto', 'Estado']
    if sort_by not in valid_columns:
        sort_by = 'Numero'
    if order not in ['asc', 'desc']:
        order = 'asc'

    # Conectar a la base de datos
    conn = get_db_connection()
    cursor = conn.cursor()

    # Consulta SQL con ordenamiento dinámico
    query = f"""
        SELECT 
            bg.Numero, 
            e.Nombre AS Banco, 
            ec.Nombre AS Beneficiario, 
            bg.Vencimiento, 
            bg.FechaEmision, 
            bg.Moneda, 
            bg.Monto, 
            bg.Estado,
            bg.Documento
        FROM BoletaGarantia bg
        JOIN Entidad e ON bg.ID_Banco = e.ID_Entidad
        JOIN EntidadComercial ec ON bg.ID_Beneficiario = ec.ID_Entidad
        ORDER BY {sort_by} {order};
    """
    cursor.execute(query)
    boletas = cursor.fetchall()

    cursor.close()
    conn.close()

    # Renderizar la plantilla con las boletas y los parámetros de ordenamiento
    return render_template('boletas_garantia.html', boletas=boletas, sort_by=sort_by, order=order)

@app.route('/add_boleta_garantia', methods=['GET', 'POST'])
@login_required
def add_boleta_garantia():
    if request.method == 'POST':
        # Capturar datos del formulario
        numero_boleta = request.form['numero_boleta']
        tomada_por_empresa = request.form['tomada_por_empresa'].upper()
        tomada_por_rut = request.form['tomada_por_rut']
        banco_nombre = request.form['banco'].upper()
        beneficiario_nombre = request.form['beneficiario'].upper()
        glosa = request.form['glosa']
        vencimiento = request.form['vencimiento']
        fecha_emision = request.form['fecha_emision']
        moneda = request.form['moneda']
        monto = float(request.form['monto'])
        estado = request.form['estado']

        # Manejar archivo adjunto
        documento = None
        if 'documento' in request.files:
            file = request.files['documento']
            if file and allowed_file(file.filename):  # Verifica si es un archivo permitido
                filename = secure_filename(file.filename)
                documento = os.path.join(app.config['UPLOAD_FOLDER'], filename).replace("\\", "/")
                file.save(documento)

        # Conectar a la base de datos
        conn = get_db_connection()
        cursor = conn.cursor()

        # Buscar o crear banco
        cursor.execute("SELECT ID_Entidad FROM Entidad WHERE Nombre = %s", (banco_nombre,))
        banco_result = cursor.fetchone()
        if not banco_result:
            rut_temporal = f"TEMP-{datetime.now().strftime('%Y%m%d%H%M%S')}"
            cursor.execute("""
                INSERT INTO Entidad (Rut, Nombre, TipoEntidad)
                VALUES (%s, %s, 'Banco') RETURNING ID_Entidad
            """, (rut_temporal, banco_nombre))
            id_banco = cursor.fetchone()[0]
        else:
            id_banco = banco_result[0]

        # Buscar o crear beneficiario
        cursor.execute("SELECT ID_Entidad FROM EntidadComercial WHERE Nombre = %s", (beneficiario_nombre,))
        beneficiario_result = cursor.fetchone()
        if not beneficiario_result:
            rut_temporal = f"TEMP-{datetime.now().strftime('%Y%m%d%H%M%S')}"
            cursor.execute("""
                INSERT INTO EntidadComercial (Rut, Nombre, TipoEntidad)
                VALUES (%s, %s, 'Empresa') RETURNING ID_Entidad
            """, (rut_temporal, beneficiario_nombre))
            id_beneficiario = cursor.fetchone()[0]
        else:
            id_beneficiario = beneficiario_result[0]

        # Buscar o crear la empresa que tomó la boleta
        cursor.execute("""
            SELECT ID_Entidad FROM EntidadComercial WHERE Nombre = %s AND Rut = %s AND TipoEntidad = 'Empresa'
        """, (tomada_por_empresa, tomada_por_rut))
        tomada_por_result = cursor.fetchone()
        if not tomada_por_result:
            cursor.execute("""
                INSERT INTO EntidadComercial (Rut, Nombre, TipoEntidad)
                VALUES (%s, %s, 'Empresa') RETURNING ID_Entidad
            """, (tomada_por_rut, tomada_por_empresa))
            id_tomada_por = cursor.fetchone()[0]
        else:
            id_tomada_por = tomada_por_result[0]

        # Insertar boleta de garantía
        cursor.execute("""
            INSERT INTO BoletaGarantia 
            (Numero, ID_Banco, ID_Beneficiario, Glosa, Vencimiento, Moneda, Monto, FechaEmision, Estado, Documento, Tomada_Por_Empresa, Tomada_Por_Rut)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (numero_boleta ,id_banco, id_beneficiario, glosa, vencimiento, moneda, monto, fecha_emision, estado, documento, tomada_por_empresa, tomada_por_rut))
        conn.commit()
        cursor.close()
        conn.close()

        return redirect(url_for('boletas_garantia'))

    return render_template('add_boleta_garantia.html')

@app.route('/edit_boleta_garantia/<int:numero>', methods=['GET', 'POST'])
@login_required
def edit_boleta_garantia(numero):
    conn = get_db_connection()
    cursor = conn.cursor()

    if request.method == 'POST':
        # Capturar datos del formulario
        glosa = request.form['glosa']
        vencimiento = request.form['vencimiento']
        fecha_emision = request.form['fecha_emision']
        moneda = request.form['moneda']
        monto = float(request.form['monto'])
        estado = request.form['estado']

        # Manejar archivo adjunto
        documento = None
        if 'documento' in request.files:
            file = request.files['documento']
            if file and allowed_file(file.filename):  # Verifica si es un archivo permitido
                filename = secure_filename(file.filename)
                documento = os.path.join(app.config['UPLOAD_FOLDER'], filename).replace("\\", "/")
                file.save(documento)

        # Actualizar los datos en la base de datos
        query = """
            UPDATE BoletaGarantia
            SET Glosa = %s, Vencimiento = %s, FechaEmision = %s, Moneda = %s, 
                Monto = %s, Estado = %s, Documento = COALESCE(%s, Documento)
            WHERE Numero = %s
        """
        cursor.execute(query, (glosa, vencimiento, fecha_emision, moneda, monto, estado, documento, numero))
        conn.commit()
        cursor.close()
        conn.close()

        return redirect(url_for('boletas_garantia'))

    # Obtener los datos actuales de la boleta para mostrarlos en el formulario
    query = "SELECT Glosa, Vencimiento, FechaEmision, Moneda, Monto, Estado FROM BoletaGarantia WHERE Numero = %s"
    cursor.execute(query, (numero,))
    boleta = cursor.fetchone()
    cursor.close()
    conn.close()

    return render_template('edit_boleta_garantia.html', boleta=boleta, numero=numero)

@app.route('/polizas', methods=['GET'])
@login_required
def listar_polizas():
    conn = get_db_connection()
    cursor = conn.cursor()

    # Obtener parámetros de ordenación desde la URL
    sort_by = request.args.get('sort_by', 'Numero')  # Columna por defecto: 'Numero'
    order = request.args.get('order', 'asc')  # Orden por defecto: ascendente

    # Validar columnas permitidas para evitar SQL injection
    valid_columns = ['Numero', 'TipoAsegurado', 'FechaInicio', 'FechaTermino', 'Monto']
    if sort_by not in valid_columns:
        sort_by = 'Numero'
    if order not in ['asc', 'desc']:
        order = 'asc'

    # Consultar pólizas existentes con orden dinámico
    query = f"SELECT * FROM Polizas ORDER BY {sort_by} {order}"
    cursor.execute(query)
    polizas = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template('polizas.html', polizas=polizas, sort_by=sort_by, order=order)

@app.route('/add_poliza', methods=['GET', 'POST'])
@login_required
def agregar_poliza():
    if request.method == 'POST':
        conn = get_db_connection()
        cursor = conn.cursor()

        try:
            # Capturar datos del formulario
            numero = request.form['numero']  # Corregido: Debe coincidir con el formulario
            tipo_asegurado = request.form['tipo_asegurado']
            fecha_inicio = request.form['fecha_inicio']
            fecha_termino = request.form['fecha_termino']
            monto = float(request.form['monto'])

            # Manejo del archivo adjunto
            adjunto_poliza = None
            if 'adjunto_poliza' in request.files:
                file = request.files['adjunto_poliza']
                if file and allowed_file(file.filename):
                    filename = secure_filename(file.filename)
                    adjunto_poliza = os.path.join(app.config['UPLOAD_FOLDER'], filename).replace("\\", "/")
                    file.save(adjunto_poliza)

            # Validar si el número de póliza ya existe
            cursor.execute("SELECT 1 FROM Polizas WHERE Numero = %s", (numero,))
            if cursor.fetchone():
                flash("El número de póliza ya existe. Por favor, ingrese otro.", "error")
                return redirect(url_for('agregar_poliza'))
            
            if fecha_inicio > fecha_termino:
                flash("La fecha de inicio no puede ser posterior a la fecha de término.", "error")
                return redirect(url_for('agregar_poliza'))

            # Insertar en la base de datos
            cursor.execute("""
                INSERT INTO Polizas (Numero, TipoAsegurado, FechaInicio, FechaTermino, Monto, AdjuntoPoliza)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (numero, tipo_asegurado, fecha_inicio, fecha_termino, monto, adjunto_poliza))

            conn.commit()
            flash('Póliza agregada exitosamente.', 'success')

        except Exception as e:
            conn.rollback()
            flash(f'Error al agregar la póliza: {e}', 'error')
        finally:
            cursor.close()
            conn.close()

        return redirect(url_for('listar_polizas'))

    return render_template('add_polizas.html')

@app.route('/edit_poliza/<int:numero>', methods=['GET', 'POST'])
@login_required
def editar_poliza(numero):
    conn = get_db_connection()
    cursor = conn.cursor()

    if request.method == 'POST':
        try:
            # Capturar datos del formulario
            tipo_asegurado = request.form['tipo_asegurado']
            fecha_inicio = request.form['fecha_inicio']
            fecha_termino = request.form['fecha_termino']
            monto = float(request.form['monto'])

            # Manejo del archivo adjunto
            adjunto_poliza = None
            if 'adjunto_poliza' in request.files:
                file = request.files['adjunto_poliza']
                if file and allowed_file(file.filename):
                    filename = secure_filename(file.filename)
                    adjunto_poliza = os.path.join(app.config['UPLOAD_FOLDER'], filename)
                    file.save(adjunto_poliza)

            # Actualizar en la base de datos
            cursor.execute("""
                UPDATE Polizas
                SET TipoAsegurado = %s, FechaInicio = %s, FechaTermino = %s, Monto = %s, AdjuntoPoliza = %s
                WHERE Numero = %s
            """, (tipo_asegurado, fecha_inicio, fecha_termino, monto, adjunto_poliza, numero))

            conn.commit()
            flash('Póliza actualizada exitosamente.', 'success')
        except Exception as e:
            conn.rollback()
            flash(f'Error al actualizar la póliza: {e}', 'error')
        finally:
            cursor.close()
            conn.close()

        return redirect(url_for('listar_polizas'))

    # Obtener datos de la póliza actual
    cursor.execute("SELECT * FROM Polizas WHERE Numero = %s", (numero,))
    poliza = cursor.fetchone()
    cursor.close()
    conn.close()

    if not poliza:
        flash('La póliza no existe.', 'error')
        return redirect(url_for('listar_polizas'))

    return render_template('edit_polizas.html', poliza=poliza)

@app.route('/delete_poliza/<int:numero>', methods=['POST'])
@login_required
def eliminar_poliza(numero):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        # Eliminar la póliza de la base de datos
        cursor.execute("DELETE FROM Polizas WHERE Numero = %s", (numero,))
        conn.commit()
        flash('Póliza eliminada exitosamente.', 'success')
    except Exception as e:
        conn.rollback()
        flash(f'Error al eliminar la póliza: {e}', 'error')
    finally:
        cursor.close()
        conn.close()

    return redirect(url_for('listar_polizas'))


# Ejecutar la aplicación
if __name__ == '__main__':
    app.run(debug=True)