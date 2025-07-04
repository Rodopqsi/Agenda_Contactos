# 📋 REGLAS DEL NEGOCIO - AGENDA DE CONTACTOS V2.1

**Sistema de Gestión de Contactos con Eventos y Auditoría**
**Fecha:** 4 de julio de 2025
**Versión:** 2.1

---

## 🏢 REGLAS GENERALES DEL SISTEMA

### **RN-001: Propósito del Sistema**
- El sistema debe permitir gestionar contactos personales y profesionales de manera organizada
- Debe facilitar el seguimiento de eventos y recordatorios asociados a cada contacto
- Debe mantener un historial completo de todas las operaciones realizadas

### **RN-002: Usuarios del Sistema**
- El sistema es de uso individual (monousuario)
- No requiere autenticación para el acceso
- Todas las operaciones se registran con el usuario de base de datos actual

---

## 👥 REGLAS DE CONTACTOS

### **RN-003: Información Obligatoria**
- **Nombre**: Obligatorio, máximo 50 caracteres, no puede estar vacío
- **Apellido**: Obligatorio, máximo 50 caracteres, no puede estar vacío
- **Categoría**: Obligatoria, debe existir y estar activa en el sistema

### **RN-004: Información Opcional**
- **Teléfono**: Opcional, máximo 20 caracteres, solo números, espacios, guiones, paréntesis y símbolo +
- **Correo**: Opcional, máximo 100 caracteres, debe cumplir formato de email válido
- **Fecha de Evento**: Opcional, no puede ser anterior a la fecha actual
- **Descripción de Evento**: Opcional, máximo 200 caracteres

### **RN-005: Validación de Email**
- Si se proporciona email, debe cumplir el patrón: `nombre@dominio.extensión`
- Acepta letras, números, punto, guión bajo, porcentaje, más y guión en el nombre
- Acepta letras, números, punto y guión en el dominio
- La extensión debe tener al menos 2 caracteres

### **RN-006: Validación de Teléfono**
- Solo acepta caracteres numéricos (0-9)
- Permite espacios, guiones (-), paréntesis () y símbolo más (+) para formato
- Frontend limpia automáticamente caracteres no válidos

### **RN-007: Fechas del Sistema**
- **Fecha de Creación**: Se asigna automáticamente al crear el contacto
- **Fecha de Modificación**: Se actualiza automáticamente en cada edición
- **Fecha de Evento**: Debe ser igual o posterior a la fecha actual

### **RN-008: Estado de Contactos**
- Todos los contactos tienen un estado: **Activo (Y)** o **Inactivo (N)**
- Por defecto se crean como **Activos**
- Los contactos **Inactivos** no aparecen en listados ni búsquedas
- El borrado es **lógico** (se marca como inactivo, no se elimina físicamente)

---

## 📂 REGLAS DE CATEGORÍAS

### **RN-009: Categorías del Sistema**
- Existen 4 categorías predefinidas del sistema:
  1. **Trabajo** (ID: 1)
  2. **Familia** (ID: 2)
  3. **Amigos** (ID: 3)
  4. **Servicios** (ID: 4)

### **RN-010: Protección de Categorías del Sistema**
- Las categorías con ID 1-4 **NO pueden ser eliminadas**
- Las categorías del sistema **NO pueden ser modificadas**
- Siempre deben permanecer **activas**

### **RN-011: Categorías Personalizadas**
- Los usuarios pueden crear nuevas categorías (ID >= 5)
- **Nombre**: Obligatorio, máximo 50 caracteres, único en el sistema
- No puede existir otra categoría activa con el mismo nombre (insensible a mayúsculas)

### **RN-012: Eliminación de Categorías**
- Solo se pueden eliminar categorías personalizadas (ID >= 5)
- **NO se puede eliminar** una categoría que tenga contactos activos asociados
- El borrado es **lógico** (se marca como inactiva)
- Al eliminar una categoría, se verifica que no tenga contactos activos

### **RN-013: Estado de Categorías**
- Todas las categorías tienen un estado: **Activo (Y)** o **Inactivo (N)**
- Solo aparecen en listados las categorías **activas**
- Los contactos solo pueden asociarse a categorías **activas**

---

## 🗓️ REGLAS DE EVENTOS Y RECORDATORIOS

### **RN-014: Eventos Opcionales**
- Los eventos son **completamente opcionales**
- Un contacto puede existir sin fecha ni descripción de evento
- Si se proporciona fecha, la descripción es opcional y viceversa

### **RN-015: Fechas de Eventos**
- Las fechas de eventos **no pueden ser anteriores** a la fecha actual
- Se permiten fechas futuras sin límite específico
- El frontend previene la selección de fechas pasadas

### **RN-016: Descripción de Eventos**
- Máximo **200 caracteres**
- Texto libre, puede incluir cualquier información relevante
- Ejemplos: "Cumpleaños", "Reunión anual", "Cita médica", "Llamar para presupuesto"

