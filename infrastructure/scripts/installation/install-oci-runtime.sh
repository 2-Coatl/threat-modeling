#!/usr/bin/env bash
# infrastructure/scripts/installation/install-oci-runtime.sh
# Install Podman-based OCI runtime environment

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
        log_error "This script must be run as root (use sudo)"
        return 1
    fi

    if ! command -v apt-get >/dev/null 2>&1; then
        log_error "apt-get not found - this installer supports Debian/Ubuntu hosts"
        return 1
    fi

    log_debug "Prerequisites validated"
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
# VERIFICATION FUNCTION
# =============================================================================

verify_oci_runtime_functional() {
    if ! command -v "${OCI_RUNTIME_BIN}" >/dev/null 2>&1; then
        log_debug "${OCI_RUNTIME_BIN} binary not available"
        return 1
    fi

    local info_output
    if ! info_output=$(timeout 15s "${OCI_RUNTIME_BIN}" info 2>&1); then
        log_debug "${OCI_RUNTIME_BIN} info failed: $info_output"
        return 1
    fi

    return 0
}

# =============================================================================
# STEP 1: REFRESH PACKAGE INDEX
# =============================================================================

refresh_package_index() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Refreshing package index"

    local output
    output=$(apt-get update 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "apt-get update failed"
        echo "$output" | grep -v "^debconf:" >&2
        return 1
    fi

    log_success "Package index refreshed"
    return 0
}

# =============================================================================
# STEP 2: ENSURE PODMAN REPOSITORY
# =============================================================================

ensure_podman_repository() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Ensuring ${OCI_RUNTIME_BIN} repository availability"

    if apt-cache show "${OCI_RUNTIME_BIN}" >/dev/null 2>&1; then
        log_info "${OCI_RUNTIME_BIN} package available from existing repositories"
        log_success "Repository already configured"
        return 0
    fi

    if [[ ! -r /etc/os-release ]]; then
        log_warning "Cannot detect operating system release; skipping custom repository configuration"
        return 0
    fi

    # shellcheck disable=SC1091
    source /etc/os-release

    if [[ "${ID}" != "ubuntu" ]]; then
        log_warning "Unsupported distribution '${ID}' for upstream Podman repository"
        return 0
    fi

    local repo_suffix="xUbuntu_${VERSION_ID}"
    local repo_url="https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/${repo_suffix}/"
    local keyring_dir="/etc/apt/keyrings"
    local keyring_file="${keyring_dir}/libcontainers-archive-keyring.gpg"
    local list_file="/etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"

    mkdir -p -m 0755 "${keyring_dir}"

    if [[ ! -f "${keyring_file}" ]]; then
        log_info "Downloading Podman repository signing key"

        if command -v curl >/dev/null 2>&1; then
            if ! curl -fsSL "${repo_url}Release.key" | gpg --dearmor -o "${keyring_file}"; then
                log_error "Failed to install Podman repository signing key"
                return 1
            fi
        elif command -v wget >/dev/null 2>&1; then
            if ! wget -qO- "${repo_url}Release.key" | gpg --dearmor -o "${keyring_file}"; then
                log_error "Failed to install Podman repository signing key"
                return 1
            fi
        else
            log_error "Neither curl nor wget is available to download repository key"
            return 1
        fi
    fi

    echo "deb [signed-by=${keyring_file}] ${repo_url} /" > "${list_file}"

    log_info "Added Podman repository: ${repo_url}"

    local output
    output=$(apt-get update 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "apt-get update failed after adding Podman repository"
        echo "$output" | grep -v "^debconf:" >&2
        return 1
    fi

    if apt-cache show "${OCI_RUNTIME_BIN}" >/dev/null 2>&1; then
        log_success "Podman repository configured"
    else
        log_warning "Podman package still unavailable after configuring repository"
    fi

    return 0
}

# =============================================================================
# STEP 3: INSTALL PODMAN RUNTIME
# =============================================================================

