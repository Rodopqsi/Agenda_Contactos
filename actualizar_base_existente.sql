SELECT column_name 
FROM user_tab_columns 
WHERE table_name = 'CONTACTOS' 
AND column_name = 'DESCRIPCION_EVENTO';

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
    END IF;
END;
/

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
    END IF;
END;
/

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
    END IF;
END;
/

UPDATE contactos 
SET activo = 'Y' 
WHERE activo IS NULL;

UPDATE categorias 
SET activo = 'Y' 
WHERE activo IS NULL;

COMMIT;

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
    END IF;
END;
/

DECLARE
    v_max_id NUMBER;
    v_seq_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_seq_exists FROM user_sequences WHERE sequence_name = 'SEQ_CONTACTO_ID';
    SELECT NVL(MAX(id_contacto), 0) + 1 INTO v_max_id FROM contactos;
    IF v_seq_exists > 0 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE seq_contacto_id';
    END IF;
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_contacto_id START WITH ' || v_max_id || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;
/

DECLARE
    v_max_id NUMBER;
    v_seq_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_seq_exists FROM user_sequences WHERE sequence_name = 'SEQ_CATEGORIA_ID';
    SELECT GREATEST(NVL(MAX(id_categoria), 4) + 1, 5) INTO v_max_id FROM categorias;
    IF v_seq_exists > 0 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE seq_categoria_id';
    END IF;
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_categoria_id START WITH ' || v_max_id || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;
/

DECLARE
    v_max_id NUMBER;
    v_seq_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_seq_exists FROM user_sequences WHERE sequence_name = 'SEQ_HISTORIAL_ID';
    SELECT NVL(MAX(id_historial), 0) + 1 INTO v_max_id FROM historial_cambios;
    IF v_seq_exists > 0 THEN
        EXECUTE IMMEDIATE 'DROP SEQUENCE seq_historial_id';
    END IF;
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_historial_id START WITH ' || v_max_id || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;
/

DECLARE
    v_index_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_index_exists FROM user_indexes WHERE index_name = 'IDX_CONTACTOS_DESCRIPCION';
    IF v_index_exists = 0 THEN
        EXECUTE IMMEDIATE 'CREATE INDEX idx_contactos_descripcion ON contactos(descripcion_evento)';
    END IF;
    SELECT COUNT(*) INTO v_index_exists FROM user_indexes WHERE index_name = 'IDX_CONTACTOS_ACTIVO';
    IF v_index_exists = 0 THEN
        EXECUTE IMMEDIATE 'CREATE INDEX idx_contactos_activo ON contactos(activo)';
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_contactos_id
    BEFORE INSERT ON contactos
    FOR EACH ROW
BEGIN
    IF :NEW.id_contacto IS NULL THEN
        :NEW.id_contacto := seq_contacto_id.NEXTVAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_contactos_modificacion
    BEFORE UPDATE ON contactos
    FOR EACH ROW
BEGIN
    :NEW.fecha_modificacion := SYSDATE;
END;
/

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

INSERT INTO historial_cambios (descripcion, tipo_operacion, tabla_afectada)
VALUES ('Base de datos actualizada con nuevos campos y funcionalidades', 'UPDATE', 'SISTEMA');

SELECT 'Contactos existentes: ' || COUNT(*) as info FROM contactos WHERE activo = 'Y';
SELECT 'Categorías existentes: ' || COUNT(*) as info FROM categorias WHERE activo = 'Y';
SELECT 'Registros en historial: ' || COUNT(*) as info FROM historial_cambios;

SELECT 'Campo descripcion_evento: ' || 
       CASE WHEN COUNT(*) > 0 THEN 'EXISTE' ELSE 'NO EXISTE' END as resultado
FROM user_tab_columns 
WHERE table_name = 'CONTACTOS' AND column_name = 'DESCRIPCION_EVENTO';

COMMIT;

SELECT 'ACTUALIZACIÓN COMPLETADA EXITOSAMENTE' as mensaje,
       'Tus contactos existentes están preservados' as nota,
       'Fecha: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') as fecha_actualizacion
FROM dual;
