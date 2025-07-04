-- =========================
-- SECCIÓN 1: LIMPIEZA (opcional)
-- Borra objetos si ya existen, útil para reiniciar todo
-- =========================

/*
-- Descomenta si quieres limpiar todo antes de crear de nuevo
DROP SEQUENCE seq_contacto_id;
DROP SEQUENCE seq_categoria_id;
DROP SEQUENCE seq_historial_id;
DROP TABLE historial_cambios CASCADE CONSTRAINTS;
DROP TABLE contactos CASCADE CONSTRAINTS;
DROP TABLE categorias CASCADE CONSTRAINTS;
DROP PROCEDURE agregar_contacto;
DROP PROCEDURE actualizar_contacto;
DROP PROCEDURE eliminar_contacto;
DROP PROCEDURE agregar_categoria;
DROP PROCEDURE eliminar_categoria;
DROP PROCEDURE buscar_contacto;
DROP PROCEDURE contactos_por_categoria;
DROP FUNCTION obtener_eventos_semana;
DROP FUNCTION obtener_recordatorios_hoy;
*/

-- =========================
-- SECCIÓN 2: TABLAS
-- Aquí van las tablas principales del sistema
-- =========================

-- Tabla de categorías (tipos de contactos)
CREATE TABLE categorias (
    id_categoria    NUMBER(10) NOT NULL,
    nombre_categoria VARCHAR2(50) NOT NULL,
    fecha_creacion  DATE DEFAULT SYSDATE,
    activo          CHAR(1) DEFAULT 'Y' CHECK (activo IN ('Y', 'N')),
    CONSTRAINT pk_categorias PRIMARY KEY (id_categoria),
    CONSTRAINT uk_categorias_nombre UNIQUE (nombre_categoria)
);

