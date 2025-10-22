#!/usr/bin/env bash
# scripts/setup/create-threatmodel-user.sh
# Create dedicated threatmodel system user

set -euo pipefail

# =============================================================================
# INITIALIZATION
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

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

    if ! command -v useradd >/dev/null 2>&1; then
        log_error "useradd command not found"
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
# CHECK USER EXISTS
# =============================================================================

user_exists() {
    local username="$1"
    id "$username" &>/dev/null
}

# =============================================================================
# CREATE USER
# =============================================================================

create_threatmodel_user() {
    log_info "Creating system user: $THREAT_MODEL_USER"

    if user_exists "$THREAT_MODEL_USER"; then
        log_info "User already exists: $THREAT_MODEL_USER"
        return 0
    fi

    if ! useradd \
        --system \
        --create-home \
        --home-dir "$THREAT_MODEL_HOME" \
        --shell "$THREAT_MODEL_SHELL" \
        --comment "Threat Modeling Service User" \
        "$THREAT_MODEL_USER"; then
        log_error "Failed to create user: $THREAT_MODEL_USER"
        return 1
    fi

    log_success "User created: $THREAT_MODEL_USER"

    local user_info
    user_info=$(id "$THREAT_MODEL_USER")
    log_info "  $user_info"

    return 0
}

# =============================================================================
# ADD USER TO GROUPS
# =============================================================================

add_user_to_groups() {
    log_info "Adding user to supplementary groups..."

    IFS=',' read -ra groups <<< "$THREAT_MODEL_GROUPS"

    for group in "${groups[@]}"; do
        group=$(echo "$group" | xargs)

        if ! getent group "$group" &>/dev/null; then
            log_warning "Group does not exist: $group (skipping)"
            continue
        fi

        if usermod -aG "$group" "$THREAT_MODEL_USER"; then
            log_info "  Added to group: $group"
        else
            log_warning "  Failed to add to group: $group"
        fi
    done

    log_success "Groups configured"
    return 0
}

# =============================================================================
# CREATE USER DIRECTORIES
# =============================================================================

create_user_directories() {
    log_info "Creating user directories..."

    local user_dirs=(
        "$THREAT_MODEL_HOME/.ssh"
        "$THREAT_MODEL_HOME/.cache"
        "$THREAT_MODEL_HOME/bin"
    )

    for dir in "${user_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            if mkdir -p "$dir"; then
                chown "$THREAT_MODEL_USER:$THREAT_MODEL_GROUP" "$dir"
                chmod 700 "$dir"
                log_debug "Created: $dir"
            else
                log_error "Failed to create: $dir"
                return 1
            fi
        fi
    done

    log_success "User directories created"
    return 0
}

# =============================================================================
# CONFIGURE SUDOERS
# =============================================================================

configure_sudoers() {
    log_info "Configuring sudoers..."

    local sudoers_content="# Threat Modeling System - Sudo Configuration
# Allow vagrant user to execute specific commands as threatmodel user

# Disable requiretty for threatmodel user
Defaults:$THREAT_MODEL_USER !requiretty

# Allow vagrant to run commands as threatmodel without password
"

    for cmd in "${ALLOWED_COMMANDS[@]}"; do
        sudoers_content+="vagrant ALL=($THREAT_MODEL_USER) NOPASSWD: $cmd"$'\n'
    done

    sudoers_content+="
# Allow threatmodel to write to its own directories
Defaults:$THREAT_MODEL_USER env_keep += \"PATH\"
Defaults:$THREAT_MODEL_USER env_keep += \"PYTHONPATH\"
"

    echo "$sudoers_content" > "$SUDOERS_FILE"
    chmod 440 "$SUDOERS_FILE"

    if ! visudo -c -f "$SUDOERS_FILE" &>/dev/null; then
        log_error "Invalid sudoers configuration"
        rm -f "$SUDOERS_FILE"
        return 1
    fi

    log_success "Sudoers configured: $SUDOERS_FILE"
    return 0
}

# =============================================================================
# CREATE SYSTEM DIRECTORIES
# =============================================================================

create_system_directories() {
    log_info "Creating system directories..."

    local system_dirs=(
        "$APP_LOG_DIR"
        "$APP_STATE_DIR"
        "$APP_CACHE_DIR"
    )

    for dir in "${system_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            if mkdir -p "$dir"; then
                log_debug "Created: $dir"
            else
                log_error "Failed to create: $dir"
                return 1
            fi
        fi

        chown "$THREAT_MODEL_USER:$THREAT_MODEL_GROUP" "$dir"
        chmod "$DIR_PERMISSIONS" "$dir"
        log_info "  Configured: $dir"
    done

    log_success "System directories configured"
    return 0
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    log_header "Threat Model User Setup"

    create_threatmodel_user || return 1
    add_user_to_groups || return 1
    create_user_directories || return 1
    configure_sudoers || return 1
    create_system_directories || return 1

    log_success "Threat model user setup completed"
    log_info "User: $THREAT_MODEL_USER"
    log_info "Home: $THREAT_MODEL_HOME"
    log_info "Groups: $THREAT_MODEL_GROUPS"

    return 0
}

# =============================================================================
# EXECUTION
# =============================================================================

main "$@"
exit $?