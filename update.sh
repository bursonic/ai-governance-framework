#!/bin/bash

# AI Governance Framework - Update Script
# This script updates an existing framework installation

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# GitHub repository (update this when hosted)
REPO_URL="${AI_GOV_REPO_URL:-https://github.com/org/ai-governance-framework.git}"
TEMP_DIR="/tmp/ai-gov-update-$$"

# Helper functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

print_note() {
    echo -e "${BLUE}→${NC} $1"
}

cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

# Main update function
main() {
    echo "AI Governance Framework Updater"
    echo "================================"
    echo

    # Check if framework is installed
    if [ ! -f ".claude/ai-gov-version.txt" ]; then
        print_error "Framework not installed in this project"
        print_info "Run install.sh first to install the framework"
        exit 1
    fi

    # Get current version
    CURRENT_VERSION=$(cat .claude/ai-gov-version.txt)
    print_info "Current version: $CURRENT_VERSION"

    # Fetch latest version
    print_info "Fetching latest framework version..."

    # Check if we're running from the framework repo itself
    if [ -f "$(dirname "$0")/commands/memory-init.md" ]; then
        print_info "Updating from local framework repository..."
        FRAMEWORK_DIR="$(dirname "$0")"
        NEW_VERSION=$(grep "^VERSION=" "$FRAMEWORK_DIR/install.sh" | cut -d'"' -f2)
    else
        print_info "Downloading latest framework from ${REPO_URL}..."
        git clone --depth 1 "$REPO_URL" "$TEMP_DIR" 2>/dev/null || {
            print_error "Failed to download framework"
            print_info "Make sure git is installed and the repository URL is correct"
            exit 1
        }
        FRAMEWORK_DIR="$TEMP_DIR"
        NEW_VERSION=$(grep "^VERSION=" "$FRAMEWORK_DIR/install.sh" | cut -d'"' -f2)
    fi

    print_info "Latest version: $NEW_VERSION"

    # Check if update is needed
    if [ "$CURRENT_VERSION" = "$NEW_VERSION" ]; then
        print_success "Already up to date!"
        exit 0
    fi

    echo
    print_note "This update will:"
    echo "  • Overwrite framework commands (except custom-* files)"
    echo "  • Overwrite framework templates"
    echo "  • Overwrite framework rules"
    echo "  • Preserve your custom-* commands"
    echo "  • Preserve your .claude/memory.md"
    echo
    echo -n "Continue with update? [y/N] "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Update cancelled."
        exit 0
    fi

    echo
    print_info "Starting update..."

    # Count changes
    UPDATED=0
    ADDED=0
    PRESERVED=0

    # Update commands (framework files only)
    print_info "Updating commands..."
    if [ -d "$FRAMEWORK_DIR/commands" ]; then
        for file in "$FRAMEWORK_DIR"/commands/*.md; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")

                # Skip custom files
                if [[ "$filename" =~ ^custom- ]] || [[ "$filename" =~ -custom\.md$ ]]; then
                    continue
                fi

                # Check if file exists
                if [ -f ".claude/commands/$filename" ]; then
                    # Check if content changed
                    if ! cmp -s "$file" ".claude/commands/$filename" 2>/dev/null; then
                        # Make writable, update, then read-only again
                        chmod 644 ".claude/commands/$filename"
                        cp "$file" ".claude/commands/$filename"
                        chmod 444 ".claude/commands/$filename"
                        print_success "Updated: $filename"
                        ((UPDATED++))
                    else
                        print_note "Unchanged: $filename"
                    fi
                else
                    # New file
                    cp "$file" ".claude/commands/$filename"
                    chmod 444 ".claude/commands/$filename"
                    print_success "Added: $filename"
                    ((ADDED++))
                fi
            fi
        done
    fi

    # Preserve custom commands
    if [ -d ".claude/commands" ]; then
        for file in .claude/commands/custom-*.md .claude/commands/*-custom.md; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                print_note "Preserved: $filename (custom)"
                ((PRESERVED++))
            fi
        done
    fi

    # Update templates
    print_info "Updating templates..."
    if [ -d "$FRAMEWORK_DIR/templates" ]; then
        for file in "$FRAMEWORK_DIR"/templates/*.md; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")

                if [ -f ".claude/templates/$filename" ]; then
                    if ! cmp -s "$file" ".claude/templates/$filename" 2>/dev/null; then
                        chmod 644 ".claude/templates/$filename"
                        cp "$file" ".claude/templates/$filename"
                        chmod 444 ".claude/templates/$filename"
                        print_success "Updated: templates/$filename"
                        ((UPDATED++))
                    else
                        print_note "Unchanged: templates/$filename"
                    fi
                else
                    cp "$file" ".claude/templates/$filename"
                    chmod 444 ".claude/templates/$filename"
                    print_success "Added: templates/$filename"
                    ((ADDED++))
                fi
            fi
        done
    fi

    # Update rules
    if [ -f "$FRAMEWORK_DIR/rules/claude_code.md" ]; then
        print_info "Updating rules..."
        if [ -f ".claude/claude_code.md" ]; then
            if ! cmp -s "$FRAMEWORK_DIR/rules/claude_code.md" ".claude/claude_code.md" 2>/dev/null; then
                chmod 644 ".claude/claude_code.md"
                cp "$FRAMEWORK_DIR/rules/claude_code.md" ".claude/claude_code.md"
                chmod 444 ".claude/claude_code.md"
                print_success "Updated: claude_code.md"
                ((UPDATED++))
            else
                print_note "Unchanged: claude_code.md"
            fi
        else
            cp "$FRAMEWORK_DIR/rules/claude_code.md" ".claude/claude_code.md"
            chmod 444 ".claude/claude_code.md"
            print_success "Added: claude_code.md"
            ((ADDED++))
        fi
    fi

    # Update README
    if [ -f "$FRAMEWORK_DIR/.claude/AI_GOVERNANCE_README.md" ]; then
        if [ -f ".claude/AI_GOVERNANCE_README.md" ]; then
            cp "$FRAMEWORK_DIR/.claude/AI_GOVERNANCE_README.md" ".claude/AI_GOVERNANCE_README.md"
            chmod 644 ".claude/AI_GOVERNANCE_README.md"
        fi
    fi

    # Update version file
    echo "$NEW_VERSION" > .claude/ai-gov-version.txt
    print_success "Updated version: $CURRENT_VERSION → $NEW_VERSION"

    echo
    echo "================================"
    print_success "Update complete!"
    echo
    echo "Summary:"
    echo "  Updated files: $UPDATED"
    echo "  New files: $ADDED"
    echo "  Preserved custom files: $PRESERVED"
    echo
    echo "Version: $CURRENT_VERSION → $NEW_VERSION"
    echo

    if [ $ADDED -gt 0 ]; then
        print_info "New commands/templates were added. Check .claude/ for details."
    fi

    if [ -f ".claude/memory.md" ]; then
        print_note "Your project memory (.claude/memory.md) was preserved"
    fi

    echo
}

# Run main function
main "$@"
