# kbcolor

GUI mínima (zenity) para el RGB del teclado de la Lenovo LOQ 15IRX10 (ITE `048d:c693`) en Linux. Usa [lampctl](https://github.com/Salvo6516/lampctl).

- Presets, color libre, brillo (escala el color) y volver al modo firmware (`Fn+Espacio`).
- Recuerda el último color en `~/.config/kbcolor`.

## Instalar

Dependencias: `zenity`, `polkit` (pkexec), `git`, `gcc`, `make`.

```
./install.sh
```

Instala `lampctl` en `/usr/local/bin`, el comando `kbcolor`, el lanzador del menú y el servicio que reaplica el color al arrancar y tras suspender.

## Notas

- El color de arranque se fija al instalar (`/etc/lampctl.conf`). Para cambiarlo: `echo COLOR=rrggbb | sudo tee /etc/lampctl.conf`.
- Con color manual activo, `Fn+Espacio` no responde. Elegir "Firmware" lo devuelve.
- `lampctl` no está verificado en todo el hardware; no flashea firmware.
