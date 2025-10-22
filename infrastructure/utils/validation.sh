#!/usr/bin/env bash
# infrastructure/utils/validation.sh - Common validation functions

# Prevent multiple sourcing
if [[ "${VALIDATION_LOADED:-}" == "true" ]]; then
    return 0
fi

# ============================================================================
# SUDO AND PERMISSIONS
# ============================================================================

check_sudo_access() {
    if [[ "${EUID}" -eq 0 ]]; then
        return 0
    fi

    if sudo -n true 2>/dev/null; then
        return 0
    else
        echo "ERROR: Sudo access required" >&2
        echo "Run: sudo -v" >&2
        return 1
    fi
}

validate_sudo_noninteractive() {
    local _sudo_output

    _sudo_output=$(sudo -n true 2>&1)

    if echo "${_sudo_output}" | grep -q "password is required"; then
        return 1
    else
        return 0
    fi
}

get_user_info() {
    local _info_user
    local _info_home
    local _info_groups

    _info_user=$(whoami)
    _info_home=$(eval echo "~${_info_user}")
    _info_groups=$(groups "${_info_user}" 2>/dev/null || echo "unknown")

    echo "User: ${_info_user}"
    echo "Home: ${_info_home}"
    echo "Groups: ${_info_groups}"
}

user_in_group() {
    local _group_user="${1}"
    local _group_name="${2}"
    local _group_list

    _group_list=$(groups "${_group_user}" 2>/dev/null)

    if echo "${_group_list}" | grep -qw "${_group_name}"; then
        return 0
    else
        return 1
    fi
}

# ============================================================================
# FILE AND DIRECTORY CHECKS
# ============================================================================

check_write_permission() {
    local _write_dir="${1}"

    if [[ ! -d "${_write_dir}" ]]; then
        return 1
    fi

    if [[ -w "${_write_dir}" ]]; then
        return 0
    else
        return 1
    fi
}

check_read_permission() {
    local _read_file="${1}"

    if [[ ! -f "${_read_file}" ]]; then
        return 1
    fi

    if [[ -r "${_read_file}" ]]; then
        return 0
    else
        return 1
    fi
}

# ============================================================================
# COMMAND CHECKS
# ============================================================================

command_exists() {
    local _cmd_name="${1}"

    if command -v "${_cmd_name}" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# ============================================================================
# PYTHON VALIDATION
# ============================================================================

validate_python_version() {
    local _py_min_major="${1}"
    local _py_min_minor="${2}"

    if ! command_exists python3; then
        return 1
    fi

    local _py_version
    _py_version=$(python3 --version 2>&1 | awk '{print $2}')

    local _py_major
    local _py_minor

    _py_major=$(echo "${_py_version}" | cut -d. -f1)
    _py_minor=$(echo "${_py_version}" | cut -d. -f2)

    if [[ "${_py_major}" -gt "${_py_min_major}" ]]; then
        return 0
    elif [[ "${_py_major}" -eq "${_py_min_major}" ]] && [[ "${_py_minor}" -ge "${_py_min_minor}" ]]; then
        return 0
    else
        return 1
    fi
}

validate_python_module() {
    local _module_name="${1}"

    if python3 -c "import ${_module_name}" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# ============================================================================
# DIRECTORY STRUCTURE VALIDATION
# ============================================================================

validate_directory_structure() {
    local _base_path="${1}"
    shift
    local _required_dirs=("$@")

    local _missing_dirs=()

    for _dir in "${_required_dirs[@]}"; do
        local _full_path="${_base_path}/${_dir}"

        if [[ ! -d "${_full_path}" ]]; then
            _missing_dirs+=("${_dir}")
        fi
    done

    if [[ ${#_missing_dirs[@]} -eq 0 ]]; then
        return 0
    else
        echo "Missing directories:" >&2
        printf '  - %s\n' "${_missing_dirs[@]}" >&2
        return 1
    fi
}

# ============================================================================
# FILE SIZE VALIDATION
# ============================================================================

validate_file_size() {
    local _file_path="${1}"
    local _min_size="${2}"

    if [[ ! -f "${_file_path}" ]]; then
        return 1
    fi

    local _file_size
    _file_size=$(stat -c%s "${_file_path}" 2>/dev/null || stat -f%z "${_file_path}" 2>/dev/null)

    if [[ "${_file_size}" -ge "${_min_size}" ]]; then
        return 0
    else
        return 1
    fi
}

# ============================================================================
# NETWORK VALIDATION
# ============================================================================

validate_network_connectivity() {
    local _test_host="${1:-8.8.8.8}"

    if ping -c 1 -W 2 "${_test_host}" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# ============================================================================
# MARK AS LOADED
# ============================================================================

readonly VALIDATION_LOADED="true"