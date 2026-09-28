#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST="127.0.0.1"
PORT="5173"
SETUP_ONLY=false

usage() {
  cat <<'EOF'
Usage: ./run.sh [options]

Install the frontend dependencies when needed and start the local Vue app.

Options:
  --host HOST     Address Vite binds to (default: 127.0.0.1)
  --port PORT     Port Vite listens on (default: 5173)
  --setup-only    Install dependencies without starting the server
  -h, --help      Show this help message

The backend is expected at http://127.0.0.1:5000 by default.
EOF
}

while (($#)); do
  case "$1" in
    --host)
      [[ $# -ge 2 ]] || { echo "Error: --host requires a value." >&2; exit 2; }
      HOST="$2"
      shift 2
      ;;
    --port)
      [[ $# -ge 2 ]] || { echo "Error: --port requires a value." >&2; exit 2; }
      PORT="$2"
      shift 2
      ;;
    --setup-only)
      SETUP_ONLY=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown option '$1'." >&2
      usage >&2
      exit 2
      ;;
  esac
done

command -v node >/dev/null 2>&1 || {
  echo "Error: Node.js is required but was not found." >&2
  exit 1
}

command -v npm >/dev/null 2>&1 || {
  echo "Error: npm is required but was not found." >&2
  exit 1
}

cd "$ROOT_DIR"

if [[ ! -d node_modules ]]; then
  echo "Installing frontend dependencies..."
  npm ci
else
  echo "Frontend dependencies are ready."
fi

if [[ "$SETUP_ONLY" == true ]]; then
  echo "Setup complete."
  exit 0
fi

echo "Starting Atelier at http://${HOST}:${PORT}"
echo "Make sure the backend is running at http://127.0.0.1:5000"
exec npm run dev -- --host "$HOST" --port "$PORT"