-- Tabla de contactos (los datos principales)
CREATE TABLE contactos (
    id_contacto         NUMBER(10) NOT NULL,
    nombre              VARCHAR2(50) NOT NULL,
    apellido            VARCHAR2(50) NOT NULL,
    telefono            VARCHAR2(20),
    correo              VARCHAR2(100),
    id_categoria        NUMBER(10) NOT NULL,
    fecha_evento        DATE,
    descripcion_evento  VARCHAR2(200),
    fecha_creacion      DATE DEFAULT SYSDATE,
    fecha_modificacion  DATE,
    activo              CHAR(1) DEFAULT 'Y' CHECK (activo IN ('Y', 'N')),
    CONSTRAINT pk_contactos PRIMARY KEY (id_contacto),
    CONSTRAINT fk_contactos_categoria FOREIGN KEY (id_categoria) 
        REFERENCES categorias(id_categoria),
    CONSTRAINT chk_contactos_email CHECK (
        correo IS NULL OR 
        REGEXP_LIKE(correo, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
    )
);

-- Tabla para guardar historial de cambios (auditoría)
CREATE TABLE historial_cambios (
    id_historial    NUMBER(10) NOT NULL,
    descripcion     VARCHAR2(500) NOT NULL,
    fecha           DATE DEFAULT SYSDATE,
    usuario         VARCHAR2(50) DEFAULT USER,
    tipo_operacion  VARCHAR2(20),
    tabla_afectada  VARCHAR2(50),
    CONSTRAINT pk_historial PRIMARY KEY (id_historial)
);

-- =========================
-- SECCIÓN 3: SECUENCIAS
-- Para autoincrementar los IDs
-- =========================

-- Secuencia para categorías (empieza desde 5 para no interferir con las del sistema)
CREATE SEQUENCE seq_categoria_id START WITH 5 INCREMENT BY 1 NOCACHE NOCYCLE;

-- Secuencia para contactos (empieza desde un número alto para no interferir con datos existentes)
-- Si ya tienes contactos, ajusta el START WITH a un número mayor al máximo ID existente
CREATE SEQUENCE seq_contacto_id START WITH 1000 INCREMENT BY 1 NOCACHE NOCYCLE;

-- Secuencia para historial
CREATE SEQUENCE seq_historial_id START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- =========================
-- SECCIÓN 4: ÍNDICES
-- Mejoran la velocidad de las búsquedas
-- =========================

CREATE INDEX idx_contactos_nombre ON contactos(nombre, apellido);
CREATE INDEX idx_contactos_telefono ON contactos(telefono);
CREATE INDEX idx_contactos_correo ON contactos(correo);
CREATE INDEX idx_contactos_categoria ON contactos(id_categoria);
CREATE INDEX idx_contactos_fecha_evento ON contactos(fecha_evento);
CREATE INDEX idx_contactos_descripcion ON contactos(descripcion_evento);
CREATE INDEX idx_contactos_activo ON contactos(activo);
CREATE INDEX idx_historial_fecha ON historial_cambios(fecha);
CREATE INDEX idx_categorias_activo ON categorias(activo);

-- =========================
-- SECCIÓN 5: TRIGGERS
-- Automatizan tareas como IDs y auditoría
-- =========================

-- IDs automáticos para categorías
CREATE OR REPLACE TRIGGER trg_categorias_id
    BEFORE INSERT ON categorias
    FOR EACH ROW
BEGIN
    IF :NEW.id_categoria IS NULL THEN
        :NEW.id_categoria := seq_categoria_id.NEXTVAL;
    END IF;
END;
/

-- IDs automáticos para contactos
CREATE OR REPLACE TRIGGER trg_contactos_id
    BEFORE INSERT ON contactos
    FOR EACH ROW
BEGIN
    IF :NEW.id_contacto IS NULL THEN
        :NEW.id_contacto := seq_contacto_id.NEXTVAL;
    END IF;
END;
/

-- IDs automáticos para historial
CREATE OR REPLACE TRIGGER trg_historial_id
    BEFORE INSERT ON historial_cambios
    FOR EACH ROW
BEGIN
    IF :NEW.id_historial IS NULL THEN
        :NEW.id_historial := seq_historial_id.NEXTVAL;
    END IF;
END;
/

-- Actualiza la fecha de modificación cuando se edita un contacto
CREATE OR REPLACE TRIGGER trg_contactos_modificacion
    BEFORE UPDATE ON contactos
    FOR EACH ROW
BEGIN
    :NEW.fecha_modificacion := SYSDATE;
END;
/

-- Guarda en historial cada vez que se agrega, edita o borra un contacto
CREATE OR REPLACE TRIGGER trg_contactos_historial
    AFTER INSERT OR UPDATE OR DELETE ON contactos
    FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(20);
    v_descripcion VARCHAR2(500);
BEGIN
    CASE
        WHEN INSERTING THEN
            v_operacion := 'INSERT';
            v_descripcion := 'Contacto agregado: ' || :NEW.nombre || ' ' || :NEW.apellido;
        WHEN UPDATING THEN
            v_operacion := 'UPDATE';
            v_descripcion := 'Contacto actualizado: ' || :NEW.nombre || ' ' || :NEW.apellido;
        WHEN DELETING THEN
            v_operacion := 'DELETE';
            v_descripcion := 'Contacto eliminado: ' || :OLD.nombre || ' ' || :OLD.apellido;
    END CASE;
    
    INSERT INTO historial_cambios (
        descripcion, tipo_operacion, tabla_afectada
    ) VALUES (
        v_descripcion, v_operacion, 'CONTACTOS'
    );
END;
/

-- Guarda en historial cada vez que se agrega, edita o borra una categoría
CREATE OR REPLACE TRIGGER trg_categorias_historial
    AFTER INSERT OR UPDATE OR DELETE ON categorias
    FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(20);
    v_descripcion VARCHAR2(500);
BEGIN
    CASE
        WHEN INSERTING THEN
            v_operacion := 'INSERT';
            v_descripcion := 'Categoría creada: ' || :NEW.nombre_categoria;
        WHEN UPDATING THEN
            v_operacion := 'UPDATE';
            v_descripcion := 'Categoría actualizada: ' || :NEW.nombre_categoria;
        WHEN DELETING THEN
            v_operacion := 'DELETE';
            v_descripcion := 'Categoría eliminada: ' || :OLD.nombre_categoria;
    END CASE;
    
    INSERT INTO historial_cambios (
        descripcion, tipo_operacion, tabla_afectada
    ) VALUES (
        v_descripcion, v_operacion, 'CATEGORIAS'
    );
END;
/

-- =========================
-- SECCIÓN 6: PROCEDIMIENTOS
-- Acciones principales para manejar contactos y categorías
-- =========================

-- Agregar contacto nuevo
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
    -- Checa si la categoría existe y está activa
    DECLARE
        v_categoria_existe NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_categoria_existe
        FROM categorias
        WHERE id_categoria = p_categoria AND activo = 'Y';
        
        IF v_categoria_existe = 0 THEN
            p_resultado := -3; -- Categoría no válida
            RETURN;
        END IF;
    END;
    
    -- Inserta el contacto
    INSERT INTO contactos (
        nombre, apellido, telefono, correo, id_categoria, 
        fecha_evento, descripcion_evento, fecha_creacion
    ) VALUES (
        TRIM(p_nombre), TRIM(p_apellido), TRIM(p_telefono), 
        TRIM(p_correo), p_categoria, p_fecha_evento, 
        TRIM(p_descripcion_evento), SYSDATE
    );
    
    p_resultado := SQL%ROWCOUNT;
    COMMIT;
    
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        p_resultado := -2; -- Contacto duplicado
    WHEN OTHERS THEN
        ROLLBACK;
        p_resultado := -1; -- Error general
END;
/

-- Actualizar datos de un contacto
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
    -- Checa si el contacto existe y está activo
    DECLARE
        v_contacto_existe NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_contacto_existe
        FROM contactos
        WHERE id_contacto = p_id AND activo = 'Y';
        
        IF v_contacto_existe = 0 THEN
            p_resultado := 0; -- Contacto no encontrado
            RETURN;
        END IF;
    END;
    
    -- Checa si la categoría existe y está activa
    DECLARE
        v_categoria_existe NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_categoria_existe
        FROM categorias
        WHERE id_categoria = p_categoria AND activo = 'Y';
        
        IF v_categoria_existe = 0 THEN
            p_resultado := -3; -- Categoría no válida
            RETURN;
        END IF;
    END;
    
    -- Actualiza el contacto
    UPDATE contactos 
    SET nombre = TRIM(p_nombre),
        apellido = TRIM(p_apellido),
        telefono = TRIM(p_telefono),
        correo = TRIM(p_correo),
        id_categoria = p_categoria,
        fecha_evento = p_fecha_evento,
        descripcion_evento = TRIM(p_descripcion_evento),
        fecha_modificacion = SYSDATE
    WHERE id_contacto = p_id AND activo = 'Y';
    
    p_resultado := SQL%ROWCOUNT;
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_resultado := -1; -- Error general
END;
/

-- Borrado lógico de un contacto
CREATE OR REPLACE PROCEDURE eliminar_contacto(
    p_id IN NUMBER,
    p_resultado OUT NUMBER
) AS
BEGIN
    -- Checa si el contacto existe y está activo
    DECLARE
        v_contacto_existe NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_contacto_existe
        FROM contactos
        WHERE id_contacto = p_id AND activo = 'Y';
        
        IF v_contacto_existe = 0 THEN
            p_resultado := 0; -- Contacto no encontrado
            RETURN;
        END IF;
    END;
    
    -- Marca como inactivo
    UPDATE contactos 
    SET activo = 'N',
        fecha_modificacion = SYSDATE
    WHERE id_contacto = p_id;
    
    p_resultado := SQL%ROWCOUNT;
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_resultado := -1; -- Error general
END;
/

-- Agregar una nueva categoría
CREATE OR REPLACE PROCEDURE agregar_categoria(
    p_nombre IN VARCHAR2,
    p_resultado OUT NUMBER
) AS
    v_categoria_existe NUMBER;
    v_nuevo_id NUMBER;
BEGIN
    -- Checa si ya existe una categoría con ese nombre
    SELECT COUNT(*)
    INTO v_categoria_existe
    FROM categorias
    WHERE UPPER(TRIM(nombre_categoria)) = UPPER(TRIM(p_nombre))
    AND activo = 'Y';
    
    IF v_categoria_existe > 0 THEN
        p_resultado := -2; -- Ya existe
        RETURN;
    END IF;
    
    -- Inserta la nueva categoría
    INSERT INTO categorias (nombre_categoria, fecha_creacion)
    VALUES (TRIM(p_nombre), SYSDATE)
    RETURNING id_categoria INTO v_nuevo_id;
    
    p_resultado := v_nuevo_id;
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_resultado := -1; -- Error general
END;
/

-- Eliminar (lógicamente) una categoría
CREATE OR REPLACE PROCEDURE eliminar_categoria(
    p_categoria_id IN NUMBER,
    p_resultado OUT NUMBER
) AS
    v_contactos_asociados NUMBER;
    v_categoria_existe NUMBER;
BEGIN
    -- Checa si la categoría existe y está activa
    SELECT COUNT(*)
    INTO v_categoria_existe
    FROM categorias
    WHERE id_categoria = p_categoria_id AND activo = 'Y';
    
    IF v_categoria_existe = 0 THEN
        p_resultado := 0; -- No encontrada
        RETURN;
    END IF;
    
    -- No se pueden borrar las categorías del sistema (IDs 1-4)
    IF p_categoria_id <= 4 THEN
        p_resultado := -3; -- Categoría del sistema
        RETURN;
    END IF;
    
    -- Checa si tiene contactos asociados
    SELECT COUNT(*)
    INTO v_contactos_asociados
    FROM contactos
    WHERE id_categoria = p_categoria_id AND activo = 'Y';
    
    IF v_contactos_asociados > 0 THEN
        p_resultado := -2; -- Tiene contactos asociados
        RETURN;
    END IF;
    
    -- Marca como inactiva
    UPDATE categorias 
    SET activo = 'N'
    WHERE id_categoria = p_categoria_id;
    
    p_resultado := SQL%ROWCOUNT;
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_resultado := -1; -- Error general
END;
/

-- Buscar contactos por término (nombre, apellido, etc.)
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
        WHERE c.activo = 'Y' 
        AND cat.activo = 'Y'
        AND (
            UPPER(c.nombre) LIKE '%' || UPPER(TRIM(p_termino)) || '%'
            OR UPPER(c.apellido) LIKE '%' || UPPER(TRIM(p_termino)) || '%'
            OR UPPER(c.telefono) LIKE '%' || UPPER(TRIM(p_termino)) || '%'
            OR UPPER(c.correo) LIKE '%' || UPPER(TRIM(p_termino)) || '%'
            OR UPPER(c.descripcion_evento) LIKE '%' || UPPER(TRIM(p_termino)) || '%'
        )
        ORDER BY c.nombre, c.apellido;
END;
/

-- Obtener todos los contactos de una categoría
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
        AND c.activo = 'Y'
        AND cat.activo = 'Y'
        ORDER BY c.nombre, c.apellido;
END;
/

-- =========================
-- SECCIÓN 7: FUNCIONES
-- Consultas útiles para reportes y estadísticas
-- =========================

-- Eventos de la semana (próximos 7 días)
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
        AND c.activo = 'Y'
        AND cat.activo = 'Y'
        ORDER BY c.fecha_evento, c.nombre;
    
    RETURN eventos_cursor;
END;
/

-- Recordatorios para hoy
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
        AND c.activo = 'Y'
        AND cat.activo = 'Y'
        ORDER BY c.fecha_evento, c.nombre;
    
    RETURN recordatorios_cursor;
END;
/

-- Cuántos contactos hay en una categoría
CREATE OR REPLACE FUNCTION contar_contactos_categoria(
    p_categoria_id IN NUMBER
) RETURN NUMBER
AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM contactos
    WHERE id_categoria = p_categoria_id
    AND activo = 'Y';
    
    RETURN v_count;
END;
/

-- Estadísticas generales del sistema
CREATE OR REPLACE FUNCTION obtener_estadisticas_generales
RETURN SYS_REFCURSOR
AS
    stats_cursor SYS_REFCURSOR;
BEGIN
    OPEN stats_cursor FOR
        SELECT 
            (SELECT COUNT(*) FROM contactos WHERE activo = 'Y') as total_contactos,
            (SELECT COUNT(*) FROM categorias WHERE activo = 'Y') as total_categorias,
            (SELECT COUNT(*) FROM contactos WHERE fecha_evento IS NOT NULL AND activo = 'Y') as contactos_con_eventos,
            (SELECT COUNT(*) FROM contactos WHERE TRUNC(fecha_evento) = TRUNC(SYSDATE) AND activo = 'Y') as eventos_hoy,
            (SELECT COUNT(*) FROM contactos WHERE fecha_evento BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE) + 7 AND activo = 'Y') as eventos_semana
        FROM dual;
    
    RETURN stats_cursor;
