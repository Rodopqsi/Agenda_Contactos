import cx_Oracle
import os
from datetime import datetime

class DatabaseManager:
    def __init__(self):
        self.username = os.getenv('ORACLE_USER', 'system')
        self.password = os.getenv('ORACLE_PASSWORD', 'oracle')
        self.dsn = os.getenv('ORACLE_DSN', 'localhost:1521/xepdb1')
        
    def get_connection(self):
        try:
            connection = cx_Oracle.connect(
                user=self.username,
                password=self.password,
                dsn=self.dsn
            )
            return connection
        except cx_Oracle.Error as error:
            print(f"Error conectando a Oracle: {error}")
            return None
    

    def obtener_todas_categorias(self):
        conn = self.get_connection()
        if not conn:
            return []
        
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT id_categoria, nombre_categoria FROM categorias ORDER BY nombre_categoria")
            categorias = cursor.fetchall()
            return categorias
        except Exception as e:
            print(f"Error obteniendo categorías: {e}")
            return []
        finally:
            conn.close()
    
    def obtener_todos_contactos(self):
        conn = self.get_connection()
        if not conn:
            return []
        
        try:
            cursor = conn.cursor()
            query = """
                SELECT c.id_contacto, c.nombre, c.apellido, c.telefono, 
                       c.correo, cat.nombre_categoria, c.fecha_evento, c.descripcion_evento
                FROM contactos c
                JOIN categorias cat ON c.id_categoria = cat.id_categoria
                ORDER BY c.nombre, c.apellido
            """
            cursor.execute(query)
            contactos = cursor.fetchall()
            return contactos
        except Exception as e:
            print(f"Error obteniendo contactos: {e}")
            return []
        finally:
            conn.close()
    
    def buscar_contactos(self, termino):
        conn = self.get_connection()
        if not conn:
            return []
        
        try:
            cursor = conn.cursor()
            ref_cursor = cursor.var(cx_Oracle.CURSOR)
            cursor.callproc("buscar_contacto", [termino, ref_cursor])
            
            result_cursor = ref_cursor.getvalue()
            contactos = result_cursor.fetchall()
            result_cursor.close()
            
            return contactos
        except Exception as e:
            print(f"Error buscando contactos: {e}")
            return []
        finally:
            conn.close()
    
    def obtener_contactos_categoria(self, categoria_id):
        conn = self.get_connection()
        if not conn:
            return []
        
        try:
            cursor = conn.cursor()
            
            # Usar la misma estructura que obtener_todos_contactos
            query = """
                SELECT c.id_contacto, c.nombre, c.apellido, c.telefono, 
                       c.correo, cat.nombre_categoria, c.fecha_evento, c.descripcion_evento
                FROM contactos c
                JOIN categorias cat ON c.id_categoria = cat.id_categoria
                WHERE c.id_categoria = :categoria_id
                ORDER BY c.nombre, c.apellido
            """
            cursor.execute(query, {'categoria_id': categoria_id})
            contactos = cursor.fetchall()
            return contactos
            
        except Exception as e:
            print(f"Error obteniendo contactos por categoría: {e}")
            return []
        finally:
            conn.close()
    
    def obtener_recordatorios_hoy(self):
        conn = self.get_connection()
        if not conn:
            return []
    
        try:
            cursor = conn.cursor()
            result_cursor = cursor.callfunc("obtener_recordatorios_hoy", cx_Oracle.CURSOR)
            recordatorios = result_cursor.fetchall()
            result_cursor.close()
            return recordatorios
        except Exception as e:
            print(f"Error obteniendo recordatorios: {e}")
            return []
        finally:
            conn.close()

    
    def obtener_eventos_semana(self):
        conn = self.get_connection()
        if not conn:
            return []
    
        try:
            cursor = conn.cursor()
            result_cursor = cursor.callfunc("obtener_eventos_semana", cx_Oracle.CURSOR)
            eventos = result_cursor.fetchall()
            result_cursor.close()
            return eventos
        except Exception as e:
            print(f"Error obteniendo eventos de la semana: {e}")
            return []
        finally:
            conn.close()

    
    def agregar_contacto(self, nombre, apellido, telefono, correo, categoria, fecha_evento=None, descripcion_evento=None):
        conn = self.get_connection()
        if not conn:
            return False
        
        try:
            cursor = conn.cursor()
            resultado = cursor.var(cx_Oracle.NUMBER)
            if fecha_evento and isinstance(fecha_evento, str):
                fecha_evento = datetime.strptime(fecha_evento, '%Y-%m-%d').date()
            
            cursor.callproc("agregar_contacto", [
                nombre, apellido, telefono, correo, categoria, fecha_evento, descripcion_evento, resultado
            ])
            
            return resultado.getvalue() > 0
        except Exception as e:
            print(f"Error agregando contacto: {e}")
            return False
        finally:
            conn.close()
    
    def actualizar_contacto(self, contacto_id, nombre, apellido, telefono, correo, categoria, fecha_evento=None, descripcion_evento=None):
        conn = self.get_connection()
        if not conn:
            return False
        
        try:
            cursor = conn.cursor()
            resultado = cursor.var(cx_Oracle.NUMBER)

            if fecha_evento and isinstance(fecha_evento, str):
                fecha_evento = datetime.strptime(fecha_evento, '%Y-%m-%d').date()
            
            cursor.callproc("actualizar_contacto", [
                contacto_id, nombre, apellido, telefono, correo, categoria, fecha_evento, descripcion_evento, resultado
            ])
            
            return resultado.getvalue() > 0
        except Exception as e:
            print(f"Error actualizando contacto: {e}")
            return False
        finally:
            conn.close()
    
    def eliminar_contacto(self, contacto_id):
        conn = self.get_connection()
        if not conn:
            return False
        
        try:
            cursor = conn.cursor()
            resultado = cursor.var(cx_Oracle.NUMBER)
            cursor.callproc("eliminar_contacto", [contacto_id, resultado])
            
            return resultado.getvalue() > 0
        except Exception as e:
            print(f"Error eliminando contacto: {e}")
            return False
        finally:
            conn.close()
    
    def obtener_historial_cambios(self, limite=10):
        conn = self.get_connection()
        if not conn:
            return []
        
        try:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT descripcion, fecha 
                FROM historial_cambios 
                ORDER BY fecha DESC 
                FETCH FIRST :limite ROWS ONLY
            """, [limite])
            
            historial = cursor.fetchall()
            return historial
        except Exception as e:
            print(f"Error obteniendo historial: {e}")
            return []
        finally:
            conn.close()
    


    
    def agregar_categoria(self, nombre):
        conn = self.get_connection()
        if not conn:
            return {'success': False, 'error': 'Error de conexión'}

        try:
            cursor = conn.cursor()
            resultado = cursor.var(cx_Oracle.NUMBER)
            cursor.callproc("agregar_categoria", [nombre, resultado])
            conn.commit()

            valor = resultado.getvalue()
            if valor == -2:
                return {'success': False, 'error': 'La categoría ya existe'}
            elif valor == -1:
                return {'success': False, 'error': 'Error al crear categoría'}
            else:
                return {'success': True, 'id': valor}
        except Exception as e:
            conn.rollback()
            print(f"Error agregando categoría: {e}")
            return {'success': False, 'error': str(e)}
        finally:
            conn.close()

    def actualizar_categoria(self, categoria_id, nombre):
        conn = self.get_connection()
        if not conn:
            return {'success': False, 'error': 'Error de conexión'}

        try:
            cursor = conn.cursor()
            resultado = cursor.var(cx_Oracle.NUMBER)
            cursor.callproc("agregar_categoria", [nombre, resultado])

            # AGREGAR COMMIT
            conn.commit()

            valor = resultado.getvalue()
            if valor == -2:
                return {'success': False, 'error': 'La categoría ya existe'}
            elif valor == -1:
                return {'success': False, 'error': 'Error al crear categoría'}
            else:
                return {'success': True, 'id': valor}
        except Exception as e:
            conn.rollback()
            print(f"Error agregando categoría: {e}")
            return {'success': False, 'error': str(e)}
        finally:
            conn.close()

    def eliminar_categoria(self, categoria_id):
        conn = self.get_connection()
        if not conn:
            return {'success': False, 'error': 'Error de conexión'}

        try:
            cursor = conn.cursor()
            resultado = cursor.var(cx_Oracle.NUMBER)
            cursor.callproc("eliminar_categoria", [categoria_id, resultado])
            conn.commit()

            valor = resultado.getvalue()
            if valor == -2:
                return {'success': False, 'error': 'No se puede eliminar: tiene contactos asociados'}
            elif valor == -3:
                return {'success': False, 'error': 'No se puede eliminar: categoría del sistema'}
            elif valor == -1:
                return {'success': False, 'error': 'Error al eliminar categoría'}
            elif valor == 0:
                return {'success': False, 'error': 'Categoría no encontrada'}
            else:
                return {'success': True}
        except Exception as e:
            # AGREGAR ROLLBACK
            conn.rollback()
            print(f"Error eliminando categoría: {e}")
            return {'success': False, 'error': str(e)}
        finally:
            conn.close()

    def obtener_categoria_por_id(self, categoria_id):
        conn = self.get_connection()
        if not conn:
            return None

        try:
            cursor = conn.cursor()
            cursor.execute("SELECT id_categoria, nombre_categoria FROM categorias WHERE id_categoria = :1", [categoria_id])
            categoria = cursor.fetchone()
            return categoria
        except Exception as e:
            print(f"Error obteniendo categoría: {e}")
            return None
        finally:
            conn.close()

    def contar_contactos_por_categoria(self, categoria_id):
        conn = self.get_connection()
        if not conn:
            return 0

        try:
            cursor = conn.cursor()
            cursor.execute("SELECT COUNT(*) FROM contactos WHERE id_categoria = :1", [categoria_id])
            count = cursor.fetchone()[0]
            return count
        except Exception as e:
            print(f"Error contando contactos: {e}")
            return 0
        finally:
            conn.close()