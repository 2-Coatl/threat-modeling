#!/usr/bin/env bash
# infrastructure/scripts/setup/configure-plantuml-service.sh
# Configure PlantUML as systemd service

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

    if [[ ! -d "$TOMCAT_HOME" ]]; then
        log_error "Tomcat not found at: $TOMCAT_HOME"
        log_error "Run install-tomcat.sh first"
        return 1
    fi

    if ! id "$TOMCAT_USER" &>/dev/null; then
        log_error "User does not exist: $TOMCAT_USER"
        log_error "Run install-tomcat.sh first"
        return 1
    fi

    if ! command -v systemctl >/dev/null 2>&1; then
        log_error "systemctl not found - systemd required"
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
# CREATE SYSTEMD SERVICE
# =============================================================================

create_systemd_service() {
    log_info "Creating systemd service..."

    local service_file="/etc/systemd/system/plantuml.service"

    cat > "$service_file" << EOF
[Unit]
Description=PlantUML Server (Apache Tomcat)
Documentation=https://plantuml.com/
After=network.target

[Service]
Type=forking

User=$TOMCAT_USER
Group=$TOMCAT_USER

Environment="JAVA_HOME=$JAVA_HOME"
Environment="CATALINA_HOME=$TOMCAT_HOME"
Environment="CATALINA_BASE=$TOMCAT_HOME"
Environment="CATALINA_PID=$TOMCAT_HOME/temp/tomcat.pid"
Environment="GRAPHVIZ_DOT=/usr/bin/dot"

ExecStart=$TOMCAT_HOME/bin/startup.sh
ExecStop=$TOMCAT_HOME/bin/shutdown.sh

Restart=on-failure
RestartSec=10

# Security settings
PrivateTmp=true
NoNewPrivileges=true

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=plantuml

[Install]
WantedBy=multi-user.target
EOF

    chmod 644 "$service_file"

    log_success "Systemd service created: $service_file"

    return 0
}

# =============================================================================
# CREATE LOG DIRECTORY
# =============================================================================

create_log_directory() {
    log_info "Creating log directory..."

    local log_dir="/var/log/plantuml"

    if [[ ! -d "$log_dir" ]]; then
        mkdir -p "$log_dir"
    fi

    chown "$TOMCAT_USER:$TOMCAT_USER" "$log_dir"
    chmod 755 "$log_dir"

    log_success "Log directory configured: $log_dir"

    return 0
}

# =============================================================================
# CONFIGURE LOGROTATE
# =============================================================================

configure_logrotate() {
    log_info "Configuring logrotate..."

    local logrotate_file="/etc/logrotate.d/plantuml"

    cat > "$logrotate_file" << EOF
$TOMCAT_HOME/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 $TOMCAT_USER $TOMCAT_USER
    sharedscripts
    postrotate
        if [ -f $TOMCAT_HOME/temp/tomcat.pid ]; then
            kill -USR1 \$(cat $TOMCAT_HOME/temp/tomcat.pid)
        fi
    endscript
}

/var/log/plantuml/*.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
    create 0640 $TOMCAT_USER $TOMCAT_USER
}
EOF

    chmod 644 "$logrotate_file"

    log_success "Logrotate configured: $logrotate_file"

    return 0
}

# =============================================================================
# RELOAD SYSTEMD
# =============================================================================

reload_systemd() {
    log_info "Reloading systemd daemon..."

    local output
    output=$(systemctl daemon-reload 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "Failed to reload systemd"
        echo "$output" >&2
        return 1
    fi

    log_success "Systemd daemon reloaded"

    return 0
}

# =============================================================================
# ENABLE SERVICE
# =============================================================================

enable_service() {
    log_info "Enabling plantuml service..."

    local output
    output=$(systemctl enable plantuml.service 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "Failed to enable service"
        echo "$output" >&2
        return 1
    fi

    log_success "Service enabled for autostart"

    return 0
}

# =============================================================================
# CREATE MANAGEMENT ALIASES
# =============================================================================

create_management_aliases() {
    log_info "Creating management commands..."

    local aliases_file="/etc/profile.d/plantuml-aliases.sh"

    cat > "$aliases_file" << 'EOF'
# PlantUML Server Management Aliases

alias plantuml-start='sudo systemctl start plantuml'
alias plantuml-stop='sudo systemctl stop plantuml'
alias plantuml-restart='sudo systemctl restart plantuml'
alias plantuml-status='sudo systemctl status plantuml'
alias plantuml-logs='sudo journalctl -u plantuml -f'
alias plantuml-url='echo "http://localhost:8080/plantuml"'
EOF

    chmod 644 "$aliases_file"

    log_success "Management commands configured"
    log_info "  Source: $aliases_file"
    log_info "Commands available after logout/login:"
    log_info "  plantuml-start    - Start the service"
    log_info "  plantuml-stop     - Stop the service"
    log_info "  plantuml-restart  - Restart the service"
    log_info "  plantuml-status   - Check service status"
    log_info "  plantuml-logs     - View live logs"
    log_info "  plantuml-url      - Show server URL"

    return 0
}

# =============================================================================
# TEST SERVICE CONFIGURATION
# =============================================================================

test_service_configuration() {
    log_info "Testing service configuration..."

    if ! systemctl is-enabled plantuml.service &>/dev/null; then
        log_error "Service not enabled"
        return 1
    fi

    log_info "Service unit status:"

    local unit_status
    unit_status=$(systemctl list-unit-files | grep plantuml.service || echo "not found")

    log_info "  $unit_status"

    log_success "Service configuration validated"

    return 0
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    log_header "PlantUML Service Configuration"

    create_systemd_service || return 1
    create_log_directory || return 1
    configure_logrotate || return 1
    reload_systemd || return 1
    enable_service || return 1
    create_management_aliases || return 1
    test_service_configuration || return 1

    log_success "PlantUML service configuration completed"

    log_info "Summary:"
    log_info "  Service: plantuml.service"
    log_info "  User: $TOMCAT_USER"
    log_info "  Home: $TOMCAT_HOME"
    log_info "  Logs: /var/log/plantuml"
    log_info "  Port: $TOMCAT_PORT"

    log_info "ACCION REQUERIDA: Start service with:"
    log_info "  sudo systemctl start plantuml"
    log_info "  plantuml-start (after re-login)"

    log_info "Verify with:"
    log_info "  curl http://localhost:$TOMCAT_PORT/plantuml"

    return 0
}

# =============================================================================
# EXECUTION
# =============================================================================

main "$@"
exit $?