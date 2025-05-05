#!/usr/bin/env bash
set -euo pipefail

# --- 0. Detectar python3 ---
if ! command -v python3 &> /dev/null; then
  echo "⚠️ Python3 no está instalado."
  echo "   Instálalo con: sudo apt update && sudo apt install python3"
  exit 1
fi
PYTHON_BIN=python3

# --- 1. Comprobar que python -m venv funciona ---
if ! $PYTHON_BIN -m venv --help &> /dev/null; then
  echo "⚠️ No se puede crear el entorno virtual: módulo venv no disponible."
  echo "   Instálalo con: sudo apt update && sudo apt install python3-venv"
  exit 1
fi

# --- 2. Ir al directorio del script ---
cd "$(dirname "$0")"

# --- 3. Clonar el repositorio si no existe ---
if [[ ! -d "gitingest" ]]; then
  echo "🔵 Clonando gitingest..."
  git clone https://github.com/cyclotruc/gitingest.git
fi
cd gitingest

# --- 4. Crear entorno virtual si hace falta ---
if [[ ! -d ".venv" ]]; then
  echo "🔵 Creando entorno virtual..."
  $PYTHON_BIN -m venv .venv
fi

# --- 5. Activar el virtualenv ---
echo "🔵 Activando entorno virtual..."
# shellcheck disable=SC1091
source .venv/bin/activate

# --- 6. Instalar dependencias ---
echo "🔵 Instalando dependencias..."
pip install --upgrade pip
pip install -r requirements.txt

# --- 7. Ir a src ---
cd src

# --- 8. Levantar Uvicorn en segundo plano ---
echo "🟢 Levantando servidor en http://localhost:8000 ..."
uvicorn server.main:app \
  --host 0.0.0.0 \
  --port 8000 \
  --reload &
UVICORN_PID=$!

# --- 9. Esperar un momento ---
sleep 2

# --- 10. Abrir navegador ---
if command -v xdg-open &> /dev/null; then
  echo "🌐 Abriendo http://localhost:8000 en tu navegador..."
  xdg-open http://localhost:8000
else
  echo "🌐 Abre manualmente http://localhost:8000"
fi

# --- 11. Mantener Uvicorn vivo hasta Ctrl+C ---
wait $UVICORN_PID
