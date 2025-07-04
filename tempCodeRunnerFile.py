from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
from database import DatabaseManager
from datetime import datetime

app = Flask(__name__)
app.secret_key = 'rodolfo2006' 

# Configurar headers de seguridad y desactivar APIs innecesarias
@app.after_request
def after_request(response):
    # Desactivar APIs de rastreo para evitar advertencias
    response.headers['Permissions-Policy'] = (
        'attribution-reporting=(), '
        'browsing-topics=(), '
        'interest-cohort=(), '
        'private-state-token-redemption=(), '
        'private-state-token-issuance=()'
    )
    # Headers de seguridad básicos
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    return response

db = DatabaseManager()

@app.route('/')
def index():
    """Página principal con dashboard"""
    recordatorios = db.obtener_recordatorios_hoy()
    eventos_semana = db.obtener_eventos_semana()
    categorias = db.obtener_todas_categorias()
    contactos = db.obtener_todos_contactos()
    historial = db.obtener_historial_cambios(5)
    
    return render_template('index.html', 
                            recordatorios=recordatorios,
                            eventos_semana=eventos_semana,
                            contactos=contactos,
                            historial=historial,
                            categorias=categorias)    
@app.route('/contactos')
def listar_contactos():
    """Listar todos los contactos"""
    categoria_id = request.args.get('categoria')
    termino_busqueda = request.args.get('buscar')
    
    if categoria_id:
        contactos = db.obtener_contactos_categoria(int(categoria_id))
    elif termino_busqueda:
        contactos = db.buscar_contactos(termino_busqueda)
    else:
        contactos = db.obtener_todos_contactos()
    
    categorias = db.obtener_todas_categorias()
    
    return render_template('contactos.html', 
                        contactos=contactos, 
                        categorias=categorias,
                        categoria_seleccionada=categoria_id,
                        termino_busqueda=termino_busqueda)

@app.route('/agregar', methods=['GET', 'POST'])
def agregar_contacto():
    """Agregar nuevo contacto"""
    if request.method == 'POST':
        try:
            # Obtener datos del formulario
            nombre = request.form.get('nombre', '').strip()
            apellido = request.form.get('apellido', '').strip()
            telefono = request.form.get('telefono', '').strip()
            correo = request.form.get('correo', '').strip()
            categoria = request.form.get('categoria', '').strip()
            fecha_evento = request.form.get('fecha_evento', '').strip()
            descripcion_evento = request.form.get('descripcion_evento', '').strip()
            
            # Validar campos requeridos
            if not nombre:
                flash('El nombre es obligatorio', 'error')
                categorias = db.obtener_todas_categorias()
                return render_template('agregar.html', categorias=categorias)
            
            if not apellido:
                flash('El apellido es obligatorio', 'error')
                categorias = db.obtener_todas_categorias()
                return render_template('agregar.html', categorias=categorias)
            
            if not categoria:
                flash('La categoría es obligatoria', 'error')
                categorias = db.obtener_todas_categorias()
                return render_template('agregar.html', categorias=categorias)
            
            try:
                categoria_id = int(categoria)
            except ValueError:
                flash('Categoría inválida', 'error')
                categorias = db.obtener_todas_categorias()
                return render_template('agregar.html', categorias=categorias)
            
            # Convertir fecha si no está vacía
            fecha_evento_obj = None
            if fecha_evento:
                fecha_evento_obj = fecha_evento
            
            # Intentar agregar el contacto
            print(f"Intentando agregar contacto: {nombre} {apellido}")
            resultado = db.agregar_contacto(nombre, apellido, telefono, correo, categoria_id, fecha_evento_obj, descripcion_evento)
            
            if resultado:
                flash(f'Contacto {nombre} {apellido} agregado exitosamente', 'success')
                return redirect(url_for('listar_contactos'))
            else:
                flash('Error al agregar contacto. Verifique los datos e intente nuevamente.', 'error')
                print(f"Error al agregar contacto: {nombre} {apellido}")
                
        except Exception as e:
            flash(f'Error inesperado: {str(e)}', 'error')
            print(f"Error en agregar_contacto: {str(e)}")
    
    categorias = db.obtener_todas_categorias()
    return render_template('agregar.html', categorias=categorias)

