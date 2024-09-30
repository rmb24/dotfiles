#!/bin/bash

# Captura la pantalla
scrot -o -z /tmp/screenshot.png

# Verifica si la captura fue exitosa
if [ $? -eq 0 ]; then
    # Aplica desenfoque a la captura usando ImageMagick
    magick /tmp/screenshot.png -blur 0x5 /tmp/screenshotblur.png
    
    # Verifica si el desenfoque fue exitoso
    if [ $? -eq 0 ]; then
        # Bloquea la pantalla con la imagen desenfocada
        i3lock -i /tmp/screenshotblur.png
        
        # Limpia las imágenes temporales después de desbloquear
        rm /tmp/screenshot.png /tmp/screenshotblur.png
    else
        echo "Error al desenfocar la captura de pantalla."
        exit 1
    fi
else
    echo "Error al capturar la pantalla."
    exit 1
fi