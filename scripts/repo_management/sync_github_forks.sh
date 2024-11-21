#!/bin/bash

# Function to check if the GitHub CLI is installed
check_gh_cli_installed() {
    if ! command -v gh &> /dev/null; then
        echo "GitHub CLI (gh) is not installed. Please install it first."
        exit 1
    fi
}

# Authenticate with GitHub CLI if needed
authenticate_github_cli() {
    echo "Checking GitHub CLI authentication..."
    if ! gh auth status &> /dev/null; then
        echo "You are not logged into GitHub CLI. Please log in."
        gh auth login
    else
        echo "GitHub CLI authenticated successfully."
    fi
}

# Fetch all repositories and sync the forked ones
sync_forked_repositories() {
    echo "Fetching list of repositories..."
    repos=$(gh repo list --limit 1000 --json name,isFork,defaultBranchRef,owner --template "{{range .}}{{if .isFork}}{{.owner.login}}/{{.name}} {{.defaultBranchRef.name}}{{\"\n\"}}{{end}}{{end}}")

    if [[ -z "$repos" ]]; then
        echo "No forked repositories found."
        exit 0
    fi

    echo "Found the following forked repositories:"
    echo "$repos"

    # Loop through each forked repository and sync
    echo "Starting sync process for forked repositories..."
    while IFS= read -r repo; do
        repo_full_name=$(echo "$repo" | awk '{print $1}')
        branch_name=$(echo "$repo" | awk '{print $2}')
        
        echo "Syncing repository: $repo_full_name on branch: $branch_name"
        gh repo sync "$repo_full_name" --branch "$branch_name"

        if [[ $? -eq 0 ]]; then
            echo "Successfully synced $repo_full_name."
        else
            echo "Failed to sync $repo_full_name."
        fi
    done <<< "$repos"

    echo "Sync process completed."
}

# Main script execution
check_gh_cli_installed
authenticate_github_cli
sync_forked_repositories
