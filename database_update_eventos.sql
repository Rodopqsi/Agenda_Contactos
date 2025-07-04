-- =====================================================
-- SCRIPT SQL PARA AGREGAR DESCRIPCIÓN DE EVENTOS
-- =====================================================

-- 1. Agregar columna descripcion_evento a la tabla contactos
ALTER TABLE contactos ADD descripcion_evento VARCHAR2(200);

-- 2. Crear comentario para la nueva columna
COMMENT ON COLUMN contactos.descripcion_evento IS 'Descripción opcional del evento o recordatorio';

-- 3. Actualizar el procedimiento agregar_contacto
CREATE OR REPLACE PROCEDURE agregar_contacto(
    p_nombre IN VARCHAR2,
    p_apellido IN VARCHAR2,
    p_telefono IN VARCHAR2,
    p_correo IN VARCHAR2,
    p_categoria IN NUMBER,
    p_fecha_evento IN DATE,
    p_descripcion_evento IN VARCHAR2,
    p_resultado OUT NUMBER
) AS
BEGIN
    INSERT INTO contactos (
        nombre, apellido, telefono, correo, id_categoria, 
        fecha_evento, descripcion_evento, fecha_creacion
    ) VALUES (
        p_nombre, p_apellido, p_telefono, p_correo, p_categoria, 
        p_fecha_evento, p_descripcion_evento, SYSDATE
    );
    
    p_resultado := SQL%ROWCOUNT;
    
    -- Agregar al historial
    INSERT INTO historial_cambios (descripcion, fecha)
    VALUES ('Contacto agregado: ' || p_nombre || ' ' || p_apellido, SYSDATE);
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_resultado := -1;
END;
/

-- 4. Actualizar el procedimiento actualizar_contacto
CREATE OR REPLACE PROCEDURE actualizar_contacto(
    p_id IN NUMBER,
    p_nombre IN VARCHAR2,
    p_apellido IN VARCHAR2,
    p_telefono IN VARCHAR2,
    p_correo IN VARCHAR2,
    p_categoria IN NUMBER,
    p_fecha_evento IN DATE,
    p_descripcion_evento IN VARCHAR2,
    p_resultado OUT NUMBER
) AS
BEGIN
    UPDATE contactos 
    SET nombre = p_nombre,
        apellido = p_apellido,
        telefono = p_telefono,
        correo = p_correo,
        id_categoria = p_categoria,
        fecha_evento = p_fecha_evento,
        descripcion_evento = p_descripcion_evento,
        fecha_modificacion = SYSDATE
    WHERE id_contacto = p_id;
    
    p_resultado := SQL%ROWCOUNT;
    
    -- Agregar al historial
    INSERT INTO historial_cambios (descripcion, fecha)
    VALUES ('Contacto actualizado: ' || p_nombre || ' ' || p_apellido, SYSDATE);
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_resultado := -1;
END;
/

-- 5. Actualizar la función obtener_eventos_semana
CREATE OR REPLACE FUNCTION obtener_eventos_semana
RETURN SYS_REFCURSOR
AS
    eventos_cursor SYS_REFCURSOR;
BEGIN
    OPEN eventos_cursor FOR
        SELECT c.id_contacto, c.nombre, c.apellido, c.fecha_evento, 
               cat.nombre_categoria, c.descripcion_evento
        FROM contactos c
        JOIN categorias cat ON c.id_categoria = cat.id_categoria
        WHERE c.fecha_evento BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE) + 7
        ORDER BY c.fecha_evento;
    
    RETURN eventos_cursor;
END;
/

-- 6. Actualizar la función obtener_recordatorios_hoy
CREATE OR REPLACE FUNCTION obtener_recordatorios_hoy
RETURN SYS_REFCURSOR
AS
    recordatorios_cursor SYS_REFCURSOR;
BEGIN
    OPEN recordatorios_cursor FOR
        SELECT c.id_contacto, c.nombre, c.apellido, c.fecha_evento, 
               cat.nombre_categoria, c.descripcion_evento
        FROM contactos c
        JOIN categorias cat ON c.id_categoria = cat.id_categoria
        WHERE TRUNC(c.fecha_evento) = TRUNC(SYSDATE)
        ORDER BY c.fecha_evento;
    
    RETURN recordatorios_cursor;
END;
/

-- 7. Actualizar el procedimiento buscar_contacto
CREATE OR REPLACE PROCEDURE buscar_contacto(
    p_termino IN VARCHAR2,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT c.id_contacto, c.nombre, c.apellido, c.telefono, 
               c.correo, cat.nombre_categoria, c.fecha_evento, c.descripcion_evento
        FROM contactos c
        JOIN categorias cat ON c.id_categoria = cat.id_categoria
        WHERE UPPER(c.nombre) LIKE '%' || UPPER(p_termino) || '%'
           OR UPPER(c.apellido) LIKE '%' || UPPER(p_termino) || '%'
           OR UPPER(c.telefono) LIKE '%' || UPPER(p_termino) || '%'
           OR UPPER(c.correo) LIKE '%' || UPPER(p_termino) || '%'
           OR UPPER(c.descripcion_evento) LIKE '%' || UPPER(p_termino) || '%'
        ORDER BY c.nombre, c.apellido;
END;
/

-- 8. Actualizar el procedimiento contactos_por_categoria
CREATE OR REPLACE PROCEDURE contactos_por_categoria(
    p_categoria_id IN NUMBER,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT c.id_contacto, c.nombre, c.apellido, c.telefono, 
               c.correo, cat.nombre_categoria, c.fecha_evento, c.descripcion_evento
        FROM contactos c
        JOIN categorias cat ON c.id_categoria = cat.id_categoria
        WHERE c.id_categoria = p_categoria_id
        ORDER BY c.nombre, c.apellido;
END;
/

-- 9. Crear índice para mejorar búsquedas por descripción
CREATE INDEX idx_contactos_descripcion ON contactos(descripcion_evento);

-- 10. Verificar cambios
SELECT 'Estructura actualizada correctamente' as mensaje FROM dual;

