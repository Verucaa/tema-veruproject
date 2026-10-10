#!/usr/bin/env bash
#
# VeruProject Premium Theme — installer for Pterodactyl v1.x
#
# Menu:  Install  |  Uninstall (hapus)  |  Repair (perbaiki)  |  Exit
#
# Usage:
#   bash install.sh {PANEL_DIR}        interactive menu (asks dir if missing)
#   bash install.sh {PANEL_DIR} --yes  install, no prompts
#   bash install.sh --help
#
# Requirements: bash, panel dir containing an `artisan` file.
set -euo pipefail

cd "$(dirname "$0")"

THEME_NAME="veruproject"
CREDIT="Template oleh VeruProject"

PANEL_DIR=""
FORCE=0

help() {
    cat <<EOF
VeruProject theme installer for Pterodactyl v1.x

Usage:
  bash install.sh [PANEL_DIR]        interactive menu
  bash install.sh [PANEL_DIR] --yes  install directly, no menu
  bash install.sh --help             this help

Menu actions:
  [1] Install    copy CSS/JS + replace 2 Blade files (with backup)
  [2] Hapus      remove theme files + restore Blade backups (if any)
  [3] Perbaiki   re-apply theme after a panel update (same as install, keep backups)
  [4] Exit

Env: VP_FORCE=1  skips the confirm prompt inside install/repair

Report bugs/requests at: https://github.com/VeruProject/pterodactyl-theme
EOF
}

die() { echo "ERROR: $*" >&2; exit 1; }

ask_panel_dir() {
    if [[ -n "$PANEL_DIR" ]]; then return; fi
    local d="${1:-/var/www/pterodactyl}"
    read -r -p "Panel directory? [$d] " choice
    [[ -n "$choice" ]] && d="$choice"
    PANEL_DIR="$d"
}

guard_panel() {
    [[ -f "$PANEL_DIR/artisan" ]] || die "'$PANEL_DIR' does not look like a Pterodactyl panel (no artisan file)."
}

flash() { echo "Run: (cd $PANEL_DIR && php artisan view:clear)"; }

# ---------------------------------------------------------------- assets ----
install_assets() {
    mkdir -p "$PANEL_DIR/public/themes/$THEME_NAME/css"
    mkdir -p "$PANEL_DIR/public/themes/$THEME_NAME/js"
    cp -v "public/themes/$THEME_NAME/css/app.css" "$PANEL_DIR/public/themes/$THEME_NAME/css/app.css"
    cp -v "public/themes/$THEME_NAME/js/app.js"   "$PANEL_DIR/public/themes/$THEME_NAME/js/app.js"
}

# ------------------------------------------------- leaf blades (with backup) -
install_blades() {
    local stamp blade dest
    # timestamp+pid+random keeps backups unique even when install and repair run
    # in the same second from the same process
    stamp="$(date +%Y%m%d-%H%M%S)-$$-$RANDOM"
    for blade in resources/views/templates/wrapper.blade.php resources/views/layouts/admin.blade.php; do
        dest="$PANEL_DIR/$blade"
        mkdir -p "$(dirname "$dest")"
        [[ -f "$dest" ]] && cp -v "$dest" "$dest.bak-$stamp"
        cp -v "$blade" "$dest"
    done
    echo "Originals backed up as *.bak-$stamp."
}

# ------------------------------------------------------------------- install -
do_install() {
    echo "==> Installing $THEME_NAME theme into $PANEL_DIR"
    install_assets
    if [[ "$FORCE" == "1" ]] || [[ "${VP_FORCE:-}" == "1" ]]; then
        install_blades
    else
        read -r -p "Replace 2 Blade files (wrapper + admin)? Originals will be backed up. [y/N] " ok
        if [[ "$ok" =~ ^[yY] ]]; then install_blades; else
            echo "Blade files left untouched. Copy them manually:"
            echo "  cp resources/views/templates/wrapper.blade.php $PANEL_DIR/resources/views/templates/wrapper.blade.php"
            echo "  cp resources/views/layouts/admin.blade.php     $PANEL_DIR/resources/views/layouts/admin.blade.php"
        fi
    fi
    flash
    echo "Done. Hard-refresh (Ctrl+Shift+R) to see changes."
}

# ------------------------------------------------------------------- repair -
do_repair() {
    echo "==> Re-applying $THEME_NAME theme (for after a panel update)"
    install_assets
    install_blades
    flash
    echo "Theme re-applied."
}

# ------------------------------------------------------------------ uninstall -
do_uninstall() {
    echo "==> Removing $THEME_NAME theme from $PANEL_DIR"
    local restored=0
    for blade in resources/views/templates/wrapper.blade.php resources/views/layouts/admin.blade.php; do
        local dest backup
        dest="$PANEL_DIR/$blade"
        # oldest backup = first-ever pre-theme original; later backups may
        # hold the themed file itself (repair re-backs-up the current file)
        backup="$(ls -1t "$dest".bak-* 2>/dev/null | tail -1 || true)"
        if [[ -n "$backup" && -f "$dest" ]]; then
            cp -v "$backup" "$dest" && restored=1
            rm -v -f "$dest".bak-*
        else
            echo "no backup for $blade — left as-is"
        fi
    done
    if [[ -d "$PANEL_DIR/public/themes/$THEME_NAME" ]]; then
        rm -v -rf "$PANEL_DIR/public/themes/$THEME_NAME"
    else
        echo "no theme assets at $PANEL_DIR/public/themes/$THEME_NAME — nothing removed"
    fi
    flash
    if [[ "$restored" == "1" ]]; then
        echo "Theme removed; original Blade files restored."
    else
        echo "No Blade backups found — originals were already gone or never backed up."
    fi
}

# --------------------------------------------------------------------- menu -
menu() {
    while true; do
        cat <<EOF

  VeruProject Premium Theme — Pterodactyl v1.x
  $CREDIT
  Panel dir: $PANEL_DIR

  [1] Install theme
  [2] Hapus theme (uninstall + restore originals)
  [3] Perbaiki theme (re-apply after panel update)
  [4] Exit

EOF
        read -r -p "Select [1-4]: " choice || exit 0
        case "$choice" in
            1) do_install ;;
            2) do_uninstall ;;
            3) do_repair ;;
            4) echo "Bye."; exit 0 ;;
            *) echo "Invalid choice." ;;
        esac
        echo
        read -r -p "Press Enter to return to menu..." _ || exit 0
    done
}

# --------------------------------------------------------------------- main -
# ------------------------------------------------------------- arg parsing --
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h) help; exit 0 ;;
        --yes) FORCE=1 ;;
        *) PANEL_DIR="$1" ;;
    esac
    shift
done

if [[ -z "$PANEL_DIR" ]]; then
    ask_panel_dir "/var/www/pterodactyl"
fi

guard_panel
echo "Panel detected: $PANEL_DIR"

if [[ "$FORCE" == "1" ]]; then do_install; exit 0; fi
menu