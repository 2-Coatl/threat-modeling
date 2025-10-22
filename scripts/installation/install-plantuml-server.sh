#!/usr/bin/env bash
# scripts/installation/install-plantuml-server.sh
# Install PlantUML Server WAR application

set -euo pipefail

# =============================================================================
# INITIALIZATION
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# =============================================================================
# GLOBAL VARIABLES
# =============================================================================

# Use a fixed temporary file location instead of $$
TEMP_WAR_FILE="/tmp/plantuml-install-$(date +%s).war"

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

    if ! command -v wget >/dev/null 2>&1; then
        log_error "wget not found - run install-system-dependencies.sh first"
        return 1
    fi

    if [[ ! -d "$TOMCAT_HOME" ]]; then
        log_error "Tomcat not found at: $TOMCAT_HOME"
        log_error "Run install-tomcat.sh first"
        return 1
    fi

    if ! command -v dot >/dev/null 2>&1; then
        log_error "Graphviz not found - run install-system-dependencies.sh first"
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

verify_plantuml_server_functional() {
    local war_file="$TOMCAT_HOME/webapps/plantuml.war"

    if [[ ! -f "$war_file" ]]; then
        return 1
    fi

    local file_size
    file_size=$(stat -c%s "$war_file" 2>/dev/null || echo "0")

    if [[ $file_size -lt 1000000 ]]; then
        return 1
    fi

    return 0
}

# =============================================================================
# STEP 1: DOWNLOAD PLANTUML WAR
# =============================================================================

download_plantuml_war() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Downloading PlantUML Server WAR"

    local download_success=false

    # Strategy 1: Try specific version from PLANTUML_WAR_VERSION
    if [[ -n "${PLANTUML_WAR_VERSION:-}" ]]; then
        local war_url="https://github.com/plantuml/plantuml-server/releases/download/${PLANTUML_WAR_VERSION}/plantuml-jsp-${PLANTUML_WAR_VERSION}.war"
        log_info "Trying version ${PLANTUML_WAR_VERSION}: $war_url"

        set +e
        wget -O "$TEMP_WAR_FILE" "$war_url" >/dev/null 2>&1
        local exit_code=$?
        set -e

        if [[ $exit_code -eq 0 ]] && [[ -f "$TEMP_WAR_FILE" ]]; then
            download_success=true
            log_info "Downloaded specific version successfully"
        fi
    fi

    # Strategy 2: Try latest release (fallback)
    if [[ "$download_success" == "false" ]]; then
        log_info "Trying latest release from GitHub..."

        # Get latest release version from GitHub API
        local latest_version
        latest_version=$(curl -s https://api.github.com/repos/plantuml/plantuml-server/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

        if [[ -n "$latest_version" ]]; then
            local war_url="https://github.com/plantuml/plantuml-server/releases/download/${latest_version}/plantuml-jsp-${latest_version}.war"
            log_info "Detected latest version: ${latest_version}"
            log_info "Downloading from: $war_url"

            set +e
            wget -O "$TEMP_WAR_FILE" "$war_url" >/dev/null 2>&1
            local exit_code=$?
            set -e

            if [[ $exit_code -eq 0 ]] && [[ -f "$TEMP_WAR_FILE" ]]; then
                download_success=true
                log_info "Downloaded latest version successfully"
            fi
        fi
    fi

    # Check if download was successful
    if [[ "$download_success" == "false" ]] || [[ ! -f "$TEMP_WAR_FILE" ]]; then
        log_error "Failed to download PlantUML WAR from all sources"
        rm -f "$TEMP_WAR_FILE"
        return 1
    fi

    local file_size
    file_size=$(stat -c%s "$TEMP_WAR_FILE" 2>/dev/null)

    if [[ $file_size -lt 1000000 ]]; then
        log_error "Downloaded file too small: $file_size bytes"
        rm -f "$TEMP_WAR_FILE"
        return 1
    fi

    log_success "PlantUML WAR downloaded"
    log_info "  Size: $((file_size / 1024 / 1024)) MB"
    log_info "  Location: $TEMP_WAR_FILE"

    return 0
}

# =============================================================================
# STEP 2: VERIFY WAR INTEGRITY
# =============================================================================

verify_war_integrity() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Verifying WAR integrity"

    if [[ ! -f "$TEMP_WAR_FILE" ]]; then
        log_error "WAR file not found: $TEMP_WAR_FILE"
        return 1
    fi

    if ! command -v unzip >/dev/null 2>&1; then
        log_info "Installing unzip..."
        apt-get install -y unzip >/dev/null 2>&1
    fi

    log_info "Testing WAR file integrity..."

    local output
    set +e
    output=$(unzip -t "$TEMP_WAR_FILE" 2>&1)
    local exit_code=$?
    set -e

    if [[ $exit_code -ne 0 ]]; then
        log_error "WAR file is corrupted"
        echo "$output" >&2
        rm -f "$TEMP_WAR_FILE"
        return 1
    fi

    if ! echo "$output" | grep -q "WEB-INF"; then
        log_error "Invalid WAR structure"
        rm -f "$TEMP_WAR_FILE"
        return 1
    fi

    log_success "WAR integrity verified"

    return 0
}

