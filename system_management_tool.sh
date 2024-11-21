#!/bin/bash

LOG_FILE="/var/log/system_management_tool.log"
exec > >(tee -a "$LOG_FILE") 2>&1

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

usage() {
    echo "Usage: $0 [module] [action]"
    echo "Modules:"
    echo "  maintenance     - Perform system maintenance (update, clean, etc.)"
    echo "  setup           - Set up development tools and environments"
    echo "  backup          - Manage backups and audits"
    echo "  repo_management - Sync GitHub repositories"
    echo ""
    echo "Actions vary by module. Run '$0 [module] help' for details."
    exit 0
}

if [[ $# -lt 2 ]]; then
    usage
fi

MODULE="$1"
ACTION="$2"

case "$MODULE" in
    maintenance)
        case "$ACTION" in
            update)
                bash scripts/maintenance/system_update_manager.sh
                ;;
            report)
                bash scripts/maintenance/generate_installed_packages_report.sh
                ;;
            *)
                echo "Unknown action for maintenance: $ACTION"
                usage
                ;;
        esac
        ;;
    setup)
        case "$ACTION" in
            vscode)
                bash scripts/setup/install_vscode_extensions.sh
                ;;
            gpu)
                bash scripts/setup/gpu_setup_manager.sh
                ;;
            *)
                echo "Unknown action for setup: $ACTION"
                usage
                ;;
        esac
        ;;
    backup)
        case "$ACTION" in
            usb_backup)
                bash scripts/backup/daily_usb_backup.sh
                ;;
            audit)
                bash scripts/backup/package_audit.sh
                ;;
            *)
                echo "Unknown action for backup: $ACTION"
                usage
                ;;
        esac
        ;;
    repo_management)
        case "$ACTION" in
            sync)
                bash scripts/repo_management/sync_github_forks.sh
                ;;
            *)
                echo "Unknown action for repo_management: $ACTION"
                usage
                ;;
        esac
        ;;
    *)
        echo "Unknown module: $MODULE"
        usage
        ;;
esac
