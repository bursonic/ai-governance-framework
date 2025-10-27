#!/bin/bash

# AI Governance Framework - Uninstall Script
# This script safely removes framework files while preserving custom files and project memory

# Note: Don't use 'set -e' because we want to continue even if some operations fail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Main uninstall function
main() {
    echo "AI Governance Framework Uninstaller"
    echo "===================================="
    echo

    # Check if framework is installed
    if [ ! -f ".claude/ai-gov-version.txt" ]; then
        print_error "Framework is not installed in this directory"
        exit 1
    fi

    INSTALLED_VERSION=$(cat .claude/ai-gov-version.txt)
    print_info "Found framework version: ${INSTALLED_VERSION}"
    echo

    # Warn user about what will be removed
    echo "This will remove:"
    echo "  - Framework commands (non-custom) from .claude/commands/"
    echo "  - Framework templates from .claude/templates/"
    echo "  - Framework rules (claude_code.md)"
    echo "  - Framework metadata (ai-gov-version.txt, AI_GOVERNANCE_README.md)"
    echo "  - Framework tools from .ai-gov/tools/"
    echo
    echo "This will PRESERVE:"
    echo "  - Custom commands (custom-*.md, *-custom.md)"
    echo "  - Project memory (.ai-gov/memory.md)"
    echo "  - Generated artifacts (.ai-gov/code-graph*.json, enrichment/)"
    echo "  - Any other user files in .claude/ or .ai-gov/"
    echo

    # Confirm uninstall
    echo -n "Do you want to uninstall the framework? [y/N] "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Uninstall cancelled."
        exit 0
    fi

    echo
    print_info "Starting uninstall..."

    # Remove framework commands (but keep custom commands)
    if [ -d ".claude/commands" ]; then
        print_info "Removing framework commands..."
        removed_count=0
        # First make all framework files writable
        chmod -R u+w .claude/commands 2>/dev/null || true

        for file in .claude/commands/*.md; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                # Remove only framework files (not custom-* or *-custom.md)
                if [[ ! "$filename" =~ ^custom- ]] && [[ ! "$filename" =~ -custom\.md$ ]]; then
                    rm -f "$file"
                    print_success "Removed: $filename"
                    ((removed_count++))
                fi
            fi
        done

        # Remove commands directory if empty
        if [ -d ".claude/commands" ] && [ -z "$(ls -A .claude/commands)" ]; then
            rmdir .claude/commands
            print_info "Removed empty commands directory"
        elif [ -d ".claude/commands" ]; then
            print_warning "Keeping commands directory (contains custom files)"
        fi

        if [ $removed_count -eq 0 ]; then
            print_info "No framework commands to remove"
        fi
    fi

    # Remove framework templates
    if [ -d ".claude/templates" ]; then
        print_info "Removing framework templates..."
        removed_count=0
        # First make all template files writable
        chmod -R u+w .claude/templates 2>/dev/null || true

        for file in .claude/templates/*.md; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                rm -f "$file"
                print_success "Removed: $filename"
                ((removed_count++))
            fi
        done

        # Remove templates directory if empty
        if [ -d ".claude/templates" ] && [ -z "$(ls -A .claude/templates)" ]; then
            rmdir .claude/templates
            print_info "Removed empty templates directory"
        fi

        if [ $removed_count -eq 0 ]; then
            print_info "No framework templates to remove"
        fi
    fi

    # Remove framework rules
    if [ -f ".claude/claude_code.md" ]; then
        print_info "Removing framework rules..."
        chmod u+w ".claude/claude_code.md" 2>/dev/null || true
        rm -f ".claude/claude_code.md"
        print_success "Removed: claude_code.md"
    fi

    # Remove framework metadata
    if [ -f ".claude/AI_GOVERNANCE_README.md" ]; then
        print_info "Removing framework metadata..."
        rm ".claude/AI_GOVERNANCE_README.md"
        print_success "Removed: AI_GOVERNANCE_README.md"
    fi

    if [ -f ".claude/ai-gov-version.txt" ]; then
        rm ".claude/ai-gov-version.txt"
        print_success "Removed: ai-gov-version.txt"
    fi

    # Remove .claude directory if empty
    if [ -d ".claude" ] && [ -z "$(ls -A .claude)" ]; then
        rmdir .claude
        print_success "Removed empty .claude directory"
    elif [ -d ".claude" ]; then
        print_warning "Keeping .claude directory (contains user files)"
        echo "    Remaining files:"
        ls -la .claude | tail -n +4 | sed 's/^/    /'
    fi

    # Remove framework tools from .ai-gov/tools/
    if [ -d ".ai-gov/tools" ]; then
        print_info "Removing framework tools..."

        # Remove tool files
        for tool_file in graph-generator.py run-graph-generator.sh requirements.txt; do
            if [ -f ".ai-gov/tools/$tool_file" ]; then
                rm ".ai-gov/tools/$tool_file"
                print_success "Removed: $tool_file"
            fi
        done

        # Remove virtual environment
        if [ -d ".ai-gov/tools/venv" ]; then
            rm -rf ".ai-gov/tools/venv"
            print_success "Removed: venv/"
        fi

        # Remove __pycache__
        if [ -d ".ai-gov/tools/__pycache__" ]; then
            rm -rf ".ai-gov/tools/__pycache__"
            print_success "Removed: __pycache__/"
        fi

        # Remove tools directory if empty
        if [ -d ".ai-gov/tools" ] && [ -z "$(ls -A .ai-gov/tools)" ]; then
            rmdir .ai-gov/tools
            print_info "Removed empty tools directory"
        elif [ -d ".ai-gov/tools" ]; then
            print_warning "Keeping tools directory (contains user files)"
            echo "    Remaining files:"
            ls -la .ai-gov/tools | tail -n +4 | sed 's/^/    /'
        fi
    fi

    # Check what remains in .ai-gov
    if [ -d ".ai-gov" ]; then
        remaining_files=$(ls -A .ai-gov 2>/dev/null | wc -l)
        if [ "$remaining_files" -eq 0 ]; then
            rmdir .ai-gov
            print_success "Removed empty .ai-gov directory"
        else
            print_info "Keeping .ai-gov directory with user data:"
            ls -la .ai-gov | tail -n +4 | sed 's/^/    /'
        fi
    fi

    echo
    echo "===================================="
    print_success "Uninstall complete!"
    echo
    echo "Framework has been removed from this project."

    # Show what was preserved
    if [ -d ".claude" ] || [ -d ".ai-gov" ]; then
        echo
        print_info "Preserved directories/files:"
        [ -d ".claude" ] && echo "  - .claude/ (contains custom files)"
        [ -f ".ai-gov/memory.md" ] && echo "  - .ai-gov/memory.md (project memory)"
        [ -f ".ai-gov/code-graph.json" ] && echo "  - .ai-gov/code-graph.json"
        [ -f ".ai-gov/code-graph-enriched.json" ] && echo "  - .ai-gov/code-graph-enriched.json"
        [ -d ".ai-gov/enrichment" ] && echo "  - .ai-gov/enrichment/ (enrichment artifacts)"
    fi

    echo

    # Remove the uninstall script itself
    print_info "Removing uninstall script..."
    rm -f "$0"
}

# Run main function
main "$@"
