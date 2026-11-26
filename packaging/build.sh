#!/bin/sh
# Compila lampctl (fijado a un commit) y arma kbcolor .rpm y .deb en artefacto/.
# Uso: packaging/build.sh <version>     |     packaging/build.sh --test (solo tests de lampctl)
set -eu
cd "$(dirname "$0")/.."

# Fijado: lo que se publica no cambia si el autor de lampctl pushea algo nuevo.
LAMPCTL_REPO=https://github.com/Salvo6516/lampctl
LAMPCTL_REF=0fbac81c536e748b862463cc8596703e7849ad2c
NFPM_VERSION=2.49.0

rm -rf build && mkdir -p build
git clone -q "$LAMPCTL_REPO" build/lampctl
git -C build/lampctl checkout -q "$LAMPCTL_REF"
make -C build/lampctl test

[ "${1:?falta version, o --test}" = --test ] && exit 0
VERSION=$1; export VERSION

# estatico: el binario corre en cualquier distro sin depender de la glibc del runner
make -B -C build/lampctl lampctl CFLAGS="${LAMPCTL_CFLAGS:--O2 -Wall -Wextra -static}"
make -C build/lampctl lampctl.service BINDIR=/usr/bin
mv build/lampctl/lampctl.service build/lampctl.service
sed 's|@BIN@|kbcolor|' kbcolor.desktop > build/kbcolor.desktop

if ! command -v nfpm >/dev/null; then
  u=https://github.com/goreleaser/nfpm/releases/download/v$NFPM_VERSION
  t=nfpm_${NFPM_VERSION}_Linux_x86_64.tar.gz
  curl -fsSLo "build/$t" "$u/$t"
  curl -fsSLo build/checksums.txt "$u/checksums.txt"
  (cd build && grep " $t\$" checksums.txt | sha256sum -c -)
  tar -xzf "build/$t" -C build nfpm
  PATH="$PWD/build:$PATH"
fi
mkdir -p artefacto
for p in rpm deb; do nfpm package -f packaging/nfpm.yaml -p $p -t artefacto/; done
(cd artefacto && sha256sum ./* | sed 's| \./| |' > SHA256SUMS)
ls -l artefacto
