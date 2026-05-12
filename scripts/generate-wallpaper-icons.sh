#!/usr/bin/env bash
# =============================================================================
# generate-wallpaper-icons.sh
# Gera thumbnails dos seus wallpapers para uso no menu rofi
# =============================================================================
#
# Dependências: imagemagick (convert) ou ffmpeg
# Instale com: sudo pacman -S imagemagick
#              ou: sudo apt install imagemagick
#
# Uso:
#   ./generate-wallpaper-icons.sh
#   ./generate-wallpaper-icons.sh ~/Imagens/wallpapers ~/.cache/wallpaper-icons 300x169
#
# =============================================================================

set -euo pipefail

# --- Configuração ---
WALLPAPER_DIR="${1:-$HOME/wallpapers}"
ICONS_DIR="${2:-$HOME/.cache/wallpaper-icons}"
THUMB_SIZE="${3:-300x169}"   # 16:9 padrão; mude para 200x200 se quiser quadrado
QUALITY=85                   # qualidade JPEG dos thumbnails (0-100)

# Extensões suportadas
EXTENSIONS=("jpg" "jpeg" "png" "webp" "bmp" "tiff" "gif")

# --- Cores para output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_ok()      { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error()   { echo -e "${RED}[ERRO]${NC}  $*"; }
log_skip()    { echo -e "${CYAN}[SKIP]${NC}  $*"; }

# Gera/atualiza thumbnails — ESPERA terminar antes de abrir o rofi
mkdir -p "$ICONS_DIR"

if command -v convert &>/dev/null; then
    for ext in jpg jpeg png webp bmp; do
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

# Cria diretório de ícones
mkdir -p "$ICONS_DIR"

# --- Conta arquivos ---
total=0
for ext in "${EXTENSIONS[@]}"; do
    count=$(find "$WALLPAPER_DIR" -maxdepth 1 -iname "*.${ext}" 2>/dev/null | wc -l)
    total=$((total + count))
done

if [[ $total -eq 0 ]]; then
    log_warn "Nenhum wallpaper encontrado em: $WALLPAPER_DIR"
    log_warn "Extensões suportadas: ${EXTENSIONS[*]}"
    exit 0
fi

echo ""
echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Gerador de Wallpaper Icons       ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo ""
log_info "Wallpapers:  $WALLPAPER_DIR"
log_info "Ícones:      $ICONS_DIR"
log_info "Tamanho:     ${THUMB_SIZE}px"
log_info "Total:       $total imagens"
echo ""

# --- Geração dos thumbnails ---
generated=0
skipped=0
errors=0

for ext in "${EXTENSIONS[@]}"; do
    while IFS= read -r wallpaper; do
        [[ -z "$wallpaper" ]] && continue

        filename=$(basename "$wallpaper")
        # Nome do thumbnail: mesmo nome mas sempre .jpg
        thumb_name="${filename%.*}.jpg"
        thumb_path="$ICONS_DIR/$thumb_name"

        # Pula se já existe e wallpaper não foi modificado
        if [[ -f "$thumb_path" && "$thumb_path" -nt "$wallpaper" ]]; then
            log_skip "$filename"
            ((skipped++))
            continue
        fi

        # Gera thumbnail com imagemagick
        # - resize mantendo aspecto e cortando para preencher o tamanho exato
        if convert "$wallpaper" \
            -thumbnail "${THUMB_SIZE}^" \
            -gravity center \
            -extent "$THUMB_SIZE" \
            -quality "$QUALITY" \
            "$thumb_path" 2>/dev/null; then
            log_ok "$filename  →  $thumb_name"
            ((generated++))
        else
            log_error "Falha ao processar: $filename"
            ((errors++))
        fi

    done < <(find "$WALLPAPER_DIR" -maxdepth 1 -iname "*.${ext}" 2>/dev/null | sort)
done

# --- Limpa thumbnails órfãos (wallpaper foi deletado) ---
orphans=0
while IFS= read -r thumb; do
    thumb_base=$(basename "$thumb" .jpg)
    found=false
    for ext in "${EXTENSIONS[@]}"; do
        for ext_file in "${EXTENSIONS[@]}"; do
            if [[ -f "$WALLPAPER_DIR/${thumb_base}.${ext_file}" ]]; then
                found=true
                break 2
            fi
        done
    done
    # Verifica se existe algum arquivo com esse nome base
    if ! find "$WALLPAPER_DIR" -maxdepth 1 -iname "${thumb_base}.*" | grep -q .; then
        log_warn "Removendo thumbnail órfão: $(basename "$thumb")"
        rm -f "$thumb"
        ((orphans++))
    fi
done < <(find "$ICONS_DIR" -maxdepth 1 -name "*.jpg" 2>/dev/null)

# --- Resumo ---
echo ""
echo -e "${CYAN}─────────────────────────────────────${NC}"
echo -e "  ${GREEN}Gerados:${NC}  $generated"
echo -e "  ${CYAN}Pulados:${NC}  $skipped  (já existem)"
[[ $orphans -gt 0 ]] && echo -e "  ${YELLOW}Órfãos:${NC}   $orphans  (removidos)"
[[ $errors  -gt 0 ]] && echo -e "  ${RED}Erros:${NC}    $errors"
echo -e "${CYAN}─────────────────────────────────────${NC}"
echo ""
log_ok "Pronto! Ícones em: $ICONS_DIR"
echo ""