### **RN-017: Eventos de Hoy**
- Se consideran "eventos de hoy" aquellos cuya fecha coincide con la fecha actual
- Se muestran en la sección de recordatorios
- Incluyen tanto fecha como descripción si están disponibles

### **RN-018: Eventos de la Semana**
- Se consideran "eventos de la semana" aquellos en los próximos 7 días (incluyendo hoy)
- Se ordenan por fecha ascendente y luego por nombre del contacto
- Solo se incluyen eventos de contactos activos

---

## 🔍 REGLAS DE BÚSQUEDA Y FILTRADO

### **RN-019: Búsqueda Global**
- La búsqueda se realiza en todos los campos de texto:
  - Nombre del contacto
  - Apellido del contacto
  - Teléfono
  - Correo electrónico
  - Descripción del evento

### **RN-020: Criterios de Búsqueda**
- La búsqueda es **insensible a mayúsculas y minúsculas**
- Utiliza coincidencia parcial (contiene el término)
- Busca en **múltiples campos simultáneamente**
- Solo incluye contactos y categorías **activos**

### **RN-021: Filtro por Categoría**
- Permite filtrar contactos por una categoría específica
- Solo muestra categorías **activas** en el selector
- Al seleccionar una categoría, solo muestra contactos de esa categoría
- Se puede combinar con búsqueda por texto

### **RN-022: Resultados de Búsqueda**
- Los resultados se ordenan por **nombre y apellido** ascendente
- Se incluye **contador dinámico** de resultados encontrados
- Los resultados se actualizan **en tiempo real** mientras se escribe
- No hay límite en el número de resultados mostrados

---

## 📊 REGLAS DE EXPORTACIÓN

### **RN-023: Exportación Básica**
- Incluye todos los contactos **activos** del sistema
- Formato: Excel (.xlsx)
- Campos exportados: Nombre, Apellido, Teléfono, Email, Categoría, Fecha Evento, Descripción

### **RN-024: Exportación Avanzada**
- Incluye solo los contactos **visibles** según filtros aplicados
- Agrega hoja adicional con **estadísticas**:
  - Total de contactos
  - Total por categoría
  - Contactos con eventos
  - Eventos próximos (7 días)

### **RN-025: Formato de Exportación**
- Archivo Excel con formato profesional
- Incluye **metadatos**: fecha de exportación, total de registros
- Las fechas se exportan en formato legible
- Los campos vacíos se muestran como celdas en blanco

---

## 📝 REGLAS DE AUDITORÍA E HISTORIAL

### **RN-026: Registro Automático**
- **Todas las operaciones** se registran automáticamente en el historial
- No requiere intervención manual del usuario
- Se ejecuta mediante triggers de base de datos

### **RN-027: Operaciones Auditadas**
- **Contactos**: INSERT (agregar), UPDATE (modificar), DELETE (eliminar lógico)
- **Categorías**: INSERT (agregar), UPDATE (modificar), DELETE (eliminar lógico)
- **Sistema**: Inicialización, actualizaciones importantes

### **RN-028: Información del Historial**
- **Descripción**: Texto descriptivo de la operación realizada
- **Fecha**: Timestamp exacto de la operación
- **Usuario**: Usuario de base de datos que ejecutó la operación
- **Tipo de Operación**: INSERT, UPDATE, DELETE, SYSTEM
- **Tabla Afectada**: CONTACTOS, CATEGORIAS, SISTEMA

### **RN-029: Retención del Historial**
- El historial **nunca se elimina** automáticamente
- Sirve para auditoría y recuperación de información
- Permite rastrear todos los cambios realizados en el sistema

---

## 🔐 REGLAS DE INTEGRIDAD Y SEGURIDAD

### **RN-030: Integridad Referencial**
- Un contacto **siempre debe tener** una categoría válida y activa
- **No se permite** eliminar una categoría que tenga contactos activos
- Las claves primarias se generan automáticamente mediante secuencias

### **RN-031: Validación de Datos**
- **Todos los datos** se validan tanto en frontend como en backend
- **Campos obligatorios** no pueden estar vacíos o contener solo espacios
- **Longitudes máximas** se respetan estrictamente
- **Formatos específicos** (email) se validan con expresiones regulares

### **RN-032: Transaccionalidad**
- Todas las operaciones de modificación incluyen **COMMIT explícito**
- En caso de error, se ejecuta **ROLLBACK automático**
- Las operaciones complejas se ejecutan como **transacciones atómicas**

### **RN-033: Prevención de Duplicados**
- **Contactos**: No hay restricción de duplicados (pueden existir personas con mismo nombre)
- **Categorías**: No pueden existir dos categorías activas con el mismo nombre
- **IDs**: Son únicos y se generan automáticamente