# =============================================================================
# STEP 3: DEPLOY TO TOMCAT
# =============================================================================

deploy_to_tomcat() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Deploying to Tomcat"

    local webapps_dir="$TOMCAT_HOME/webapps"
    local war_file="$webapps_dir/plantuml.war"
    local exploded_dir="$webapps_dir/plantuml"

    if [[ ! -d "$webapps_dir" ]]; then
        log_error "Tomcat webapps directory not found: $webapps_dir"
        rm -f "$TEMP_WAR_FILE"
        return 1
    fi

    if [[ ! -f "$TEMP_WAR_FILE" ]]; then
        log_error "Temporary WAR file not found: $TEMP_WAR_FILE"
        return 1
    fi

    if [[ -f "$war_file" ]]; then
        log_info "Removing existing WAR file..."
        rm -f "$war_file"
    fi

    if [[ -d "$exploded_dir" ]]; then
        log_info "Removing existing exploded directory..."
        rm -rf "$exploded_dir"
    fi

    log_info "Copying WAR to webapps..."

    if ! cp "$TEMP_WAR_FILE" "$war_file"; then
        log_error "Failed to copy WAR file"
        rm -f "$TEMP_WAR_FILE"
        return 1
    fi

    if [[ ! -f "$war_file" ]]; then
        log_error "WAR file not created in webapps"
        rm -f "$TEMP_WAR_FILE"
        return 1
    fi

    chown "$TOMCAT_USER:$TOMCAT_USER" "$war_file"
    chmod 644 "$war_file"

    # Clean up temporary file
    rm -f "$TEMP_WAR_FILE"

    log_success "PlantUML deployed to Tomcat"
    log_info "  Location: $war_file"

    return 0
}

# =============================================================================
# STEP 4: CONFIGURE PLANTUML
# =============================================================================

configure_plantuml() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Configuring PlantUML"

    local config_file="$TOMCAT_HOME/conf/Catalina/localhost/plantuml.xml"
    local config_dir
    config_dir=$(dirname "$config_file")

    if [[ ! -d "$config_dir" ]]; then
        mkdir -p "$config_dir"
        chown -R "$TOMCAT_USER:$TOMCAT_USER" "$config_dir"
    fi

    cat > "$config_file" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Context path="/plantuml">
    <!-- PlantUML Context Configuration -->

    <!-- Increase timeout for large diagrams -->
    <Parameter name="PLANTUML_LIMIT_SIZE" value="8192" override="false"/>

    <!-- Enable Graphviz -->
    <Parameter name="GRAPHVIZ_DOT" value="/usr/bin/dot" override="false"/>

    <!-- Security: Disable remote includes -->
    <Parameter name="ALLOW_PLANTUML_INCLUDE" value="false" override="false"/>
</Context>
EOF

    chown "$TOMCAT_USER:$TOMCAT_USER" "$config_file"
    chmod 644 "$config_file"

    log_success "PlantUML configured"
    log_info "  Config: $config_file"

    return 0
}

# =============================================================================
# STEP 5: CREATE SYSTEMD OVERRIDE
# =============================================================================

create_systemd_override() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Creating systemd override for PlantUML"

    local override_dir="/etc/systemd/system/plantuml.service.d"
    local override_file="$override_dir/graphviz.conf"

    if [[ ! -d "$override_dir" ]]; then
        mkdir -p "$override_dir"
    fi

    cat > "$override_file" << EOF
[Service]
# Ensure Graphviz is available to PlantUML
Environment="GRAPHVIZ_DOT=/usr/bin/dot"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
EOF

    chmod 644 "$override_file"

    log_success "Systemd override created"
    log_info "  Override: $override_file"

    return 0
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    log_header "PlantUML Server Installation"

    if is_component_functional "plantuml-server"; then
        log_success "PlantUML Server already functional"
        log_info "Skipping installation (idempotence)"
        return 0
    fi

    log_info "PlantUML Server not functional, proceeding with installation"

    download_plantuml_war 1 5 || return 1
    verify_war_integrity 2 5 || return 1
    deploy_to_tomcat 3 5 || return 1
    configure_plantuml 4 5 || return 1
    create_systemd_override 5 5 || return 1

    if verify_plantuml_server_functional; then
        log_success "PlantUML Server installation verified"
        mark_installation_state "plantuml-server"

        log_info "Installation details:"
        log_info "  WAR: $TOMCAT_HOME/webapps/plantuml.war"
        log_info "  URL: http://localhost:$TOMCAT_PORT/plantuml"
        log_info "  Graphviz: $(command -v dot)"

        log_info "ACCION REQUERIDA: Start Tomcat with: sudo systemctl start plantuml"

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