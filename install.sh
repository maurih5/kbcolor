#!/bin/sh
# Instala kbcolor: lampctl en /usr/local/bin (root), symlink, lanzador y servicio de arranque.
set -e
D=$(cd "$(dirname "$0")" && pwd)

# lampctl va en ruta de root: pkexec lo corre como root, no debe ser escribible por el usuario
if ! command -v lampctl >/dev/null; then
  T=$(mktemp -d)
  git clone --depth 1 https://github.com/Salvo6516/lampctl "$T/lampctl"
  make -C "$T/lampctl"
  sudo make -C "$T/lampctl" install PREFIX=/usr/local SYSTEMD=/etc/systemd/system
  rm -rf "$T"
fi

mkdir -p ~/.local/bin ~/.local/share/applications
ln -sfn "$D/kbcolor.sh" ~/.local/bin/kbcolor
sed "s|@BIN@|$HOME/.local/bin/kbcolor|" "$D/kbcolor.desktop" > ~/.local/share/applications/kbcolor.desktop

# color al arrancar y tras suspender: usa el ultimo guardado por kbcolor
echo "COLOR=$(cat ~/.config/kbcolor 2>/dev/null || echo 4a6fa5)" | sudo tee /etc/lampctl.conf >/dev/null
sudo systemctl daemon-reload
sudo systemctl enable lampctl.service
echo "listo. Abri 'kbcolor' o buscalo en el menu."
