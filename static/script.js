
function confirmarEliminar(id, nombre) {
    document.getElementById('nombreContacto').textContent = nombre;
    document.getElementById('formEliminar').action = '/eliminar/' + id;
    
    const modal = new bootstrap.Modal(document.getElementById('modalEliminar'));
    modal.show();
}

// Actualizar recordatorios en tiempo real
function actualizarRecordatorios() {
    const btn = event.target;
    const originalText = btn.innerHTML;
    
    // Mostrar spinner
    btn.innerHTML = '<span class="spinner"></span> Actualizando...';
    btn.disabled = true;
    
    // Simular carga y recargar página
    setTimeout(() => {
        location.reload();
    }, 1000);
}

// Validación de formularios
document.addEventListener('DOMContentLoaded', function() {
    // Validar teléfono
    const telefonoInput = document.getElementById('telefono');
    if (telefonoInput) {
        telefonoInput.addEventListener('input', function() {
            const valor = this.value.replace(/\D/g, ''); // Solo números
            this.value = valor;
        });
    }
    
    // Validar fecha de evento
    const fechaEventoInput = document.getElementById('fecha_evento');
    if (fechaEventoInput) {
        const hoy = new Date().toISOString().split('T')[0];
        fechaEventoInput.min = hoy; // No permitir fechas pasadas
    }
    
    // Auto-dismiss alerts
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(alert => {
        setTimeout(() => {
            const bsAlert = new bootstrap.Alert(alert);
            bsAlert.close();
        }, 5000);
    });
});

// Función para búsqueda 
function buscarContactos() {
    const input = document.getElementById('buscarInput');
    const termino = input.value.toLowerCase();
    const filas = document.querySelectorAll('tbody tr');
    
    filas.forEach(fila => {
        const texto = fila.textContent.toLowerCase();
        if (texto.includes(termino)) {
            fila.style.display = '';
        } else {
            fila.style.display = 'none';
        }
    });
}

// Función para exportar contactos (opcional)
function exportarContactos() {
    // Esta función se puede implementar para exportar a CSV
    alert('Función de exportación en desarrollo');
}

// Notificaciones del sistema
function mostrarNotificacion(mensaje, tipo = 'info') {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${tipo} alert-dismissible fade show`;
    alertDiv.innerHTML = `
        ${mensaje}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    const container = document.querySelector('.container');
    container.insertBefore(alertDiv, container.firstChild);
    
    setTimeout(() => {
        alertDiv.remove();
    }, 3000);
}
// Función para confirmar eliminación de categoría
function confirmarEliminarCategoria(id, nombre, contactos) {
    document.getElementById('nombreCategoria').textContent = nombre;
    document.getElementById('numeroContactos').textContent = contactos;
    
    const advertencia = document.getElementById('advertenciaContactos');
    const btnEliminar = document.getElementById('btnEliminar');
    const form = document.getElementById('formEliminarCategoria');
    
    if (contactos > 0) {
        advertencia.style.display = 'block';
        btnEliminar.style.display = 'none';
        form.action = '#';
    } else {
        advertencia.style.display = 'none';
        btnEliminar.style.display = 'inline-block';
        form.action = '/categorias/eliminar/' + id;
    }
    
    const modal = new bootstrap.Modal(document.getElementById('modalEliminarCategoria'));
    modal.show();
}

// Validación en tiempo real para el formulario de categorías
document.addEventListener('DOMContentLoaded', function() {
    const nombreInput = document.getElementById('nombre');
    if (nombreInput) {
        nombreInput.addEventListener('input', function() {
            const valor = this.value.trim();
            const contador = document.createElement('small');
            contador.className = 'form-text';
            contador.textContent = `${valor.length}/50 caracteres`;
            
            // Remover contador anterior
            const contadorAnterior = this.parentNode.querySelector('.contador-caracteres');
            if (contadorAnterior) {
                contadorAnterior.remove();
            }
            
            // Agregar nuevo contador
            contador.className += ' contador-caracteres';
            this.parentNode.appendChild(contador);
            
            // Validar longitud
            if (valor.length > 50) {
                this.classList.add('is-invalid');
                contador.className += ' text-danger';
            } else {
                this.classList.remove('is-invalid');
                contador.className = contador.className.replace(' text-danger', '');
            }
        });
    }
});