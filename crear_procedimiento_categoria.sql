-- Crear procedimiento almacenado para obtener contactos por categoría
-- Este procedimiento debe existir en la base de datos Oracle

CREATE OR REPLACE PROCEDURE contactos_por_categoria(
    p_categoria_id IN NUMBER,
    p_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN p_cursor FOR
    SELECT c.id, c.nombre, c.apellido, c.telefono, c.correo, cat.nombre as categoria_nombre,
           c.fecha_evento, c.descripcion_evento
    FROM contactos c
    INNER JOIN categorias cat ON c.categoria_id = cat.id
    WHERE c.categoria_id = p_categoria_id
    ORDER BY c.nombre, c.apellido;
END contactos_por_categoria;
/

-- Verificar que el procedimiento se creó correctamente
SELECT procedure_name, status 
FROM user_procedures 
WHERE procedure_name = 'CONTACTOS_POR_CATEGORIA';

-- Probar el procedimiento
DECLARE
    v_cursor SYS_REFCURSOR;
    v_id NUMBER;
    v_nombre VARCHAR2(100);
    v_apellido VARCHAR2(100);
    v_telefono VARCHAR2(20);
    v_correo VARCHAR2(100);
    v_categoria VARCHAR2(100);
    v_fecha_evento DATE;
    v_descripcion VARCHAR2(255);
BEGIN
    -- Probar con categoría ID 1
    contactos_por_categoria(1, v_cursor);
    
    LOOP
        FETCH v_cursor INTO v_id, v_nombre, v_apellido, v_telefono, v_correo, v_categoria, v_fecha_evento, v_descripcion;
        EXIT WHEN v_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ', Nombre: ' || v_nombre || ' ' || v_apellido || ', Categoría: ' || v_categoria);
    END LOOP;
    
    CLOSE v_cursor;
END;
/
