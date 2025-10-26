#!/usr/bin/env bash
# infrastructure/scripts/setup/configure-diagram-service.sh
# Configure Diagram Service as systemd service

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

    if ! command -v systemctl >/dev/null 2>&1; then
        log_error "systemctl not found - systemd required"
        return 1
    fi

    if ! python3 -c "import flask" 2>/dev/null; then
        log_error "Flask not installed - run install-diagram-service.sh first"
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

    local service_file="/etc/systemd/system/diagram-service.service"

    cat > "$service_file" << EOF
[Unit]
Description=Diagram Service - Flask Web Interface for PlantUML
Documentation=https://flask.palletsprojects.com/
After=network.target plantuml.service

[Service]
Type=simple
User=$THREAT_MODEL_USER
Group=$THREAT_MODEL_GROUP

# Working directory
WorkingDirectory=$PROJECT_ROOT/api

# Environment variables
Environment="PYTHONUNBUFFERED=1"
Environment="FLASK_APP=app.py"
Environment="FLASK_ENV=production"
Environment="PLANTUML_SERVER=http://localhost:$TOMCAT_PORT/plantuml"

# Start command - using gunicorn for production
ExecStart=/usr/local/bin/gunicorn \\
    --bind 0.0.0.0:5000 \\
    --workers 2 \\
    --timeout 120 \\
    --access-logfile /var/log/diagram-service/access.log \\
    --error-logfile /var/log/diagram-service/error.log \\
    --log-level info \\
    app:app

# Restart policy
Restart=on-failure
RestartSec=10

# Security settings
PrivateTmp=true
NoNewPrivileges=true

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=diagram-service

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

    local log_dir="/var/log/diagram-service"

    if [[ ! -d "$log_dir" ]]; then
        mkdir -p "$log_dir"
    fi

    chown "$THREAT_MODEL_USER:$THREAT_MODEL_GROUP" "$log_dir"
    chmod 755 "$log_dir"

    log_success "Log directory configured: $log_dir"

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
    log_info "Enabling diagram-service..."

    local output
    output=$(systemctl enable diagram-service.service 2>&1)
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
# START SERVICE
# =============================================================================

start_service() {
    log_info "Starting diagram-service..."

    if systemctl is-active --quiet diagram-service.service; then
        log_info "Service already running, restarting..."
        systemctl restart diagram-service.service
    else
        systemctl start diagram-service.service
    fi

    sleep 3

    if systemctl is-active --quiet diagram-service.service; then
        log_success "Service started successfully"
        return 0
    else
        log_error "Service failed to start"
        systemctl status diagram-service.service --no-pager || true
        return 1
    fi
}

# =============================================================================
# VERIFY SERVICE
# =============================================================================

verify_service() {
    log_info "Verifying service accessibility..."

    local max_attempts=6
    local attempt=0

    while [[ $attempt -lt $max_attempts ]]; do
        if curl -sf --max-time 2 "http://localhost:5000/health" >/dev/null 2>&1; then
            log_success "Service accessible at http://localhost:5000"
            return 0
        fi

        attempt=$((attempt + 1))
        if [[ $attempt -lt $max_attempts ]]; then
            sleep 5
        fi
    done

    log_warning "Could not verify service accessibility"
    log_info "Check manually: http://localhost:5000"

    return 0
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    log_header "Diagram Service Configuration"

    create_systemd_service || return 1
    create_log_directory || return 1
    reload_systemd || return 1
    enable_service || return 1
    start_service || return 1
    verify_service || return 0

    log_success "Diagram service configuration completed"

    cat << EOF
------------------------------------------------------------
  Diagram Service - Configuration Complete
------------------------------------------------------------

Access the service:
  - Web Interface:  http://localhost:5000
  - API Health:     http://localhost:5000/health
  - API Docs:       See app.py for endpoints

Service management:
  - Start:   sudo systemctl start diagram-service
  - Stop:    sudo systemctl stop diagram-service
  - Restart: sudo systemctl restart diagram-service
  - Status:  sudo systemctl status diagram-service
  - Logs:    sudo journalctl -u diagram-service -f

Log files:
  - Access:  /var/log/diagram-service/access.log
  - Error:   /var/log/diagram-service/error.log

Configuration:
  - Service: /etc/systemd/system/diagram-service.service
  - App Dir: $PROJECT_ROOT/api
  - History: $PROJECT_ROOT/api/history

------------------------------------------------------------
EOF

    return 0
}

# =============================================================================
# EXECUTION
# =============================================================================

main "$@"
exit $?