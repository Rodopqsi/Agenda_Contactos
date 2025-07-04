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
    
    // Mejoras para responsive móvil
    initializeMobileOptimizations();
});

// Función para optimizaciones móviles
function initializeMobileOptimizations() {
    // Detectar si es dispositivo móvil
    const isMobile = window.innerWidth <= 768;
    
    if (isMobile) {
        // Prevenir zoom en inputs
        const inputs = document.querySelectorAll('input[type="text"], input[type="email"], input[type="tel"], input[type="password"], input[type="date"], input[type="search"], textarea, select');
        inputs.forEach(input => {
            input.addEventListener('focus', function() {
                // Asegurar que el font-size sea de al menos 16px
                if (window.getComputedStyle(this).fontSize === '16px') {
                    this.style.fontSize = '16px';
                }
                
                // Scroll suave al input
                setTimeout(() => {
                    this.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }, 300);
            });
        });
        
        // Mejorar manejo del teclado virtual
        handleVirtualKeyboard();
        
        // Optimizar tablas para móvil
        optimizeTablesForMobile();
        
        // Mejorar modales en móvil
        optimizeModalsForMobile();
    }
    
    // Listener para cambios de orientación
    window.addEventListener('orientationchange', function() {
        setTimeout(() => {
            // Ajustar altura después del cambio de orientación
            adjustViewportHeight();
        }, 500);
    });
}

// Manejo del teclado virtual
function handleVirtualKeyboard() {
    let viewportHeight = window.innerHeight;
    
    // Detectar cuando aparece/desaparece el teclado
    window.addEventListener('resize', function() {
        const currentHeight = window.innerHeight;
        const heightDifference = viewportHeight - currentHeight;
        
        if (heightDifference > 150) {
            // Teclado apareció
            document.body.classList.add('keyboard-visible');
            
            // Ajustar contenedor
            const container = document.querySelector('.container-fluid');
            if (container) {
                container.style.minHeight = currentHeight + 'px';
            }
        } else {
            // Teclado desapareció
            document.body.classList.remove('keyboard-visible');
            
            // Restaurar altura original
            const container = document.querySelector('.container-fluid');
            if (container) {
                container.style.minHeight = '100vh';
            }
        }
    });
}

// Optimizar tablas para móvil
function optimizeTablesForMobile() {
    const tables = document.querySelectorAll('.table-responsive');
    tables.forEach(table => {
        // Agregar indicador de scroll
        const scrollIndicator = document.createElement('div');
        scrollIndicator.className = 'scroll-indicator';
        scrollIndicator.innerHTML = '← Desliza para ver más →';
        scrollIndicator.style.cssText = `
            text-align: center;
            font-size: 0.8em;
            color: #666;
            padding: 0.5rem;
            background: rgba(255,255,255,0.9);
            border-radius: 4px;
            margin-bottom: 0.5rem;
        `;
        
        table.parentNode.insertBefore(scrollIndicator, table);
        
        // Ocultar indicador después de interacción
        table.addEventListener('scroll', function() {
            scrollIndicator.style.display = 'none';
        }, { once: true });
    });
}

// Optimizar modales para móvil
function optimizeModalsForMobile() {
    const modals = document.querySelectorAll('.modal');
    modals.forEach(modal => {
        modal.addEventListener('show.bs.modal', function() {
            // Prevenir scroll del body
            document.body.style.overflow = 'hidden';
            
            // Ajustar altura del modal
            const modalDialog = modal.querySelector('.modal-dialog');
            if (modalDialog && window.innerWidth <= 576) {
                modalDialog.classList.add('modal-fullscreen');
            }
        });
        
        modal.addEventListener('hidden.bs.modal', function() {
            // Restaurar scroll del body
            document.body.style.overflow = '';
        });
    });
}

// Ajustar altura del viewport
function adjustViewportHeight() {
    const vh = window.innerHeight * 0.01;
    document.documentElement.style.setProperty('--vh', `${vh}px`);
}

// Inicializar ajuste de altura
adjustViewportHeight();

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

