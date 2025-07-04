#!/usr/bin/env python
# -*- coding: utf-8 -*-

import database

def debug_update_procedure():
    try:
        db = database.DatabaseManager()
        print("Depurando procedimiento actualizar_contacto...")
        conn = db.get_connection()
        
        if conn:
            print("✓ Conexión exitosa")
            
            cursor = conn.cursor()
            
            # Obtener un contacto existente para probar
            print("\n--- Obteniendo contacto para depuración ---")
            cursor.execute("""
                SELECT c.id_contacto, c.nombre, c.apellido, c.id_categoria, cat.nombre_categoria, cat.activa
                FROM contactos c 
                LEFT JOIN categorias cat ON c.id_categoria = cat.id_categoria
                WHERE c.activo = 'Y' AND ROWNUM = 1
            """)
            contacto = cursor.fetchone()
            
            if contacto:
                contacto_id, nombre_orig, apellido_orig, categoria_id, categoria_nombre, categoria_activa = contacto
                print(f"✓ Contacto: ID={contacto_id}, {nombre_orig} {apellido_orig}")
                print(f"✓ Categoría: ID={categoria_id}, {categoria_nombre}, Activa={categoria_activa}")
                
                # Verificar que la categoría esté activa
                cursor.execute("SELECT COUNT(*) FROM categorias WHERE id_categoria = :1 AND activa = 1", [categoria_id])
                cat_count = cursor.fetchone()[0]
                print(f"✓ Categorías activas con ID {categoria_id}: {cat_count}")
                
                # Verificar que el contacto esté activo
                cursor.execute("SELECT COUNT(*) FROM contactos WHERE id_contacto = :1 AND activo = 'Y'", [contacto_id])
                cont_count = cursor.fetchone()[0]
                print(f"✓ Contactos activos con ID {contacto_id}: {cont_count}")
                
                if cat_count > 0 and cont_count > 0:
                    print("\n--- Intentando actualización manual ---")
                    try:
                        cursor.execute("""
                            UPDATE contactos 
                            SET apellido = :1,
                                fecha_modificacion = SYSDATE
                            WHERE id_contacto = :2 AND activo = 'Y'
                        """, [apellido_orig + " (Test)", contacto_id])
                        
                        rows_affected = cursor.rowcount
                        print(f"✓ Filas afectadas por UPDATE manual: {rows_affected}")
                        
                        if rows_affected > 0:
                            print("✓ UPDATE manual exitoso")
                            conn.commit()
                        else:
                            print("✗ UPDATE manual no afectó filas")
                            
                    except Exception as e:
                        print(f"✗ Error en UPDATE manual: {e}")
                        
                else:
                    print("✗ Datos inconsistentes para la prueba")
                
            else:
                print("✗ No se encontró ningún contacto para depuración")
            
            conn.close()
            return True
        else:
            print("✗ Error de conexión")
            return False
            
    except Exception as e:
        print(f"✗ Error: {e}")
        return False

if __name__ == "__main__":
    debug_update_procedure()
