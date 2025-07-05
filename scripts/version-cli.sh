#!/bin/bash

CONFIG_FILE="$(dirname "$0")/version.config.json"
SCRIPT_FILE="$(dirname "$0")/version.sh"
LOG_FILE="$(dirname "$0")/version.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_action() {
  local action="$1"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] $action" >> "$LOG_FILE"
}

if [ ! -f "$CONFIG_FILE" ]; then
  echo -e "${RED}Error: version.config.json not found.${NC}"
  exit 1
fi

# Read config values
CURRENT_VERSION=$(jq -r '.version' "$CONFIG_FILE")
PROJECT_NAME=$(jq -r '.project.displayName' "$CONFIG_FILE")

check_git_clean() {
  # Ignore log and config files
  local ignore_patterns=('version.log' 'version.config.json')
  local status_output
  status_output=$(git status --porcelain)
  
  # Filter out files listed in ignore_patterns
  for pattern in "${ignore_patterns[@]}"; do
    status_output=$(echo "$status_output" | grep -v "$pattern")
  done

  if [[ -n "$status_output" ]]; then
    echo -e "${RED}Working tree is not clean. Please commit or stash changes before continuing.${NC}"
    git status
    exit 1
  fi
}

# Check if there are commits since the latest version tag
commits_since_last_tag() {
  # Get latest tag that matches semantic versioning pattern vX.Y.Z
  local last_tag
  last_tag=$(git describe --tags --abbrev=0 2>/dev/null || true)
  if [[ -z "$last_tag" ]]; then
    # No tag yet – treat as first release
    echo 1
    return
  fi
  git rev-list "$last_tag"..HEAD --count
}

git_tag_version() {
  local version="$1"

  # Working tree was already checked before version bump; no need to re-check here

  # Commit all changes automatically
  git add .
  if ! git commit -m "Release v$version" &>/dev/null; then
    echo -e "${YELLOW}ℹ️  No changes to commit.${NC}"
  fi

  # Create or move tag to current commit
  if git rev-parse "v$version" >/dev/null 2>&1; then
    echo -e "${YELLOW}ℹ️  Tag v$version already exists. It will be updated to the latest commit.${NC}"
    git tag -d "v$version"
  fi

  git tag -a "v$version" -m "Release v$version"

  echo -e "${YELLOW}⚠️  Push tag v$version to origin? (y/N)${NC}"
  read -r confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo -e "${RED}🚫 Operation cancelled.${NC}"
    return
  fi

  git push --force origin "v$version"

  echo -e "${GREEN}✅ Git tag v$version pushed successfully.${NC}"
}

configure_project() {
  echo -e "${YELLOW}📝 Project Configuration${NC}"
  echo -e "${CYAN}Current project name: $PROJECT_NAME${NC}"
  
  read -rp "Enter new project name: " new_name
  read -rp "Enter new display name: " new_display
  
  if [ -z "$new_name" ] || [ -z "$new_display" ]; then
    echo -e "${RED}❌ Both names are required!${NC}"
    return
  fi
  
  # Update config using jq
  if command -v jq > /dev/null; then
    jq --arg name "$new_name" \
       --arg display "$new_display" \
       '.project.name = $name | .project.displayName = $display' \
       "$CONFIG_FILE" > tmp.json && mv tmp.json "$CONFIG_FILE"
    
    PROJECT_NAME="$new_display"
    echo -e "${GREEN}✅ Project updated successfully!${NC}"
  else
    echo -e "${RED}❌ jq is required for this operation. Please install jq.${NC}"
  fi
}

reset_version_interactive() {
  echo -e "${YELLOW}⚠️  This will reset version to 1.0.0 and CLEAR ALL HISTORY!${NC}"
  read -rp "Are you sure? (type 'RESET' to confirm): " confirm
  
  if [ "$confirm" == "RESET" ]; then
    "$SCRIPT_FILE" reset
    CURRENT_VERSION="1.0.0"
    log_action "RESET version to 1.0.0"
    echo -e "${GREEN}✅ Version reset to 1.0.0${NC}"
  else
    echo -e "${RED}🚫 Reset cancelled${NC}"
  fi
}

print_menu() {
  echo -e "${YELLOW}=============================="
  echo -e "  🚀 $PROJECT_NAME"
  echo -e "  🔖 Current version: ${CYAN}$CURRENT_VERSION${YELLOW}"
  echo -e "==============================${NC}"
  echo "1) 📜 Show version history"
  echo "2) 🔹 Update patch version"
  echo "3) 🔶 Update minor version"
  echo "4) 🔴 Update major version"
  echo "5) ✏️  Set specific version"
  echo "6) 🔄 Reset to 1.0.0"
  echo "7) ⚙️  Configure project"
  echo "8) ❓ Help"
  echo "9) 👋 Exit"
  echo
}

while true; do
  clear
  print_menu
  read -rp "Select an option [1-9]: " choice
  case $choice in
    1)
      "$SCRIPT_FILE" history
      ;;
    2)
      check_git_clean
      if [[ $(commits_since_last_tag) -eq 0 ]]; then
        echo -e "${YELLOW}ℹ️  No new commits since last tag. Nothing to release.${NC}"
        read -rp "Press Enter to continue..."
        continue
      fi
      "$SCRIPT_FILE" patch
      CURRENT_VERSION=$(jq -r '.version' "$CONFIG_FILE")
      log_action "Updated patch version to $CURRENT_VERSION"
      git_tag_version "$CURRENT_VERSION"
      ;;
    3)
      check_git_clean
      if [[ $(commits_since_last_tag) -eq 0 ]]; then
        echo -e "${YELLOW}ℹ️  No new commits since last tag. Nothing to release.${NC}"
        read -rp "Press Enter to continue..."
        continue
      fi
      "$SCRIPT_FILE" minor
      CURRENT_VERSION=$(jq -r '.version' "$CONFIG_FILE")
      log_action "Updated minor version to $CURRENT_VERSION"
      git_tag_version "$CURRENT_VERSION"
      ;;
    4)
      check_git_clean
      if [[ $(commits_since_last_tag) -eq 0 ]]; then
        echo -e "${YELLOW}ℹ️  No new commits since last tag. Nothing to release.${NC}"
        read -rp "Press Enter to continue..."
        continue
      fi
      "$SCRIPT_FILE" major
      CURRENT_VERSION=$(jq -r '.version' "$CONFIG_FILE")
      log_action "Updated major version to $CURRENT_VERSION"
      git_tag_version "$CURRENT_VERSION"
      ;;
    5)
      read -rp "Enter the version you want to set (e.g. 1.2.3): " new_version
      check_git_clean
      "$SCRIPT_FILE" set "$new_version"
      CURRENT_VERSION="$new_version"
      log_action "Set version to $new_version"
      git_tag_version "$new_version"
      ;;
    6)
      reset_version_interactive
      ;;
    7)
      configure_project
      ;;
    8)
      "$SCRIPT_FILE" help
      ;;
    9)
      echo -e "${GREEN}👋 Goodbye!${NC}"
      exit 0
      ;;
  esac
  echo
  read -rp "Press Enter to continue..."
done