@app.route('/editar/<int:contacto_id>', methods=['GET', 'POST'])
def editar_contacto(contacto_id):
    """Editar contacto existente"""
    if request.method == 'POST':
        try:
            # Obtener datos del formulario
            nombre = request.form.get('nombre', '').strip()
            apellido = request.form.get('apellido', '').strip()
            telefono = request.form.get('telefono', '').strip()
            correo = request.form.get('correo', '').strip()
            categoria = request.form.get('categoria', '').strip()
            fecha_evento = request.form.get('fecha_evento', '').strip()
            descripcion_evento = request.form.get('descripcion_evento', '').strip()
            
            # Validar campos requeridos
            if not nombre:
                flash('El nombre es obligatorio', 'error')
                contactos = db.obtener_todos_contactos()
                contacto = next((c for c in contactos if c[0] == contacto_id), None)
                if contacto:
                    categorias = db.obtener_todas_categorias()
                    return render_template('editar.html', contacto=contacto, categorias=categorias)
                else:
                    flash('Contacto no encontrado', 'error')
                    return redirect(url_for('listar_contactos'))
            
            if not apellido:
                flash('El apellido es obligatorio', 'error')
                contactos = db.obtener_todos_contactos()
                contacto = next((c for c in contactos if c[0] == contacto_id), None)
                if contacto:
                    categorias = db.obtener_todas_categorias()
                    return render_template('editar.html', contacto=contacto, categorias=categorias)
                else:
                    flash('Contacto no encontrado', 'error')
                    return redirect(url_for('listar_contactos'))
            
            if not categoria:
                flash('La categoría es obligatoria', 'error')
                contactos = db.obtener_todos_contactos()
                contacto = next((c for c in contactos if c[0] == contacto_id), None)
                if contacto:
                    categorias = db.obtener_todas_categorias()
                    return render_template('editar.html', contacto=contacto, categorias=categorias)
                else:
                    flash('Contacto no encontrado', 'error')
                    return redirect(url_for('listar_contactos'))
            
            try:
                categoria_id = int(categoria)
            except ValueError:
                flash('Categoría inválida', 'error')
                contactos = db.obtener_todos_contactos()
                contacto = next((c for c in contactos if c[0] == contacto_id), None)
                if contacto:
                    categorias = db.obtener_todas_categorias()
                    return render_template('editar.html', contacto=contacto, categorias=categorias)
                else:
                    flash('Contacto no encontrado', 'error')
                    return redirect(url_for('listar_contactos'))
            
            # Convertir fecha si no está vacía
            fecha_evento_obj = None
            if fecha_evento:
                fecha_evento_obj = fecha_evento
            
            # Intentar actualizar el contacto
            print(f"Intentando actualizar contacto ID {contacto_id}: {nombre} {apellido}")
            resultado = db.actualizar_contacto(contacto_id, nombre, apellido, telefono, correo, categoria_id, fecha_evento_obj, descripcion_evento)
            
            if resultado:
                flash(f'Contacto {nombre} {apellido} actualizado exitosamente', 'success')
                return redirect(url_for('listar_contactos'))
            else:
                flash('Error al actualizar contacto. Verifique los datos e intente nuevamente.', 'error')
                print(f"Error al actualizar contacto ID {contacto_id}: {nombre} {apellido}")
                
        except Exception as e:
            flash(f'Error inesperado: {str(e)}', 'error')
            print(f"Error en editar_contacto: {str(e)}")

    contactos = db.obtener_todos_contactos()
    contacto = next((c for c in contactos if c[0] == contacto_id), None)
    
    if not contacto:
        flash('Contacto no encontrado', 'error')
        return redirect(url_for('listar_contactos'))
    
    categorias = db.obtener_todas_categorias()
    return render_template('editar.html', contacto=contacto, categorias=categorias)

@app.route('/eliminar/<int:contacto_id>', methods=['POST'])
def eliminar_contacto(contacto_id):
    """Eliminar contacto"""
    if db.eliminar_contacto(contacto_id):
        flash('Contacto eliminado exitosamente', 'success')
    else:
        flash('Error al eliminar contacto', 'error')
    
    return redirect(url_for('listar_contactos'))

@app.route('/api/recordatorios')
def api_recordatorios():
    """API para obtener recordatorios del día"""
    recordatorios = db.obtener_recordatorios_hoy()
    return jsonify([{
        'id': r[0],
        'nombre': f"{r[1]} {r[2]}",
        'fecha': r[3].strftime('%Y-%m-%d') if r[3] else None,
        'categoria': r[4]
    } for r in recordatorios])

@app.route('/api/eventos-semana')
def api_eventos_semana():
    """API para obtener eventos de la semana"""
    eventos = db.obtener_eventos_semana()
    return jsonify([{
        'id': e[0],
        'nombre': f"{e[1]} {e[2]}",
        'fecha': e[3].strftime('%Y-%m-%d') if e[3] else None,
        'categoria': e[4]
    } for e in eventos])

@app.route('/historial')
def historial():
    """Ver historial completo de cambios"""
    historial_cambios = db.obtener_historial_cambios(50)
    return render_template('historial.html', historial=historial_cambios)
