#!/bin/bash
# Script para limpiar archivos .md innecesarios

echo "=== Limpieza de archivos .md de desarrollo ==="

# Archivos que se pueden eliminar
archivos_eliminar=(
    "SOLUCION_FILTRADO_CATEGORIA.md"
    "CORRECCION_FILTRADO_CATEGORIA.md"
    "CORRECTIONS_LOG.md"
    "EVENTOS_DESCRIPCION.md"
)

for archivo in "${archivos_eliminar[@]}"; do
    if [ -f "$archivo" ]; then
        echo "Eliminando: $archivo"
        rm "$archivo"
    else
        echo "No encontrado: $archivo"
    fi
done

echo ""
echo "=== Archivos .md restantes ==="
ls -la *.md 2>/dev/null || echo "No hay archivos .md restantes"

echo ""
echo "=== Limpieza completada ==="
echo "Archivos conservados recomendados:"
echo "  - README.md o README_V2.1.md (elige uno)"
echo "  - REGLAS_DEL_NEGOCIO.md (útil para mantenimiento)"
