#!/usr/bin/env bash
# config/variables.sh - Global project variables
# This file is sourced by all scripts and must not have dependencies

# Prevent multiple sourcing
if [[ "${VARIABLES_LOADED:-}" == "true" ]]; then
    return 0
fi

# ============================================================================
# PROJECT PATHS
# ============================================================================

# Project root - resolved from config/ directory
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Project name
readonly PROJECT_NAME="dashboard"

# Main directories
readonly APP_BASE_DIR="/opt/dashboard"
readonly APP_LOG_DIR="/var/log/dashboard"
readonly APP_STATE_DIR="/var/lib/dashboard/state"
readonly APP_CACHE_DIR="/var/cache/dashboard"

# Project structure
readonly MODELS_DIR="${PROJECT_ROOT}/${PROJECT_NAME}/models"
readonly OUTPUT_DIR="${PROJECT_ROOT}/${PROJECT_NAME}/output"
readonly TEMPLATES_DIR="${PROJECT_ROOT}/${PROJECT_NAME}/templates"
readonly DIAGRAMS_DIR="${OUTPUT_DIR}/diagrams"
readonly REPORTS_DIR="${OUTPUT_DIR}/reports"

# Infrastructure directories
readonly SCRIPTS_DIR="${PROJECT_ROOT}/scripts"
readonly INSTALL_SCRIPTS_DIR="${SCRIPTS_DIR}/installation"
readonly SETUP_SCRIPTS_DIR="${SCRIPTS_DIR}/setup"
readonly UTILS_DIR="${PROJECT_ROOT}/infrastructure/utils"
readonly CONFIG_DIR="${PROJECT_ROOT}/config"
readonly BIN_DIR="${PROJECT_ROOT}/bin"

# ============================================================================
# SYSTEM USER CONFIGURATION
# ============================================================================

readonly THREAT_MODEL_USER="threatmodel"
readonly THREAT_MODEL_GROUP="threatmodel"
readonly THREAT_MODEL_HOME="/home/threatmodel"
readonly THREAT_MODEL_SHELL="/bin/bash"
readonly THREAT_MODEL_GROUPS="adm"

# ============================================================================
# PERMISSION CONFIGURATION
# ============================================================================

readonly DIR_PERMISSIONS="755"
readonly DIR_PERMISSIONS_SHARED="775"
readonly FILE_PERMISSIONS="644"
readonly EXEC_PERMISSIONS="755"
readonly LOG_PERMISSIONS="640"

# ============================================================================
# LOGGING CONFIGURATION
# ============================================================================

readonly LOG_FILE="${APP_LOG_DIR}/threatmodel.log"
readonly LOG_LEVEL="${LOG_LEVEL:-INFO}"
readonly LOG_MAX_SIZE=$((10 * 1024 * 1024))  # 10MB

# ============================================================================
# INSTALLATION CONFIGURATION
# ============================================================================

# Timeouts (seconds)
readonly INSTALL_TIMEOUT=1800  # 30 minutes
readonly COMMAND_TIMEOUT=300   # 5 minutes

# =============================================================================
# OCI RUNTIME CONFIGURATION
# =============================================================================

readonly OCI_RUNTIME_NAME="${OCI_RUNTIME_NAME:-Podman}"
readonly OCI_RUNTIME_BIN="${OCI_RUNTIME_BIN:-podman}"
readonly OCI_RUNTIME_SERVICE="${OCI_RUNTIME_SERVICE:-podman.socket}"
readonly OCI_RUNTIME_GROUP="${OCI_RUNTIME_GROUP:-podman}"
readonly OCI_RUNTIME_LOG_DIR="${OCI_RUNTIME_LOG_DIR:-/var/log/${OCI_RUNTIME_BIN}}"
readonly OCI_STORAGE_ROOT="${OCI_STORAGE_ROOT:-/var/lib/containers/storage}"
readonly OCI_RUN_ROOT="${OCI_RUN_ROOT:-/run/containers/storage}"

# PlantUML configuration
readonly PLANTUML_VERSION="1.2024.3"
readonly PLANTUML_JAR="/usr/share/plantuml/plantuml.jar"
readonly PLANTUML_URL="https://sourceforge.net/projects/plantuml/files/plantuml.jar/download"

# Python configuration
readonly PYTHON_MIN_MAJOR=3
readonly PYTHON_MIN_MINOR=6

# ============================================================================
# SUDOERS CONFIGURATION
# ============================================================================

readonly SUDOERS_FILE="/etc/sudoers.d/threatmodel"
readonly ALLOWED_COMMANDS=(
    "${BIN_DIR}/generate"
    "/usr/bin/python3"
)

# ============================================================================
# SYSTEM CONFIGURATION
# ============================================================================

# Debian frontend (for apt-get)
export DEBIAN_FRONTEND=noninteractive

# ============================================================================
# VALIDATION
# ============================================================================

