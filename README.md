# 📱 Agenda de Contactos - Versión Responsive con Colores Pasteles

Una aplicación web moderna y completamente responsive para gestionar contactos con una interfaz elegante en colores pasteles.

## ✨ Características Principales

### 🎨 Diseño Moderno
- **Paleta de colores pasteles** suaves y elegantes
- **Diseño completamente responsive** que se adapta a todos los dispositivos
- **Animaciones sutiles** y transiciones fluidas
- **Tipografía moderna** con iconos Font Awesome

### 🔍 Filtrado Avanzado
- **Filtrado en tiempo real** para contactos y categorías
- **Búsqueda por texto** con resaltado de coincidencias
- **Filtros por categoría, estado y tipo**
- **Contador dinámico** de resultados
- **Indicador visual** de filtros activos
- **Atajos de teclado** (Ctrl+F para buscar, Escape para limpiar)

### 📊 Exportación de Datos
- **Exportación a Excel** con SheetJS
- **Opción simple**: Lista básica de contactos
- **Opción avanzada**: Incluye hoja de estadísticas detalladas
- **Exportación de datos filtrados**
- **Opción de impresión** de la lista actual

### 📱 Experiencia Móvil
- **Navegación optimizada** para dispositivos pequeños
- **Offcanvas menu** para acceso rápido
- **Botones flotantes** para acciones principales
- **Tablas responsive** con columnas colapsibles
- **Formularios adaptables** a pantallas pequeñas

## 🛠️ Tecnologías Utilizadas

- **Backend**: Python Flask
- **Frontend**: HTML5, CSS3, JavaScript
- **Framework CSS**: Bootstrap 5
- **Base de datos**: SQLite
- **Exportación**: SheetJS (xlsx)
- **Iconos**: Font Awesome 6
- **Fuentes**: Google Fonts

## 📋 Funcionalidades

### 👥 Gestión de Contactos
- ✅ Agregar nuevos contactos
- ✅ Editar contactos existentes
- ✅ Eliminar contactos
- ✅ Búsqueda y filtrado avanzado
- ✅ Categorización automática
- ✅ Fechas de eventos/recordatorios
- ✅ **Descripción de eventos** (Nuevo: v2.1)

### 🏷️ Gestión de Categorías
- ✅ Crear categorías personalizadas
- ✅ Editar categorías existentes
- ✅ Eliminar categorías (con validación)
- ✅ Filtrado por categoría
- ✅ Estadísticas por categoría

### 📈 Panel de Control
- ✅ Dashboard con estadísticas
- ✅ Eventos de la semana con descripciones
- ✅ Actividad reciente
- ✅ Recordatorios automáticos con contexto
- ✅ Acciones rápidas

### 📱 Características Responsive

#### Escritorio (1200px+)
- Layout de 3 columnas
- Menú de navegación completo
- Tablas con todas las columnas visibles
- Formularios en dos columnas

#### Tablet (768px - 1199px)
- Layout de 2 columnas
- Menú colapsible
- Algunas columnas ocultas en tablas
- Formularios adaptables

#### Móvil (< 768px)
- Layout de 1 columna
- Menú offcanvas
- Botones flotantes
- Columnas de tabla priorizadas
- Formularios apilados

## 🎨 Paleta de Colores

```css
/* Colores principales */
--primary-pastel: #8BC390      /* Verde menta suave */
--secondary-pastel: #A8DADC    /* Azul grisáceo */
--success-pastel: #90C695      /* Verde éxito */
--info-pastel: #89CDF1         /* Azul información */
--warning-pastel: #F4D03F      /* Amarillo advertencia */
--danger-pastel: #F1948A       /* Rojo error */
--light-pastel: #F8F9FA        /* Blanco suave */
--dark-pastel: #5D6D7E         /* Gris oscuro */
```

## 🚀 Instalación y Uso

1. **Clona o descarga el proyecto**
   ```bash
   git clone [tu-repositorio]
   cd agenda_contactos
   ```

2. **Instala las dependencias**
   ```bash
   pip install -r requirements.txt
   ```

3. **Configura la base de datos Oracle**
   - Asegúrate de tener Oracle Database instalado y configurado
   - Configura las variables de entorno:
     ```bash
     set ORACLE_USER=tu_usuario
     set ORACLE_PASSWORD=tu_contraseña
     set ORACLE_DSN=localhost:1521/xepdb1
     ```

