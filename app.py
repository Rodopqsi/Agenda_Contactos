from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
from database import DatabaseManager
from datetime import datetime

app = Flask(__name__)
app.secret_key = 'rodolfo2006' 

db = DatabaseManager()

@app.route('/')
def index():
    """Página principal con dashboard"""
    recordatorios = db.obtener_recordatorios_hoy()
    eventos_semana = db.obtener_eventos_semana()
    categorias = db.obtener_todas_categorias()
    historial = db.obtener_historial_cambios(5)
    
    return render_template('index.html', 
                            recordatorios=recordatorios,
                            eventos_semana=eventos_semana,
                            historial=historial,categorias=categorias, db=db)    
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
        nombre = request.form['nombre']
        apellido = request.form['apellido']
        telefono = request.form['telefono']
        correo = request.form['correo']
        categoria = int(request.form['categoria'])
        fecha_evento = request.form['fecha_evento'] or None
        
        if db.agregar_contacto(nombre, apellido, telefono, correo, categoria, fecha_evento):
            flash('Contacto agregado exitosamente', 'success')
            return redirect(url_for('listar_contactos'))
        else:
            flash('Error al agregar contacto', 'error')
    
    categorias = db.obtener_todas_categorias()
    return render_template('agregar.html', categorias=categorias)

@app.route('/editar/<int:contacto_id>', methods=['GET', 'POST'])
def editar_contacto(contacto_id):
    """Editar contacto existente"""
    if request.method == 'POST':
        nombre = request.form['nombre']
        apellido = request.form['apellido']
        telefono = request.form['telefono']
        correo = request.form['correo']
        categoria = int(request.form['categoria'])
        fecha_evento = request.form['fecha_evento'] or None
        
        if db.actualizar_contacto(contacto_id, nombre, apellido, telefono, correo, categoria, fecha_evento):
            flash('Contacto actualizado exitosamente', 'success')
            return redirect(url_for('listar_contactos'))
        else:
            flash('Error al actualizar contacto', 'error')

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
            'es_sistema': categoria[0] <= 4  # Las primeras 4 son del sistema
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
    
    # No permitir editar categorías del sistema
    if categoria[0] <= 4:  # Usar categoria[0] en lugar de categoria_id
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
    # AGREGAR VALIDACIÓN ANTES DE ELIMINAR
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

if __name__ == '__main__':
    
    app.run(debug=True, host='0.0.0.0', port=5000)
