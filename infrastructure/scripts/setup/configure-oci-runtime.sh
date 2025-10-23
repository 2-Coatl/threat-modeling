#!/usr/bin/env bash
# infrastructure/scripts/setup/configure-oci-runtime.sh
# Configure system integration for the OCI runtime (Podman)

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
        # shellcheck source=/dev/null
        source "$PROJECT_ROOT/infrastructure/utils/core.sh"

        if ! load_project_environment; then
            echo "ERROR: Failed to load project environment" >&2
            return 1
        fi
    else
        echo "CRITICAL: Core system not found at: $PROJECT_ROOT/infrastructure/utils/core.sh" >&2
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

    if ! command -v "${OCI_RUNTIME_BIN}" >/dev/null 2>&1; then
        log_error "${OCI_RUNTIME_BIN} binary not found - run install-oci-runtime.sh first"
        return 1
    fi

    if ! command -v systemctl >/dev/null 2>&1; then
        log_error "systemctl not available - systemd required"
        return 1
    fi

    return 0
}

# =============================================================================
# LOAD ENVIRONMENT AND VALIDATE
# =============================================================================

if ! load_environment; then
    echo "CRITICAL: Environment loading failed" >&2
    exit 1
fi

if ! validate_prerequisites; then
    log_error "Prerequisites validation failed"
    exit 1
fi

# =============================================================================
# STEP 1: CONFIGURE CONTAINER REGISTRIES
# =============================================================================

configure_registries() {
    log_step 1 4 "Configuring container registries"

    mkdir -p /etc/containers

    local registries_conf="/etc/containers/registries.conf"

    if [[ ! -f "$registries_conf" ]]; then
        cat > "$registries_conf" <<'INNER_HEREDOC'
# Default registries for Podman runtime
unqualified-search-registries = ["docker.io", "quay.io"]

[[registry]]
prefix = "docker.io"
location = "registry-1.docker.io"

[[registry.mirror]]
location = "registry-1.docker.io"
INNER_HEREDOC
        chmod 644 "$registries_conf"
        log_success "Created registries configuration"
    else
        log_info "Registries configuration already present"
    fi

    return 0
}

# =============================================================================
# STEP 2: CONFIGURE RUNTIME GROUPS AND DIRECTORIES
# =============================================================================

configure_runtime_permissions() {
    log_step 2 4 "Configuring runtime permissions"

    mkdir -p "$OCI_RUNTIME_LOG_DIR"
    chmod 750 "$OCI_RUNTIME_LOG_DIR"
    chown "$THREAT_MODEL_USER:$THREAT_MODEL_GROUP" "$OCI_RUNTIME_LOG_DIR"

    if getent group "$OCI_RUNTIME_GROUP" >/dev/null 2>&1; then
        log_info "Adding $THREAT_MODEL_USER to group $OCI_RUNTIME_GROUP"
        usermod -a -G "$OCI_RUNTIME_GROUP" "$THREAT_MODEL_USER"
    else
        log_warning "Runtime group $OCI_RUNTIME_GROUP not present - skipping"
    fi

    # Ensure subuid/subgid ranges for rootless containers
    if ! grep -q "^$THREAT_MODEL_USER:" /etc/subuid; then
        echo "$THREAT_MODEL_USER:100000:65536" >> /etc/subuid
        log_info "Configured subuid range for $THREAT_MODEL_USER"
    fi

    if ! grep -q "^$THREAT_MODEL_USER:" /etc/subgid; then
        echo "$THREAT_MODEL_USER:100000:65536" >> /etc/subgid
        log_info "Configured subgid range for $THREAT_MODEL_USER"
    fi

    log_success "Runtime permissions configured"
    return 0
}

# =============================================================================
# STEP 3: ENABLE PODMAN SOCKET SERVICE
# =============================================================================

enable_runtime_socket() {
    log_step 3 4 "Enabling ${OCI_RUNTIME_SERVICE}"

    if systemctl list-unit-files | grep -q "${OCI_RUNTIME_SERVICE}"; then
        local output
        output=$(systemctl enable --now "${OCI_RUNTIME_SERVICE}" 2>&1 || true)
        if systemctl is-active --quiet "${OCI_RUNTIME_SERVICE}"; then
            log_success "${OCI_RUNTIME_SERVICE} active"
        else
            log_warning "${OCI_RUNTIME_SERVICE} enablement returned: $output"
        fi
    else
        log_warning "${OCI_RUNTIME_SERVICE} unit not provided by packages"
    fi

    return 0
}

# =============================================================================
# STEP 4: VERIFY RUNTIME HEALTH
# =============================================================================

verify_runtime_configuration() {
    log_step 4 4 "Verifying runtime configuration"

    if verify_oci_runtime_functional; then
        log_success "${OCI_RUNTIME_NAME} configuration validated"
        return 0
    fi

    log_error "${OCI_RUNTIME_NAME} verification failed"
    return 1
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    log_header "${OCI_RUNTIME_NAME} Configuration"

    configure_registries || return 1
    configure_runtime_permissions || return 1
    enable_runtime_socket || return 1
    verify_runtime_configuration || return 1

    return 0
}

# =============================================================================
# EXECUTION
# =============================================================================

main "$@"
exit $?
