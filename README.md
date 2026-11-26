# kbcolor

GUI mínima (zenity) para el RGB del teclado de la Lenovo LOQ 15IRX10 (ITE `048d:c693`) en Linux. Incluye [lampctl](https://github.com/Salvo6516/lampctl) (MIT, de Salvatore Depietra).

- Presets, color libre, brillo (escala el color) y volver al modo firmware (`Fn+Espacio`).
- Recuerda el último color en `~/.config/kbcolor`.

> `lampctl` no está verificado en todo el hardware. No flashea firmware.

## Instalar

Bajá el paquete de la [última release](https://github.com/maurih5/kbcolor/releases/latest).

Fedora / RHEL:
```
sudo dnf install ./kbcolor-*.rpm
```
Debian / Ubuntu:
```
sudo apt install ./kbcolor_*.deb
```

Después abrí **Teclado RGB** desde el menú, o corré `kbcolor`.

Para que el color se aplique al arrancar y tras suspender:
```
echo COLOR=4a6fa5 | sudo tee /etc/lampctl.conf
sudo systemctl enable lampctl.service
```

Verificar la descarga: `sha256sum -c SHA256SUMS --ignore-missing`.

## Notas

- Con color manual activo, `Fn+Espacio` no responde. "Firmware" en la lista lo devuelve.
- Los paquetes son `amd64`/`x86_64`.

## Desarrollo

- `packaging/build.sh <versión>` arma el `.rpm` y el `.deb` en `artefacto/` (necesita `gcc`, `make`, `glibc-static`, `curl`).
- `install.sh` instala directo desde el repo, sin paquete.
- PRs a `main`: checks `test` y `Compilar paquetes`. Al mergear se publica una release con el mismo artefacto.
  Versión SemVer automática según la etiqueta de la PR: `bugfix` (default, patch), `feature` (minor), `breaking` (major).
- `lampctl` está fijado a un commit en `packaging/build.sh`. Para actualizarlo, cambiá `LAMPCTL_REF` después de revisar el diff.
