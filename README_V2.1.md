# 📱 Agenda de Contactos - Sistema Completo V2.1

Una aplicación web moderna y responsive para gestionar contactos con funcionalidades avanzadas, colores pasteles actualizados y optimización móvil completa.

## 🚀 Características Principales

### ✨ **Funcionalidades Core**
- **Gestión completa de contactos** (CRUD)
- **Categorización** de contactos
- **Eventos y recordatorios** con descripción
- **Filtrado en tiempo real**
- **Exportación a Excel** (simple y avanzada)
- **Historial de cambios** y auditoría
- **Contador de resultados** dinámico

### 🎨 **Diseño y UX**
- **Colores pasteles** (actualizado: rojo en lugar de rosado)
- **Diseño completamente responsive**
- **Optimizado para móviles** y tablets
- **Interfaz moderna** con Bootstrap 5
- **Iconos Font Awesome**
- **Animaciones suaves**

### 📱 **Optimizaciones Móviles V2.1**
- **Prevención de zoom** en inputs (font-size 16px)
- **Manejo inteligente del teclado virtual**
- **Navegación touch-friendly**
- **Tablas responsive** con scroll horizontal
- **Modales fullscreen** en móviles pequeños
- **Botones flotantes** (FAB) optimizados
- **Viewport optimizado** para mejor experiencia

### 🔧 **Funcionalidades Técnicas**
- **Base de datos Oracle** con PL/SQL
- **Triggers automáticos** para auditoría
- **Procedimientos almacenados** optimizados
- **Validación de datos** en frontend y backend
- **Borrado lógico** para integridad referencial
- **Índices optimizados** para búsquedas rápidas

## 🛠️ Tecnologías Utilizadas

- **Backend**: Python Flask
- **Base de Datos**: Oracle Database con PL/SQL
- **Frontend**: HTML5, CSS3, JavaScript ES6+
- **Framework CSS**: Bootstrap 5.3
- **Iconos**: Font Awesome 6.4
- **Fuentes**: Google Fonts (Poppins)

## 📦 Instalación

### 1. **Clonar el repositorio**
```bash
git clone [URL_DEL_REPOSITORIO]
cd agenda_contactos
```

### 2. **Instalar dependencias**
```bash
pip install -r requirements.txt
```

### 3. **Configurar la base de datos**

#### Para instalación nueva:
```sql
-- Ejecutar database_complete_plsql.sql
```

#### Para actualizar BD existente:
```sql
-- Ejecutar actualizar_base_existente.sql
-- Preserva todos los contactos existentes
```

### 4. **Ejecutar la aplicación**
```bash
python app.py
```

## 🗃️ Estructura de la Base de Datos

### **Tablas Principales**
- `categorias`: Tipos de contactos (Trabajo, Familia, Amigos, Servicios)
- `contactos`: Información principal con eventos y descripción
- `historial_cambios`: Auditoría completa de cambios

### **Características de BD**
- **Secuencias automáticas** para IDs únicos
- **Triggers de auditoría** que registran todos los cambios
- **Validación de emails** con expresiones regulares
- **Borrado lógico** con campo `activo` (Y/N)
- **Índices optimizados** para búsquedas rápidas

### **Procedimientos y Funciones**
- `agregar_contacto`: Inserción con validaciones
- `actualizar_contacto`: Modificación con auditoría
- `eliminar_contacto`: Borrado lógico
- `buscar_contacto`: Búsqueda avanzada
- `obtener_eventos_semana`: Próximos eventos
- `obtener_recordatorios_hoy`: Eventos del día

## 📱 Características Responsive V2.1

### **Móviles (≤768px) - Mejorado**
- **Font-size 16px** en inputs (previene zoom en iOS)
- **Teclado virtual** manejado inteligentemente
- **Contenedor flexible** que se adapta al viewport
- **Botones táctiles** con altura mínima 44px
- **Offcanvas** al 85% del ancho
- **Tablas con scroll** horizontal suave e indicadores
- **InputMode optimizado** para cada tipo de campo

### **Móviles Pequeños (≤576px) - Nuevo**
- **Modales fullscreen** para mejor usabilidad
- **Offcanvas full width** cuando es necesario
- **Espaciado compacto** optimizado
- **Tipografía escalada** apropiadamente
- **Navegación simplificada**

### **Tablets y Landscape - Optimizado**
- **Navegación compacta** en orientación horizontal
- **Botones flotantes** redimensionados dinámicamente
- **Modales centrados** con altura adecuada
- **Detección de cambios** de orientación

### **Características Técnicas Móviles**
- **Detección de dispositivos táctiles**
- **Prevención de zoom** automático
- **Scroll suave** con `-webkit-overflow-scrolling: touch`
- **Feedback táctil** mejorado
- **Meta viewport** optimizado

## 🎨 Colores Pasteles V2.1

### **Paleta Actualizada**
- **Azul Pastel**: `#B8D4F0` (Primary)
- **Verde Pastel**: `#C8E6C9` (Success)
- **Rojo Pastel**: `#FFB3BA` (Danger - Actualizado desde rosado)
- **Púrpura Pastel**: `#E1BEE7` (Info)
- **Amarillo Pastel**: `#FFF9C4` (Warning)
- **Menta Pastel**: `#B2DFDB` (Light)
- **Lavanda Pastel**: `#E6E6FA` (Secondary)

### **Aplicación de Colores**
- **Gradientes dinámicos** en botones y headers
- **Fondos degradados** para cards y contenedores
- **Borders pasteles** para elementos activos
- **Texto con contraste** optimizado para accesibilidad
- **Estados hover** con transiciones suaves

## 📊 Funcionalidades Avanzadas

