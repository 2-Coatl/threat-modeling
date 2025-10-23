#!/usr/bin/env bash
# Configure Tomcat documentation and manager apps access

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

    if [[ ! -d "$TOMCAT_HOME" ]]; then
        log_error "Tomcat not found at: $TOMCAT_HOME"
        return 1
    fi

    local webapps_dir="$TOMCAT_HOME/webapps"
    if [[ ! -d "$webapps_dir" ]]; then
        log_error "Webapps directory not found: $webapps_dir"
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
# CONFIGURE DOCS ACCESS
# =============================================================================

configure_docs_access() {
    log_info "Configuring documentation access..."

    local context_dir="$TOMCAT_HOME/conf/Catalina/localhost"
    local docs_context="$context_dir/docs.xml"

    if [[ ! -d "$context_dir" ]]; then
        mkdir -p "$context_dir"
        chown -R "$TOMCAT_USER:$TOMCAT_USER" "$context_dir"
    fi

    cat > "$docs_context" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true">
    <!-- Allow access from any IP -->
    <Valve className="org.apache.catalina.valves.RemoteAddrValve"
           allow=".*" />
</Context>
EOF

    chown "$TOMCAT_USER:$TOMCAT_USER" "$docs_context"
    chmod 644 "$docs_context"

    log_success "Documentation access configured: $docs_context"

    return 0
}

# =============================================================================
# CONFIGURE EXAMPLES ACCESS
# =============================================================================

configure_examples_access() {
    log_info "Configuring examples access..."

    local context_dir="$TOMCAT_HOME/conf/Catalina/localhost"
    local examples_context="$context_dir/examples.xml"

    cat > "$examples_context" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true">
    <!-- Allow access from any IP -->
    <Valve className="org.apache.catalina.valves.RemoteAddrValve"
           allow=".*" />
</Context>
EOF

    chown "$TOMCAT_USER:$TOMCAT_USER" "$examples_context"
    chmod 644 "$examples_context"

    log_success "Examples access configured: $examples_context"

    return 0
}

# =============================================================================
# CONFIGURE MANAGER ACCESS
# =============================================================================

configure_manager_access() {
    log_info "Configuring manager access..."

    local context_dir="$TOMCAT_HOME/conf/Catalina/localhost"
    local manager_context="$context_dir/manager.xml"

    cat > "$manager_context" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true">
    <!-- Allow access from any IP -->
    <Valve className="org.apache.catalina.valves.RemoteAddrValve"
           allow=".*" />
</Context>
EOF

    chown "$TOMCAT_USER:$TOMCAT_USER" "$manager_context"
    chmod 644 "$manager_context"

    log_success "Manager access configured: $manager_context"

    return 0
}

# =============================================================================
# CONFIGURE HOST-MANAGER ACCESS
# =============================================================================

configure_host_manager_access() {
    log_info "Configuring host-manager access..."

    local context_dir="$TOMCAT_HOME/conf/Catalina/localhost"
    local host_manager_context="$context_dir/host-manager.xml"

    cat > "$host_manager_context" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true">
    <!-- Allow access from any IP -->
    <Valve className="org.apache.catalina.valves.RemoteAddrValve"
           allow=".*" />
</Context>
EOF

    chown "$TOMCAT_USER:$TOMCAT_USER" "$host_manager_context"
    chmod 644 "$host_manager_context"

    log_success "Host-manager access configured: $host_manager_context"

    return 0
}

# =============================================================================
# RELOAD TOMCAT
# =============================================================================

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

# =============================================================================
# VERIFY ACCESS
# =============================================================================

verify_access() {
    log_info "Verifying access to Tomcat applications..."

    local base_url="http://localhost:$TOMCAT_PORT"
    local apps=(
        "docs"
        "examples"
        "manager"
        "host-manager"
    )

    local max_attempts=6
    local attempt=0

    while [[ $attempt -lt $max_attempts ]]; do
        local all_ok=true

        for app in "${apps[@]}"; do
            if curl -sf --max-time 2 "${base_url}/${app}/" >/dev/null 2>&1; then
                log_success "Application reachable: ${base_url}/${app}/"
            else
                all_ok=false
                log_debug "Application not ready yet: ${base_url}/${app}/"
            fi
        done

        if [[ "$all_ok" == "true" ]]; then
            log_success "All applications accessible"
            return 0
        fi

        attempt=$((attempt + 1))
        if [[ $attempt -lt $max_attempts ]]; then
            sleep 5
        fi
    done

    log_warning "Some applications not accessible (may not be deployed)"

    return 0
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    log_header "Tomcat Documentation Access Configuration"

    configure_docs_access || return 1
    configure_examples_access || return 1
    configure_manager_access || return 1
    configure_host_manager_access || return 1
    reload_tomcat || return 1
    verify_access || return 0

    log_success "Tomcat documentation access configuration completed"

    log_info "Access Tomcat applications from host machine:"
    log_info "  Documentation:  http://localhost:$TOMCAT_PORT/docs/"
    log_info "  Examples:       http://localhost:$TOMCAT_PORT/examples/"
    log_info "  Manager:        http://localhost:$TOMCAT_PORT/manager/"
    log_info "  Host Manager:   http://localhost:$TOMCAT_PORT/host-manager/"

    log_info "Note: Manager apps require authentication"
    log_info "      Configure users in: $TOMCAT_HOME/conf/tomcat-users.xml"

    return 0
}

# =============================================================================
# EXECUTION
# =============================================================================

main "$@"
exit $?