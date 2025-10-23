#!/usr/bin/env bash
# infrastructure/scripts/installation/install-tomcat.sh
# Install Apache Tomcat web server

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

    if ! command -v java >/dev/null 2>&1; then
        log_error "Java not found - run install-system-dependencies.sh first"
        return 1
    fi

    if ! command -v wget >/dev/null 2>&1; then
        log_error "wget not found - run install-system-dependencies.sh first"
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

verify_tomcat_functional() {
    if [[ ! -d "$TOMCAT_HOME" ]]; then
        return 1
    fi

    if [[ ! -f "$TOMCAT_HOME/bin/catalina.sh" ]]; then
        return 1
    fi

    if [[ ! -x "$TOMCAT_HOME/bin/catalina.sh" ]]; then
        return 1
    fi

    local version_output
    version_output=$("$TOMCAT_HOME/bin/catalina.sh" version 2>&1 || echo "")

    if ! echo "$version_output" | grep -q "Apache Tomcat"; then
        return 1
    fi

    return 0
}

# =============================================================================
# STEP 1: CREATE TOMCAT USER
# =============================================================================

create_tomcat_user() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Creating Tomcat user"

    if id "$TOMCAT_USER" &>/dev/null; then
        log_info "User already exists: $TOMCAT_USER"
        return 0
    fi

    if ! useradd \
        --system \
        --create-home \
        --home-dir "$TOMCAT_USER_HOME" \
        --shell /bin/false \
        --comment "Apache Tomcat Service User" \
        "$TOMCAT_USER"; then
        log_error "Failed to create user: $TOMCAT_USER"
        return 1
    fi

    log_success "User created: $TOMCAT_USER"

    local user_info
    user_info=$(id "$TOMCAT_USER")
    log_info "  $user_info"

    return 0
}

# =============================================================================
# STEP 2: DOWNLOAD TOMCAT
# =============================================================================

download_tomcat() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Downloading Tomcat $TOMCAT_VERSION"

    local tomcat_archive="apache-tomcat-${TOMCAT_VERSION}.tar.gz"
    local download_url="$TOMCAT_MIRROR/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/${tomcat_archive}"
    local temp_dir="/tmp/tomcat-install-$$"

    if [[ -d "$TOMCAT_HOME" ]] && verify_tomcat_functional; then
        log_info "Tomcat already installed at: $TOMCAT_HOME"
        return 0
    fi

    mkdir -p "$temp_dir"

    log_info "Downloading from: $download_url"

    local output
    output=$(wget -O "$temp_dir/$tomcat_archive" "$download_url" 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "Failed to download Tomcat"
        echo "$output" >&2
        rm -rf "$temp_dir"
        return 1
    fi

    if [[ ! -f "$temp_dir/$tomcat_archive" ]]; then
        log_error "Downloaded file not found"
        rm -rf "$temp_dir"
        return 1
    fi

    local file_size
    file_size=$(stat -c%s "$temp_dir/$tomcat_archive" 2>/dev/null)

    if [[ $file_size -lt 1000000 ]]; then
        log_error "Downloaded file too small: $file_size bytes"
        rm -rf "$temp_dir"
        return 1
    fi

    log_info "Downloading checksum file..."

    local sha512_url="${download_url}.sha512"
    local sha512_file="$temp_dir/$tomcat_archive.sha512"

    if wget -O "$sha512_file" "$sha512_url" 2>/dev/null; then
        log_info "Verifying checksum..."

        local expected_sha512
        expected_sha512=$(cat "$sha512_file" | awk '{print $1}')

        local actual_sha512
        actual_sha512=$(sha512sum "$temp_dir/$tomcat_archive" | awk '{print $1}')

        if [[ "$actual_sha512" != "$expected_sha512" ]]; then
            log_error "Checksum mismatch"
            log_error "  Expected: $expected_sha512"
            log_error "  Got: $actual_sha512"
            rm -rf "$temp_dir"
            return 1
        fi

        log_success "Tomcat downloaded and verified"
        log_info "  Size: $((file_size / 1024 / 1024)) MB"
        log_info "  Checksum: OK"
    else
        log_warning "Could not download checksum file, skipping verification"
        log_success "Tomcat downloaded (checksum not verified)"
        log_info "  Size: $((file_size / 1024 / 1024)) MB"
    fi

    return 0
}

# =============================================================================
# STEP 3: EXTRACT AND INSTALL
# =============================================================================

