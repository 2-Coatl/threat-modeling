#!/usr/bin/env bash
# infrastructure/scripts/setup/configure-permissions.sh
# Configure file and directory permissions for threat modeling system

set -euo pipefail

# =============================================================================
# INITIALIZATION
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$SCRIPT_DIR/../../.." && pwd)}"

# =============================================================================
# LOAD ENVIRONMENT
# =============================================================================

load_environment() {
    if [[ -f "$PROJECT_ROOT/infrastructure/utils/core.sh" ]]; then
        source "$PROJECT_ROOT/infrastructure/utils/core.sh"

        if ! load_project_environment; then
            echo "ERROR: Failed to load project environment" >&2
            return 1
        fi
    else
        echo "CRITICAL: Core system not found" >&2
        return 1
    fi

    return 0
}

# =============================================================================
# VALIDATE PREREQUISITES
# =============================================================================

validate_prerequisites() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        return 1
    fi

    if ! id "$THREAT_MODEL_USER" &>/dev/null; then
        log_error "User does not exist: $THREAT_MODEL_USER"
        log_error "Run create-threatmodel-user.sh first"
        return 1
    fi

    return 0
}

# =============================================================================
# LOAD AND VALIDATE
# =============================================================================

if ! load_environment; then
    exit 1
fi

if ! validate_prerequisites; then
    exit 1
fi

# =============================================================================
# CONFIGURE LOG DIRECTORY
# =============================================================================

configure_log_directory() {
    log_info "Configuring log directory: $APP_LOG_DIR"

    if [[ ! -d "$APP_LOG_DIR" ]]; then
        mkdir -p "$APP_LOG_DIR"
    fi

    chown -R "$THREAT_MODEL_USER:$THREAT_MODEL_GROUP" "$APP_LOG_DIR"
    chmod "$DIR_PERMISSIONS" "$APP_LOG_DIR"

    if [[ -f "$LOG_FILE" ]]; then
        chmod "$LOG_PERMISSIONS" "$LOG_FILE"
    fi

    log_success "Log directory configured"
    return 0
}

# =============================================================================
# CONFIGURE STATE DIRECTORY
# =============================================================================

configure_state_directory() {
    log_info "Configuring state directory: $APP_STATE_DIR"

    if [[ ! -d "$APP_STATE_DIR" ]]; then
        mkdir -p "$APP_STATE_DIR"
    fi

    chown -R "$THREAT_MODEL_USER:$THREAT_MODEL_GROUP" "$APP_STATE_DIR"
    chmod "$DIR_PERMISSIONS" "$APP_STATE_DIR"

    log_success "State directory configured"
    return 0
}

# =============================================================================
# CONFIGURE CACHE DIRECTORY
# =============================================================================

configure_cache_directory() {
    log_info "Configuring cache directory: $APP_CACHE_DIR"

    if [[ ! -d "$APP_CACHE_DIR" ]]; then
        mkdir -p "$APP_CACHE_DIR"
    fi

    chown -R "$THREAT_MODEL_USER:$THREAT_MODEL_GROUP" "$APP_CACHE_DIR"
    chmod "$DIR_PERMISSIONS" "$APP_CACHE_DIR"

    log_success "Cache directory configured"
    return 0
}

# =============================================================================
# CONFIGURE OUTPUT DIRECTORY
# =============================================================================

configure_output_directory() {
    log_info "Configuring output directory: $OUTPUT_DIR"

    local output_dirs=(
        "$OUTPUT_DIR"
        "$DIAGRAMS_DIR"
        "$REPORTS_DIR"
    )

    for dir in "${output_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
        fi

        chown "$THREAT_MODEL_USER:$THREAT_MODEL_GROUP" "$dir"
        chmod "$DIR_PERMISSIONS_SHARED" "$dir"
        log_debug "Configured: $dir"
    done

    log_success "Output directory configured"
    return 0
}

