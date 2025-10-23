#!/usr/bin/env bash
# infrastructure/scripts/installation/install-pytm-framework.sh
# Install pytm framework and PlantUML

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

    # Check Python is available
    if ! command -v python3 >/dev/null 2>&1; then
        log_error "Python3 not found - run install-system-dependencies.sh first"
        return 1
    fi

    # Check pip is available
    if ! command -v pip3 >/dev/null 2>&1; then
        log_error "pip3 not found - run install-system-dependencies.sh first"
        return 1
    fi

    # Check Java is available
    if ! command -v java >/dev/null 2>&1; then
        log_error "Java not found - run install-system-dependencies.sh first"
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

verify_pytm_functional() {
    local test_script="
import sys
try:
    from pytm import TM, Server, Dataflow, Actor
    tm = TM('test')
    server = Server('test_server')
    actor = Actor('test_actor')
    flow = Dataflow(actor, server, 'test_flow')
    sys.exit(0)
except ImportError as e:
    print(f'Import failed: {e}', file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f'pytm error: {e}', file=sys.stderr)
    sys.exit(1)
"

    local output
    output=$(python3 -c "$test_script" 2>&1)
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        return 0
    else
        log_debug "pytm verification failed: $output"
        return 1
    fi
}

# =============================================================================
# STEP 1: UPGRADE PIP
# =============================================================================

upgrade_pip() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Upgrading pip"

    log_info "Upgrading pip to latest version..."

    local output
    output=$(python3 -m pip install --upgrade pip 2>&1)
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
# STEP 2: INSTALL PYTM PACKAGE
# =============================================================================

install_pytm_package() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Installing pytm package"

    log_info "Installing pytm from PyPI..."

    local output
    output=$(pip3 install pytm 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "Failed to install pytm"
        echo "$output" >&2
        return 1
    fi

    local pytm_version
    pytm_version=$(pip3 show pytm 2>/dev/null | grep "^Version:" | awk '{print $2}')

    if [[ -z "$pytm_version" ]]; then
        log_error "pytm not found after installation"
        return 1
    fi

    log_success "pytm package installed"
    log_info "  Version: $pytm_version"

    return 0
}

# =============================================================================
# STEP 3: INSTALL PYTHON DEPENDENCIES
# =============================================================================

install_python_dependencies() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Installing Python dependencies"

    local dependencies=(
        "graphviz"
        "pydot"
        "Pillow"
    )

    for package in "${dependencies[@]}"; do
        log_info "Installing: $package"

        local output
        output=$(pip3 install "$package" 2>&1)
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
# STEP 4: INSTALL PLANTUML
# =============================================================================

install_plantuml() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Installing PlantUML"

    local plantuml_jar="$PLANTUML_JAR"
    local plantuml_url="$PLANTUML_URL"

    if [[ -f "$plantuml_jar" ]]; then
        local file_size
        file_size=$(stat -c%s "$plantuml_jar" 2>/dev/null)

        if [[ $file_size -gt 1000000 ]]; then
            log_info "PlantUML already exists and valid"
            log_info "  Location: $plantuml_jar"
            log_info "  Size: $((file_size / 1024 / 1024)) MB"
            return 0
        else
            log_warning "PlantUML exists but too small, re-downloading"
            rm -f "$plantuml_jar"
        fi
    fi

    local plantuml_dir
    plantuml_dir="$(dirname "$plantuml_jar")"

    if [[ ! -d "$plantuml_dir" ]]; then
        if ! mkdir -p "$plantuml_dir"; then
            log_error "Failed to create directory: $plantuml_dir"
            return 1
        fi
    fi

    log_info "Downloading PlantUML from: $plantuml_url"

    local output
    output=$(wget -O "$plantuml_jar" "$plantuml_url" 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "Failed to download PlantUML"
        echo "$output" >&2
        return 1
    fi

    if [[ ! -f "$plantuml_jar" ]]; then
        log_error "PlantUML file not created"
        return 1
    fi

    local file_size
    file_size=$(stat -c%s "$plantuml_jar" 2>/dev/null)

    if [[ $file_size -lt 1000000 ]]; then
        log_error "Downloaded file too small: $file_size bytes (expected > 1MB)"
        rm -f "$plantuml_jar"
        return 1
    fi

    log_info "Testing PlantUML execution..."

    local test_output
    test_output=$(java -jar "$plantuml_jar" -version 2>&1)
    local test_exit_code=$?

    if [[ $test_exit_code -ne 0 ]]; then
        log_error "PlantUML verification failed"
        echo "$test_output" >&2
        return 1
    fi

    local plantuml_version
    plantuml_version=$(echo "$test_output" | grep -oP 'PlantUML version \K[0-9.]+' | head -n1)

    log_success "PlantUML installed and verified"
    log_info "  Location: $plantuml_jar"
    log_info "  Size: $((file_size / 1024 / 1024)) MB"
    log_info "  Version: $plantuml_version"

    return 0
}

# =============================================================================
# STEP 5: CREATE PLANTUML WRAPPER
# =============================================================================

create_plantuml_wrapper() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Creating PlantUML wrapper"

    local wrapper_path="/usr/local/bin/plantuml"
    local wrapper_content="#!/bin/bash
exec java -jar $PLANTUML_JAR \"\$@\"
"

    echo "$wrapper_content" > "$wrapper_path"
    chmod 755 "$wrapper_path"

    if command -v plantuml >/dev/null 2>&1; then
        log_success "PlantUML wrapper created: $wrapper_path"
        return 0
    else
        log_warning "Wrapper created but not in PATH"
        return 0
    fi
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    log_header "pytm Framework Installation"

    if is_component_functional "pytm"; then
        log_success "pytm already functional"
        log_info "Skipping installation (idempotence)"
        return 0
    fi

    log_info "pytm not functional, proceeding with installation"

    upgrade_pip 1 5 || return 1
    install_pytm_package 2 5 || return 1
    install_python_dependencies 3 5 || return 1
    install_plantuml 4 5 || return 1
    create_plantuml_wrapper 5 5 || true

    if verify_pytm_functional; then
        log_success "pytm framework verified"
        mark_installation_state "pytm"
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