install_podman_runtime() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Installing ${OCI_RUNTIME_BIN} runtime"

    local packages=(
        "podman"
        "uidmap"
        "slirp4netns"
        "fuse-overlayfs"
        "conmon"
    )

    log_info "Installing packages: ${packages[*]}"

    local output
    output=$(apt-get install -y "${packages[@]}" 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "Failed to install OCI runtime packages"
        echo "$output" | grep -v "^debconf:" >&2
        return 1
    fi

    if ! command -v "${OCI_RUNTIME_BIN}" >/dev/null 2>&1; then
        log_error "${OCI_RUNTIME_BIN} binary not found after installation"
        return 1
    fi

    log_success "${OCI_RUNTIME_BIN} runtime installed"
    return 0
}

# =============================================================================
# STEP 4: CONFIGURE DEFAULT STORAGE
# =============================================================================

configure_storage_defaults() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Configuring containers storage defaults"

    mkdir -p "$OCI_STORAGE_ROOT"
    chmod 755 "$OCI_STORAGE_ROOT"

    mkdir -p "$OCI_RUN_ROOT"
    chmod 755 "$OCI_RUN_ROOT"

    local legacy_conf="/etc/containers/storage.conf"

    if [[ -f "$legacy_conf" ]]; then
        local legacy_updated=false

        if grep -q '\\$OCI_STORAGE_ROOT' "$legacy_conf"; then
            if sed -i "s#\\$OCI_STORAGE_ROOT#$OCI_STORAGE_ROOT#g" "$legacy_conf"; then
                log_info "Replaced legacy graphroot placeholder in $legacy_conf"
                legacy_updated=true
            else
                log_warning "Failed to update graphroot placeholder in $legacy_conf"
            fi
        fi

        if grep -q '\\$OCI_RUN_ROOT' "$legacy_conf"; then
            if sed -i "s#\\$OCI_RUN_ROOT#$OCI_RUN_ROOT#g" "$legacy_conf"; then
                log_info "Replaced legacy runroot placeholder in $legacy_conf"
                legacy_updated=true
            else
                log_warning "Failed to update runroot placeholder in $legacy_conf"
            fi
        fi

        if [[ "$legacy_updated" == "true" ]]; then
            chmod 644 "$legacy_conf"
        fi
    fi

    local drop_in_dir="/etc/containers/storage.conf.d"
    local drop_in_file="$drop_in_dir/99-threatmodel-storage.conf"

    mkdir -p "$drop_in_dir"

    local tmp_file
    if ! tmp_file=$(mktemp); then
        log_error "Failed to create temporary file for storage configuration"
        return 1
    fi

    trap 'rm -f "$tmp_file"' RETURN

    cat <<EOF > "$tmp_file"
[storage]
driver = "overlay"
graphroot = "$OCI_STORAGE_ROOT"
runroot = "$OCI_RUN_ROOT"

[storage.options]
mount_program = "/usr/bin/fuse-overlayfs"
EOF

    if [[ ! -f "$drop_in_file" ]] || ! cmp -s "$tmp_file" "$drop_in_file" 2>/dev/null; then
        install -m 644 "$tmp_file" "$drop_in_file"
        log_info "Updated storage configuration at $drop_in_file"
    else
        log_info "Storage configuration already up to date"
    fi

    trap - RETURN
    rm -f "$tmp_file"

    log_success "Storage defaults configured"
    return 0
}

# =============================================================================
# STEP 5: VERIFY INSTALLATION
# =============================================================================

final_verification() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Verifying OCI runtime"

    if verify_oci_runtime_functional; then
        log_success "${OCI_RUNTIME_BIN} runtime verified"
        mark_installation_state "oci-runtime"
        return 0
    fi

    log_error "Failed to verify ${OCI_RUNTIME_BIN} runtime"
    return 1
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    log_header "${OCI_RUNTIME_NAME} Installation"

    if is_component_functional "oci-runtime"; then
        log_success "${OCI_RUNTIME_NAME} already functional"
        log_info "Skipping installation (idempotent)"
        return 0
    fi

    local total_steps=5

    refresh_package_index 1 "$total_steps" || return 1
    ensure_podman_repository 2 "$total_steps" || return 1
    install_podman_runtime 3 "$total_steps" || return 1
    configure_storage_defaults 4 "$total_steps" || return 1
    final_verification 5 "$total_steps" || return 1

    return 0
}

# =============================================================================
# EXECUTION
# =============================================================================

main "$@"
exit $?
