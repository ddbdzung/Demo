#!/bin/bash

# Version Management CLI Script
# Usage: ./version.sh <command> [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="dashboard-service-fnb"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/version.config.json"
PACKAGE_JSON="$SCRIPT_DIR/../package.json"
VERSION_FILE="$SCRIPT_DIR/../versions/dev.md"
BUILD_SCRIPT="$SCRIPT_DIR/../build.sh"
DOCKER_REGISTRY="registry.smax.in/smaxfnb/smaxfnb_product"

# Helper functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration functions
read_config() {
    local key=$1
    local default_value=$2
    
    if [ -f "$CONFIG_FILE" ]; then
        if command -v jq > /dev/null; then
            local value=$(jq -r "$key" "$CONFIG_FILE" 2>/dev/null)
            if [ "$value" != "null" ] && [ "$value" != "" ]; then
                echo "$value"
            else
                echo "$default_value"
            fi
        else
            # Fallback for systems without jq
            echo "$default_value"
        fi
    else
        echo "$default_value"
    fi
}

is_command_enabled() {
    local command=$1
    local enabled=$(read_config ".commands.enabled.$command" "true")
    if [ "$enabled" = "true" ]; then
        return 0
    else
        return 1
    fi
}

get_config_message() {
    local key=$1
    local default_message=$2
    read_config ".messages.$key" "$default_message"
}

check_command_enabled() {
    local command=$1
    if ! is_command_enabled "$command"; then
        local message=$(get_config_message "${command}_disabled" "Command '$command' is disabled in configuration")
        print_error "$message"
        exit 1
    fi
}

# Get current version from package.json
get_current_version() {
    if [ -f "$PACKAGE_JSON" ]; then
        node -pe "require('$PACKAGE_JSON').version"
    else
        print_error "package.json not found"
        exit 1
    fi
}

# Parse semantic version
parse_version() {
    local version=$1
    IFS='.' read -r major minor patch <<< "$version"
    echo "$major $minor $patch"
}

# Increment version based on type
increment_version() {
    local current_version=$1
    local increment_type=$2
    
    read -r major minor patch <<< "$(parse_version "$current_version")"
    
    case $increment_type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            print_error "Invalid increment type: $increment_type"
            exit 1
            ;;
    esac
    
    echo "$major.$minor.$patch"
}

# Update package.json version
update_package_json() {
    local new_version=$1
    
    if command -v jq > /dev/null; then
        jq --arg version "$new_version" '.version = $version' "$PACKAGE_JSON" > tmp.json && mv tmp.json "$PACKAGE_JSON"
    else
        # Fallback for systems without jq
        node -e "
            const fs = require('fs');
            const pkg = JSON.parse(fs.readFileSync('$PACKAGE_JSON', 'utf8'));
            pkg.version = '$new_version';
            fs.writeFileSync('$PACKAGE_JSON', JSON.stringify(pkg, null, 2) + '\n');
        "
    fi
    
    print_success "Updated package.json version to $new_version"
}

# Update version history
update_version_history() {
    local version=$1
    local message=$2
    local merge_request=$3
    
    local date=$(date +"%d/%m/%Y")
    local entry="# $date - $version\n- $message"
    
    if [ -n "$merge_request" ]; then
        entry="$entry\n=> $merge_request"
    fi
    
    # Create versions directory if it doesn't exist
    mkdir -p "$(dirname "$VERSION_FILE")"
    
    # Prepend new version to the file
    if [ -f "$VERSION_FILE" ]; then
        echo -e "$entry\n" | cat - "$VERSION_FILE" > temp_version.md && mv temp_version.md "$VERSION_FILE"
    else
        echo -e "$entry" > "$VERSION_FILE"
    fi
    
    print_success "Updated version history in $VERSION_FILE"
}

# Update build script
update_build_script() {
    local new_version=$1
    
    # Check if build command is enabled
    if ! is_command_enabled "build"; then
        print_info "Build command is disabled. Skipping build script update."
        return
    fi

    if [ -f "$BUILD_SCRIPT" ]; then
        # Convert version to docker tag format (e.g., 1.2.3 -> 1.002.003)
        local docker_tag=$(echo "$new_version" | awk -F'.' '{printf "%d.%03d.%03d", $1, $2, $3}')
        
        # Update build script
        sed -i "s|$DOCKER_REGISTRY:[0-9]\+\.[0-9]\+\.[0-9]\+|$DOCKER_REGISTRY:$docker_tag|g" "$BUILD_SCRIPT"
        sed -i "s|$DOCKER_REGISTRY:[0-9]\+\.[0-9]\{3\}\.[0-9]\{3\}|$DOCKER_REGISTRY:$docker_tag|g" "$BUILD_SCRIPT"
        
        print_success "Updated build script with new version: $docker_tag"
    else
        print_warning "Build script not found: $BUILD_SCRIPT"
    fi
}

# Validate version format
validate_version() {
    local version=$1
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Invalid version format: $version (expected: x.y.z)"
        exit 1
    fi
}

# Show current version
show_current_version() {
    local current_version=$(get_current_version)
    print_info "Current version: $current_version"
    echo "$current_version"
}

# Show version history
show_version_history() {
    if [ -f "$VERSION_FILE" ]; then
        print_info "Version history:"
        echo "=================="
        cat "$VERSION_FILE"
    else
        print_warning "No version history found"
    fi
}

