#!/bin/bash

# AI Governance Framework - Installation Test Script
# This script verifies that the framework installs correctly and all components work

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

# Helper functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((TESTS_PASSED++))
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((TESTS_FAILED++))
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_section() {
    echo
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

run_test() {
    ((TOTAL_TESTS++)) || true  # Prevent set -e from killing the script
    local test_name="$1"
    local test_command="$2"

    if eval "$test_command" &>/dev/null; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((TESTS_PASSED++)) || true
        return 0
    else
        echo -e "${RED}✗${NC} $test_name"
        ((TESTS_FAILED++)) || true
        return 0  # Don't fail the script, just record the failure
    fi
}

# Main test function
main() {
    local TEST_DIR="test-install"
    local FRAMEWORK_DIR="$(pwd)"

    echo "AI Governance Framework Installation Test"
    echo "=========================================="
    echo
    print_info "Framework directory: $FRAMEWORK_DIR"
    print_info "Test directory: $TEST_DIR"
    echo

    # ========================================
    # Stage 1: Setup
    # ========================================
    print_section "Stage 1: Test Environment Setup"

    # Clean up old test directory if it exists
    if [ -d "$TEST_DIR" ]; then
        print_info "Removing old test directory..."
        rm -rf "$TEST_DIR"
    fi

    # Create fresh test directory
    print_info "Creating fresh test directory..."
    mkdir -p "$TEST_DIR"
    print_info "Changing to test directory..."
    cd "$TEST_DIR" || {
        print_error "Failed to change to test directory"
        exit 1
    }
    print_info "Now in: $(pwd)"

    # Copy test code data
    if [ -d "$FRAMEWORK_DIR/test-code-data" ]; then
        print_info "Copying test code data..."
        cp -r "$FRAMEWORK_DIR/test-code-data" .
        echo -e "${GREEN}✓${NC} Test code data copied"
    else
        print_warning "No test code data found (optional)"
    fi

    echo

    # ========================================
    # Stage 2: Installation
    # ========================================
    print_section "Stage 2: Framework Installation"

    print_info "Running install.sh..."
    print_info "Current directory: $(pwd)"
    print_info "Install script: $FRAMEWORK_DIR/install.sh"

    # Run installation (install.sh doesn't require interactive input)
    if bash "$FRAMEWORK_DIR/install.sh" > install.log 2>&1; then
        echo -e "${GREEN}✓${NC} Installation completed without errors"
    else
        print_error "Installation failed"
        echo "Installation log:"
        cat install.log
        exit 1
    fi

    echo

    # ========================================
    # Stage 3: Directory Structure Verification
    # ========================================
    print_section "Stage 3: Directory Structure Verification"

    run_test "Directory .claude exists" "[ -d .claude ]"
    run_test "Directory .claude/commands exists" "[ -d .claude/commands ]"
    run_test "Directory .claude/templates exists" "[ -d .claude/templates ]"
    run_test "Directory .ai-gov exists" "[ -d .ai-gov ]"
    run_test "Directory .ai-gov/tools exists" "[ -d .ai-gov/tools ]"
    run_test "Directory .ai-gov/tools/venv exists" "[ -d .ai-gov/tools/venv ]"

    echo

    # ========================================
    # Stage 4: Framework Files Verification
    # ========================================
    print_section "Stage 4: Framework Files Verification"

    # Check metadata files
    run_test "File .claude/ai-gov-version.txt exists" "[ -f .claude/ai-gov-version.txt ]"
    run_test "File .claude/AI_GOVERNANCE_README.md exists" "[ -f .claude/AI_GOVERNANCE_README.md ]"
    run_test "File uninstall.sh exists" "[ -f uninstall.sh ]"
    run_test "File uninstall.sh is executable" "[ -x uninstall.sh ]"

    # Check command files (should be 5 commands)
    run_test "Command gov-graph-generate.md exists" "[ -f .claude/commands/gov-graph-generate.md ]"
    run_test "Command gov-graph-enrich.md exists" "[ -f .claude/commands/gov-graph-enrich.md ]"
    run_test "Command gov-memory-init.md exists" "[ -f .claude/commands/gov-memory-init.md ]"
    run_test "Command gov-memory-update.md exists" "[ -f .claude/commands/gov-memory-update.md ]"
    run_test "Command gov-memory-create.md exists" "[ -f .claude/commands/gov-memory-create.md ]"

    # Check template files
    run_test "Template memory-structure.md exists" "[ -f .claude/templates/memory-structure.md ]"

    # Check tool files
    run_test "Tool graph-generator.py exists" "[ -f .ai-gov/tools/graph-generator.py ]"
    run_test "Tool run-graph-generator.sh exists" "[ -f .ai-gov/tools/run-graph-generator.sh ]"
    run_test "Tool requirements.txt exists" "[ -f .ai-gov/tools/requirements.txt ]"

    echo

    # ========================================
    # Stage 5: Python Environment Verification
    # ========================================
    print_section "Stage 5: Python Environment Verification"

    run_test "Python executable exists in venv" "[ -f .ai-gov/tools/venv/bin/python ]"
    run_test "Pip executable exists in venv" "[ -f .ai-gov/tools/venv/bin/pip ]"

    # Check Python packages
    print_info "Checking installed Python packages..."
    if .ai-gov/tools/venv/bin/pip list 2>/dev/null | grep -q tree-sitter-languages; then
        print_success "Package tree-sitter-languages is installed"
    else
        print_error "Package tree-sitter-languages is NOT installed"
    fi

    # Check for enricher package
    if .ai-gov/tools/venv/bin/pip list 2>/dev/null | grep -q code-graph-enricher; then
        print_success "Package code-graph-enricher is installed"
        run_test "Command enrich-graph is available" "[ -f .ai-gov/tools/venv/bin/enrich-graph ]"
    else
        print_warning "Package code-graph-enricher is NOT installed (optional)"
    fi

    echo

    # ========================================
    # Stage 6: Functional Tests
    # ========================================
    print_section "Stage 6: Functional Tests"

    # Test graph generator
    if [ -d "test-code-data" ]; then
        print_info "Testing graph generator..."
        if .ai-gov/tools/venv/bin/python .ai-gov/tools/graph-generator.py python test-code-data/ 2>&1 | grep -q "Graph saved to"; then
            echo -e "${GREEN}✓${NC} Graph generator completed successfully"
            run_test "Code graph file created" "[ -f test-code-data/.ai-gov/code-graph.json ]"

            # Verify graph content
            if [ -f test-code-data/.ai-gov/code-graph.json ]; then
                local node_count=$(cat test-code-data/.ai-gov/code-graph.json | grep -o '"id":' | wc -l)
                if [ "$node_count" -gt 0 ]; then
                    echo -e "${GREEN}✓${NC} Code graph contains $node_count nodes"
                else
                    echo -e "${RED}✗${NC} Code graph appears to be empty"
                fi
            fi
        else
            echo -e "${RED}✗${NC} Graph generator failed"
        fi

        # Test enricher if available
        if [ -f .ai-gov/tools/venv/bin/enrich-graph ] && [ -f test-code-data/.ai-gov/code-graph.json ]; then
            print_info "Testing enricher..."
            if .ai-gov/tools/venv/bin/enrich-graph test-code-data/.ai-gov/code-graph.json test-code-data/ 2>&1 | grep -q "enriched-Layer3"; then
                echo -e "${GREEN}✓${NC} Enricher completed successfully"
                run_test "Enriched graph file created" "[ -f test-code-data/.ai-gov/code-graph-enriched.json ]"
                run_test "Enrichment directory created" "[ -d test-code-data/.ai-gov/enrichment ]"
            else
                echo -e "${RED}✗${NC} Enricher failed"
            fi
        fi
    else
        print_warning "Skipping functional tests (no test code data)"
    fi

    echo

    # ========================================
    # Stage 7: Custom Files Preservation Test
    # ========================================
    print_section "Stage 7: Custom Files Preservation Test"

    print_info "Creating custom files to test preservation..."
    echo "# Custom Test" > .claude/commands/custom-test.md
    echo "# My Custom" > .claude/commands/my-custom.md
    echo "# My File" > .claude/myfile.txt

    run_test "Custom file custom-test.md created" "[ -f .claude/commands/custom-test.md ]"
    run_test "Custom file my-custom.md created" "[ -f .claude/commands/my-custom.md ]"
    run_test "Custom file myfile.txt created" "[ -f .claude/myfile.txt ]"

    echo

    # ========================================
    # Stage 8: Uninstall Test
    # ========================================
    print_section "Stage 8: Uninstall Test"

    print_info "Testing uninstall script..."
    if echo "y" | ./uninstall.sh 2>&1 | grep -q "Uninstall complete"; then
        echo -e "${GREEN}✓${NC} Uninstall completed successfully"
    else
        echo -e "${RED}✗${NC} Uninstall failed"
    fi

    # Verify framework files removed
    run_test "Framework commands removed" "[ ! -f .claude/commands/gov-graph-generate.md ]"
    run_test "Framework metadata removed" "[ ! -f .claude/ai-gov-version.txt ]"
    run_test "Uninstall script removed itself" "[ ! -f uninstall.sh ]"

    # Verify custom files preserved
    run_test "Custom file custom-test.md preserved" "[ -f .claude/commands/custom-test.md ]"
    run_test "Custom file my-custom.md preserved" "[ -f .claude/commands/my-custom.md ]"
    run_test "Custom file myfile.txt preserved" "[ -f .claude/myfile.txt ]"

    # Verify artifacts preserved if they exist (from functional tests)
    if [ -f test-code-data/.ai-gov/code-graph.json ]; then
        run_test "Code graph preserved" "[ -f test-code-data/.ai-gov/code-graph.json ]"
    fi
    if [ -f test-code-data/.ai-gov/code-graph-enriched.json ]; then
        run_test "Enriched graph preserved" "[ -f test-code-data/.ai-gov/code-graph-enriched.json ]"
    fi

    echo

    # ========================================
    # Results Summary
    # ========================================
    print_section "Test Results Summary"

    echo
    echo "Total Tests: $TOTAL_TESTS"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    else
        echo -e "${GREEN}Failed: 0${NC}"
    fi
    echo

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo
        echo "The framework installed correctly and all components work as expected."
        echo "Test directory: $FRAMEWORK_DIR/$TEST_DIR"
        echo
        return 0
    else
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}✗ SOME TESTS FAILED${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo
        echo "Please review the failures above."
        echo "Test directory: $FRAMEWORK_DIR/$TEST_DIR"
        echo
        return 1
    fi
}

# Run main function
main "$@"
