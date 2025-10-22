#!/bin/bash
# config/shell/diagram-service-aliases.sh
# Shell aliases for Diagram Service
# This file will be copied to /etc/profile.d/ during bootstrap

# Service management
alias diagram-start='sudo systemctl start diagram-service'
alias diagram-stop='sudo systemctl stop diagram-service'
alias diagram-restart='sudo systemctl restart diagram-service'
alias diagram-status='sudo systemctl status diagram-service'
alias diagram-logs='sudo journalctl -u diagram-service -f'

# Quick access
alias diagram-url='echo "http://localhost:5000"'
alias diagram-health='curl -s http://localhost:5000/health | python3 -m json.tool'
alias diagram-open='xdg-open http://localhost:5000 2>/dev/null || echo "Open http://localhost:5000 in your browser"'

# Directory navigation
alias diagram-dir='cd /vagrant/dashboard'
alias diagram-history='cd /vagrant/dashboard/history'
alias diagram-templates='cd /vagrant/dashboard/templates'

# Logs
alias diagram-access-log='sudo tail -f /var/log/diagram-service/access.log'
alias diagram-error-log='sudo tail -f /var/log/diagram-service/error.log'

# Git history commands
alias diagram-git='cd /vagrant/dashboard/history && git'
alias diagram-git-log='cd /vagrant/dashboard/history && git log --oneline --graph --all'
alias diagram-git-status='cd /vagrant/dashboard/history && git status'

# Development
alias diagram-dev='cd /vagrant/dashboard && python3 app.py'
alias diagram-test='curl -s http://localhost:5000/api/diagrams | python3 -m json.tool'

# Help
alias diagram-help='cat << EOF
Diagram Service Commands:

Service Management:
  diagram-start         - Start the service
  diagram-stop          - Stop the service
  diagram-restart       - Restart the service
  diagram-status        - Check service status
  diagram-logs          - View live logs

Access:
  diagram-url           - Show service URL
  diagram-health        - Check health status
  diagram-open          - Open in browser (if GUI available)

Navigation:
  diagram-dir           - Go to app directory
  diagram-history       - Go to history directory
  diagram-templates     - Go to templates directory

Logs:
  diagram-access-log    - View access logs
  diagram-error-log     - View error logs

Git History:
  diagram-git           - Run git commands in history dir
  diagram-git-log       - View commit history
  diagram-git-status    - View git status

Development:
  diagram-dev           - Run in development mode
  diagram-test          - Test API endpoints

Web Interface:
  http://localhost:5000               - Main editor
  http://localhost:5000/diagrams      - List all diagrams
  http://localhost:5000/diagram/NAME  - View diagram history
  http://localhost:5000/health        - Health check

EOF
'