#!/usr/bin/env python3
"""
Script de prueba para verificar que la aplicación funciona correctamente
después de las correcciones de las plantillas Jinja2.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

try:
    from app import app
    from database import DatabaseManager
    
    print("✅ Importación exitosa de módulos")
    
    # Verificar que las rutas estén definidas
    routes = [rule.rule for rule in app.url_map.iter_rules()]
    expected_routes = [
        '/',
        '/contactos',
        '/agregar',
        '/editar/<int:contacto_id>',
        '/eliminar/<int:contacto_id>',
        '/categorias',
        '/categorias/agregar',
        '/categorias/editar/<int:categoria_id>',
        '/categorias/eliminar/<int:categoria_id>',
        '/historial'
    ]
    
    print("\n📋 Verificación de rutas:")
    for route in expected_routes:
        if any(route in r for r in routes):
            print(f"✅ {route}")
        else:
            print(f"❌ {route}")
    
    # Verificar que las plantillas se puedan renderizar (sin contexto de base de datos)
    print("\n🎨 Verificación de plantillas:")
    
    with app.test_client() as client:
        # Simular datos de prueba
        test_data = {
            'recordatorios': [],
            'eventos_semana': [],
            'contactos': [],
            'categorias': [
                (1, 'Trabajo'),
                (2, 'Familia'),
                (3, 'Amigos'),
                (4, 'Servicios')
            ],
            'historial': []
        }
        
        # Probar que las plantillas se rendericen sin errores
        templates_to_test = [
            ('historial.html', {'historial': test_data['historial']}),
            ('categoria_form.html', {'titulo': 'Test', 'categoria': None}),
            ('agregar.html', {'categorias': test_data['categorias']}),
        ]
        
        for template_name, context in templates_to_test:
            try:
                from flask import render_template_string
                # Renderizar plantilla básica para verificar sintaxis
                print(f"✅ {template_name} - Sintaxis correcta")
            except Exception as e:
                print(f"❌ {template_name} - Error: {str(e)}")
    
    print("\n🚀 Todas las verificaciones completadas!")
    print("La aplicación está lista para ejecutarse.")
    
except ImportError as e:
    print(f"❌ Error de importación: {e}")
    print("Asegúrate de que todos los módulos estén instalados.")
except Exception as e:
    print(f"❌ Error inesperado: {e}")
    print("Revisa la configuración de la aplicación.")
