#!/usr/bin/env bash
# infrastructure/utils/logging.sh - Centralized logging system with fallback

# Prevent multiple sourcing
if [[ "${LOGGING_LOADED:-}" == "true" ]]; then
    return 0
fi

# ============================================================================
# GLOBAL STATE
# ============================================================================

LOG_FILE_PATH=""
LOG_LEVEL_VALUE="INFO"
LOG_INITIALIZED="false"

# ============================================================================
# COLOR CODES (for terminal output)
# ============================================================================

if [[ -t 2 ]]; then
    readonly COLOR_RED='\033[0;31m'
    readonly COLOR_GREEN='\033[0;32m'
    readonly COLOR_YELLOW='\033[1;33m'
    readonly COLOR_BLUE='\033[0;34m'
    readonly COLOR_RESET='\033[0m'
else
    readonly COLOR_RED=''
    readonly COLOR_GREEN=''
    readonly COLOR_YELLOW=''
    readonly COLOR_BLUE=''
    readonly COLOR_RESET=''
fi

# ============================================================================
# INITIALIZATION
# ============================================================================

init_logging() {
    local _init_file="${1:-}"
    local _init_level="${2:-INFO}"

    if [[ -z "${_init_file}" ]]; then
        echo "[WARNING] No log file specified, using stderr only" >&2
        LOG_INITIALIZED="false"
        return 0
    fi

    local _init_dir
    _init_dir="$(dirname "${_init_file}")"

    if [[ ! -d "${_init_dir}" ]]; then
        if ! mkdir -p "${_init_dir}" 2>/dev/null; then
            echo "[WARNING] Cannot create log directory: ${_init_dir}" >&2
            LOG_INITIALIZED="false"
            return 0
        fi
    fi

    LOG_FILE_PATH="${_init_file}"
    LOG_LEVEL_VALUE="${_init_level}"
    LOG_INITIALIZED="true"

    echo "[$(date -Iseconds)] [INFO] Logging initialized (level: ${_init_level})" >> "${LOG_FILE_PATH}"

    return 0
}

# ============================================================================
# CORE LOGGING FUNCTION
# ============================================================================

log_message() {
    local _log_level="${1}"
    local _log_text="${2}"
    local _log_timestamp

    _log_timestamp="$(date -Iseconds)"

    local _log_formatted="[${_log_timestamp}] [${_log_level}] ${_log_text}"

    if [[ "${LOG_INITIALIZED}" == "true" ]] && [[ -n "${LOG_FILE_PATH}" ]]; then
        echo "${_log_formatted}" >> "${LOG_FILE_PATH}"
    fi

    echo "${_log_formatted}" >&2
}

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_info() {
    log_message "INFO" "$*"
}

log_success() {
    local _success_msg="$*"

    if [[ "${LOG_INITIALIZED}" == "true" ]] && [[ -n "${LOG_FILE_PATH}" ]]; then
        log_message "SUCCESS" "${_success_msg}"
    fi

    echo -e "[$(date -Iseconds)] [${COLOR_GREEN}SUCCESS${COLOR_RESET}] ${_success_msg}" >&2
}

log_warning() {
    local _warn_msg="$*"

    if [[ "${LOG_INITIALIZED}" == "true" ]] && [[ -n "${LOG_FILE_PATH}" ]]; then
        log_message "WARNING" "${_warn_msg}"
    fi

    echo -e "[$(date -Iseconds)] [${COLOR_YELLOW}WARNING${COLOR_RESET}] ${_warn_msg}" >&2
}

log_error() {
    local _error_msg="$*"

    if [[ "${LOG_INITIALIZED}" == "true" ]] && [[ -n "${LOG_FILE_PATH}" ]]; then
        log_message "ERROR" "${_error_msg}"
    fi

    echo -e "[$(date -Iseconds)] [${COLOR_RED}ERROR${COLOR_RESET}] ${_error_msg}" >&2
}

log_debug() {
    if [[ "${LOG_LEVEL_VALUE}" == "DEBUG" ]]; then
        log_message "DEBUG" "$*"
    fi
}

log_header() {
    local _header_text="$*"
    local _header_separator="============================================================"

    echo "" >&2
    echo "${_header_separator}" >&2
    echo "  ${_header_text}" >&2
    echo "${_header_separator}" >&2

    if [[ "${LOG_INITIALIZED}" == "true" ]] && [[ -n "${LOG_FILE_PATH}" ]]; then
        {
            echo ""
            echo "${_header_separator}"
            echo "  ${_header_text}"
            echo "${_header_separator}"
        } >> "${LOG_FILE_PATH}"
    fi
}

log_step() {
    local _step_current="${1}"
    local _step_total="${2}"
    local _step_desc="${3}"

    log_info "[STEP ${_step_current}/${_step_total}] ${_step_desc}"
}

# ============================================================================
# MARK AS LOADED
# ============================================================================

readonly LOGGING_LOADED="true"