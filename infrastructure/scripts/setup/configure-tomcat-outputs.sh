#!/usr/bin/env bash
################################################################################
# infrastructure/scripts/setup/configure-tomcat-outputs.sh
#
# Configure Tomcat to serve threat model outputs via web interface
#
# Features:
#   - Installs outputs context from template
#   - Enables directory listings in Tomcat web.xml
#   - Sets proper permissions for output directories
#   - Validates configuration and web accessibility
#
# Usage: sudo ./configure-tomcat-outputs.sh
################################################################################

set -euo pipefail

#===============================================================================
# INITIALIZATION
#===============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

#===============================================================================
# LOAD ENVIRONMENT
#===============================================================================

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

#===============================================================================
# VALIDATE PREREQUISITES
#===============================================================================

validate_prerequisites() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        return 1
    fi

    if [[ ! -d "$TOMCAT_HOME" ]]; then
        log_error "Tomcat not found at: $TOMCAT_HOME"
        return 1
    fi

    if [[ ! -d "$OUTPUT_DIR" ]]; then
        log_error "Output directory not found: $OUTPUT_DIR"
        return 1
    fi

    # Check if context template exists
    local template="$PROJECT_ROOT/infrastructure/config/tomcat/outputs-context.xml"
    if [[ ! -f "$template" ]]; then
        log_error "Context template not found: $template"
        return 1
    fi

    return 0
}

#===============================================================================
# LOAD AND VALIDATE
#===============================================================================

if ! load_environment; then
    exit 1
fi

if ! validate_prerequisites; then
    exit 1
fi

#===============================================================================
# CREATE TOMCAT CONTEXT FOR OUTPUTS
#===============================================================================

create_outputs_context() {
    log_info "Creating Tomcat context for outputs..."

    local context_dir="$TOMCAT_HOME/conf/Catalina/localhost"
    local context_file="$context_dir/outputs.xml"
    local template="$PROJECT_ROOT/infrastructure/config/tomcat/outputs-context.xml"

    # Create context directory if needed
    if [[ ! -d "$context_dir" ]]; then
        mkdir -p "$context_dir"
        chown -R "$TOMCAT_USER:$TOMCAT_USER" "$context_dir"
    fi

    # Copy template to context location
    cp "$template" "$context_file"

    # Set ownership and permissions
    chown "$TOMCAT_USER:$TOMCAT_USER" "$context_file"
    chmod 644 "$context_file"

    log_success "Outputs context created: $context_file"

    return 0
}

#===============================================================================
# ENABLE DIRECTORY LISTINGS IN TOMCAT
#===============================================================================

enable_directory_listings() {
    log_info "Enabling directory listings in Tomcat..."

    local web_xml="$TOMCAT_HOME/conf/web.xml"
    local backup="$web_xml.backup"

    # Create backup if it doesn't exist
    if [[ ! -f "$backup" ]]; then
        cp "$web_xml" "$backup"
        log_info "Created backup: $backup"
    fi

    # Check if listings already enabled
    if grep -q '<param-name>listings</param-name>' "$web_xml" && \
       grep -A1 '<param-name>listings</param-name>' "$web_xml" | grep -q '<param-value>true</param-value>'; then
        log_info "Directory listings already enabled"
        return 0
    fi

    # Enable listings using sed
    sed -i '/<servlet-name>default<\/servlet-name>/,/<\/servlet>/{
        /<param-name>listings<\/param-name>/,/<\/init-param>/ {
            s/<param-value>false<\/param-value>/<param-value>true<\/param-value>/
        }
    }' "$web_xml"

    # Verify change was applied
    if grep -A1 '<param-name>listings</param-name>' "$web_xml" | grep -q '<param-value>true</param-value>'; then
        log_success "Directory listings enabled in web.xml"
        return 0
    else
        log_error "Failed to enable directory listings"
        log_error "Manual edit required: $web_xml"
        return 1
    fi
}

#===============================================================================
# CONFIGURE OUTPUT DIRECTORY PERMISSIONS
#===============================================================================