extract_and_install() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Extracting and installing Tomcat"

    local tomcat_archive="apache-tomcat-${TOMCAT_VERSION}.tar.gz"
    local temp_dir="/tmp/tomcat-install-$$"

    if [[ -d "$TOMCAT_HOME" ]]; then
        log_info "Removing old installation..."
        rm -rf "$TOMCAT_HOME"
    fi

    local install_dir
    install_dir=$(dirname "$TOMCAT_HOME")

    if [[ ! -d "$install_dir" ]]; then
        if ! mkdir -p "$install_dir"; then
            log_error "Failed to create: $install_dir"
            rm -rf "$temp_dir"
            return 1
        fi
    fi

    log_info "Extracting to: $install_dir"

    local output
    output=$(tar -xzf "$temp_dir/$tomcat_archive" -C "$install_dir" 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "Failed to extract Tomcat"
        echo "$output" >&2
        rm -rf "$temp_dir"
        return 1
    fi

    local extracted_dir="$install_dir/apache-tomcat-${TOMCAT_VERSION}"

    if [[ ! -d "$extracted_dir" ]]; then
        log_error "Extracted directory not found"
        rm -rf "$temp_dir"
        return 1
    fi

    if [[ "$extracted_dir" != "$TOMCAT_HOME" ]]; then
        mv "$extracted_dir" "$TOMCAT_HOME"
    fi

    rm -rf "$temp_dir"

    log_success "Tomcat extracted"
    log_info "  Location: $TOMCAT_HOME"

    return 0
}

# =============================================================================
# STEP 4: CONFIGURE PERMISSIONS
# =============================================================================

configure_permissions() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Configuring permissions"

    log_info "Setting ownership to: $TOMCAT_USER"

    chown -R "$TOMCAT_USER:$TOMCAT_USER" "$TOMCAT_HOME"

    chmod -R u+rwX,g+rX,o+rX "$TOMCAT_HOME"

    chmod +x "$TOMCAT_HOME/bin/"*.sh

    log_success "Permissions configured"

    return 0
}

# =============================================================================
# STEP 5: CONFIGURE TOMCAT
# =============================================================================

configure_tomcat() {
    local step="$1"
    local total="$2"

    log_step "$step" "$total" "Configuring Tomcat"

    local server_xml="$TOMCAT_HOME/conf/server.xml"

    if [[ ! -f "$server_xml" ]]; then
        log_error "server.xml not found"
        return 1
    fi

    log_info "Configuring connector port: $TOMCAT_PORT"

    sed -i "s/port=\"8080\"/port=\"$TOMCAT_PORT\"/" "$server_xml"

    log_info "Configuring shutdown port: $TOMCAT_SHUTDOWN_PORT"

    sed -i "s/port=\"8005\"/port=\"$TOMCAT_SHUTDOWN_PORT\"/" "$server_xml"

    local setenv_sh="$TOMCAT_HOME/bin/setenv.sh"

    cat > "$setenv_sh" << EOF
#!/bin/bash
# Tomcat Environment Configuration

export JAVA_HOME=$JAVA_HOME
export CATALINA_HOME=$TOMCAT_HOME
export CATALINA_BASE=$TOMCAT_HOME
export CATALINA_PID=$TOMCAT_HOME/temp/tomcat.pid

# JVM Options
export JAVA_OPTS="-Djava.awt.headless=true"
export JAVA_OPTS="\$JAVA_OPTS -Xms${TOMCAT_MEMORY_MIN}"
export JAVA_OPTS="\$JAVA_OPTS -Xmx${TOMCAT_MEMORY_MAX}"
export JAVA_OPTS="\$JAVA_OPTS -XX:+UseG1GC"

# Security Manager (disabled for PlantUML)
export CATALINA_OPTS=""
EOF

    chmod +x "$setenv_sh"
    chown "$TOMCAT_USER:$TOMCAT_USER" "$setenv_sh"

    log_success "Tomcat configured"
    log_info "  HTTP port: $TOMCAT_PORT"
    log_info "  Shutdown port: $TOMCAT_SHUTDOWN_PORT"
    log_info "  Memory: ${TOMCAT_MEMORY_MIN}-${TOMCAT_MEMORY_MAX}"

    return 0
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    log_header "Tomcat Installation"

    if is_component_functional "tomcat"; then
        log_success "Tomcat already functional"
        log_info "Skipping installation (idempotence)"
        return 0
    fi

    log_info "Tomcat not functional, proceeding with installation"

    create_tomcat_user 1 5 || return 1
    download_tomcat 2 5 || return 1
    extract_and_install 3 5 || return 1
    configure_permissions 4 5 || return 1
    configure_tomcat 5 5 || return 1

    if verify_tomcat_functional; then
        log_success "Tomcat installation verified"
        mark_installation_state "tomcat"

        log_info "Installation details:"
        log_info "  Home: $TOMCAT_HOME"
        log_info "  User: $TOMCAT_USER"
        log_info "  Port: $TOMCAT_PORT"
        log_info "  Version: $TOMCAT_VERSION"

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