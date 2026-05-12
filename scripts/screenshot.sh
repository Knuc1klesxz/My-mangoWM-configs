#!/usr/bin/env bash

DIR="$HOME/Imagens/Screenshots"
mkdir -p "$DIR"

DATE=$(date +%Y-%m-%d_%H-%m-%s)
FILE="$DIR/screenshot_$DATE.png"

case $1 in
    "full")
        grim "$FILE"
        ;;
    "select")
        # O slurp permite selecionar a área com o mouse
        grim -g "$(slurp)" "$FILE"
        ;;
    *)
        echo "Uso: $0 {full|select}"
        exit 1
        ;;
esac

if [ -f "$FILE" ]; then
    wl-copy < "$FILE"
    notify-send "📷 Screenshot" "Capturada com sucesso!" -t 2000
fi
