# Script PowerShell para limpiar archivos .md innecesarios

Write-Host "=== Limpieza de archivos .md de desarrollo ===" -ForegroundColor Green

# Archivos que se pueden eliminar
$archivos_eliminar = @(
    "SOLUCION_FILTRADO_CATEGORIA.md",
    "CORRECCION_FILTRADO_CATEGORIA.md",
    "CORRECTIONS_LOG.md",
    "EVENTOS_DESCRIPCION.md"
)

foreach ($archivo in $archivos_eliminar) {
    if (Test-Path $archivo) {
        Write-Host "Eliminando: $archivo" -ForegroundColor Yellow
        Remove-Item $archivo
    } else {
        Write-Host "No encontrado: $archivo" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "=== Archivos .md restantes ===" -ForegroundColor Green
Get-ChildItem *.md -ErrorAction SilentlyContinue | Format-Table Name, Length, LastWriteTime

Write-Host ""
Write-Host "=== Limpieza completada ===" -ForegroundColor Green
Write-Host "Archivos conservados recomendados:" -ForegroundColor Cyan
Write-Host "  - README.md o README_V2.1.md (elige uno)" -ForegroundColor White
Write-Host "  - REGLAS_DEL_NEGOCIO.md (útil para mantenimiento)" -ForegroundColor White
