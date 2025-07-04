-- ================================================================
-- SCRIPT PARA ACTUALIZAR BASE DE DATOS EXISTENTE
-- AGENDA DE CONTACTOS - ACTUALIZACIÓN SIN PÉRDIDA DE DATOS
-- Fecha: 4 de julio de 2025
-- ================================================================

-- IMPORTANTE: Este script actualiza una base de datos existente
-- sin borrar los contactos que ya tienes

-- ================================================================
-- 1. VERIFICAR ESTRUCTURA ACTUAL
-- ================================================================

-- Verificar si ya existe el campo descripcion_evento
SELECT column_name 
FROM user_tab_columns 
WHERE table_name = 'CONTACTOS' 
AND column_name = 'DESCRIPCION_EVENTO';

-- ================================================================
-- 2. AGREGAR CAMPOS FALTANTES (si no existen)
-- ================================================================

-- Agregar descripcion_evento si no existe
DECLARE
    v_column_exists NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_column_exists
    FROM user_tab_columns
    WHERE table_name = 'CONTACTOS'
    AND column_name = 'DESCRIPCION_EVENTO';
    
    IF v_column_exists = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE contactos ADD descripcion_evento VARCHAR2(200)';
        DBMS_OUTPUT.PUT_LINE('Campo descripcion_evento agregado exitosamente');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Campo descripcion_evento ya existe');
    END IF;
END;
/

-- Agregar fecha_modificacion si no existe
DECLARE
    v_column_exists NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_column_exists
    FROM user_tab_columns
    WHERE table_name = 'CONTACTOS'
    AND column_name = 'FECHA_MODIFICACION';
    
    IF v_column_exists = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE contactos ADD fecha_modificacion DATE';
        DBMS_OUTPUT.PUT_LINE('Campo fecha_modificacion agregado exitosamente');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Campo fecha_modificacion ya existe');
    END IF;
END;
/

-- Agregar campo activo si no existe
DECLARE
    v_column_exists NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_column_exists
    FROM user_tab_columns
    WHERE table_name = 'CONTACTOS'
    AND column_name = 'ACTIVO';
    
    IF v_column_exists = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE contactos ADD activo CHAR(1) DEFAULT ''Y'' CHECK (activo IN (''Y'', ''N''))';
        DBMS_OUTPUT.PUT_LINE('Campo activo agregado exitosamente');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Campo activo ya existe');
    END IF;
END;
/

-- ================================================================
-- 3. ACTUALIZAR REGISTROS EXISTENTES
-- ================================================================

-- Marcar todos los contactos existentes como activos
UPDATE contactos 
SET activo = 'Y' 
WHERE activo IS NULL;

-- Marcar todas las categorías existentes como activas
UPDATE categorias 
SET activo = 'Y' 
WHERE activo IS NULL;

COMMIT;

-- ================================================================
-- 4. CREAR TABLA DE HISTORIAL SI NO EXISTE
-- ================================================================

DECLARE
    v_table_exists NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_table_exists
    FROM user_tables
    WHERE table_name = 'HISTORIAL_CAMBIOS';
    
    IF v_table_exists = 0 THEN
        EXECUTE IMMEDIATE '
        CREATE TABLE historial_cambios (
            id_historial    NUMBER(10) NOT NULL,
            descripcion     VARCHAR2(500) NOT NULL,
            fecha           DATE DEFAULT SYSDATE,
            usuario         VARCHAR2(50) DEFAULT USER,
            tipo_operacion  VARCHAR2(20),
            tabla_afectada  VARCHAR2(50),
            CONSTRAINT pk_historial PRIMARY KEY (id_historial)
        )';
        DBMS_OUTPUT.PUT_LINE('Tabla historial_cambios creada exitosamente');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Tabla historial_cambios ya existe');
    END IF;
END;
/

-- ================================================================
-- 5. CREAR SECUENCIAS AJUSTADAS A DATOS EXISTENTES
-- ================================================================

-- Secuencia para contactos (ajustada al máximo ID existente)
DECLARE
    v_max_id NUMBER;
    v_seq_exists NUMBER;
BEGIN
    -- Verificar si la secuencia ya existe
    SELECT COUNT(*) INTO v_seq_exists FROM user_sequences WHERE sequence_name = 'SEQ_CONTACTO_ID';
    
    -- Obtener el máximo ID existente
    SELECT NVL(MAX(id_contacto), 0) + 1 INTO v_max_id FROM contactos;
    
    -- Crear o recrear la secuencia
    IF v_seq_exists > 0 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE seq_contacto_id';
    END IF;
    
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_contacto_id START WITH ' || v_max_id || ' INCREMENT BY 1 NOCACHE NOCYCLE';
    DBMS_OUTPUT.PUT_LINE('Secuencia de contactos configurada para empezar en: ' || v_max_id);
END;
/

-- Secuencia para categorías (ajustada al máximo ID existente)
DECLARE
    v_max_id NUMBER;
    v_seq_exists NUMBER;