// Filtro de categorías en tiempo real
function filtrarCategorias() {
    const filtroTexto = document.getElementById('filtroCategoria');
    const filtroTipo = document.getElementById('filtroTipo');
    const tabla = document.querySelector('.table tbody');
    
    if (!filtroTexto || !tabla) return;
    
    function aplicarFiltros() {
        const termino = filtroTexto.value.toLowerCase().trim();
        const tipoSeleccionado = filtroTipo ? filtroTipo.value.toLowerCase() : '';
        const filas = tabla.getElementsByTagName('tr');
        let categoriasVisibles = 0;
        
        for (let i = 0; i < filas.length; i++) {
            const fila = filas[i];
            const celdaNombre = fila.querySelector('td:nth-child(2)');
            const celdaTipo = fila.querySelector('td:nth-child(4)');
            
            if (!celdaNombre || !celdaTipo) continue;
            
            const nombre = celdaNombre.textContent.toLowerCase();
            const tipo = celdaTipo.textContent.toLowerCase();
            
            // Restaurar texto original
            const nombreOriginal = celdaNombre.getAttribute('data-original') || celdaNombre.textContent;
            const tipoOriginal = celdaTipo.getAttribute('data-original') || celdaTipo.textContent;
            
            if (!celdaNombre.getAttribute('data-original')) {
                celdaNombre.setAttribute('data-original', nombreOriginal);
                celdaTipo.setAttribute('data-original', tipoOriginal);
            }
            
            // Verificar filtro de texto
            const coincideTexto = termino === '' || nombre.includes(termino) || tipo.includes(termino);
            
            // Verificar filtro de tipo
            let coincideTipo = true;
            if (tipoSeleccionado !== '') {
                if (tipoSeleccionado === 'sistema') {
                    coincideTipo = tipo.includes('sistema');
                } else if (tipoSeleccionado === 'personalizada') {
                    coincideTipo = tipo.includes('personalizada');
                }
            }
            
            if (coincideTexto && coincideTipo) {
                fila.style.display = '';
                categoriasVisibles++;
                
                // Resaltar coincidencias
                if (termino !== '') {
                    celdaNombre.innerHTML = resaltarTexto(nombreOriginal, termino);
                    celdaTipo.innerHTML = resaltarTexto(tipoOriginal, termino);
                } else {
                    celdaNombre.innerHTML = nombreOriginal;
                    celdaTipo.innerHTML = tipoOriginal;
                }
            } else {
                fila.style.display = 'none';
            }
        }
        
        // Mostrar mensaje si no hay resultados
        mostrarMensajeSinResultados(categoriasVisibles);
        
        // Actualizar contador
        actualizarContadorResultados(categoriasVisibles, filas.length);
    }
    
    // Aplicar filtros cuando se escribe en el campo de texto
    filtroTexto.addEventListener('input', aplicarFiltros);
    
    // Aplicar filtros cuando se cambia el tipo
    if (filtroTipo) {
        filtroTipo.addEventListener('change', aplicarFiltros);
    }
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
    // Inicializar filtro de categorías
    filtrarCategorias();
    
    // Inicializar filtro de contactos
    filtrarContactos();
    
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

// Filtro de contactos en tiempo real
function filtrarContactos() {
    const filtroTexto = document.getElementById('filtroContacto');
    const filtroCategoria = document.getElementById('filtroCategoriaContacto');
    const filtroEstado = document.getElementById('filtroEstadoContacto');
    const tabla = document.querySelector('.table tbody');
    
    if (!filtroTexto || !tabla) return;
    
    function aplicarFiltrosContactos() {
        const termino = filtroTexto.value.toLowerCase().trim();
        const categoriaSeleccionada = filtroCategoria ? filtroCategoria.value.toLowerCase() : '';
        const estadoSeleccionado = filtroEstado ? filtroEstado.value : '';
        const filas = tabla.getElementsByTagName('tr');
        let contactosVisibles = 0;
        
        for (let i = 0; i < filas.length; i++) {
            const fila = filas[i];
            const celdaNombre = fila.querySelector('td:nth-child(1)');
            const celdaTelefono = fila.querySelector('td:nth-child(2)');
            const celdaEmail = fila.querySelector('td:nth-child(3)');
            const celdaCategoria = fila.querySelector('td:nth-child(4)');
            const celdaEvento = fila.querySelector('td:nth-child(5)');
            
            if (!celdaNombre || !celdaTelefono || !celdaEmail || !celdaCategoria || !celdaEvento) continue;
            
            // Obtener textos originales
            const nombre = celdaNombre.textContent.toLowerCase();
            const telefono = celdaTelefono.textContent.toLowerCase();
            const email = celdaEmail.textContent.toLowerCase();
            const categoria = celdaCategoria.textContent.toLowerCase();
            const evento = celdaEvento.textContent.toLowerCase();
            
            // Restaurar contenido original
            if (!celdaNombre.getAttribute('data-original')) {
                celdaNombre.setAttribute('data-original', celdaNombre.innerHTML);
                celdaTelefono.setAttribute('data-original', celdaTelefono.innerHTML);
                celdaEmail.setAttribute('data-original', celdaEmail.innerHTML);
            }
            
            // Verificar filtro de texto
            const coincideTexto = termino === '' || 
                nombre.includes(termino) || 
                telefono.includes(termino) || 
                email.includes(termino);
            
            // Verificar filtro de categoría
            const coincideCategoria = categoriaSeleccionada === '' || 
                categoria.includes(categoriaSeleccionada);
            
            // Verificar filtro de estado
            let coincideEstado = true;
            if (estadoSeleccionado !== '') {
                switch (estadoSeleccionado) {
                    case 'con-telefono':
                        coincideEstado = !telefono.includes('sin teléfono');
                        break;
                    case 'sin-telefono':
                        coincideEstado = telefono.includes('sin teléfono');
                        break;
                    case 'con-email':
                        coincideEstado = !email.includes('sin email');
                        break;
                    case 'sin-email':
                        coincideEstado = email.includes('sin email');
                        break;
                    case 'con-evento':
                        coincideEstado = !evento.includes('sin evento');
                        break;
                    case 'sin-evento':
                        coincideEstado = evento.includes('sin evento');
                        break;
                }
            }
            
            if (coincideTexto && coincideCategoria && coincideEstado) {
                fila.style.display = '';
                contactosVisibles++;
                
                // Resaltar coincidencias de texto
                if (termino !== '') {
                    celdaNombre.innerHTML = resaltarTextoContacto(celdaNombre.getAttribute('data-original'), termino);
                    celdaTelefono.innerHTML = resaltarTextoContacto(celdaTelefono.getAttribute('data-original'), termino);
                    celdaEmail.innerHTML = resaltarTextoContacto(celdaEmail.getAttribute('data-original'), termino);
                } else {
                    celdaNombre.innerHTML = celdaNombre.getAttribute('data-original');
                    celdaTelefono.innerHTML = celdaTelefono.getAttribute('data-original');
                    celdaEmail.innerHTML = celdaEmail.getAttribute('data-original');
                }
            } else {
                fila.style.display = 'none';
            }
        }
        
        // Mostrar mensaje si no hay resultados
        mostrarMensajeSinResultadosContactos(contactosVisibles);
        
        // Actualizar contador
        actualizarContadorContactos(contactosVisibles, filas.length);
        
        // Actualizar indicador de filtros
        actualizarIndicadorFiltros();
    }
    
    // Aplicar filtros en tiempo real
    filtroTexto.addEventListener('input', aplicarFiltrosContactos);
    
    if (filtroCategoria) {
        filtroCategoria.addEventListener('change', aplicarFiltrosContactos);
    }
    
    if (filtroEstado) {
        filtroEstado.addEventListener('change', aplicarFiltrosContactos);
    }
}

function resaltarTextoContacto(texto, termino) {
    if (!termino || !texto) return texto;
    
    const regex = new RegExp(`(${termino})`, 'gi');
    return texto.replace(regex, '<span class="filtro-highlight">$1</span>');
}

function mostrarMensajeSinResultadosContactos(contactosVisibles) {
    const tbody = document.querySelector('.table tbody');
    let mensajeExistente = document.getElementById('mensajeSinResultadosContactos');
    
    if (contactosVisibles === 0) {
        if (!mensajeExistente) {
            const mensaje = document.createElement('tr');
            mensaje.id = 'mensajeSinResultadosContactos';
            mensaje.innerHTML = `
                <td colspan="6" class="text-center py-4">
                    <i class="fas fa-search fa-2x text-muted mb-2"></i>
                    <p class="text-muted">No se encontraron contactos que coincidan con tu búsqueda</p>
                    <small class="text-muted">Intenta cambiar los filtros o términos de búsqueda</small>
                </td>
            `;
            tbody.appendChild(mensaje);
        }
    } else {
        if (mensajeExistente) {
            mensajeExistente.remove();
        }
    }
}

function actualizarContadorContactos(visibles, total) {
    const contador = document.getElementById('contadorContactos');
    
    if (contador) {
        if (visibles === total) {
            contador.textContent = `Total de contactos: ${total}`;
            contador.classList.remove('filtrado');
        } else {
            contador.textContent = `Mostrando ${visibles} de ${total} contactos`;
            contador.classList.add('filtrado');
        }
    }
}

function limpiarFiltrosContactos() {
    const filtroTexto = document.getElementById('filtroContacto');
    const filtroCategoria = document.getElementById('filtroCategoriaContacto');
    const filtroEstado = document.getElementById('filtroEstadoContacto');
    const tabla = document.querySelector('.table tbody');
    
    // Limpiar campos
    if (filtroTexto) filtroTexto.value = '';
    if (filtroCategoria) filtroCategoria.value = '';
    if (filtroEstado) filtroEstado.value = '';
    
    // Mostrar todas las filas y restaurar contenido original
    if (tabla) {
        const filas = tabla.getElementsByTagName('tr');
        for (let i = 0; i < filas.length; i++) {
            const fila = filas[i];
            fila.style.display = '';
            
            // Restaurar contenido original
            const celdaNombre = fila.querySelector('td:nth-child(1)');
            const celdaTelefono = fila.querySelector('td:nth-child(2)');
            const celdaEmail = fila.querySelector('td:nth-child(3)');
            
            if (celdaNombre && celdaNombre.getAttribute('data-original')) {
                celdaNombre.innerHTML = celdaNombre.getAttribute('data-original');
            }
            if (celdaTelefono && celdaTelefono.getAttribute('data-original')) {
                celdaTelefono.innerHTML = celdaTelefono.getAttribute('data-original');
            }
            if (celdaEmail && celdaEmail.getAttribute('data-original')) {
                celdaEmail.innerHTML = celdaEmail.getAttribute('data-original');
            }
        }
    }
    
    // Remover mensaje de sin resultados
    const mensaje = document.getElementById('mensajeSinResultadosContactos');
    if (mensaje) {
        mensaje.remove();
    }
    
    // Actualizar contador
    const total = tabla ? tabla.getElementsByTagName('tr').length : 0;
    actualizarContadorContactos(total, total);
    
    // Actualizar indicador de filtros
    actualizarIndicadorFiltros();
}

// Función para exportar contactos a Excel
function exportarContactos() {
    const tabla = document.querySelector('.table tbody');
    const filasVisibles = Array.from(tabla.getElementsByTagName('tr'))
        .filter(fila => fila.style.display !== 'none' && fila.id !== 'mensajeSinResultadosContactos');
    
    if (filasVisibles.length === 0) {
        alert('No hay contactos para exportar');
        return;
    }
    
    // Crear los datos para Excel
    const datosExcel = [];
    
    // Agregar encabezados
    datosExcel.push(['Nombre', 'Teléfono', 'Email', 'Categoría', 'Evento', 'Fecha Exportación']);
    
    // Agregar datos de contactos
    filasVisibles.forEach(fila => {
        const celdas = fila.getElementsByTagName('td');
        if (celdas.length >= 5) {
            const nombre = limpiarTexto(celdas[0].textContent);
            const telefono = limpiarTexto(celdas[1].textContent);
            const email = limpiarTexto(celdas[2].textContent);
            const categoria = limpiarTexto(celdas[3].textContent);
            const evento = limpiarTexto(celdas[4].textContent);
            const fechaExportacion = new Date().toLocaleDateString('es-ES');
            
            datosExcel.push([nombre, telefono, email, categoria, evento, fechaExportacion]);
        }
    });
    
    // Crear el libro de trabajo
    const libroTrabajo = XLSX.utils.book_new();
    const hojaTrabajo = XLSX.utils.aoa_to_sheet(datosExcel);
    
    // Configurar el ancho de las columnas
    const anchoColumnas = [
        { wch: 25 }, // Nombre
        { wch: 15 }, // Teléfono
        { wch: 30 }, // Email
        { wch: 15 }, // Categoría
        { wch: 12 }, // Evento
        { wch: 15 }  // Fecha Exportación
    ];
    hojaTrabajo['!cols'] = anchoColumnas;
    
    // Aplicar estilos a los encabezados
    const rango = XLSX.utils.decode_range(hojaTrabajo['!ref']);
    for (let C = rango.s.c; C <= rango.e.c; ++C) {
        const direccion = XLSX.utils.encode_cell({ r: 0, c: C });
        if (!hojaTrabajo[direccion]) continue;
        
        hojaTrabajo[direccion].s = {
            font: { bold: true, color: { rgb: "FFFFFF" } },
            fill: { fgColor: { rgb: "366092" } },
            alignment: { horizontal: "center" }
        };
    }
    
    // Agregar la hoja al libro
    XLSX.utils.book_append_sheet(libroTrabajo, hojaTrabajo, 'Contactos');
    
    // Crear nombre del archivo con fecha y hora
    const ahora = new Date();
    const fechaHora = ahora.toLocaleDateString('es-ES').replace(/\//g, '-') + 
                    '_' + ahora.toLocaleTimeString('es-ES', { hour12: false }).replace(/:/g, '-');
    const nombreArchivo = `contactos_${fechaHora}.xlsx`;
    
    // Descargar el archivo
    XLSX.writeFile(libroTrabajo, nombreArchivo);
    
    // Mostrar mensaje de éxito
    mostrarMensajeExportacion(filasVisibles.length, nombreArchivo);
}

// Función auxiliar para limpiar texto
function limpiarTexto(texto) {
    return texto.replace(/\s+/g, ' ').trim();
}

// Función para mostrar mensaje de exportación exitosa
function mostrarMensajeExportacion(cantidad, nombreArchivo) {
    // Crear toast de notificación
    const toast = document.createElement('div');
    toast.className = 'toast align-items-center text-bg-success border-0';
    toast.setAttribute('role', 'alert');
    toast.setAttribute('aria-live', 'assertive');
    toast.setAttribute('aria-atomic', 'true');
    toast.style.position = 'fixed';
    toast.style.top = '20px';
    toast.style.right = '20px';
    toast.style.zIndex = '9999';
    
    toast.innerHTML = `
        <div class="d-flex">
            <div class="toast-body">
                <i class="fas fa-check-circle me-2"></i>
                <strong>Exportación exitosa!</strong><br>
                Se exportaron ${cantidad} contactos a ${nombreArchivo}
            </div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
    `;
    
    document.body.appendChild(toast);
    
    // Mostrar toast
    const bsToast = new bootstrap.Toast(toast, {
        autohide: true,
        delay: 5000
    });
    bsToast.show();
    
    // Remover toast después de que se oculte
    toast.addEventListener('hidden.bs.toast', () => {
        document.body.removeChild(toast);
    });
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

// Atajos de teclado para los filtros
document.addEventListener('keydown', function(e) {
    // Ctrl + F para enfocar el filtro
    if (e.ctrlKey && e.key === 'f') {
        e.preventDefault();
        const filtroCategoria = document.getElementById('filtroCategoria');
        const filtroContacto = document.getElementById('filtroContacto');
        
        if (filtroContacto) {
            filtroContacto.focus();
            filtroContacto.select();
        } else if (filtroCategoria) {
            filtroCategoria.focus();
            filtroCategoria.select();
        }
    }
    
    // Escape para limpiar el filtro
    if (e.key === 'Escape') {
        const filtroCategoria = document.getElementById('filtroCategoria');
        const filtroContacto = document.getElementById('filtroContacto');
        
        if (filtroContacto && document.activeElement === filtroContacto) {
            limpiarFiltrosContactos();
            filtroContacto.blur();
        } else if (filtroCategoria && document.activeElement === filtroCategoria) {
            limpiarFiltro();
            filtroCategoria.blur();
        }
    }
});

// Función para mostrar indicador de filtros activos
function actualizarIndicadorFiltros() {
    const filtroTexto = document.getElementById('filtroContacto');
    const filtroCategoria = document.getElementById('filtroCategoriaContacto');
    const filtroEstado = document.getElementById('filtroEstadoContacto');
    const indicador = document.getElementById('indicadorFiltros');
    const filtrosActivos = document.getElementById('filtrosActivos');
    
    if (!indicador || !filtrosActivos) return;
    
    const filtros = [];
    
    if (filtroTexto && filtroTexto.value.trim() !== '') {
        filtros.push(`"${filtroTexto.value.trim()}"`);
    }
    
    if (filtroCategoria && filtroCategoria.value !== '') {
        filtros.push(`Categoría: ${filtroCategoria.value}`);
    }
    
    if (filtroEstado && filtroEstado.value !== '') {
        const estadoTexto = filtroEstado.options[filtroEstado.selectedIndex].text;
        filtros.push(`Estado: ${estadoTexto}`);
    }
    
    if (filtros.length > 0) {
        filtrosActivos.textContent = filtros.join(', ');
        indicador.classList.remove('d-none');
    } else {
        indicador.classList.add('d-none');
    }
}

// Función para imprimir contactos
function imprimirContactos() {
    const tabla = document.querySelector('.table tbody');
    const filasVisibles = Array.from(tabla.getElementsByTagName('tr'))
        .filter(fila => fila.style.display !== 'none' && fila.id !== 'mensajeSinResultadosContactos');
    
    if (filasVisibles.length === 0) {
        alert('No hay contactos para imprimir');
        return;
    }
    
    // Crear ventana de impresión
    const ventanaImpresion = window.open('', '_blank');
    
    // Generar contenido HTML para impresión
    let htmlImpresion = `
        <!DOCTYPE html>
        <html>
        <head>
            <title>Lista de Contactos</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 20px; }
                .header { text-align: center; margin-bottom: 30px; }
                .header h1 { color: #333; margin: 0; }
                .header p { color: #666; margin: 5px 0; }
                .table { width: 100%; border-collapse: collapse; margin-top: 20px; }
                .table th, .table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                .table th { background-color: #f8f9fa; font-weight: bold; }
                .table tr:nth-child(even) { background-color: #f9f9f9; }
                .footer { margin-top: 30px; text-align: center; color: #666; font-size: 12px; }
                @media print {
                    body { margin: 0; }
                    .no-print { display: none; }
                }
            </style>
        </head>
        <body>
            <div class="header">
                <h1>Lista de Contactos</h1>
                <p>Fecha de impresión: ${new Date().toLocaleDateString('es-ES')}</p>
                <p>Total de contactos: ${filasVisibles.length}</p>
            </div>
            
            <table class="table">
                <thead>
                    <tr>
                        <th>Nombre</th>
                        <th>Teléfono</th>
                        <th>Email</th>
                        <th>Categoría</th>
                        <th>Evento</th>
                    </tr>
                </thead>
                <tbody>
    `;
    
    // Agregar filas de contactos
    filasVisibles.forEach(fila => {
        const celdas = fila.getElementsByTagName('td');
        if (celdas.length >= 5) {
            const nombre = limpiarTexto(celdas[0].textContent);
            const telefono = limpiarTexto(celdas[1].textContent);
            const email = limpiarTexto(celdas[2].textContent);
            const categoria = limpiarTexto(celdas[3].textContent);
            const evento = limpiarTexto(celdas[4].textContent);
            
            htmlImpresion += `
                <tr>
                    <td>${nombre}</td>
                    <td>${telefono}</td>
                    <td>${email}</td>
                    <td>${categoria}</td>
                    <td>${evento}</td>
                </tr>
            `;
        }
    });
    
    htmlImpresion += `
                </tbody>
            </table>
            
            <div class="footer">
                <p>Agenda de Contactos - Generado automáticamente</p>
            </div>
        </body>
        </html>
    `;
    
    // Escribir contenido y abrir diálogo de impresión
    ventanaImpresion.document.write(htmlImpresion);
    ventanaImpresion.document.close();
    
    // Esperar a que se cargue y abrir diálogo de impresión
    ventanaImpresion.onload = function() {
        ventanaImpresion.print();
        ventanaImpresion.close();
    };
}

// Función para exportar contactos con estadísticas avanzadas
function exportarContactosAvanzado() {
    const tabla = document.querySelector('.table tbody');
    const todasLasFilas = Array.from(tabla.getElementsByTagName('tr'))
        .filter(fila => fila.id !== 'mensajeSinResultadosContactos');
    const filasVisibles = todasLasFilas.filter(fila => fila.style.display !== 'none');
    
    if (filasVisibles.length === 0) {
        alert('No hay contactos para exportar');
        return;
    }
    
    // Crear el libro de trabajo con múltiples hojas
    const libroTrabajo = XLSX.utils.book_new();
    
    // Hoja 1: Contactos
    const datosContactos = [];
    datosContactos.push(['Nombre', 'Teléfono', 'Email', 'Categoría', 'Evento', 'Estado']);
    
    filasVisibles.forEach(fila => {
        const celdas = fila.getElementsByTagName('td');
        if (celdas.length >= 5) {
            const nombre = limpiarTexto(celdas[0].textContent);
            const telefono = limpiarTexto(celdas[1].textContent);
            const email = limpiarTexto(celdas[2].textContent);
            const categoria = limpiarTexto(celdas[3].textContent);
            const evento = limpiarTexto(celdas[4].textContent);
            
            // Determinar estado del contacto
            let estado = 'Completo';
            if (telefono.includes('Sin teléfono') && email.includes('Sin email')) {
                estado = 'Incompleto';
            } else if (telefono.includes('Sin teléfono')) {
                estado = 'Sin teléfono';
            } else if (email.includes('Sin email')) {
                estado = 'Sin email';
            }
            
            datosContactos.push([nombre, telefono, email, categoria, evento, estado]);
        }
    });
    
    const hojaContactos = XLSX.utils.aoa_to_sheet(datosContactos);
    hojaContactos['!cols'] = [
        { wch: 25 }, { wch: 15 }, { wch: 30 }, { wch: 15 }, { wch: 12 }, { wch: 12 }
    ];
    
    // Hoja 2: Estadísticas
    const estadisticas = calcularEstadisticas(filasVisibles);
    const datosEstadisticas = [
        ['Estadísticas de Contactos', ''],
        ['', ''],
        ['Total de contactos exportados', estadisticas.total],
        ['Contactos con teléfono', estadisticas.conTelefono],
        ['Contactos sin teléfono', estadisticas.sinTelefono],
        ['Contactos con email', estadisticas.conEmail],
        ['Contactos sin email', estadisticas.sinEmail],
        ['Contactos con eventos', estadisticas.conEvento],
        ['Contactos sin eventos', estadisticas.sinEvento],
        ['', ''],
        ['Contactos por categoría', ''],
        ...estadisticas.porCategoria.map(cat => [cat.nombre, cat.cantidad])
    ];
    
    const hojaEstadisticas = XLSX.utils.aoa_to_sheet(datosEstadisticas);
    hojaEstadisticas['!cols'] = [{ wch: 30 }, { wch: 15 }];
    
    // Agregar hojas al libro
    XLSX.utils.book_append_sheet(libroTrabajo, hojaContactos, 'Contactos');
    XLSX.utils.book_append_sheet(libroTrabajo, hojaEstadisticas, 'Estadísticas');
    
    // Crear nombre del archivo
    const ahora = new Date();
    const fechaHora = ahora.toLocaleDateString('es-ES').replace(/\//g, '-') + 
                    '_' + ahora.toLocaleTimeString('es-ES', { hour12: false }).replace(/:/g, '-');
    const nombreArchivo = `contactos_completo_${fechaHora}.xlsx`;
    
    // Descargar
    XLSX.writeFile(libroTrabajo, nombreArchivo);
    
    // Mostrar mensaje con estadísticas
    mostrarMensajeExportacionAvanzada(estadisticas, nombreArchivo);
}

// Función para calcular estadísticas
function calcularEstadisticas(filas) {
    const estadisticas = {
        total: filas.length,
        conTelefono: 0,
        sinTelefono: 0,
        conEmail: 0,
        sinEmail: 0,
        conEvento: 0,
        sinEvento: 0,
        porCategoria: {}
    };
    
    filas.forEach(fila => {
        const celdas = fila.getElementsByTagName('td');
        if (celdas.length >= 5) {
            const telefono = limpiarTexto(celdas[1].textContent);
            const email = limpiarTexto(celdas[2].textContent);
            const categoria = limpiarTexto(celdas[3].textContent);
            const evento = limpiarTexto(celdas[4].textContent);
            
            // Contar teléfonos
            if (telefono.includes('Sin teléfono')) {
                estadisticas.sinTelefono++;
            } else {
                estadisticas.conTelefono++;
            }
            
            // Contar emails
            if (email.includes('Sin email')) {
                estadisticas.sinEmail++;
            } else {
                estadisticas.conEmail++;
            }
            
            // Contar eventos
            if (evento.includes('Sin evento')) {
                estadisticas.sinEvento++;
            } else {
                estadisticas.conEvento++;
            }
            
            // Contar por categoría
            if (estadisticas.porCategoria[categoria]) {
                estadisticas.porCategoria[categoria]++;
            } else {
                estadisticas.porCategoria[categoria] = 1;
            }
        }
    });
    
    // Convertir categorías a array
    estadisticas.porCategoria = Object.entries(estadisticas.porCategoria)
        .map(([nombre, cantidad]) => ({ nombre, cantidad }))
        .sort((a, b) => b.cantidad - a.cantidad);
    
    return estadisticas;
}

// Función para mostrar mensaje de exportación avanzada
function mostrarMensajeExportacionAvanzada(estadisticas, nombreArchivo) {
    const modal = document.createElement('div');
    modal.className = 'modal fade';
    modal.id = 'modalExportacion';
    modal.innerHTML = `
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title">
                        <i class="fas fa-check-circle"></i> Exportación Exitosa
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p><strong>Archivo:</strong> ${nombreArchivo}</p>
                    <p><strong>Total exportado:</strong> ${estadisticas.total} contactos</p>
                    
                    <div class="row mt-3">
                        <div class="col-md-6">
                            <h6>Información de contacto:</h6>
                            <ul class="list-unstyled">
                                <li><i class="fas fa-phone text-success"></i> Con teléfono: ${estadisticas.conTelefono}</li>
                                <li><i class="fas fa-phone text-muted"></i> Sin teléfono: ${estadisticas.sinTelefono}</li>
                                <li><i class="fas fa-envelope text-success"></i> Con email: ${estadisticas.conEmail}</li>
                                <li><i class="fas fa-envelope text-muted"></i> Sin email: ${estadisticas.sinEmail}</li>
                            </ul>
                        </div>
                        <div class="col-md-6">
                            <h6>Eventos:</h6>
                            <ul class="list-unstyled">
                                <li><i class="fas fa-calendar text-success"></i> Con evento: ${estadisticas.conEvento}</li>
                                <li><i class="fas fa-calendar text-muted"></i> Sin evento: ${estadisticas.sinEvento}</li>
                            </ul>
                        </div>
                    </div>
                    
                    <h6 class="mt-3">Top categorías:</h6>
                    <ul class="list-unstyled">
                        ${estadisticas.porCategoria.slice(0, 3).map(cat => 
                            `<li><span class="badge bg-info">${cat.nombre}</span> ${cat.cantidad} contactos</li>`
                        ).join('')}
                    </ul>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-success" data-bs-dismiss="modal">
                        <i class="fas fa-check"></i> Entendido
                    </button>
                </div>
            </div>
        </div>
    `;
    
    document.body.appendChild(modal);
    
    const bsModal = new bootstrap.Modal(modal);
    bsModal.show();
    
    // Remover modal después de cerrarlo
    modal.addEventListener('hidden.bs.modal', () => {
        document.body.removeChild(modal);
    });
}

// Función para manejar el contador de caracteres de la descripción del evento
function setupCharacterCounter() {
    const textarea = document.getElementById('descripcion_evento');
    const charCount = document.getElementById('charCount');
    const charCounter = document.querySelector('.char-counter');
    
    if (!textarea || !charCount) return;
    
    function updateCounter() {
        const currentLength = textarea.value.length;
        const maxLength = 200;
        
        charCount.textContent = currentLength;
        
        // Cambiar color según proximidad al límite
        charCounter.classList.remove('warning', 'char-warning', 'char-danger');
        
        if (currentLength > maxLength * 0.9) {
            charCounter.classList.add('char-danger');
        } else if (currentLength > maxLength * 0.7) {
            charCounter.classList.add('char-warning');
            charCounter.classList.add('warning');
        }
        
        // Prevenir exceder el límite
        if (currentLength > maxLength) {
            textarea.value = textarea.value.substring(0, maxLength);
            charCount.textContent = maxLength;
            charCounter.classList.add('char-danger');
        }
    }
    
    // Actualizar contador en tiempo real
    textarea.addEventListener('input', updateCounter);
    textarea.addEventListener('paste', function() {
        setTimeout(updateCounter, 10);
    });
    
    // Inicializar contador
    updateCounter();
}

// Función para mostrar/ocultar el campo de descripción según si hay fecha de evento
function setupEventDescriptionToggle() {
    const fechaEvento = document.getElementById('fecha_evento');
    const descripcionContainer = document.querySelector('#descripcion_evento').closest('.row');
    
    if (!fechaEvento || !descripcionContainer) return;
    
    function toggleDescriptionField() {
        if (fechaEvento.value) {
            descripcionContainer.style.display = 'block';
            descripcionContainer.querySelector('.mb-3').classList.add('event-related-field');
            
            // Animación suave para mostrar
            descripcionContainer.style.opacity = '0';
            descripcionContainer.style.transform = 'translateY(-10px)';
            
            setTimeout(() => {
                descripcionContainer.style.transition = 'all 0.3s ease';
                descripcionContainer.style.opacity = '1';
                descripcionContainer.style.transform = 'translateY(0)';
            }, 10);
        } else {
            // Limpiar descripción si no hay fecha
            document.getElementById('descripcion_evento').value = '';
            descripcionContainer.style.opacity = '0.5';
            descripcionContainer.querySelector('.mb-3').classList.remove('event-related-field');
        }
    }
    
    fechaEvento.addEventListener('change', toggleDescriptionField);
    
    // Inicializar estado
    toggleDescriptionField();
}

// Función para agregar tooltips a eventos en la tabla
function setupEventTooltips() {
    const eventElements = document.querySelectorAll('.event-info .bg-warning-soft');
    
    eventElements.forEach(element => {
        const description = element.closest('.event-info').querySelector('.event-description small');
        
        if (description && description.textContent.trim()) {
            element.classList.add('event-tooltip');
            element.setAttribute('data-tooltip', description.textContent.trim());
        }
    });
}

// Función para marcar eventos vencidos
function markExpiredEvents() {
    const eventElements = document.querySelectorAll('.event-info');
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    eventElements.forEach(element => {
        const dateText = element.querySelector('.bg-warning-soft')?.textContent;
        if (dateText) {
            // Extraer fecha del formato dd/mm/yyyy
            const dateMatch = dateText.match(/(\d{2})\/(\d{2})\/(\d{4})/);
            if (dateMatch) {
                const eventDate = new Date(dateMatch[3], dateMatch[2] - 1, dateMatch[1]);
                
                if (eventDate < today) {
                    element.classList.add('event-expired');
                }
            }
        }
    });
}

// Función para mejorar el filtrado de eventos
function enhanceEventFiltering() {
    const filtroEstado = document.getElementById('filtroEstadoContacto');
    
    if (filtroEstado) {
        // Agregar opciones específicas para eventos
        const eventOptions = [
            { value: 'evento-hoy', text: 'Evento hoy' },
            { value: 'evento-semana', text: 'Evento esta semana' },
            { value: 'evento-vencido', text: 'Evento vencido' }
        ];
        
        eventOptions.forEach(option => {
            const optionElement = document.createElement('option');
            optionElement.value = option.value;
            optionElement.textContent = option.text;
            filtroEstado.appendChild(optionElement);
        });
    }
}

// Inicializar funciones relacionadas con eventos
document.addEventListener('DOMContentLoaded', function() {
    setupCharacterCounter();
    setupEventDescriptionToggle();
    setupEventTooltips();
    markExpiredEvents();
    enhanceEventFiltering();
});

// Agregar a las funciones de filtrado existentes
if (typeof filtrarContactos === 'function') {
    const originalFiltrarContactos = filtrarContactos;
    
    filtrarContactos = function() {
        originalFiltrarContactos();
        
        // Re-aplicar tooltips y marcado de eventos después del filtrado
        setTimeout(() => {
            setupEventTooltips();
            markExpiredEvents();
        }, 100);
    };
}