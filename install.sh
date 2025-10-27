#!/bin/bash

# AI Governance Framework - Installation Script
# This script installs the framework into a project's .claude/ directory

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Framework version
VERSION="0.2.0"

# GitHub repository (update this when hosted)
REPO_URL="${AI_GOV_REPO_URL:-https://github.com/bursonic/ai-governance-framework.git}"
TEMP_DIR="/tmp/ai-gov-install-$$"

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

cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

# Main installation function
main() {
    echo "AI Governance Framework Installer v${VERSION}"
    echo "=============================================="
    echo

    # Check if we're in a directory (project root)
    if [ ! -w "." ]; then
        print_error "Current directory is not writable"
        exit 1
    fi

    # Check if .claude already exists and has framework files
    if [ -f ".claude/ai-gov-version.txt" ]; then
        INSTALLED_VERSION=$(cat .claude/ai-gov-version.txt)
        print_info "Framework already installed (version: ${INSTALLED_VERSION})"
        echo -n "Do you want to reinstall/update? [y/N] "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            exit 0
        fi
    fi

    # Create .claude directory if it doesn't exist
    print_info "Creating .claude directory..."
    mkdir -p .claude/commands
    mkdir -p .claude/templates

    # Clone or copy framework files
    print_info "Fetching framework files..."

    # Check if we're running from the framework repo itself
    if [ -f "$(dirname "$0")/commands/gov-memory-init.md" ]; then
        print_info "Installing from local framework repository..."
        FRAMEWORK_DIR="$(dirname "$0")"
    else
        print_info "Downloading framework from ${REPO_URL}..."
        git clone --depth 1 "$REPO_URL" "$TEMP_DIR" 2>/dev/null || {
            print_error "Failed to download framework"
            print_info "Make sure git is installed and the repository URL is correct"
            exit 1
        }
        FRAMEWORK_DIR="$TEMP_DIR"
    fi

    # Copy commands (framework files only, skip custom-* files)
    print_info "Installing commands..."
    if [ -d "$FRAMEWORK_DIR/commands" ]; then
        for file in "$FRAMEWORK_DIR"/commands/*.md; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                # Skip custom files
                if [[ ! "$filename" =~ ^custom- ]] && [[ ! "$filename" =~ -custom\.md$ ]]; then
                    cp "$file" ".claude/commands/"
                    chmod 444 ".claude/commands/$filename"  # Read-only
                    print_success "Installed command: $filename"
                fi
            fi
        done
    else
        print_error "Commands directory not found in framework"
        exit 1
    fi

    # Copy templates
    print_info "Installing templates..."
    if [ -d "$FRAMEWORK_DIR/templates" ]; then
        for file in "$FRAMEWORK_DIR"/templates/*.md; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                cp "$file" ".claude/templates/"
                chmod 444 ".claude/templates/$filename"  # Read-only
                print_success "Installed template: $filename"
            fi
        done
    else
        print_error "Templates directory not found in framework"
        exit 1
    fi

    # Install framework tools in .ai-gov (separate from .claude)
    print_info "Setting up framework tools..."
    mkdir -p .ai-gov/tools

    # Copy tools from framework
    if [ -d "$FRAMEWORK_DIR/.ai-gov/tools" ]; then
        cp -r "$FRAMEWORK_DIR"/.ai-gov/tools/* ".ai-gov/tools/"
        print_success "Copied framework tools"
    fi

    # Check if Python 3 is available
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required but not installed"
        print_info "Please install Python 3 and run the installer again"
        exit 1
    fi

    # Create virtual environment for framework tools
    print_info "Creating Python virtual environment..."
    python3 -m venv .ai-gov/tools/venv 2>/dev/null || {
        print_error "Failed to create virtual environment"
        print_info "Make sure python3-venv is installed (apt install python3-venv on Ubuntu/Debian)"
        exit 1
    }

    # Install Python dependencies
    if [ -f ".ai-gov/tools/requirements.txt" ]; then
        print_info "Installing Python dependencies..."
        .ai-gov/tools/venv/bin/pip install --quiet --upgrade pip
        .ai-gov/tools/venv/bin/pip install --quiet -r .ai-gov/tools/requirements.txt || {
            print_error "Failed to install Python dependencies"
            exit 1
        }
        print_success "Python dependencies installed"
    fi

    # Install code-graph-enricher package from GitHub
    print_info "Installing code-graph-enricher..."
    .ai-gov/tools/venv/bin/pip install --quiet git+https://github.com/bursonic/code-graph-enricher.git || {
        print_error "Failed to install code-graph-enricher"
        print_info "Continuing without enricher (graph generation will still work)"
    }

    # Check if enricher was installed successfully
    if .ai-gov/tools/venv/bin/enrich-graph -h &>/dev/null; then
        print_success "code-graph-enricher installed (enrich-graph command available)"
    else
        print_info "code-graph-enricher not available (optional)"
    fi

    # Copy rules (claude_code.md) if it exists
    if [ -f "$FRAMEWORK_DIR/rules/claude_code.md" ]; then
        print_info "Installing rules..."
        mkdir -p .claude
        cp "$FRAMEWORK_DIR/rules/claude_code.md" ".claude/claude_code.md"
        chmod 444 ".claude/claude_code.md"  # Read-only
        print_success "Installed rules: claude_code.md"
    fi

    # Copy uninstall script
    if [ -f "$FRAMEWORK_DIR/uninstall.sh" ]; then
        print_info "Installing uninstall script..."
        cp "$FRAMEWORK_DIR/uninstall.sh" "uninstall.sh"
        chmod 755 "uninstall.sh"
        print_success "Installed uninstall script (run ./uninstall.sh to remove framework)"
    fi

    # Write version file
    echo "$VERSION" > .claude/ai-gov-version.txt
    print_success "Recorded version: $VERSION"

    # Create README for users
    cat > .claude/AI_GOVERNANCE_README.md << 'EOF'
# AI Governance Framework

This directory contains AI governance framework files.

## Framework Files (Read-Only)

These files are managed by the framework and will be overwritten during updates:
- `commands/*.md` (except custom-* files)
- `templates/*.md`
- `claude_code.md`

**Do not edit these files directly!** They are marked read-only.

## Custom Commands

You can add your own commands by creating files with these naming patterns:
- `custom-*.md` (e.g., `custom-my-feature.md`)
- `*-custom.md` (e.g., `my-feature-custom.md`)

Custom files will never be touched by framework updates.

## Project Memory

Your project memory file (`.ai-gov/memory.md`) is preserved during updates.
This file lives outside `.claude/` to keep AI governance artifacts separate.

## Updates

To update the framework to the latest version:
```bash
curl -fsSL https://raw.githubusercontent.com/org/framework/main/update.sh | bash
```

Or if you have the update script:
```bash
./update.sh
```

## Version

Current framework version: see `ai-gov-version.txt`
EOF

    chmod 644 .claude/AI_GOVERNANCE_README.md

    echo
    echo "=============================================="
    print_success "Installation complete!"
    echo
    echo "Framework installed in: .claude/"
    echo "Version: $VERSION"
    echo
    echo "Next steps:"
    echo "  1. Read: .claude/AI_GOVERNANCE_README.md"
    echo "  2. Initialize project memory:"
    echo "     - For existing projects: Use /gov-memory-init command"
    echo "     - For new projects: Use /gov-memory-create command"
    echo "  3. Project memory will be stored in: .ai-gov/memory.md"
    echo "  4. Generate code graph: Use /gov-graph-generate command"
    echo "  5. Enrich code graph: Use /gov-graph-enrich command"
    echo
    print_info "Custom commands should use 'custom-*' or '*-custom' naming"
    echo
}

# Run main function
main "$@"
