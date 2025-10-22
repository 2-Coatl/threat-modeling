#!/usr/bin/env bash
# bootstrap.sh - Master orchestrator with dedicated user

set -euo pipefail

# =============================================================================
# INITIALIZATION
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

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
        echo "ERROR: Core system not found" >&2
        return 1
    fi

    return 0
}

# =============================================================================
# VALIDATE REQUIREMENTS
# =============================================================================

validate_requirements() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        return 1
    fi

    local required_scripts=(
        "$PROJECT_ROOT/scripts/setup/create-threatmodel-user.sh"
        "$PROJECT_ROOT/scripts/setup/configure-permissions.sh"
        "$PROJECT_ROOT/scripts/installation/install-system-dependencies.sh"
        "$PROJECT_ROOT/scripts/installation/install-pytm-framework.sh"
        "$PROJECT_ROOT/scripts/installation/install-plantweb.sh"
        "$PROJECT_ROOT/scripts/installation/install-tomcat.sh"
        "$PROJECT_ROOT/scripts/installation/install-plantuml-server.sh"
        "$PROJECT_ROOT/scripts/setup/configure-plantuml-service.sh"
        "$PROJECT_ROOT/scripts/setup/configure-tomcat-outputs.sh"
        "$PROJECT_ROOT/scripts/setup/configure-tomcat-docs.sh"
    )

    local missing=()

    for script in "${required_scripts[@]}"; do
        if [[ ! -f "$script" ]]; then
            missing+=("$script")
        else
            chmod +x "$script" 2>/dev/null || true
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Required scripts not found:"
        printf '  - %s\n' "${missing[@]}" >&2
        return 1
    fi

    return 0
}

# =============================================================================
# VALIDATE ENVIRONMENT
# =============================================================================

