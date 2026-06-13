#!/usr/bin/env bash

set -euo pipefail

RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*"; }

echo -e "${BOLD}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║         Student Attendance Tracker                   ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${RESET}"

read -rp "$(echo -e "${BOLD}Enter a project identifier:${RESET} ")" PROJECT_INPUT

if [[ -z "$PROJECT_INPUT" ]]; then
    error "Project identifier cannot be empty. Aborting."
    exit 1
fi

PROJECT_DIR="attendance_tracker_${PROJECT_INPUT}"
ARCHIVE_NAME="${PROJECT_DIR}_archive"

info "Project directory will be: ${BOLD}${PROJECT_DIR}${RESET}"

cleanup_on_interrupt() {
    echo ""
    warn "Interrupt received — cleaning up partial setup…"
    if [[ -d "$PROJECT_DIR" ]]; then
        info "Archiving current state → ${ARCHIVE_NAME}.tar.gz"
        tar -czf "${ARCHIVE_NAME}.tar.gz" "$PROJECT_DIR" 2>/dev/null \
            && success "Archive created: ${ARCHIVE_NAME}.tar.gz" \
            || warn "Archiving failed."
        info "Removing incomplete directory: ${PROJECT_DIR}"
        rm -rf "$PROJECT_DIR"
        success "Workspace cleaned."
    else
        info "No directory to archive — nothing to clean."
    fi
    echo -e "${RED}Bootstrap aborted by user.${RESET}"
    exit 130
}

trap cleanup_on_interrupt SIGINT

info "Creating directory structure…"

if [[ -d "$PROJECT_DIR" ]]; then
    error "Directory '${PROJECT_DIR}' already exists. Choose a different identifier."
    exit 1
fi

if ! mkdir -p "${PROJECT_DIR}/Helpers" 2>/dev/null; then
    error "Permission denied — cannot create '${PROJECT_DIR}'. Check your folder permissions."
    exit 1
fi

if ! mkdir -p "${PROJECT_DIR}/reports" 2>/dev/null; then
    error "Permission denied — cannot create reports folder."
    rm -rf "$PROJECT_DIR"
    exit 1
fi

success "Directories created."

info "Copying source files…"
cp attendance_checker.py "${PROJECT_DIR}/attendance_checker.py"
cp assets.csv "${PROJECT_DIR}/Helpers/assets.csv"
cp config.json "${PROJECT_DIR}/Helpers/config.json"
cp reports.log "${PROJECT_DIR}/reports/reports.log"
success "All source files copied."

echo ""
echo -e "${BOLD}── Attendance Threshold Configuration ──────────────────${RESET}"
echo    "   Current defaults:  Warning = 75%  |  Failure = 50%"
echo ""
read -rp "$(echo -e "Would you like to update the thresholds? ${BOLD}[y/N]${RESET}: ")" UPDATE_THRESHOLDS

if [[ "$UPDATE_THRESHOLDS" == "y" || "$UPDATE_THRESHOLDS" == "Y" ]]; then

    while true; do
        read -rp "  Enter new Warning threshold (1-100, default 75): " NEW_WARNING
        NEW_WARNING="${NEW_WARNING:-75}"
        if [[ "$NEW_WARNING" =~ ^[0-9]+$ ]] && (( NEW_WARNING >= 1 && NEW_WARNING <= 100 )); then
            break
        else
            warn "Invalid input. Please enter a numeric value between 1 and 100."
        fi
    done

    while true; do
        read -rp "  Enter new Failure threshold (1-100, default 50): " NEW_FAILURE
        NEW_FAILURE="${NEW_FAILURE:-50}"
        if [[ "$NEW_FAILURE" =~ ^[0-9]+$ ]] && (( NEW_FAILURE >= 1 && NEW_FAILURE <= 100 )); then
            break
        else
            warn "Invalid input. Please enter a numeric value between 1 and 100."
        fi
    done

    if (( NEW_FAILURE >= NEW_WARNING )); then
        warn "Failure threshold must be lower than Warning. Keeping defaults."
    else
        CONFIG_FILE="${PROJECT_DIR}/Helpers/config.json"
        sed -i '' "s/\"warning\": [0-9]*/\"warning\": ${NEW_WARNING}/" "$CONFIG_FILE"
        sed -i '' "s/\"failure\": [0-9]*/\"failure\": ${NEW_FAILURE}/" "$CONFIG_FILE"
        success "config.json updated → Warning: ${NEW_WARNING}%  |  Failure: ${NEW_FAILURE}%"
    fi
else
    info "Keeping default thresholds (Warning=75%, Failure=50%)."
fi

echo ""
echo -e "${BOLD}── Environment Health Check ─────────────────────────────${RESET}"

if PYTHON_VERSION=$(python3 --version 2>&1); then
    success "python3 found  →  ${PYTHON_VERSION}"
else
    warn "python3 not found. Install it before running attendance_checker.py."
fi

EXPECTED_FILES=(
    "${PROJECT_DIR}/attendance_checker.py"
    "${PROJECT_DIR}/Helpers/assets.csv"
    "${PROJECT_DIR}/Helpers/config.json"
    "${PROJECT_DIR}/reports/reports.log"
)

ALL_OK=true
for FILE in "${EXPECTED_FILES[@]}"; do
    if [[ -f "$FILE" ]]; then
        success "Found: ${FILE}"
    else
        error "Missing: ${FILE}"
        ALL_OK=false
    fi
done

$ALL_OK && success "All files validated." || warn "Some files are missing."

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║              Bootstrap Complete ✓                    ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  Project root : ${CYAN}${PROJECT_DIR}/${RESET}"
echo -e "  Run tracker  : ${CYAN}python3 ${PROJECT_DIR}/attendance_checker.py${RESET}"
echo ""
