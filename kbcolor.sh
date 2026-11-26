#!/bin/sh
# GUI minima: presets o color libre con zenity, lo aplica con lampctl (pkexec)
L=$(command -v lampctl) || { zenity --error --text="Falta lampctl. Corre install.sh" 2>/dev/null; exit 1; }
F=~/.config/kbcolor
last=$(cat "$F" 2>/dev/null || echo 4a6fa5)

sel=$(zenity --list --title="Teclado" --text="Elegí un preset (último: #$last)" \
  --column=Nombre --column=Hex --hide-column=2 --print-column=2 \
  "Azul acero" 4a6fa5 "Blanco cálido" ffe8c8 "Azul hielo" a8c8e8 "Gris azulado" 8fa3b8 \
  "Blanco" ffffff "Rojo" ff0000 "Verde" 00ff00 "Apagar" 000000 \
  "Firmware (Fn+Espacio)" auto "Brillo..." bright "Personalizado..." custom 2>/dev/null) || exit 0

case $sel in
  auto) pkexec "$L" auto; exit ;;
  bright)
    p=$(zenity --scale --title="Brillo" --text="Brillo de #$last" --min-value=5 --max-value=100 --value=100 2>/dev/null) || exit 0
    hex=$(printf '%s' "$last" | awk -v p="$p" '{r=strtonum("0x" substr($0,1,2));g=strtonum("0x" substr($0,3,2));b=strtonum("0x" substr($0,5,2));printf "%02x%02x%02x",r*p/100,g*p/100,b*p/100}')
    pkexec "$L" set "$hex" || zenity --error --text="Fallo lampctl ($hex)" 2>/dev/null
    exit ;;
  custom)
    c=$(zenity --color-selection --title="Color del teclado" --color="#$last" 2>/dev/null) || exit 0
    case $c in
      \#*) hex=$(printf '%s' "$c" | cut -c2-7) ;;
      *) hex=$(printf '%s' "$c" | tr -dc '0-9,' | awk -F, '{printf "%02x%02x%02x",$1,$2,$3}') ;;
    esac ;;
  *) hex=$sel ;;
esac
pkexec "$L" set "$hex" && echo "$hex" > "$F" || zenity --error --text="Fallo lampctl ($hex)" 2>/dev/null