# Validate critical variables
_validate_vars() {
    local _validate_required=(
        "PROJECT_ROOT"
        "THREAT_MODEL_USER"
        "APP_LOG_DIR"
    )

    local _validate_missing=()

    for _validate_var in "${_validate_required[@]}"; do
        if [[ -z "${!_validate_var}" ]]; then
            _validate_missing+=("${_validate_var}")
        fi
    done

    if [[ ${#_validate_missing[@]} -gt 0 ]]; then
        echo "ERROR: Required variables not set:" >&2
        printf '  - %s\n' "${_validate_missing[@]}" >&2
        return 1
    fi

    return 0
}

# Run validation
if ! _validate_vars; then
    echo "CRITICAL: Variable validation failed" >&2
    return 1
fi

# Mark as loaded
VARIABLES_LOADED="true"

# ============================================================================
# EXPORT VARIABLES FOR CHILD PROCESSES
# ============================================================================

# Project paths
export PROJECT_ROOT
export PROJECT_NAME
export APP_BASE_DIR
export APP_LOG_DIR
export APP_STATE_DIR
export APP_CACHE_DIR
export MODELS_DIR
export OUTPUT_DIR
export TEMPLATES_DIR
export DIAGRAMS_DIR
export REPORTS_DIR

# Infrastructure directories
export SCRIPTS_DIR
export INSTALL_SCRIPTS_DIR
export SETUP_SCRIPTS_DIR
export UTILS_DIR
export CONFIG_DIR
export BIN_DIR

# System user configuration
export THREAT_MODEL_USER
export THREAT_MODEL_GROUP
export THREAT_MODEL_HOME
export THREAT_MODEL_SHELL
export THREAT_MODEL_GROUPS

# Permission configuration
export DIR_PERMISSIONS
export DIR_PERMISSIONS_SHARED
export FILE_PERMISSIONS
export EXEC_PERMISSIONS
export LOG_PERMISSIONS

# Logging configuration
export LOG_FILE
export LOG_LEVEL
export LOG_MAX_SIZE

# Installation configuration
export INSTALL_TIMEOUT
export COMMAND_TIMEOUT
export PLANTUML_VERSION
export PLANTUML_JAR
export PLANTUML_URL
export PYTHON_MIN_MAJOR
export PYTHON_MIN_MINOR

# OCI runtime configuration
export OCI_RUNTIME_NAME
export OCI_RUNTIME_BIN
export OCI_RUNTIME_SERVICE
export OCI_RUNTIME_GROUP
export OCI_RUNTIME_LOG_DIR
export OCI_STORAGE_ROOT
export OCI_RUN_ROOT

# Sudoers configuration
export SUDOERS_FILE

# =============================================================================
# TOMCAT CONFIGURATION
# =============================================================================

export TOMCAT_VERSION="10.1.47"
export TOMCAT_MAJOR="10"
export TOMCAT_MIRROR="https://dlcdn.apache.org"

export TOMCAT_HOME="/opt/tomcat"
export TOMCAT_USER="tomcat"
export TOMCAT_USER_HOME="/home/tomcat"
export TOMCAT_PORT="8080"
export TOMCAT_SHUTDOWN_PORT="8005"

# JVM Memory Settings
export TOMCAT_MEMORY_MIN="512M"
export TOMCAT_MEMORY_MAX="1024M"

# =============================================================================
# PLANTUML SERVER CONFIGURATION
# =============================================================================

export PLANTUML_WAR_VERSION="v1.2025.7"
export PLANTUML_SERVER="http://localhost:${TOMCAT_PORT}/plantuml"

# =============================================================================
# JAVA CONFIGURATION
# =============================================================================

# Auto-detect Java home if not set
if [[ -z "${JAVA_HOME:-}" ]]; then
    if command -v java >/dev/null 2>&1; then
        JAVA_BIN=$(command -v java)
        export JAVA_HOME=$(dirname $(dirname $(readlink -f "$JAVA_BIN")))
    else
        export JAVA_HOME="/usr/lib/jvm/default-java"
    fi
fi

# ============================================================================
# PLANTWEB CONFIGURATION
# ============================================================================
# Add these lines at the end of config/variables.sh

# Plantweb version (latest or specific version like 1.2.0)
export PLANTWEB_VERSION="${PLANTWEB_VERSION:-latest}"

# PlantUML Server URL for Plantweb
export PLANTWEB_SERVER="${PLANTWEB_SERVER:-${PLANTUML_SERVER}}"
export PLANTWEB_SERVER_URL="${PLANTWEB_SERVER_URL:-${PLANTWEB_SERVER}}"

# Plantweb cache directory
export PLANTWEB_CACHE_DIR="${PLANTWEB_CACHE_DIR:-${HOME}/.cache/plantweb}"

# Default rendering engine (plantuml, graphviz, ditaa, auto)
export PLANTWEB_ENGINE="${PLANTWEB_ENGINE:-plantuml}"

# Default output format (svg, png, txt)
export PLANTWEB_FORMAT="${PLANTWEB_FORMAT:-svg}"

# Enable Plantweb cache
export PLANTWEB_USE_CACHE="${PLANTWEB_USE_CACHE:-true}"

# Cache maximum age in days
export PLANTWEB_CACHE_MAX_AGE="${PLANTWEB_CACHE_MAX_AGE:-30}"

# HTTP timeout in seconds
export PLANTWEB_TIMEOUT="${PLANTWEB_TIMEOUT:-60}"

# Global flag to use Plantweb in tm-generate (default: false)
export USE_PLANTWEB="${USE_PLANTWEB:-false}"