END;
/

-- =========================
-- SECCIÓN 8: DATOS INICIALES
-- Carga categorías básicas y un registro en historial
-- =========================

INSERT INTO categorias (id_categoria, nombre_categoria) VALUES (1, 'Trabajo');
INSERT INTO categorias (id_categoria, nombre_categoria) VALUES (2, 'Familia');
INSERT INTO categorias (id_categoria, nombre_categoria) VALUES (3, 'Amigos');
INSERT INTO categorias (id_categoria, nombre_categoria) VALUES (4, 'Servicios');

INSERT INTO historial_cambios (descripcion, tipo_operacion, tabla_afectada)
VALUES ('Sistema inicializado correctamente', 'SYSTEM', 'SISTEMA');

-- =========================
-- SECCIÓN 9: COMMIT Y COMENTARIOS
-- Guarda los cambios y agrega descripciones a las tablas/columnas
-- =========================

COMMIT;

COMMENT ON TABLE categorias IS 'Aquí se guardan los tipos de contactos';
COMMENT ON TABLE contactos IS 'Aquí van todos los contactos';
COMMENT ON TABLE historial_cambios IS 'Historial de cambios y auditoría';

COMMENT ON COLUMN contactos.descripcion_evento IS 'Descripción opcional del evento o recordatorio (máx. 200 caracteres)';
COMMENT ON COLUMN contactos.fecha_evento IS 'Fecha del evento o recordatorio asociado al contacto';
COMMENT ON COLUMN contactos.activo IS 'Y = activo, N = inactivo (borrado lógico)';
COMMENT ON COLUMN categorias.activo IS 'Y = activo, N = inactivo (borrado lógico)';

