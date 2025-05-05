#!/usr/bin/env bash
set -euo pipefail

# --- 0. Detectar SO y arquitectura ---
OS="$(uname -s)"
ARCH="$(uname -m)"
echo "🖥 Detectado: SO=$OS, ARQ=$ARCH"

# --- 1. Ir al directorio del script ---
cd "$(dirname "$0")"

TARGET_DIR="gitingest"
DIGEST_FILE="digest.txt"

# --- 2. Función de borrado (rm -rf) común ---
remove_unix() {
  local path="$1"
  if [[ -e "$path" ]]; then
    echo "🔴 Eliminando '$path'..."
    rm -rf "$path"
    echo "✅ '$path' eliminado."
  else
    echo "⚠️ No se encontró '$path', nada que borrar."
  fi
}

# --- 3. Ejecutar según SO ---
case "$OS" in
  Linux*|Darwin*|MINGW*|MSYS*|CYGWIN*)
    # En Linux, macOS o Git Bash en Windows usamos rm -rf
    remove_unix "$TARGET_DIR"
    remove_unix "$DIGEST_FILE"
    ;;
  *)
    echo "⚠️ SO no soportado por este script: $OS"
    echo "   Intenta borrar manualmente '$TARGET_DIR' y '$DIGEST_FILE'."
    ;;
esac

echo "🗑️ ¡Limpieza completa!"
