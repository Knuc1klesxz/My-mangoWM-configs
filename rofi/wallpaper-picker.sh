#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="${1:-$HOME/Imagens/wallpapers}"
ICONS_DIR="$HOME/.cache/wallpaper-icons"
THUMB_SIZE="300x169"
CURRENT_WALL_FILE="$HOME/.cache/current-wallpaper"
SETTER="swaybg"

apply_swaybg() { pkill swaybg 2>/dev/null || true; swaybg -m fill -i "$1" & }
apply_swww()   {
    pgrep -x swww-daemon &>/dev/null || { swww-daemon & sleep 0.5; }
    swww img "$1" --transition-type grow --transition-pos 0.5,0.5 --transition-duration 1.5 --transition-fps 60
}
apply_feh()        { feh --bg-fill "$1"; }
apply_nitrogen()   { nitrogen --set-zoom-fill "$1"; }
apply_xwallpaper() { xwallpaper --zoom "$1"; }

set_wallpaper() {
    case "$SETTER" in
        swww)       apply_swww       "$1" ;;
        swaybg)     apply_swaybg     "$1" ;;
        feh)        apply_feh        "$1" ;;
        nitrogen)   apply_nitrogen   "$1" ;;
        xwallpaper) apply_xwallpaper "$1" ;;
    esac
}

if ! command -v rofi &>/dev/null; then
    echo "Erro: rofi não encontrado."; exit 1
fi
if [[ ! -d "$WALLPAPER_DIR" ]]; then
    echo "Erro: diretório $WALLPAPER_DIR não existe."; exit 1
fi

mkdir -p "$ICONS_DIR"

if command -v convert &>/dev/null; then
    for ext in jpg jpeg png webp bmp tiff gif; do
        while IFS= read -r wall; do
            [[ -z "$wall" ]] && continue
            name=$(basename "$wall")
            thumb="$ICONS_DIR/${name%.*}.jpg"
            if [[ ! -f "$thumb" || "$thumb" -ot "$wall" ]]; then
                convert "$wall" \
                    -thumbnail "${THUMB_SIZE}^" \
                    -gravity center -extent "$THUMB_SIZE" \
                    -quality 85 "$thumb" 2>/dev/null || true
            fi
        done < <(find "$WALLPAPER_DIR" -maxdepth 1 -iname "*.${ext}" 2>/dev/null)
    done
fi

wall_names=()
wall_paths=()

while IFS= read -r wall; do
    [[ -z "$wall" ]] && continue
    name=$(basename "$wall")
    display="${name%.*}"
    wall_names+=("$display")
    wall_paths+=("$wall")
done < <(find "$WALLPAPER_DIR" -maxdepth 1 \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
       -o -iname "*.webp" -o -iname "*.bmp" -o -iname "*.tiff" \
       -o -iname "*.gif" \) \
    2>/dev/null | sort)

if [[ ${#wall_paths[@]} -eq 0 ]]; then
    echo "Nenhum wallpaper encontrado em $WALLPAPER_DIR"; exit 0
fi

rofi_input=""
for i in "${!wall_names[@]}"; do
    display="${wall_names[$i]}"
    thumb="$ICONS_DIR/${display}.jpg"
    if [[ -f "$thumb" ]]; then
        rofi_input+="${display}\0icon\x1f${thumb}\n"
    else
        rofi_input+="${display}\n"
    fi
done

chosen=$(printf "%b" "$rofi_input" | rofi \
    -dmenu \
    -i \
    -format i \
    -p "  Wallpaper" \
-theme-str '
        window {
            width: 900px;
            height: 600px;
            border-radius: 12px;
            background-color: rgba(20,20,20,0.85);
        }
        mainbox {
            background-color: transparent;
            padding: 10px;
        }
        inputbar {
            background-color: transparent;
            padding: 8px 4px;
            children: [prompt, entry];
        }
        prompt {
            background-color: transparent;
            text-color: #aaaaaa;
            padding: 0 8px 0 0;
        }
        entry {
            background-color: transparent;
            text-color: white;
            placeholder-color: #666666;
        }
        listview {
            background-color: transparent;
            columns: 4;
            lines: 3;
            spacing: 6px;
            padding: 8px 4px;
        }
        element {
            background-color: transparent;
            orientation: vertical;
            padding: 10px 6px;
            border-radius: 10px;
        }
        element selected {
            background-color: rgba(255,255,255,0.15);
            border: 2px;
            border-color: rgba(255,255,255,0.3);
            border-radius: 10px;
        }
        element-icon {
            size: 160px;
            border-radius: 8px;
        }
        element-text {
            horizontal-align: 0.5;
            padding: 6px 0 0 0;
            font: "sans 8";
            text-color: white;
        }
        element-text selected {
            text-color: white;
        }
    ' \
    -show-icons \
    2>/dev/null) || exit 0

[[ -z "$chosen" ]] && exit 0

wall_path="${wall_paths[$chosen]}"

if [[ -z "$wall_path" || ! -f "$wall_path" ]]; then
    notify-send "Wallpaper Picker" "Arquivo não encontrado" -u normal 2>/dev/null || true
    exit 1
fi

set_wallpaper "$wall_path"
echo "$wall_path" > "$CURRENT_WALL_FILE"

notify-send "Wallpaper" "$(basename "$wall_path")" \
    --urgency=low --expire-time=3000 2>/dev/null || true
