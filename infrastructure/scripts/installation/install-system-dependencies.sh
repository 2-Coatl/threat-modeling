#!/usr/bin/env bash
# infrastructure/scripts/installation/install-system-dependencies.sh
# Install system-level dependencies: Python, Graphviz, Java, pandoc

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
    # Load core system
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
    # Check root permissions
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        return 1
    fi

    # Check apt-get availability
    if ! command -v apt-get >/dev/null 2>&1; then
        log_error "apt-get not found - this script requires Debian/Ubuntu"
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

verify_system_functional() {
    local checks=(
        "command -v python3 >/dev/null 2>&1"
        "command -v pip3 >/dev/null 2>&1"
        "command -v dot >/dev/null 2>&1"
        "command -v java >/dev/null 2>&1"
        "python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 6) else 1)' 2>/dev/null"
    )

    for check in "${checks[@]}"; do
        if ! eval "$check"; then
            return 1
        fi
    done

    return 0
}

# =============================================================================
# STEP 1: CONFIGURE APT REPOSITORIES
# =============================================================================

configure_apt_repositories() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Configuring APT repositories"

    export DEBIAN_FRONTEND=noninteractive

    local sources_content
    sources_content=$(cat /etc/apt/sources.list 2>/dev/null || echo "")

    if ! echo "$sources_content" | grep -q "universe"; then
        log_info "Adding universe repository"

        local output
        output=$(add-apt-repository -y universe 2>&1)
        local exit_code=$?

        if [[ $exit_code -ne 0 ]]; then
            log_error "Failed to add universe repository"
            echo "$output" >&2
            return 1
        fi
    else
        log_info "Universe repository already configured"
    fi

    log_success "APT repositories configured"
    return 0
}

# =============================================================================
# STEP 2: UPDATE SYSTEM PACKAGES
# =============================================================================

update_system_packages() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Updating system packages"

    log_info "Running apt-get update..."

    local output
    output=$(apt-get update -y 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "apt-get update failed"
        echo "$output" | grep -v "^debconf:" >&2
        return 1
    fi

    log_success "System packages updated"
    return 0
}

# =============================================================================
# STEP 3: INSTALL PYTHON STACK
# =============================================================================

install_python_stack() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Installing Python stack"

    local packages=(
        "python3"
        "python3-pip"
        "python3-dev"
        "python3-venv"
        "build-essential"
        "libssl-dev"
        "libffi-dev"
    )

    log_info "Installing packages: ${packages[*]}"

    local output
    output=$(apt-get install -y "${packages[@]}" 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "Failed to install Python stack"
        echo "$output" | grep -v "^debconf:" >&2
        return 1
    fi

    if ! command -v python3 >/dev/null 2>&1; then
        log_error "python3 not available after installation"
        return 1
    fi

    if ! command -v pip3 >/dev/null 2>&1; then
        log_error "pip3 not available after installation"
        return 1
    fi

    local python_version
    python_version=$(python3 --version 2>&1 | awk '{print $2}')

    local pip_version
    pip_version=$(pip3 --version 2>&1 | awk '{print $2}')

    log_success "Python stack installed"
    log_info "  Python: $python_version"
    log_info "  pip: $pip_version"

    return 0
}

# =============================================================================
# STEP 4: INSTALL GRAPHVIZ
# =============================================================================

install_graphviz() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Installing Graphviz"

    local packages=(
        "graphviz"
        "libgraphviz-dev"
    )

    local output
    output=$(apt-get install -y "${packages[@]}" 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "Failed to install Graphviz"
        echo "$output" | grep -v "^debconf:" >&2
        return 1
    fi

    if ! command -v dot >/dev/null 2>&1; then
        log_error "dot command not available after installation"
        return 1
    fi

    log_info "Testing Graphviz functionality..."

    local test_dot="digraph G { A -> B; }"
    local test_output="/tmp/graphviz_test_$$.png"

    if echo "$test_dot" | dot -Tpng -o "$test_output" 2>/dev/null; then
        if [[ -f "$test_output" ]]; then
            rm -f "$test_output"
            log_info "Graphviz test successful"
        else
            log_error "Graphviz test file not created"
            return 1
        fi
    else
        log_error "Graphviz cannot generate PNG"
        return 1
    fi

    local dot_version
    dot_version=$(dot -V 2>&1 | grep -oP '\d+\.\d+\.\d+' | head -n1)

    log_success "Graphviz installed"
    log_info "  Version: $dot_version"

    return 0
}

# =============================================================================
# STEP 5: INSTALL ADDITIONAL TOOLS
# =============================================================================

install_additional_tools() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Installing additional tools"

    local packages=(
        "default-jre"
        "wget"
        "curl"
        "pandoc"
    )

    local output
    output=$(apt-get install -y "${packages[@]}" 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "Failed to install additional tools"
        echo "$output" | grep -v "^debconf:" >&2
        return 1
    fi

    if ! command -v java >/dev/null 2>&1; then
        log_error "java not available after installation"
        return 1
    fi

    local java_version
    java_version=$(java -version 2>&1 | head -n1)

    log_success "Additional tools installed"
    log_info "  Java: $java_version"

    return 0
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    log_header "System Dependencies Installation"

    if is_component_functional "system"; then
        log_success "System dependencies already functional"
        log_info "Skipping installation (idempotence)"
        return 0
    fi

    log_info "System dependencies not functional, proceeding with installation"

    configure_apt_repositories 1 5 || return 1
    update_system_packages 2 5 || return 1
    install_python_stack 3 5 || return 1
    install_graphviz 4 5 || return 1
    install_additional_tools 5 5 || return 1

    if verify_system_functional; then
        log_success "System dependencies verified"
        mark_installation_state "system"
        return 0
    else
        log_error "Verification failed after installation"
        return 1
    fi
}

# =============================================================================
# EXECUTION
# =============================================================================

main "$@"
exit $?