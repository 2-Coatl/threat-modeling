#!/usr/bin/env bash
# infrastructure/scripts/installation/install-diagram-service.sh
# Install Flask Diagram Service with versioning

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

    if ! command -v python3 >/dev/null 2>&1; then
        log_error "Python3 not found - run install-system-dependencies.sh first"
        return 1
    fi

    if ! command -v pip3 >/dev/null 2>&1; then
        log_error "pip3 not found - run install-system-dependencies.sh first"
        return 1
    fi

    if ! command -v git >/dev/null 2>&1; then
        log_error "git not found - run install-system-dependencies.sh first"
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
# CONSTANTS
# =============================================================================

DIAGRAM_SERVICE_DIR="$PROJECT_ROOT/api"
HISTORY_DIR="$DIAGRAM_SERVICE_DIR/history"
TEMPLATES_DIR="$DIAGRAM_SERVICE_DIR/templates"
STATIC_DIR="$DIAGRAM_SERVICE_DIR/static"

# =============================================================================
# STEP 1: INSTALL PYTHON DEPENDENCIES
# =============================================================================

install_python_dependencies() {
    log_step "1" "6" "Installing Python dependencies"

    log_info "Installing Flask and requirements..."

    local requirements=(
        "Flask==2.3.3"
        "Werkzeug==2.3.7"
        "requests==2.31.0"
        "gunicorn==21.2.0"
    )

    for package in "${requirements[@]}"; do
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
# STEP 2: CREATE DIRECTORY STRUCTURE
# =============================================================================

create_directory_structure() {
    log_step "2" "6" "Creating directory structure"

    local directories=(
        "$HISTORY_DIR"
        "$TEMPLATES_DIR"
        "$STATIC_DIR/css"
        "$STATIC_DIR/js"
    )

    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log_info "Created: $dir"
        else
            log_info "Already exists: $dir"
        fi
    done

    log_success "Directory structure created"

    return 0
}

# =============================================================================
# STEP 3: FIX LINE ENDINGS
# =============================================================================

fix_line_endings() {
    log_step "3" "6" "Fixing line endings"

    log_info "Converting CRLF to LF in Python files..."

    # Fix Python files
    if [[ -d "$DIAGRAM_SERVICE_DIR" ]]; then
        find "$DIAGRAM_SERVICE_DIR" -type f -name "*.py" -exec sed -i 's/\r$//' {} \; 2>/dev/null || true
        log_info "Fixed Python files"
    fi

    # Fix HTML files
    if [[ -d "$TEMPLATES_DIR" ]]; then
        find "$TEMPLATES_DIR" -type f -name "*.html" -exec sed -i 's/\r$//' {} \; 2>/dev/null || true
        log_info "Fixed HTML templates"
    fi

    log_success "Line endings fixed"

    return 0
}

# =============================================================================
# STEP 4: CONFIGURE PERMISSIONS
# =============================================================================

configure_permissions() {
    log_step "4" "6" "Configuring permissions"

    log_info "Setting ownership and permissions..."

    # Set ownership for api directory
    chown -R "$THREAT_MODEL_USER:$THREAT_MODEL_GROUP" "$DIAGRAM_SERVICE_DIR" 2>/dev/null || true

    # Make Python files executable
    find "$DIAGRAM_SERVICE_DIR" -type f -name "*.py" -exec chmod 755 {} \; 2>/dev/null || true

    # Set proper permissions for directories
    chmod 755 "$DIAGRAM_SERVICE_DIR"
    chmod 755 "$HISTORY_DIR"
    chmod 755 "$TEMPLATES_DIR"
    chmod 755 "$STATIC_DIR"

    log_success "Permissions configured"

    return 0
}

# =============================================================================
# STEP 5: INITIALIZE GIT REPOSITORY
# =============================================================================

initialize_git_repository() {
    log_step "5" "6" "Initializing Git repository"

    if [[ ! -d "$HISTORY_DIR/.git" ]]; then
        log_info "Creating Git repository in: $HISTORY_DIR"

        cd "$HISTORY_DIR"

        git init >/dev/null 2>&1
        git config user.name "Threat Model System"
        git config user.email "threatmodel@local"

        # Create initial commit
        echo "# Diagram Version History" > README.md
        git add README.md
        git commit -m "Initial commit" >/dev/null 2>&1

        log_success "Git repository initialized"
    else
        log_info "Git repository already exists"
    fi

    return 0
}

# =============================================================================
# STEP 6: VERIFY INSTALLATION
# =============================================================================

verify_installation() {
    log_step "6" "6" "Verifying installation"

    local errors=0

    # Check if Flask is installed
    if ! python3 -c "import flask" 2>/dev/null; then
        log_error "Flask not installed"
        ((errors++))
    else
        log_success "Flask: OK"
    fi

    # Check if requests is installed
    if ! python3 -c "import requests" 2>/dev/null; then
        log_error "requests not installed"
        ((errors++))
    else
        log_success "requests: OK"
    fi

    # Check if directories exist
    for dir in "$HISTORY_DIR" "$TEMPLATES_DIR" "$STATIC_DIR"; do
        if [[ ! -d "$dir" ]]; then
            log_error "Directory missing: $dir"
            ((errors++))
        fi
    done

    if [[ $errors -eq 0 ]]; then
        log_success "All verification checks passed"
        return 0
    else
        log_error "Verification failed with $errors errors"
        return 1
    fi
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    log_header "Diagram Service Installation"

    # Check if already installed
    if python3 -c "import flask" 2>/dev/null && [[ -d "$HISTORY_DIR" ]]; then
        log_success "Diagram service already installed"
        log_info "Skipping installation (idempotence)"
        return 0
    fi

    log_info "Installing diagram service..."

    install_python_dependencies || return 1
    create_directory_structure || return 1
    fix_line_endings || return 1
    configure_permissions || return 1
    initialize_git_repository || return 1
    verify_installation || return 1

    log_success "Diagram service installation completed"

    log_info "Installation summary:"
    log_info "  Service directory: $DIAGRAM_SERVICE_DIR"
    log_info "  History directory: $HISTORY_DIR"
    log_info "  Templates: $TEMPLATES_DIR"
    log_info "  Static files: $STATIC_DIR"

    log_info "NEXT STEPS:"
    log_info "  1. Copy Flask app files to: $DIAGRAM_SERVICE_DIR"
    log_info "  2. Copy templates to: $TEMPLATES_DIR"
    log_info "  3. Configure systemd service"
    log_info "  4. Start service: sudo systemctl start diagram-service"

    return 0
}

# =============================================================================
# EXECUTION
# =============================================================================

main "$@"
exit $?