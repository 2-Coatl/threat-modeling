#!/bin/bash
# infrastructure/config/shell/oci-runtime-aliases.sh
# Shell aliases for the configured OCI runtime (Podman)
# This file is copied to /etc/profile.d/ during bootstrap

# Runtime binary aliases
alias oci="${OCI_RUNTIME_BIN:-podman}"
alias oci-version="${OCI_RUNTIME_BIN:-podman} --version"
alias oci-info="${OCI_RUNTIME_BIN:-podman} info"
alias oci-ps="${OCI_RUNTIME_BIN:-podman} ps --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}'"
alias oci-images="${OCI_RUNTIME_BIN:-podman} images"
alias oci-pull="${OCI_RUNTIME_BIN:-podman} pull"

# Systemd integration
alias oci-socket-status="sudo systemctl status ${OCI_RUNTIME_SERVICE:-podman.socket}"
alias oci-socket-restart="sudo systemctl restart ${OCI_RUNTIME_SERVICE:-podman.socket}"

# Threat model user helpers
alias oci-rootless-shell="sudo -u ${THREAT_MODEL_USER:-threatmodel} -H ${OCI_RUNTIME_BIN:-podman} info"
