#!/usr/bin/env bash
set -euo pipefail

# Ir al directorio donde está este script
cd "$(dirname "$0")"

TARGET_DIR="gitingest"

# 1. Eliminar la carpeta clonada
if [[ -d "$TARGET_DIR" ]]; then
  echo "🔴 Eliminando directorio '$TARGET_DIR'..."
  rm -rf "$TARGET_DIR"
  echo "✅ '$TARGET_DIR' eliminado."
else
  echo "⚠️ No se encontró '$TARGET_DIR', nada que borrar."
fi

# 2. Eliminar digest.txt (si existe)
if [[ -f "digest.txt" ]]; then
  echo "🔴 Eliminando 'digest.txt'..."
  rm -f "digest.txt"
  echo "✅ 'digest.txt' eliminado."
else
  echo "⚠️ No se encontró 'digest.txt'."
fi

echo "🗑️ ¡Limpieza completa!"
