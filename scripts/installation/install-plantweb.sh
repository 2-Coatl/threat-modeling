#!/usr/bin/env bash
# scripts/installation/install-plantweb.sh
# Install Plantweb Python client for PlantUML Server

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
        log_error "This script must be run as root (use sudo)"
        return 1
    fi

    if ! command -v python3 >/dev/null 2>&1; then
        log_error "Python3 not found - run install-system-dependencies.sh first"
        return 1
    fi

    if ! command -v pip3 >/dev/null 2>&1; then
        log_error "pip3 not found - run install-system-dependencies.sh first"
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

verify_plantweb_functional() {
    local test_script="
import sys
try:
    # Test plantweb package import
    import plantweb
    from plantweb.render import render

    # Test our module import
    sys.path.insert(0, '/vagrant')
    from api.plantweb import configure, render as pw_render

    sys.exit(0)
except ImportError as e:
    print(f'Import failed: {e}', file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
"

    local output
    output=$(python3 -c "$test_script" 2>&1)
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        return 0
    else
        log_debug "Plantweb verification failed: $output"
        return 1
    fi
}

# =============================================================================
# STEP 1: UPGRADE PIP
# =============================================================================

upgrade_pip() {
    log_step "1" "5" "Upgrading pip"

    log_info "Upgrading pip to latest version..."

    local output
    output=$(python3 -m pip install --upgrade pip --quiet 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "Failed to upgrade pip"
        echo "$output" >&2
        return 1
    fi

    local pip_version
    pip_version=$(pip3 --version 2>&1 | awk '{print $2}')

    log_success "pip upgraded"
    log_info "  Version: $pip_version"

    return 0
}

# =============================================================================
# STEP 2: INSTALL PLANTWEB PACKAGE
# =============================================================================

install_plantweb_package() {
    log_step "2" "5" "Installing Plantweb package"

    log_info "Installing Plantweb from PyPI..."

    local output
    output=$(pip3 install plantweb --quiet 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "Failed to install Plantweb"
        echo "$output" >&2
        return 1
    fi

    local plantweb_version
    plantweb_version=$(pip3 show plantweb 2>/dev/null | grep "^Version:" | awk '{print $2}')

    if [[ -z "$plantweb_version" ]]; then
        log_error "Plantweb not found after installation"
        return 1
    fi

    log_success "Plantweb package installed"
    log_info "  Version: $plantweb_version"

    return 0
}

# =============================================================================
# STEP 3: INSTALL PYTHON DEPENDENCIES
# =============================================================================

install_python_dependencies() {
    log_step "3" "5" "Installing Python dependencies"

    local dependencies=(
        "requests"
        "appdirs"
    )

    for package in "${dependencies[@]}"; do
        log_info "Installing: $package"

        local output
        output=$(pip3 install "$package" --quiet 2>&1)
        local exit_code=$?

        if [[ $exit_code -ne 0 ]]; then
            log_error "Failed to install: $package"
            echo "$output" >&2
            return 1
        fi
    done

    log_success "Python dependencies installed"

    return 0
}

# =============================================================================
# STEP 4: CONFIGURE PLANTWEB
# =============================================================================

configure_plantweb() {
    log_step "4" "5" "Configuring Plantweb"

    local cache_dir="${HOME}/.cache/plantweb"
    local config_file="${HOME}/.plantwebrc"

    # Create cache directory
    log_info "Creating cache directory..."
    if ! mkdir -p "$cache_dir" 2>/dev/null; then
        log_warning "Failed to create cache directory: $cache_dir"
    else
        chmod 755 "$cache_dir"
        log_debug "Created: $cache_dir"
    fi

    # Create global configuration file
    log_info "Creating configuration file: $config_file"

    cat > "$config_file" << EOF
{
    "server": "${PLANTUML_SERVER:-http://localhost:8080/plantuml}",
    "cache_dir": "${cache_dir}",
    "engine": "plantuml",
    "format": "svg",
    "use_cache": true,
    "cache_max_age_days": 30,
    "timeout_seconds": 60,
    "verify_ssl": true
}
EOF

    chmod 644 "$config_file"

    # Create project configuration
    local project_config="$PROJECT_ROOT/config/plantweb.json"

    log_info "Creating project configuration: $project_config"

    cat > "$project_config" << EOF
{
    "server": "${PLANTUML_SERVER:-http://localhost:8080/plantuml}",
    "engine": "plantuml",
    "format": "svg",
    "use_cache": true
}
EOF

    chmod 644 "$project_config"

    log_success "Plantweb configured"
    log_info "  Config: $config_file"
    log_info "  Project config: $project_config"
    log_info "  Server: ${PLANTUML_SERVER:-http://localhost:8080/plantuml}"
    log_info "  Cache: $cache_dir"

    return 0
}

# =============================================================================
# STEP 5: CREATE MODULE STRUCTURE
# =============================================================================

create_module_structure() {
    log_step "5" "5" "Verifying module structure"

    local module_dir="$PROJECT_ROOT/api/plantweb"

    if [[ ! -d "$module_dir" ]]; then
        log_error "Module directory not found: $module_dir"
        log_error "Please ensure all module files are in place"
        return 1
    fi

    # Check for required module files
    local required_files=(
        "__init__.py"
        "config.py"
        "renderer.py"
        "cache.py"
        "pytm_adapter.py"
        "cli.py"
        "exceptions.py"
    )

    local missing_files=()

    for file in "${required_files[@]}"; do
        if [[ ! -f "$module_dir/$file" ]]; then
            missing_files+=("$file")
        fi
    done

    if [[ ${#missing_files[@]} -gt 0 ]]; then
        log_error "Missing module files:"
        printf '  - %s\n' "${missing_files[@]}" >&2
        return 1
    fi

    log_success "Module structure verified"
    log_info "  Location: $module_dir"
    log_info "  Files: ${#required_files[@]}"

    return 0
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    log_header "Plantweb Installation"

    if is_component_functional "plantweb"; then
        log_success "Plantweb already functional"
        log_info "Skipping installation (idempotence)"
        return 0
    fi

    log_info "Plantweb not functional, proceeding with installation"

    upgrade_pip || return 1
    install_plantweb_package || return 1
    install_python_dependencies || return 1
    configure_plantweb || return 1
    create_module_structure || return 1

    if verify_plantweb_functional; then
        log_success "Plantweb verified"
        mark_installation_state "plantweb"

        log_info "Installation details:"
        log_info "  Package: plantweb (PyPI)"
        log_info "  Module: api.plantweb"
        log_info "  Config: ${HOME}/.plantwebrc"
        log_info "  Cache: ${HOME}/.cache/plantweb"

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