### **Filtrado y Búsqueda**
- **Búsqueda en tiempo real** en todos los campos incluyendo descripción de eventos
- **Filtro por categoría** con dropdown dinámico
- **Contador de resultados** actualizado instantáneamente
- **Destacado de coincidencias** en resultados
- **Limpieza rápida** de filtros

### **Exportación Mejorada**
- **Excel básico** con todos los contactos
- **Excel avanzado** con filtros aplicados y estadísticas
- **Formato profesional** con estilos y colores
- **Metadatos incluidos** (fecha, total de registros)
- **Impresión optimizada** para móviles

### **Eventos y Recordatorios**
- **Fecha opcional** para eventos futuros
- **Descripción detallada** hasta 200 caracteres
- **Vista de próximos eventos** (7 días)
- **Recordatorios del día** actual
- **Contador de caracteres** en tiempo real

## 🔧 Scripts de Base de Datos

### **`database_complete_plsql.sql`**
- Script completo para instalación nueva
- Incluye tablas, secuencias, triggers, procedimientos y funciones
- Datos iniciales de 4 categorías del sistema
- Verificaciones de integridad y comentarios descriptivos
- Secuencias ajustadas para evitar conflictos

### **`actualizar_base_existente.sql`** - Nuevo
- Para actualizar base de datos existente **sin perder contactos**
- Agrega campos faltantes (`descripcion_evento`, `activo`, etc.)
- Ajusta secuencias automáticamente basándose en datos existentes
- Crea triggers y procedimientos nuevos
- Preserva 100% de los datos actuales

## 🚀 Mejoras V2.1 - Responsive y Colores

### **✅ Cambios de Diseño**
- Cambio completo de **rosado → rojo pastel**
- Meta viewport optimizado con `maximum-scale=1.0, user-scalable=no`
- Estilos inline para prevenir FOUC (Flash of Unstyled Content)
- Soporte para `viewport-fit=cover` (iPhone X+)

### **✅ Optimizaciones Móviles**
- **Font-size 16px** obligatorio en todos los inputs (previene zoom iOS)
- **InputMode** específico para cada tipo de campo (`tel`, `email`, `text`)
- **Autocomplete** apropiado para mejor UX
- **Spellcheck** controlado por tipo de campo
- **Manejo inteligente del teclado virtual**

### **✅ Características Técnicas Agregadas**
- Detección automática de aparición/desaparición del teclado
- Clase `.keyboard-visible` para ajustes dinámicos
- Scroll automático al input activo en móviles
- Indicadores de scroll para tablas largas
- Feedback táctil mejorado con `transform: scale()`

### **✅ Accesibilidad Mejorada**
- **Altura mínima 44px** para elementos táctiles
- Soporte para `prefers-reduced-motion`
- Soporte básico para `prefers-color-scheme: dark`
- Mejor contraste de colores
- Navegación por teclado optimizada

## 📝 Notas Técnicas Importantes

### **Para Móviles iOS**
- El `font-size: 16px` en inputs es **crítico** para prevenir zoom automático
- `maximum-scale=1.0, user-scalable=no` previene zoom manual problemático
- `format-detection=telephone=no` evita detección automática de números

### **Para Desarrollo**
- Usar **`actualizar_base_existente.sql`** si ya tienes contactos
- Las **secuencias se ajustan automáticamente** al máximo ID existente
- El **borrado lógico** mantiene integridad referencial
- Los **triggers registran todos los cambios** automáticamente

### **Para Producción**
- Hacer **backup completo** antes de ejecutar scripts SQL
- Verificar **privilegios de base de datos** necesarios
- Ajustar **tablespaces** según necesidades del servidor
- Las **categorías 1-4 son del sistema** y no se pueden eliminar

## 🔮 Futuras Mejoras Planificadas

- [ ] **PWA** (Progressive Web App) con service workers
- [ ] **Push notifications** para recordatorios
- [ ] **Sincronización offline** con almacenamiento local
- [ ] **Importación masiva** desde CSV/Excel
- [ ] **API REST** para integración con otras apps
- [ ] **Autenticación multi-usuario** con roles
- [ ] **Backup automático** programado
- [ ] **Geolocalización** de contactos
- [ ] **Integración con calendario** del sistema
- [ ] **Búsqueda por voz** en móviles

## 🧪 Testing y Compatibilidad

### **Navegadores Probados**
- ✅ Chrome 90+ (móvil y desktop)
- ✅ Safari 14+ (iOS y macOS)
- ✅ Firefox 88+ (móvil y desktop)
- ✅ Edge 90+ (desktop)
- ✅ Samsung Internet 14+

### **Dispositivos Probados**
- ✅ iPhone SE, 12, 13, 14 (Safari)
- ✅ iPad Air, Pro (Safari)
- ✅ Samsung Galaxy S20, S21, S22 (Chrome, Samsung Internet)
- ✅ Google Pixel 4, 5, 6 (Chrome)
- ✅ Desktop 1920x1080, 2560x1440

## 📄 Licencia

Este proyecto está bajo la **Licencia MIT** - ver el archivo [LICENSE](LICENSE) para más detalles.

## 🤝 Contribución

Las contribuciones son **bienvenidas**. Por favor:

1. **Fork** el proyecto
2. **Crear** una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. **Push** a la rama (`git push origin feature/AmazingFeature`)
5. **Abrir** un Pull Request

### **Guías de Contribución**
- Mantener el **estilo de código** consistente
- **Probar en móviles** antes de enviar PR
- **Documentar** nuevas funcionalidades
- **Respetar** la paleta de colores pasteles
- **Validar** con diferentes tamaños de pantalla

---

**Desarrollado con ❤️ usando colores pasteles y optimización móvil completa**

**Versión 2.1** - Julio 2025 - Responsive Update