4. **Ejecuta la aplicación**
   ```bash
   python app.py
   ```

5. **Abre tu navegador**
   - Ve a `http://localhost:5000`
   - ¡Disfruta de tu nueva agenda responsive!

## 🔧 Verificación de la Instalación

Para verificar que todo esté funcionando correctamente, puedes ejecutar:

```bash
python test_app.py
```

Este script verificará que:
- Todos los módulos se importen correctamente
- Las rutas estén definidas
- Las plantillas no tengan errores de sintaxis

## 📁 Estructura del Proyecto

```
agenda_contactos/
├── app.py                 # Aplicación principal Flask
├── database.py            # Gestión de base de datos
├── requirements.txt       # Dependencias Python
├── README.md             # Este archivo
├── static/
│   ├── style.css         # Estilos CSS principales
│   └── script.js         # JavaScript para funcionalidades
└── templates/
    ├── base.html         # Plantilla base responsive
    ├── index.html        # Dashboard principal
    ├── contactos.html    # Lista de contactos
    ├── categorias.html   # Gestión de categorías
    ├── agregar.html      # Formulario nuevo contacto
    ├── editar.html       # Formulario editar contacto
    ├── categoria_form.html # Formulario categorías
    └── historial.html    # Historial de cambios
```

## 🔧 Características Técnicas

### Responsive Design
- **Mobile First**: Diseño pensado primero para móviles
- **Breakpoints**: Bootstrap 5 estándar
- **Flexbox y Grid**: Layout moderno y flexible
- **Imágenes responsive**: Adaptables a cualquier pantalla

### Accesibilidad
- **Contraste adecuado**: Colores que cumplen estándares WCAG
- **Navegación por teclado**: Atajos y navegación accessible
- **Semántica HTML**: Estructura clara y comprensible
- **Aria labels**: Etiquetas descriptivas para lectores de pantalla

### Rendimiento
- **CSS optimizado**: Selectores eficientes y variables CSS
- **JavaScript modular**: Código organizado y reutilizable
- **Imágenes optimizadas**: Iconos vectoriales y fuentes web
- **Carga progresiva**: Elementos que se cargan según necesidad

## 🌟 Mejoras Implementadas

### Versión 2.1 - Descripción de Eventos
- ✅ **Campo de descripción** para eventos con límite de 200 caracteres
- ✅ **Contador de caracteres** en tiempo real con colores de advertencia
- ✅ **Diseño minimalista** que se integra con la paleta pastel
- ✅ **Visualización contextual** en dashboard y lista de contactos
- ✅ **Búsqueda por descripción** de eventos
- ✅ **Responsive design** adaptado a la nueva funcionalidad

### Versión 2.0 - Responsive + Pasteles
- ✅ Diseño completamente responsive
- ✅ Paleta de colores pasteles
- ✅ Filtrado en tiempo real
- ✅ Exportación avanzada a Excel
- ✅ Experiencia móvil optimizada
- ✅ Validación de formularios mejorada
- ✅ Animaciones y transiciones suaves
- ✅ Accesibilidad mejorada
- ✅ Código reorganizado y optimizado

### Funcionalidades Nuevas
- 🔍 **Filtrado inteligente**: Búsqueda por múltiples criterios
- 📊 **Estadísticas avanzadas**: Gráficos y métricas detalladas
- 🎯 **Acciones rápidas**: Botones flotantes para móvil
- 🔄 **Navegación fluida**: Offcanvas y menús adaptativos
- 📱 **PWA Ready**: Preparado para ser Progressive Web App

## 🤝 Contribución

Si quieres contribuir a este proyecto:

1. Haz un fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Añadir nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crea un Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🎯 Próximas Mejoras

- [ ] Modo oscuro con paleta pastel
- [ ] Sincronización con servicios en la nube
- [ ] Aplicación móvil nativa
- [ ] Importación desde otros formatos
- [ ] Integración con calendarios
- [ ] Backup automático
- [ ] Búsqueda por geolocalización
- [ ] Integración con redes sociales

---

**Desarrollado con ❤️ y colores pasteles** 🎨

*Una aplicación moderna, responsive y elegante para gestionar tus contactos de forma eficiente en cualquier dispositivo.*