-- =========================
-- SECCIÓN 10: VERIFICACIÓN Y MENSAJE FINAL
-- Consultas rápidas para checar que todo quedó bien
-- =========================

SELECT 'Tablas creadas: ' || COUNT(*) as resultado
FROM user_tables 
WHERE table_name IN ('CATEGORIAS', 'CONTACTOS', 'HISTORIAL_CAMBIOS');

SELECT 'Secuencias creadas: ' || COUNT(*) as resultado
FROM user_sequences 
WHERE sequence_name IN ('SEQ_CATEGORIA_ID', 'SEQ_CONTACTO_ID', 'SEQ_HISTORIAL_ID');

SELECT 'Procedimientos creados: ' || COUNT(*) as resultado
FROM user_procedures 
WHERE object_name IN ('AGREGAR_CONTACTO', 'ACTUALIZAR_CONTACTO', 'ELIMINAR_CONTACTO', 
                      'AGREGAR_CATEGORIA', 'ELIMINAR_CATEGORIA', 'BUSCAR_CONTACTO', 
                      'CONTACTOS_POR_CATEGORIA');

SELECT 'Funciones creadas: ' || COUNT(*) as resultado
FROM user_procedures 
WHERE object_name IN ('OBTENER_EVENTOS_SEMANA', 'OBTENER_RECORDATORIOS_HOY', 
                      'CONTAR_CONTACTOS_CATEGORIA', 'OBTENER_ESTADISTICAS_GENERALES');

SELECT 'Triggers creados: ' || COUNT(*) as resultado
FROM user_triggers 
WHERE trigger_name LIKE 'TRG_%';

SELECT 'Índices creados: ' || COUNT(*) as resultado
FROM user_indexes 
WHERE index_name LIKE 'IDX_%';

SELECT 'BASE DE DATOS AGENDA DE CONTACTOS CREADA EXITOSAMENTE' as mensaje,
       'Versión 2.1 - Con descripción de eventos' as version,
       'Fecha: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') as fecha_creacion
FROM dual;


-- Actualizacion 
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