# Release a new version
release_version() {
    local increment_type=$1
    local message=$2
    local merge_request=$3
    
    local current_version=$(get_current_version)
    local new_version=$(increment_version "$current_version" "$increment_type")

    # No duplicate-tag loop; git_tag_version will fail if the tag truly exists

    print_info "Releasing new $increment_type version: $current_version -> $new_version"
    
    # Update all version references
    update_package_json "$new_version"
    update_version_history "$new_version" "$message" "$merge_request"
    update_build_script "$new_version"
    update_config_version "$new_version"
    
    print_success "Successfully released version $new_version"
}

# Set specific version
set_version() {
    local version=$1
    local message=$2
    local merge_request=$3
    
    validate_version "$version"
    
    local current_version=$(get_current_version)
    print_info "Setting version: $current_version -> $version"
    
    # Update all version references
    update_package_json "$version"
    update_version_history "$version" "$message" "$merge_request"
    update_build_script "$version"
    update_config_version "$version"
    
    print_success "Successfully set version to $version"
}

# Build and push Docker image
build_and_push() {
    local version=$1
    
    check_command_enabled "build"
    
    if [ -z "$version" ]; then
        version=$(get_current_version)
    fi
    
    print_info "Building and pushing Docker image for version $version"
    
    if [ -f "$BUILD_SCRIPT" ]; then
        chmod +x "$BUILD_SCRIPT"
        ./"$BUILD_SCRIPT"
        print_success "Build and push completed"
    else
        print_error "Build script not found: $BUILD_SCRIPT"
        exit 1
    fi
}

# Show help
show_help() {
    cat << EOF
Version Management CLI

Usage: $0 <command> [options]

Commands:
  current                     Show current version
  history                     Show version history
  
  major [message] [mr_url]    Increment major version (x.0.0)
  minor [message] [mr_url]    Increment minor version (x.y.0)
  patch [message] [mr_url]    Increment patch version (x.y.z)
  
  set <version> [message] [mr_url]  Set specific version
  
  build [version]             Build and push Docker image $(is_command_enabled "build" && echo "(ENABLED)" || echo "(DISABLED)")
  
  release <type> [message] [mr_url]  Full release (increment + build + push) $(is_command_enabled "release" && echo "(ENABLED)" || echo "(DISABLED)")

Options:
  message                     Commit/release message
  mr_url                      Merge request URL
  version                     Semantic version (x.y.z)
  type                        Version increment type (major|minor|patch)

Examples:
  $0 current
  $0 patch "Fix authentication bug"
  $0 minor "Add new user management features" "https://gitlab.com/project/merge_requests/123"
  $0 set 2.1.0 "Major release with new features"$(is_command_enabled "build" && echo "
  $0 build" || echo "")$(is_command_enabled "release" && echo "
  $0 release patch \"Hotfix for critical bug\"" || echo "")

Configuration:
  Commands can be enabled/disabled in: $CONFIG_FILE
  
  To enable build/release commands:
  - Edit $CONFIG_FILE
  - Set "commands.enabled.build" to true
  - Set "commands.enabled.release" to true

EOF
}

# Reset to initial version
reset_version() {
    local version="1.0.0"
    print_info "Resetting to initial version: $version"
    
    # Update all version references
    update_package_json "$version"
    update_config_version "$version"
    
    # Remove version history
    if [ -f "$VERSION_FILE" ]; then
        rm "$VERSION_FILE"
        print_success "Removed version history file: $VERSION_FILE"
    else
        print_warning "Version history file not found: $VERSION_FILE"
    fi
    
    # Reset build script
    update_build_script "$version"
    
    print_success "Successfully reset to version $version. Version history cleared."
}

# Update version in config.json
update_config_version() {
    local new_version=$1
    if [ -f "$CONFIG_FILE" ]; then
        if command -v jq > /dev/null; then
            jq --arg version "$new_version" '.version = $version' "$CONFIG_FILE" > tmp.json && mv tmp.json "$CONFIG_FILE"
            print_success "Updated config.json version to $new_version"
        else
            # Fallback without jq
            sed -i.bak "s/\"version\": \".*\"/\"version\": \"$new_version\"/" "$CONFIG_FILE"
            rm -f "${CONFIG_FILE}.bak"
            print_success "Updated config.json version to $new_version (using sed)"
        fi
    else
        print_warning "Config file not found: $CONFIG_FILE"
    fi
}

# Main command handling
main() {
    case "${1:-}" in
        current)
            show_current_version
            ;;
        history)
            show_version_history
            ;;
        major)
            release_version "major" "${2:-Version bump}" "${3:-}"
            ;;
        minor)
            release_version "minor" "${2:-Version bump}" "${3:-}"
            ;;
        patch)
            release_version "patch" "${2:-Version bump}" "${3:-}"
            ;;
        set)
            if [ -z "${2:-}" ]; then
                print_error "Version number required"
                echo "Usage: $0 set <version> [message] [mr_url]"
                exit 1
            fi
            set_version "$2" "${3:-Version set}" "${4:-}"
            ;;
        build)
            build_and_push "${2:-}"
            ;;
        release)
            check_command_enabled "release"
            if [ -z "${2:-}" ]; then
                print_error "Release type required"
                echo "Usage: $0 release <type> [message] [mr_url]"
                exit 1
            fi
            release_version "$2" "${3:-Release}" "${4:-}"
            build_and_push
            ;;
        help|--help|-h)
            show_help
            ;;
        reset)
            reset_version
            ;;
        *)
            print_error "Unknown command: ${1:-}"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