---

## 📱 REGLAS DE INTERFAZ Y UX

### **RN-034: Responsive Design**
- La interfaz debe **adaptarse** a todos los tamaños de pantalla
- **Móviles**: Navegación simplificada, botones táctiles grandes
- **Tablets**: Diseño híbrido que aprovecha el espacio disponible
- **Desktop**: Interfaz completa con todas las funcionalidades visibles

### **RN-035: Accesibilidad Móvil**
- **Font-size mínimo 16px** en inputs para prevenir zoom en iOS
- **Altura mínima 44px** para elementos táctiles
- **Indicadores visuales** para tablas con scroll horizontal
- **Feedback táctil** para interacciones

### **RN-036: Colores y Diseño**
- **Paleta de colores pasteles**: azul, verde, rojo, púrpura, amarillo, menta
- **Alto contraste** para legibilidad
- **Gradientes suaves** para elementos interactivos
- **Consistencia visual** en toda la aplicación

### **RN-037: Feedback al Usuario**
- **Mensajes de confirmación** para operaciones exitosas
- **Alertas de error** para operaciones fallidas
- **Indicadores de carga** para operaciones que toman tiempo
- **Contador en tiempo real** de resultados de búsqueda

---

## 🔧 REGLAS TÉCNICAS DE BASE DE DATOS

### **RN-038: Secuencias Automáticas**
- **Categorías**: Inician desde ID 5 (1-4 reservados para sistema)
- **Contactos**: Inician desde ID alto (1000) para evitar conflictos con datos existentes
- **Historial**: Inicia desde ID 1
- Se **ajustan automáticamente** si existen datos previos

### **RN-039: Triggers Automáticos**
- **Auto-incremento**: Asignación automática de IDs únicos
- **Fecha de modificación**: Actualización automática en cambios
- **Auditoría**: Registro automático en historial de cambios
- **Validaciones**: Verificación de integridad referencial

### **RN-040: Índices Optimizados**
- **Búsquedas por nombre**: Índice compuesto (nombre, apellido)
- **Búsquedas por contacto**: Índices en teléfono, correo
- **Filtros**: Índices en categoría, estado activo, fecha evento
- **Descripción**: Índice en descripción de evento para búsquedas

### **RN-041: Procedimientos Almacenados**
- **Validaciones centralizadas** en procedimientos de BD
- **Manejo de errores** con códigos de resultado específicos:
  - **1 o mayor**: Operación exitosa (número de registros afectados)
  - **0**: No se encontró el registro
  - **-1**: Error general
  - **-2**: Registro duplicado o con dependencias
  - **-3**: Categoría no válida o del sistema

---

## 🚀 REGLAS DE RENDIMIENTO

### **RN-042: Optimización de Consultas**
- **Paginación**: No implementada (se asume conjunto de datos pequeño a mediano)
- **Índices**: Optimizados para las consultas más frecuentes
- **Joins**: Minimizados y optimizados con índices apropiados

### **RN-043: Carga de Datos**
- **Lazy loading**: No se implementa carga diferida
- **Cache**: No se implementa cache de aplicación
- **Búsqueda en tiempo real**: Optimizada para respuesta inmediata

---

## 📋 REGLAS DE MANTENIMIENTO

### **RN-044: Backup y Recuperación**
- **Responsabilidad del administrador** realizar backups regulares
- **Antes de actualizaciones** siempre realizar backup completo
- **Scripts de migración** preservan datos existentes

### **RN-045: Actualizaciones del Sistema**
- **Usar script específico** para bases de datos existentes
- **Verificar compatibilidad** antes de aplicar cambios
- **Mantener integridad** de datos durante migraciones

---

## 🎯 CASOS DE USO PRINCIPALES

### **CU-001: Gestionar Contacto Personal**
- Agregar familiares y amigos con información básica
- Asociar eventos como cumpleaños, aniversarios
- Mantener información de contacto actualizada

### **CU-002: Gestionar Contacto Profesional**
- Registrar colegas, clientes, proveedores
- Programar reuniones, llamadas, seguimientos
- Categorizar por tipo de relación laboral

### **CU-003: Seguimiento de Eventos**
- Registrar fechas importantes asociadas a contactos
- Consultar eventos próximos (7 días)
- Revisar recordatorios del día actual

### **CU-004: Búsqueda y Organización**
- Buscar contactos por cualquier campo de información
- Filtrar por categoría para organización
- Exportar listas para uso externo

---

**Documento generado el:** 4 de julio de 2025  
**Versión del Sistema:** 2.1 - Responsive Update  
**Última actualización:** Optimización móvil y cambio de colores  

---

*Este documento define las reglas de negocio completas del sistema de agenda de contactos, basado en el análisis exhaustivo del código fuente, base de datos y funcionalidades implementadas.*
