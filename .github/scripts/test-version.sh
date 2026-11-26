#!/usr/bin/env bash
# Tests de calcular-version.sh y version-actual.sh. Sin dependencias: bash y git.
# Uso: bash .github/scripts/test-version.sh   (sale con 1 si algun caso falla)
set -uo pipefail

dir="$(cd "$(dirname "$0")" && pwd)"
fallas=0

caso() { # caso <descripcion> <esperado> <comando...>
  local desc="$1" esperado="$2"; shift 2
  local obtenido
  obtenido=$("$@" 2>&1 | tr '\n' ' ' | sed 's/ $//')
  if [ "$obtenido" = "$esperado" ]; then echo "ok   - $desc"
  else echo "FAIL - $desc"; echo "       esperado: $esperado"; echo "       obtenido: $obtenido"; fallas=$((fallas + 1)); fi
}
falla() { # falla <descripcion> <comando...>: tiene que salir con error
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "FAIL - $desc (no dio error)"; fallas=$((fallas + 1)); else echo "ok   - $desc"; fi
}

cv="$dir/calcular-version.sh"
caso "bugfix"                    "version=1.1.3 versionCode=11" bash "$cv" bugfix 1.1.2 10
caso "feature"                   "version=1.2.0 versionCode=11" bash "$cv" feature 1.1.2 10
caso "breaking"                  "version=2.0.0 versionCode=11" bash "$cv" breaking 1.1.2 10
caso "repo nuevo (0.0.0), feature" "version=0.1.0 versionCode=1" bash "$cv" feature 0.0.0 0
caso "patch de dos digitos"      "version=1.0.10 versionCode=21" bash "$cv" bugfix 1.0.9 20
falla "tipo invalido"            bash "$cv" raro 1.2.0 21
falla "version con sufijo"       bash "$cv" bugfix 1.2.0-rc.1 5
falla "version mal formada"      bash "$cv" bugfix 1.2 5
falla "versionCode no numerico"  bash "$cv" bugfix 1.2.0 abc

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
( cd "$tmp" && git init -q . && git -c user.name=t -c user.email=t@t commit -q --allow-empty -m inicial ) >/dev/null
va() { (cd "$tmp" && bash "$dir/version-actual.sh" "$@"); }
caso "sin tags: valores por defecto"  "versionName=0.0.0 versionCode=0" va
caso "sin tags: valores recibidos"    "versionName=1.1.2 versionCode=20109" va 1.1.2 20109
(cd "$tmp" && git tag 1.0.0 && git -c user.name=t -c user.email=t@t tag -a viejo -m "release viejo")
caso "ignora tags livianos y anotados sin versionCode" "versionName=0.0.0 versionCode=0" va
(cd "$tmp" && for t in "1.1.3 20110" "1.2.0 20112" "1.1.4 20111"; do
  set -- $t; git -c user.name=t -c user.email=t@t tag -a "$1" -m "versionCode=$2"; done)
caso "toma el tag con mayor versionCode" "versionName=1.2.0 versionCode=20112" va 9.9.9 1

echo
if [ "$fallas" -gt 0 ]; then echo "❌ $fallas caso(s) fallaron"; exit 1; fi
echo "✅ todos los casos pasaron"