# =============================================================================
# CONFIGURE BIN PERMISSIONS
# =============================================================================

configure_bin_permissions() {
    log_info "Configuring bin permissions: $BIN_DIR"

    if [[ ! -d "$BIN_DIR" ]]; then
        log_warning "Bin directory does not exist: $BIN_DIR"
        return 0
    fi

    local bin_scripts=(
        "$BIN_DIR/generate"
        "$BIN_DIR/setup"
    )

    for script in "${bin_scripts[@]}"; do
        if [[ -f "$script" ]]; then
            chmod "$EXEC_PERMISSIONS" "$script"
            log_debug "Made executable: $script"
        else
            log_warning "Script not found: $script"
        fi
    done

    log_success "Bin permissions configured"
    return 0
}

# =============================================================================
# CREATE WRAPPER SCRIPTS
# =============================================================================

create_wrapper_scripts() {
    log_info "Creating wrapper scripts..."

    local wrapper_dir="$THREAT_MODEL_HOME/bin"

    if [[ ! -d "$wrapper_dir" ]]; then
        mkdir -p "$wrapper_dir"
        chown "$THREAT_MODEL_USER:$THREAT_MODEL_GROUP" "$wrapper_dir"
    fi

    local generate_wrapper="$wrapper_dir/generate"

    cat > "$generate_wrapper" << 'EOF'
#!/usr/bin/env bash
# Wrapper to run generate as threatmodel user

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="/vagrant"

exec sudo -u threatmodel "${PROJECT_ROOT}/bin/generate" "$@"
EOF

    chmod "$EXEC_PERMISSIONS" "$generate_wrapper"
    chown "$THREAT_MODEL_USER:$THREAT_MODEL_GROUP" "$generate_wrapper"

    log_success "Wrapper scripts created"
    log_info "  $generate_wrapper"

    return 0
}

# =============================================================================
# CONFIGURE MODELS DIRECTORY
# =============================================================================

configure_models_directory() {
    log_info "Configuring models directory: $MODELS_DIR"

    if [[ ! -d "$MODELS_DIR" ]]; then
        mkdir -p "$MODELS_DIR"
    fi

    chmod "$DIR_PERMISSIONS_SHARED" "$MODELS_DIR"

    log_success "Models directory configured"
    return 0
}

# =============================================================================
# SET FINAL PERMISSIONS
# =============================================================================

set_final_permissions() {
    log_info "Setting final permissions..."

    if [[ -d "$OUTPUT_DIR" ]]; then
        find "$OUTPUT_DIR" -type d -exec chmod "$DIR_PERMISSIONS_SHARED" {} \;
        find "$OUTPUT_DIR" -type f -exec chmod "$FILE_PERMISSIONS" {} \;
        chown -R "$THREAT_MODEL_USER:$THREAT_MODEL_GROUP" "$OUTPUT_DIR"
    fi

    if [[ -d "$APP_LOG_DIR" ]]; then
        find "$APP_LOG_DIR" -type f -exec chmod "$LOG_PERMISSIONS" {} \;
    fi

    log_success "Final permissions set"
    return 0
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    log_header "Permission Configuration"

    configure_log_directory || return 1
    configure_state_directory || return 1
    configure_cache_directory || return 1
    configure_output_directory || return 1
    configure_models_directory || return 1
    configure_bin_permissions || return 1
    create_wrapper_scripts || return 1
    set_final_permissions || return 1

    log_success "Permission configuration completed"

    log_info "Summary:"
    log_info "  Log dir: $APP_LOG_DIR (owner: $THREAT_MODEL_USER)"
    log_info "  State dir: $APP_STATE_DIR (owner: $THREAT_MODEL_USER)"
    log_info "  Output dir: $OUTPUT_DIR (owner: $THREAT_MODEL_USER, group writable)"

    return 0
}

# =============================================================================
# EXECUTION
# =============================================================================

main "$@"
exit $?