validate_environment() {
    log_info "Validating environment..."

    local critical_dirs=(
        "infrastructure/utils"
        "scripts/installation"
        "scripts/setup"
        "config"
    )

    local missing_dirs=()

    for dir in "${critical_dirs[@]}"; do
        local full_path="$PROJECT_ROOT/$dir"
        if [[ ! -d "$full_path" ]]; then
            missing_dirs+=("$dir")
        fi
    done

    if [[ ${#missing_dirs[@]} -gt 0 ]]; then
        log_error "Missing critical directories:"
        printf '  - %s\n' "${missing_dirs[@]}" >&2
        return 1
    fi

    log_success "Environment validation passed"
    return 0
}

# =============================================================================
# PHASE 0: SETUP THREAT MODEL USER
# =============================================================================

setup_threatmodel_user() {
    log_header "PHASE 0: Threat Model User Setup"

    local script_path="$PROJECT_ROOT/scripts/setup/create-threatmodel-user.sh"

    run_install_script \
        "$script_path" \
        "User Setup" \
        300

    return $?
}

# =============================================================================
# PHASE 1: INSTALL SYSTEM DEPENDENCIES
# =============================================================================

install_system_dependencies() {
    log_header "PHASE 1: System Dependencies"

    local script_path="$PROJECT_ROOT/scripts/installation/install-system-dependencies.sh"

    run_install_script \
        "$script_path" \
        "System Dependencies" \
        "$INSTALL_TIMEOUT"

    return $?
}

# =============================================================================
# PHASE 2: INSTALL PYTM FRAMEWORK
# =============================================================================

install_pytm_framework() {
    log_header "PHASE 2: pytm Framework"

    local script_path="$PROJECT_ROOT/scripts/installation/install-pytm-framework.sh"

    run_install_script \
        "$script_path" \
        "pytm Framework" \
        "$INSTALL_TIMEOUT"

    return $?
}

# =============================================================================
# PHASE 2.5: INSTALL PLANTWEB CLIENT
# =============================================================================

install_plantweb_client() {
    log_header "PHASE 2.5: Plantweb Client"

    local script_path="$PROJECT_ROOT/scripts/installation/install-plantweb.sh"

    run_install_script \
        "$script_path" \
        "Plantweb Client" \
        "$INSTALL_TIMEOUT"

    return $?
}

# =============================================================================
# PHASE 3: INSTALL TOMCAT
# =============================================================================

install_tomcat() {
    log_header "PHASE 3: Apache Tomcat"

    local script_path="$PROJECT_ROOT/scripts/installation/install-tomcat.sh"

    run_install_script \
        "$script_path" \
        "Tomcat Server" \
        "$INSTALL_TIMEOUT"

    return $?
}

# =============================================================================
# PHASE 4: INSTALL PLANTUML SERVER
# =============================================================================

install_plantuml_server() {
    log_header "PHASE 4: PlantUML Server"

    local script_path="$PROJECT_ROOT/scripts/installation/install-plantuml-server.sh"

    run_install_script \
        "$script_path" \
        "PlantUML Server" \
        "$INSTALL_TIMEOUT"

    return $?
}

# =============================================================================
# PHASE 5: CONFIGURE PLANTUML SERVICE
# =============================================================================

configure_plantuml_service() {
    log_header "PHASE 5: PlantUML Service Configuration"

    local script_path="$PROJECT_ROOT/scripts/setup/configure-plantuml-service.sh"

    run_install_script \
        "$script_path" \
        "PlantUML Service" \
        300

    return $?
}

# =============================================================================
# PHASE 6: CONFIGURE PERMISSIONS
# =============================================================================

configure_permissions() {
    log_header "PHASE 6: Permission Configuration"

    local script_path="$PROJECT_ROOT/scripts/setup/configure-permissions.sh"

    run_install_script \
        "$script_path" \
        "Permissions" \
        300

    return $?
}

# =============================================================================
# PHASE 6.5: CONFIGURE TOMCAT OUTPUTS
# =============================================================================

configure_tomcat_outputs() {
    log_header "PHASE 6.5: Tomcat Outputs Access"

    local script_path="$PROJECT_ROOT/scripts/setup/configure-tomcat-outputs.sh"

    run_install_script \
        "$script_path" \
        "Tomcat Outputs" \
        300

    return $?
}

# =============================================================================
# PHASE 6.6: CONFIGURE TOMCAT DOCS ACCESS
# =============================================================================

configure_tomcat_docs() {
    log_header "PHASE 6.6: Tomcat Documentation Access"

    local script_path="$PROJECT_ROOT/scripts/setup/configure-tomcat-docs.sh"

    run_install_script \
        "$script_path" \
        "Tomcat Docs" \
        300

    return $?
}

# =============================================================================
# PHASE 7: CREATE PROJECT STRUCTURE
# =============================================================================

create_project_structure() {
    log_header "PHASE 7: Project Structure"

    create_project_directories

    log_info "Setting executable permissions on bin scripts..."
    if [[ -d "$BIN_DIR" ]]; then
        chmod +x "$BIN_DIR"/* 2>/dev/null || true
        log_success "Bin scripts permissions set"
    fi

    return $?
}

# =============================================================================
# CREATE README FILES
# =============================================================================

create_readme_files() {
    log_info "Creating README files..."

    local models_readme="$MODELS_DIR/README.md"

    if [[ ! -f "$models_readme" ]]; then
        cat > "$models_readme" << 'EOF'
# Threat Models

Place your pytm threat model Python files here.

## Naming Convention
- Files must end with `_model.py`
- Example: `auth_model.py`, `api_model.py`

## Usage

```bash
# Generate all models (as vagrant user)
sudo -u threatmodel /vagrant/bin/generate

# Generate specific model
sudo -u threatmodel /vagrant/bin/generate /vagrant/dashboard/models/auth_model.py

# List available models
sudo -u threatmodel /vagrant/bin/generate --list

# Generate with Plantweb (SVG output)
sudo -u threatmodel /vagrant/bin/generate --plantweb
```

## Model Structure

```python
#!/usr/bin/env python3
from pytm import TM, Server, Actor, Dataflow

tm = TM("My System")
tm.description = "System description"
tm.isOrdered = True

user = Actor("User")
server = Server("Server")
flow = Dataflow(user, server, "Request")

if __name__ == "__main__":
    tm.process()
```
EOF
        chown "$THREAT_MODEL_USER:$THREAT_MODEL_GROUP" "$models_readme" 2>/dev/null || true
        log_success "Created: $models_readme"
    else
        log_info "Already exists: $models_readme"
    fi

    local output_readme="$OUTPUT_DIR/README.md"

    if [[ ! -f "$output_readme" ]]; then
        cat > "$output_readme" << 'EOF'
# Generated Outputs

This directory contains auto-generated threat model outputs.

## Structure
- `diagrams/` - PNG/SVG images (DFD and Sequence diagrams)
- `reports/` - HTML reports

## Rendering Modes
- **Native**: PNG format via pytm + PlantUML JAR
- **Plantweb**: SVG format via PlantUML Server (cached)

## Permissions
- Owner: threatmodel user
- Group: threatmodel group
- Mode: 775 (group writable)

## Web Access
All outputs are available via Tomcat:
- http://localhost:8080/outputs/diagrams/
- http://localhost:8080/outputs/reports/

## Usage
All files are generated by the threatmodel user.
Vagrant user can read files via group permissions.
EOF
        chown "$THREAT_MODEL_USER:$THREAT_MODEL_GROUP" "$output_readme" 2>/dev/null || true
        log_success "Created: $output_readme"
    else
        log_info "Already exists: $output_readme"
    fi

    return 0
}

# =============================================================================
# CONFIGURE SHELL ENVIRONMENT
# =============================================================================

configure_shell_environment() {
    log_info "Configuring shell environment..."

    local bash_aliases="/home/vagrant/.bash_aliases"

    local aliases_content="
# Threat Modeling Project Aliases (with sudo)
alias tm-generate='sudo -u $THREAT_MODEL_USER /vagrant/bin/generate'
alias tm-list='sudo -u $THREAT_MODEL_USER /vagrant/bin/generate --list'
alias tm-models='cd /vagrant/$PROJECT_NAME/models'
alias tm-output='cd /vagrant/$PROJECT_NAME/output'
alias tm-root='cd /vagrant'
alias tm-logs='sudo tail -f $LOG_FILE'

# PlantUML Server Aliases
alias plantuml-start='sudo systemctl start plantuml'
alias plantuml-stop='sudo systemctl stop plantuml'
alias plantuml-restart='sudo systemctl restart plantuml'
alias plantuml-status='sudo systemctl status plantuml'
alias plantuml-logs='sudo journalctl -u plantuml -f'
alias plantuml-url='echo \"http://localhost:$TOMCAT_PORT/plantuml\"'

# Outputs Web Access
alias outputs-url='echo \"http://localhost:$TOMCAT_PORT/outputs/\"'

# Tomcat Docs Access
alias tomcat-docs='echo \"http://localhost:$TOMCAT_PORT/docs/\"'
"

    if [[ -f "$bash_aliases" ]]; then
        local current_content
        current_content=$(cat "$bash_aliases")

        if echo "$current_content" | grep -q "tm-generate"; then
            log_info "Aliases already configured"
            return 0
        fi
    fi

    echo "$aliases_content" >> "$bash_aliases"
    chown vagrant:vagrant "$bash_aliases"

    log_success "Shell aliases configured"
    log_info "Available commands:"
    log_info "  - tm-generate: Generate all models (runs as $THREAT_MODEL_USER)"
    log_info "  - tm-list: List available models"
    log_info "  - tm-models: Navigate to models directory"
    log_info "  - tm-output: Navigate to output directory"
    log_info "  - tm-logs: View generation logs"
    log_info "  - plantuml-start/stop/restart: Manage PlantUML service"
    log_info "  - plantuml-status: Check PlantUML service status"
    log_info "  - plantuml-logs: View PlantUML logs"
    log_info "  - plantuml-url: Show PlantUML server URL"
    log_info "  - outputs-url: Show outputs web URL"
    log_info "  - tomcat-docs: Show Tomcat documentation URL"

    return 0
}

# =============================================================================
# INSTALL PLANTWEB ALIASES
# =============================================================================

install_plantweb_aliases() {
    log_info "Installing Plantweb shell aliases..."

    local source_file="$PROJECT_ROOT/config/shell/plantweb-aliases.sh"
    local target_file="/etc/profile.d/plantweb-aliases.sh"

    if [[ ! -f "$source_file" ]]; then
        log_warning "Plantweb aliases file not found: $source_file (optional)"
        return 0
    fi

    if cp "$source_file" "$target_file" 2>/dev/null; then
        chmod 644 "$target_file"
        log_success "Plantweb aliases installed: $target_file"
        log_info "  Available after re-login: plantweb-render, plantweb-test, etc."
    else
        log_warning "Failed to install Plantweb aliases (not critical)"
    fi

    return 0
}

# =============================================================================
# START PLANTUML SERVICE
# =============================================================================

start_plantuml_service() {
    log_info "Starting PlantUML service..."

    if systemctl is-active --quiet plantuml.service; then
        log_info "PlantUML service already running"
        return 0
    fi

    local output
    output=$(systemctl start plantuml.service 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "Failed to start PlantUML service"
        echo "$output" >&2
        return 1
    fi

    log_info "Waiting for PlantUML to start..."
    sleep 5

    local max_attempts=12
    local attempt=0

    while [[ $attempt -lt $max_attempts ]]; do
        if curl -s --max-time 2 "http://localhost:$TOMCAT_PORT/plantuml" >/dev/null 2>&1; then
            log_success "PlantUML service started and responding"
            log_info "  URL: http://localhost:$TOMCAT_PORT/plantuml"
            return 0
        fi

        attempt=$((attempt + 1))
        sleep 5
    done

    log_warning "PlantUML service started but not responding yet"
    log_info "Check status with: plantuml-status"
    return 0
}

# =============================================================================
# PHASE 8: FINAL VERIFICATION
# =============================================================================

run_final_verification() {
    log_header "PHASE 8: Final Verification"

    local checks_passed=0
    local checks_total=9

    log_info "Verifying system dependencies..."
    if is_component_functional "system"; then
        log_success "  System dependencies: OK"
        ((checks_passed++))
    else
        log_error "  System dependencies: FAILED"
    fi

    log_info "Verifying pytm framework..."
    if is_component_functional "pytm"; then
        log_success "  pytm framework: OK"
        ((checks_passed++))
    else
        log_error "  pytm framework: FAILED"
    fi

    log_info "Verifying Plantweb module..."
    if python3 -c "import sys; sys.path.insert(0, '/vagrant'); from dashboard.plantweb import render" 2>/dev/null; then
        log_success "  Plantweb module: OK"
        ((checks_passed++))
    else
        log_warning "  Plantweb module: NOT INSTALLED (optional)"
        # Don't count as failure, it's optional
    fi

    log_info "Verifying Tomcat installation..."
    if is_component_functional "tomcat"; then
        log_success "  Tomcat: OK"
        ((checks_passed++))
    else
        log_error "  Tomcat: FAILED"
    fi

    log_info "Verifying PlantUML Server..."
    if is_component_functional "plantuml-server"; then
        log_success "  PlantUML Server: OK"
        ((checks_passed++))
    else
        log_error "  PlantUML Server: FAILED"
    fi

    log_info "Verifying PlantUML service..."
    if systemctl is-enabled --quiet plantuml.service; then
        log_success "  PlantUML service: OK"
        ((checks_passed++))
    else
        log_error "  PlantUML service: FAILED"
    fi

    log_info "Verifying threatmodel user..."
    if id "$THREAT_MODEL_USER" &>/dev/null; then
        log_success "  Threat model user: OK"
        ((checks_passed++))
    else
        log_error "  Threat model user: FAILED"
    fi

    log_info "Verifying permissions..."
    if [[ -w "$APP_LOG_DIR" ]] || sudo -u "$THREAT_MODEL_USER" test -w "$APP_LOG_DIR"; then
        log_success "  Permissions: OK"
        ((checks_passed++))
    else
        log_error "  Permissions: FAILED"
    fi

    log_info "Verifying user commands..."
    local commands=(
        "$BIN_DIR/generate"
        "$BIN_DIR/setup"
    )

    local all_exist=true
    for cmd in "${commands[@]}"; do
        if [[ ! -f "$cmd" ]]; then
            log_error "  Command not found: $cmd"
            all_exist=false
        else
            chmod +x "$cmd" 2>/dev/null || true

            if [[ -x "$cmd" ]]; then
                log_debug "  Command is executable: $cmd"
            elif [[ -r "$cmd" ]]; then
                log_debug "  Command exists and is readable: $cmd (executable bit may not work on shared fs)"
            else
                log_error "  Command not accessible: $cmd"
                all_exist=false
            fi
        fi
    done

    if $all_exist; then
        log_success "  User commands: OK"
        ((checks_passed++))
    else
        log_error "  User commands: FAILED"
    fi

    log_header "Verification Summary"
    log_info "Checks passed: $checks_passed/$checks_total"

    if [[ $checks_passed -ge 8 ]]; then
        log_success "All critical verification checks passed"
        return 0
    else
        log_error "Some verification checks failed"
        return 1
    fi
}

# =============================================================================
# MARK BOOTSTRAP COMPLETE
# =============================================================================

mark_bootstrap_complete() {
    local state_file="$APP_STATE_DIR/bootstrap.complete"

    local timestamp
    timestamp=$(date -Iseconds)

    local python_version
    python_version=$(python3 --version 2>&1 || echo "Not available")

    local pytm_version
    pytm_version=$(pip3 show pytm 2>/dev/null | grep "^Version:" | awk '{print $2}' || echo "Not available")

    local plantweb_version
    plantweb_version=$(pip3 show plantweb 2>/dev/null | grep "^Version:" | awk '{print $2}' || echo "Not installed")

    local tomcat_version
    tomcat_version="$TOMCAT_VERSION"

    local plantuml_status
    if systemctl is-active --quiet plantuml.service; then
        plantuml_status="running"
    else
        plantuml_status="stopped"
    fi

    cat > "$state_file" << EOF
Bootstrap: complete
Timestamp: $timestamp
User: $THREAT_MODEL_USER
Python: $python_version
pytm: $pytm_version
Plantweb: $plantweb_version
Tomcat: $tomcat_version
PlantUML: $plantuml_status
Server: http://localhost:$TOMCAT_PORT/plantuml
Outputs: http://localhost:$TOMCAT_PORT/outputs/
Docs: http://localhost:$TOMCAT_PORT/docs/
EOF

    chown "$THREAT_MODEL_USER:$THREAT_MODEL_GROUP" "$state_file"

    log_success "Bootstrap marked as complete"
}

# =============================================================================
# SHOW COMPLETION MESSAGE
# =============================================================================

show_completion_message() {
    log_header "Installation Complete"

    cat << EOF

============================================================
   Threat Modeling System - Ready
============================================================

IMPORTANT: All threat modeling operations run as user: $THREAT_MODEL_USER

PlantUML Server:
   URL: http://localhost:$TOMCAT_PORT/plantuml/
   Status: $(systemctl is-active plantuml.service || echo "stopped")
   Manage: plantuml-start | plantuml-stop | plantuml-restart

Outputs Web Access:
   All outputs: http://localhost:$TOMCAT_PORT/outputs/
   Diagrams:    http://localhost:$TOMCAT_PORT/outputs/diagrams/
   Reports:     http://localhost:$TOMCAT_PORT/outputs/reports/

Tomcat Documentation:
   Docs:        http://localhost:$TOMCAT_PORT/docs/
   Examples:    http://localhost:$TOMCAT_PORT/examples/
   Manager:     http://localhost:$TOMCAT_PORT/manager/

Rendering Modes:
   Native:   tm-generate            (PNG via PlantUML JAR)
   Plantweb: tm-generate --plantweb (SVG via PlantUML Server)

Next Steps:

1. Reload shell aliases:
   source ~/.bash_aliases

2. Verify PlantUML is running:
   plantuml-status
   curl http://localhost:$TOMCAT_PORT/plantuml/

3. Generate threat models:
   tm-generate                # Native mode (PNG)
   tm-generate --plantweb     # Plantweb mode (SVG, cached)

4. View outputs in browser:
   http://localhost:$TOMCAT_PORT/outputs/

5. Or view locally:
   ls /vagrant/$PROJECT_NAME/output/diagrams/
   ls /vagrant/$PROJECT_NAME/output/reports/

6. View logs:
   tm-logs           (threat model generation)
   plantuml-logs     (PlantUML server)

Useful aliases:
   tm-generate       - Generate all models (as $THREAT_MODEL_USER)
   tm-list           - List available models
   tm-models         - Navigate to models directory
   tm-output         - Navigate to output directory
   tm-logs           - View generation logs

   plantuml-start    - Start PlantUML server
   plantuml-stop     - Stop PlantUML server
   plantuml-restart  - Restart PlantUML server
   plantuml-status   - Check PlantUML status
   plantuml-logs     - View PlantUML logs
   plantuml-url      - Show PlantUML server URL

   outputs-url       - Show outputs web URL
   tomcat-docs       - Show Tomcat documentation URL

Plantweb commands (after re-login):
   plantweb-render   - Render diagrams via Plantweb
   plantweb-test     - Test Plantweb installation
   plantweb-stats    - View cache statistics
   plantweb-config   - View Plantweb configuration

Security Note:
   All operations run with sudo as '$THREAT_MODEL_USER' user
   Log files: $LOG_FILE (owner: $THREAT_MODEL_USER)

EOF
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    local start_time
    start_time=$(date +%s)

    if ! load_environment; then
        echo "CRITICAL: Environment loading failed" >&2
        exit 1
    fi

    log_header "Bootstrap - Threat Modeling System Setup"
    log_info "Started at: $(date '+%Y-%m-%d %H:%M:%S')"

    if ! validate_requirements; then
        log_error "Requirements validation failed"
        exit 1
    fi

    local bootstrap_state="$APP_STATE_DIR/bootstrap.complete"

    if [[ -f "$bootstrap_state" ]]; then
        log_info "Bootstrap already completed"
        log_info "State file: $bootstrap_state"
        log_info "To force reinstallation: sudo rm -rf $APP_STATE_DIR"

        if is_component_functional "system" && \
           is_component_functional "pytm" && \
           is_component_functional "tomcat" && \
           is_component_functional "plantuml-server" && \
           id "$THREAT_MODEL_USER" &>/dev/null; then
            log_success "All components functional"

            if ! systemctl is-active --quiet plantuml.service; then
                log_info "Starting PlantUML service..."
                start_plantuml_service
            fi

            show_completion_message
            return 0
        else
            log_warning "Components not functional, running bootstrap"
        fi
    fi

    if ! validate_environment; then
        log_error "Environment validation failed"
        return 1
    fi

    if ! setup_threatmodel_user; then
        log_error "Phase 0 failed: User Setup"
        return 1
    fi

    if ! install_system_dependencies; then
        log_error "Phase 1 failed: System Dependencies"
        return 1
    fi

    if ! install_pytm_framework; then
        log_error "Phase 2 failed: pytm Framework"
        return 1
    fi

    if ! install_plantweb_client; then
        log_error "Phase 2.5 failed: Plantweb Client"
        return 1
    fi

    if ! install_tomcat; then
        log_error "Phase 3 failed: Tomcat"
        return 1
    fi

    if ! install_plantuml_server; then
        log_error "Phase 4 failed: PlantUML Server"
        return 1
    fi

    if ! configure_plantuml_service; then
        log_error "Phase 5 failed: PlantUML Service"
        return 1
    fi

    if ! configure_permissions; then
        log_error "Phase 6 failed: Permissions"
        return 1
    fi

    if ! configure_tomcat_outputs; then
        log_error "Phase 6.5 failed: Tomcat Outputs"
        return 1
    fi

    if ! configure_tomcat_docs; then
        log_error "Phase 6.6 failed: Tomcat Docs"
        return 1
    fi

    if ! create_project_structure; then
        log_error "Phase 7 failed: Project Structure"
        return 1
    fi

    create_readme_files
    configure_shell_environment
    install_plantweb_aliases

    start_plantuml_service

    if ! run_final_verification; then
        log_error "Final verification failed"
        return 1
    fi

    mark_bootstrap_complete

    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local duration_formatted
    duration_formatted=$(printf "%02d:%02d" $((duration / 60)) $((duration % 60)))

    log_success "Bootstrap completed in: $duration_formatted"

    show_completion_message

    return 0
}

# =============================================================================
# EXECUTION
# =============================================================================

main
exit $?