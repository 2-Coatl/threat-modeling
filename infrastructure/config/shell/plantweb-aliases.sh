#!/bin/bash
# infrastructure/config/shell/plantweb-aliases.sh
# Shell aliases for Plantweb
# This file will be copied to /etc/profile.d/ during bootstrap

# Plantweb rendering commands
alias plantweb-render='/vagrant/infrastructure/bin/plantweb-render'
alias plantweb-test='bash /vagrant/infrastructure/scripts/test-plantweb.sh'

# Configuration commands
alias plantweb-config='plantweb-render --config'
alias plantweb-server='echo ${PLANTUML_SERVER:-http://localhost:8080/plantuml}'

# Cache management
alias plantweb-clear-cache='plantweb-render --clear-cache'
alias plantweb-stats='plantweb-render --stats'
alias plantweb-cache-dir='echo ${PLANTWEB_CACHE_DIR:-~/.cache/plantweb}'

# Quick rendering
alias pw-render='plantweb-render'
alias pw-svg='plantweb-render --format svg'
alias pw-png='plantweb-render --format png'

# Threat model generation with Plantweb
alias tm-generate-plantweb='tm-generate --plantweb'
alias tm-generate-native='tm-generate --native'

# Help
alias plantweb-help='plantweb-render --help'
