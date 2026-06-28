#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Exequiel Trujillo <exequiel.trujillo@ug.uchile.cl>
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Renombra el applicationId / paquete de la app en TODOS los sitios derivados.
# El applicationId es prácticamente inmutable tras publicar, así que esta es la
# forma segura de fijarlo (o cambiarlo) una sola vez sin olvidar ningún archivo.
#
# Uso:
#   tool/rename_app_id.sh <nuevo.application.id>
# Ejemplo:
#   tool/rename_app_id.sh io.github.miusuario.kalendaryo
#
# No usa red. Idempotente: si el id ya coincide, no hace nada.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# --- Fuente única de verdad: lee el id actual desde tool/.app_id ---
ID_FILE="tool/.app_id"
OLD_ID="$(cat "$ID_FILE" 2>/dev/null || echo "com.example.app")"
NEW_ID="${1:-}"

if [[ -z "$NEW_ID" ]]; then
  echo "ERROR: falta el nuevo applicationId." >&2
  echo "Uso: tool/rename_app_id.sh <nuevo.application.id>" >&2
  exit 1
fi

# Validación: minúsculas, segmentos separados por puntos, sin guiones.
if [[ ! "$NEW_ID" =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]]; then
  echo "ERROR: '$NEW_ID' no es un applicationId válido (reverse-DNS, minúsculas)." >&2
  exit 1
fi

if [[ "$OLD_ID" == "$NEW_ID" ]]; then
  echo "El applicationId ya es '$NEW_ID'. Nada que hacer."
  exit 0
fi

OLD_PATH="${OLD_ID//.//}"   # p.ej. com.example.app -> com/example/app
NEW_PATH="${NEW_ID//.//}"

echo "Renombrando: $OLD_ID  ->  $NEW_ID"

# 1) Mueve el árbol de fuentes Kotlin al nuevo paquete.
KOTLIN_ROOT="android/app/src/main/kotlin"
if [[ -d "$KOTLIN_ROOT/$OLD_PATH" ]]; then
  mkdir -p "$KOTLIN_ROOT/$(dirname "$NEW_PATH")"
  git mv "$KOTLIN_ROOT/$OLD_PATH" "$KOTLIN_ROOT/$NEW_PATH" 2>/dev/null \
    || mv "$KOTLIN_ROOT/$OLD_PATH" "$KOTLIN_ROOT/$NEW_PATH"
  # Limpia directorios padres vacíos del viejo paquete.
  find "$KOTLIN_ROOT" -type d -empty -delete 2>/dev/null || true
fi

# 2) Reemplaza el identificador en el contenido de archivos relevantes.
#    (paquetes Kotlin, FQN en el puente Dart, build.gradle, metadatos, docs)
grep -rIl --exclude-dir=.git --exclude='.app_id' \
     --exclude='rename_app_id.sh' "$OLD_ID" . \
  | while IFS= read -r f; do
      sed -i "s|$OLD_ID|$NEW_ID|g" "$f"
      echo "  actualizado: $f"
    done

# 3) Renombra la receta de F-Droid: metadata/<appId>.yml
if [[ -f "metadata/$OLD_ID.yml" ]]; then
  git mv "metadata/$OLD_ID.yml" "metadata/$NEW_ID.yml" 2>/dev/null \
    || mv "metadata/$OLD_ID.yml" "metadata/$NEW_ID.yml"
  echo "  renombrado: metadata/$NEW_ID.yml"
fi

# 4) Persiste el nuevo id como fuente de verdad.
echo "$NEW_ID" > "$ID_FILE"

echo "Hecho. applicationId fijado en '$NEW_ID'."
echo "Recuerda: 'flutter clean' antes del próximo build."
