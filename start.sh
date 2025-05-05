#!/usr/bin/env bash
set -euo pipefail

# --- 0. Detectar SO y arquitectura ---
OS="$(uname -s)"
ARCH="$(uname -m)"

echo "🖥  Detectado: SO=$OS, ARQ=$ARCH"

# Funciones de instalación por plataforma
install_python_linux() {
  echo "⚙️ Instalando Python3 en Linux (apt)..."
  sudo apt update
  sudo apt install -y python3 python3-venv python3-pip
}

install_python_mac() {
  echo "⚙️ Instalando Python3 en macOS (Homebrew)..."
  if ! command -v brew &> /dev/null; then
    echo "  Homebrew no encontrado. Instálalo desde https://brew.sh/"
    exit 1
  fi
  brew update
  brew install python
}

warn_windows_python() {
  echo "⚠️ En Windows instala Python 3.8+ desde https://python.org/downloads/windows/ y asegúrate de activar 'Add to PATH'."
}

# --- 1. Detectar python3 o py en Windows ---
PYTHON_BIN=""
if command -v python3 &> /dev/null; then
  PYTHON_BIN=python3
elif [[ "$OS" =~ MINGW|CYGWIN|MSYS ]] && command -v py &> /dev/null; then
  PYTHON_BIN="py -3"
fi

if [[ -z "$PYTHON_BIN" ]]; then
  echo "⚠️ Python3 no encontrado."
  case "$OS" in
    Linux*)   install_python_linux ;;
    Darwin*)  install_python_mac ;;
    MINGW*|MSYS*|CYGWIN*) warn_windows_python ;;
    *)        echo "  SO no reconocido, instala Python 3 manualmente." && exit 1 ;;
  esac
  # Tras la instalación, volvemos a buscar python3
  if command -v python3 &> /dev/null; then
    PYTHON_BIN=python3
  elif command -v py &> /dev/null; then
    PYTHON_BIN="py -3"
  else
    echo "❌ No se pudo encontrar Python tras la instalación." && exit 1
  fi
fi
echo "🐍 Usando intérprete: $PYTHON_BIN"

# --- 2. Comprobar venv disponible ---
if ! $PYTHON_BIN -m venv --help &> /dev/null; then
  echo "⚠️ El módulo venv no está disponible."
  case "$OS" in
    Linux*)   echo "   sudo apt install python3-venv" ;;
    Darwin*)  echo "   brew install python" ;;
    MINGW*|MSYS*|CYGWIN*) echo "   Asegúrate de que en el instalador de Windows marcaste 'venv'." ;;
  esac
  exit 1
fi

# --- 3. Ir al directorio del script ---
cd "$(dirname "$0")"

# --- 4. Clonar el repo si falta ---
if [[ ! -d "gitingest" ]]; then
  echo "🔵 Clonando gitingest..."
  git clone https://github.com/cyclotruc/gitingest.git
fi
cd gitingest

# --- 5. Crear entorno virtual ---
if [[ ! -d ".venv" ]]; then
  echo "🔵 Creando entorno virtual..."
  $PYTHON_BIN -m venv .venv
fi

# --- 6. Activar el virtualenv ---
echo "🔵 Activando entorno virtual..."
case "$OS" in
  Linux*|Darwin*)
    # En macOS y Linux
    # shellcheck disable=SC1091
    source .venv/bin/activate
    ;;
  MINGW*|MSYS*|CYGWIN*)
    # En Windows (Git Bash, etc.)
    # shellcheck disable=SC1091
    source .venv/Scripts/activate
    ;;
  *)
    echo "⚠️ SO desconocido: intentando activar bin/activate"
    source .venv/bin/activate
    ;;
esac

# --- 7. Instalar dependencias ---
echo "🔵 Instalando dependencias..."
pip install --upgrade pip
pip install -r requirements.txt

# --- 8. Ir a src ---
cd src

# --- 9. Levantar servidor Uvicorn ---
echo "🟢 Levantando servidor en http://localhost:8000 ..."
uvicorn server.main:app \
  --host 0.0.0.0 \
  --port 8000 \
  --reload &
UVICORN_PID=$!

# --- 10. Esperar un momento ---
sleep 2

# --- 11. Abrir navegador automáticamente ---
if command -v xdg-open &> /dev/null; then
  xdg-open http://localhost:8000
elif command -v open &> /dev/null; then
  open http://localhost:8000
else
  echo "🌐 Abre manualmente tu navegador en http://localhost:8000"
fi

# --- 12. Mantener Uvicorn vivo hasta Ctrl+C ---
wait $UVICORN_PID