configure_output_permissions() {
    log_info "Configuring output directory permissions..."

    local diagrams_dir="$OUTPUT_DIR/diagrams"
    local reports_dir="$OUTPUT_DIR/reports"

    # Set directory permissions (755 = rwxr-xr-x)
    chmod 755 "$OUTPUT_DIR"
    chmod 755 "$diagrams_dir" 2>/dev/null || true
    chmod 755 "$reports_dir" 2>/dev/null || true

    # Set file permissions (644 = rw-r--r--)
    find "$diagrams_dir" -type f -exec chmod 644 {} \; 2>/dev/null || true
    find "$reports_dir" -type f -exec chmod 644 {} \; 2>/dev/null || true

    log_success "Permissions configured"

    return 0
}

#===============================================================================
# RELOAD TOMCAT
#===============================================================================

reload_tomcat() {
    log_info "Reloading Tomcat to apply changes..."

    local reload_output
    set +e
    reload_output=$(systemctl reload plantuml 2>&1)
    local exit_code=$?
    set -e

    if [[ $exit_code -ne 0 ]]; then
        log_warning "Reload failed, attempting restart..."

        set +e
        systemctl restart plantuml
        exit_code=$?
        set -e

        if [[ $exit_code -ne 0 ]]; then
            log_error "Failed to restart Tomcat"
            return 1
        fi
    fi

    log_info "Waiting for Tomcat to be ready..."
    sleep 5

    log_success "Tomcat reloaded"

    return 0
}

#===============================================================================
# VERIFY OUTPUTS ACCESSIBLE
#===============================================================================

verify_outputs_accessible() {
    log_info "Verifying outputs are accessible..."

    local max_attempts=6
    local attempt=0
    local base_url="http://localhost:$TOMCAT_PORT"

    # Test endpoints
    local endpoints=(
        "/outputs/"
        "/outputs/diagrams/"
        "/outputs/reports/"
    )

    while [[ $attempt -lt $max_attempts ]]; do
        local all_ok=true

        for endpoint in "${endpoints[@]}"; do
            if ! curl -sf --max-time 2 "${base_url}${endpoint}" >/dev/null 2>&1; then
                all_ok=false
                break
            fi
        done

        if [[ "$all_ok" == "true" ]]; then
            log_success "All outputs endpoints accessible"
            for endpoint in "${endpoints[@]}"; do
                log_success "Endpoint reachable: ${base_url}${endpoint}"
            done
            return 0
        fi

        attempt=$((attempt + 1))
        if [[ $attempt -lt $max_attempts ]]; then
            sleep 5
        fi
    done

    log_warning "Could not verify all outputs accessibility"
    log_warning "Check manually: ${base_url}/outputs/"

    return 0
}

#===============================================================================
# MAIN FUNCTION
#===============================================================================

main() {
    log_header "Tomcat Outputs Configuration"

    create_outputs_context || return 1
    enable_directory_listings || return 1
    configure_output_permissions || return 1
    reload_tomcat || return 1
    verify_outputs_accessible || return 0

    log_success "Tomcat outputs configuration completed"

    cat << EOF
------------------------------------------------------------
  Tomcat Outputs - Configuration Complete
------------------------------------------------------------

Access outputs via web browser:
  - All outputs:  http://localhost:$TOMCAT_PORT/outputs/
  - Diagrams:     http://localhost:$TOMCAT_PORT/outputs/diagrams/
  - Reports:      http://localhost:$TOMCAT_PORT/outputs/reports/

Configuration files:
  - Context:      $TOMCAT_HOME/conf/Catalina/localhost/outputs.xml
  - Web config:   $TOMCAT_HOME/conf/web.xml
  - Backup:       $TOMCAT_HOME/conf/web.xml.backup

Output directories:
  - Base:         $OUTPUT_DIR/
  - Diagrams:     $OUTPUT_DIR/diagrams/
  - Reports:      $OUTPUT_DIR/reports/

------------------------------------------------------------
EOF

    return 0
}

#===============================================================================
# EXECUTION
#===============================================================================

main "$@"
exit $?