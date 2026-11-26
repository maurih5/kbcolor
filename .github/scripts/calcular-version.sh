#!/usr/bin/env bash
# Calcula la proxima version estable X.Y.Z del artefacto a publicar (solo main, sin rc).
#
# Uso: calcular-version.sh <tipo> <versionName actual> <versionCode actual>
#   tipo: bugfix | feature | breaking (etiqueta de la PR)
#   versionName/versionCode actuales: la ultima publicada (salida de version-actual.sh).
#
# Imprime "version=..." y "versionCode=..." (formato de $GITHUB_OUTPUT).
set -euo pipefail

tipo="${1:-bugfix}"
version_actual="${2:?falta versionName actual}"
code_actual="${3:?falta versionCode actual}"

error() { echo "❌ $*" >&2; exit 1; }

[[ "$code_actual" =~ ^[0-9]+$ ]] || error "versionCode '$code_actual' no es numerico"
[[ "$version_actual" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]] ||
  error "versionName '$version_actual' no tiene el formato X.Y.Z"
major=${BASH_REMATCH[1]} minor=${BASH_REMATCH[2]} patch=${BASH_REMATCH[3]}

case "$tipo" in
  bugfix)   patch=$(( patch + 1 )) ;;
  feature)  minor=$(( minor + 1 )); patch=0 ;;
  breaking) major=$(( major + 1 )); minor=0; patch=0 ;;
  *) error "tipo '$tipo' invalido (bugfix|feature|breaking)" ;;
esac

echo "version=$major.$minor.$patch"
echo "versionCode=$(( code_actual + 1 ))"