BEGIN
    -- Verificar si la secuencia ya existe
    SELECT COUNT(*) INTO v_seq_exists FROM user_sequences WHERE sequence_name = 'SEQ_CATEGORIA_ID';
    
    -- Obtener el máximo ID existente (mínimo 5)
    SELECT GREATEST(NVL(MAX(id_categoria), 4) + 1, 5) INTO v_max_id FROM categorias;
    
    -- Crear o recrear la secuencia
    IF v_seq_exists > 0 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE seq_categoria_id';
    END IF;
    
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_categoria_id START WITH ' || v_max_id || ' INCREMENT BY 1 NOCACHE NOCYCLE';
    DBMS_OUTPUT.PUT_LINE('Secuencia de categorías configurada para empezar en: ' || v_max_id);
END;
/

-- Secuencia para historial
DECLARE
    v_max_id NUMBER;
    v_seq_exists NUMBER;
BEGIN
    -- Verificar si la secuencia ya existe
    SELECT COUNT(*) INTO v_seq_exists FROM user_sequences WHERE sequence_name = 'SEQ_HISTORIAL_ID';
    
    -- Obtener el máximo ID existente
    SELECT NVL(MAX(id_historial), 0) + 1 INTO v_max_id FROM historial_cambios;
    
    -- Crear o recrear la secuencia
    IF v_seq_exists > 0 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE seq_historial_id';
    END IF;
    
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_historial_id START WITH ' || v_max_id || ' INCREMENT BY 1 NOCACHE NOCYCLE';
    DBMS_OUTPUT.PUT_LINE('Secuencia de historial configurada para empezar en: ' || v_max_id);
END;
/

-- ================================================================
-- 6. CREAR ÍNDICES FALTANTES
-- ================================================================

-- Crear índices si no existen
DECLARE
    v_index_exists NUMBER;
BEGIN
    -- Índice para descripción de evento
    SELECT COUNT(*) INTO v_index_exists FROM user_indexes WHERE index_name = 'IDX_CONTACTOS_DESCRIPCION';
    IF v_index_exists = 0 THEN
        EXECUTE IMMEDIATE 'CREATE INDEX idx_contactos_descripcion ON contactos(descripcion_evento)';
        DBMS_OUTPUT.PUT_LINE('Índice para descripción de evento creado');
    END IF;
    
    -- Índice para estado activo
    SELECT COUNT(*) INTO v_index_exists FROM user_indexes WHERE index_name = 'IDX_CONTACTOS_ACTIVO';
    IF v_index_exists = 0 THEN
        EXECUTE IMMEDIATE 'CREATE INDEX idx_contactos_activo ON contactos(activo)';
        DBMS_OUTPUT.PUT_LINE('Índice para estado activo creado');
    END IF;
END;
/

-- ================================================================
-- 7. CREAR/ACTUALIZAR TRIGGERS
-- ================================================================

-- Trigger para auto-incrementar ID de contactos
CREATE OR REPLACE TRIGGER trg_contactos_id
    BEFORE INSERT ON contactos
    FOR EACH ROW
BEGIN
    IF :NEW.id_contacto IS NULL THEN
        :NEW.id_contacto := seq_contacto_id.NEXTVAL;
    END IF;
END;
/

-- Trigger para actualizar fecha de modificación
CREATE OR REPLACE TRIGGER trg_contactos_modificacion
    BEFORE UPDATE ON contactos
    FOR EACH ROW
BEGIN
    :NEW.fecha_modificacion := SYSDATE;
END;
/

-- Trigger para historial automático
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

-- ================================================================
-- 8. INSERTAR REGISTRO EN HISTORIAL
-- ================================================================

INSERT INTO historial_cambios (descripcion, tipo_operacion, tabla_afectada)
VALUES ('Base de datos actualizada con nuevos campos y funcionalidades', 'UPDATE', 'SISTEMA');

-- ================================================================
-- 9. VERIFICACIÓN FINAL
-- ================================================================

SELECT 'Contactos existentes: ' || COUNT(*) as info FROM contactos WHERE activo = 'Y';
SELECT 'Categorías existentes: ' || COUNT(*) as info FROM categorias WHERE activo = 'Y';
SELECT 'Registros en historial: ' || COUNT(*) as info FROM historial_cambios;

-- Verificar campos nuevos
SELECT 'Campo descripcion_evento: ' || 
       CASE WHEN COUNT(*) > 0 THEN 'EXISTE' ELSE 'NO EXISTE' END as resultado
FROM user_tab_columns 
WHERE table_name = 'CONTACTOS' AND column_name = 'DESCRIPCION_EVENTO';

COMMIT;

-- ================================================================
-- MENSAJE FINAL
-- ================================================================

SELECT 'ACTUALIZACIÓN COMPLETADA EXITOSAMENTE' as mensaje,
       'Tus contactos existentes están preservados' as nota,
       'Fecha: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') as fecha_actualizacion
FROM dual;

-- ================================================================
-- INSTRUCCIONES:
-- 1. Ejecuta este script en tu base de datos existente
-- 2. Conservará todos tus contactos actuales
-- 3. Agregará los nuevos campos necesarios
-- 4. Configurará las secuencias correctamente
-- 5. Instalará los triggers para nuevas funcionalidades
-- ================================================================
