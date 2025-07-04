# Script PowerShell para limpiar TODOS los archivos innecesarios

Write-Host "=== LIMPIEZA COMPLETA DEL PROYECTO ===" -ForegroundColor Green

# Archivos de prueba/debug (ELIMINAR)
$archivos_prueba = @(
    "debug_categoria.py",
    "test_app.py",
    "test_filtro_categoria.py", 
    "test_simple.py",
    "verificar_columnas.py",
    "verificar_estructura.py"
)

# Scripts de limpieza (ELIMINAR)
$archivos_limpieza = @(
    "limpiar_md.ps1",
    "limpiar_md.sh"
)

# Documentación de desarrollo (OPCIONAL - descomenta para eliminar)
$archivos_documentacion = @(
    # "SOLUCION_FILTRADO_CATEGORIA.md"
)

# Scripts SQL opcionales (OPCIONAL - descomenta para eliminar)  
$archivos_sql_opcionales = @(
    # "crear_procedimiento_categoria.sql",
    # "actualizar_base_existente.sql"
)

Write-Host "`n1. Eliminando archivos de prueba/debug..." -ForegroundColor Yellow
foreach ($archivo in $archivos_prueba) {
    if (Test-Path $archivo) {
        Write-Host "   Eliminando: $archivo" -ForegroundColor Red
        Remove-Item $archivo
    } else {
        Write-Host "   No encontrado: $archivo" -ForegroundColor Gray
    }
}

Write-Host "`n2. Eliminando scripts de limpieza..." -ForegroundColor Yellow
foreach ($archivo in $archivos_limpieza) {
    if (Test-Path $archivo) {
        Write-Host "   Eliminando: $archivo" -ForegroundColor Red
        Remove-Item $archivo
    } else {
        Write-Host "   No encontrado: $archivo" -ForegroundColor Gray
    }
}

Write-Host "`n3. Limpiando cache de Python..." -ForegroundColor Yellow
if (Test-Path "__pycache__") {
    Write-Host "   Eliminando: __pycache__" -ForegroundColor Red
    Remove-Item "__pycache__" -Recurse -Force
}

Write-Host "`n=== ARCHIVOS RESTANTES ===" -ForegroundColor Green
Get-ChildItem -Name | Where-Object { $_ -notlike ".*" -and $_ -ne "venv" } | Sort-Object

Write-Host "`n=== LIMPIEZA COMPLETADA ===" -ForegroundColor Green
Write-Host "✅ Archivos eliminados: Scripts de prueba, debug y limpieza" -ForegroundColor Cyan
Write-Host "✅ Archivos conservados: Aplicación principal y documentación importante" -ForegroundColor Cyan
Write-Host "📁 Directorios conservados: .git, venv, static, templates" -ForegroundColor Cyan

Write-Host "`n📋 ARCHIVOS PRINCIPALES RESTANTES:" -ForegroundColor Yellow
Write-Host "   app.py                          ← Aplicación Flask" -ForegroundColor White
Write-Host "   database.py                     ← Base de datos" -ForegroundColor White  
Write-Host "   requirements.txt                ← Dependencias" -ForegroundColor White
Write-Host "   README.md                       ← Documentación" -ForegroundColor White
Write-Host "   REGLAS_DEL_NEGOCIO.md           ← Reglas del negocio" -ForegroundColor White
Write-Host "   database_complete_plsql.sql     ← Script completo de BD" -ForegroundColor White
Write-Host "   database_update_eventos.sql     ← Actualización de eventos" -ForegroundColor White