@app.route('/categorias')
def listar_categorias():
    """Listar todas las categorías con conteo de contactos"""
    categorias = db.obtener_todas_categorias()
    categorias_con_conteo = []
    
    for categoria in categorias:
        conteo = db.contar_contactos_por_categoria(categoria[0])
        categorias_con_conteo.append({
            'id': categoria[0],
            'nombre': categoria[1],
            'contactos': conteo,
            'es_sistema': categoria[0] <= 4  
        })
    
    return render_template('categorias.html', categorias=categorias_con_conteo)

@app.route('/categorias/agregar', methods=['GET', 'POST'])
def agregar_categoria():
    """Agregar nueva categoría"""
    if request.method == 'POST':
        nombre = request.form['nombre'].strip()
        
        if not nombre:
            flash('El nombre de la categoría es requerido', 'error')
            return render_template('categoria_form.html', titulo='Agregar Categoría')
        
        resultado = db.agregar_categoria(nombre)
        
        if resultado['success']:
            flash('Categoría agregada exitosamente', 'success')
            return redirect(url_for('listar_categorias'))
        else:
            flash(resultado['error'], 'error')
    
    return render_template('categoria_form.html', titulo='Agregar Categoría')

@app.route('/categorias/editar/<int:categoria_id>', methods=['GET', 'POST'])
def editar_categoria(categoria_id):
    categoria = db.obtener_categoria_por_id(categoria_id)
    
    if not categoria:
        flash('Categoría no encontrada', 'error')
        return redirect(url_for('listar_categorias'))
    
    if categoria[0] <= 4: 
        flash('No se pueden editar las categorías del sistema', 'error')
        return redirect(url_for('listar_categorias'))
    
    if request.method == 'POST':
        nombre = request.form['nombre'].strip()
        
        if not nombre:
            flash('El nombre de la categoría es requerido', 'error')
            return render_template('categoria_form.html', categoria=categoria, titulo='Editar Categoría')
        
        resultado = db.actualizar_categoria(categoria_id, nombre)
        
        if resultado['success']:
            flash('Categoría actualizada exitosamente', 'success')
            return redirect(url_for('listar_categorias'))
        else:
            flash(resultado['error'], 'error')
    
    return render_template('categoria_form.html', categoria=categoria, titulo='Editar Categoría')

@app.route('/categorias/eliminar/<int:categoria_id>', methods=['POST'])
def eliminar_categoria(categoria_id):
    if categoria_id <= 4:
        flash('No se pueden eliminar las categorías del sistema', 'error')
        return redirect(url_for('listar_categorias'))
    
    resultado = db.eliminar_categoria(categoria_id)
    
    if resultado['success']:
        flash('Categoría eliminada exitosamente', 'success')
    else:
        flash(resultado['error'], 'error')
    
    return redirect(url_for('listar_categorias'))

@app.route('/api/categorias')
def api_categorias():
    """API para obtener todas las categorías"""
    categorias = db.obtener_todas_categorias()
    return jsonify([{
        'id': c[0],
        'nombre': c[1]
    } for c in categorias])

@app.route('/debug/test-db')
def test_db_connection():
    """Endpoint de prueba para verificar la conexión a la base de datos"""
    try:
        # Prueba 1: Conexión
        conn = db.get_connection()
        if not conn:
            return "❌ Error: No se pudo conectar a la base de datos"
        conn.close()
        
        # Prueba 2: Obtener categorías
        categorias = db.obtener_todas_categorias()
        if not categorias:
            return "❌ Error: No se pudieron obtener categorías"
        
        # Prueba 3: Intentar agregar un contacto de prueba
        resultado = db.agregar_contacto(
            nombre="TestDebug",
            apellido="Usuario",
            telefono="123456789",
            correo="debug@test.com",
            categoria=1,
            fecha_evento=None,
            descripcion_evento="Prueba de debug"
        )
        
        if resultado:
            # Intentar eliminar el contacto de prueba
            contactos = db.obtener_todos_contactos()
            test_contacto = None
            for contacto in contactos:
                if contacto[1] == "TestDebug" and contacto[2] == "Usuario":
                    test_contacto = contacto
                    break
            
            if test_contacto:
                db.eliminar_contacto(test_contacto[0])
                return f"✅ Todo funciona correctamente. Categorías: {len(categorias)}, Contacto agregado y eliminado exitosamente"
            else:
                return "⚠️ Contacto se agregó pero no se pudo recuperar de la base de datos"
        else:
            return "❌ Error: No se pudo agregar contacto de prueba"
            
    except Exception as e:
        return f"❌ Error durante la prueba: {str(e)}"

if __name__ == '__main__':
    
    app.run(debug=True, host='0.0.0.0', port=5000)
