# AI Governance Framework

> A structured framework for AI-driven software development workflows using Claude Code commands and rules

[![Version](https://img.shields.io/badge/version-0.2.0-blue.svg)](https://github.com/bursonic/ai-governance-framework)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Overview

The AI Governance Framework provides a standardized approach to managing AI-assisted development workflows with Claude Code. It implements the **Memory-Specification-Research-Planning-Implementation-Testing (MEM-SPEC-RES-PLAN-DO)** development cycle with built-in tools for project context management and code analysis.

### Key Features

- **📝 Project Memory Management** - Maintain project context across AI sessions with metadata storage
- **🔍 Code Graph Generation** - Extract code structure into queryable graph models using tree-sitter
- **🔧 Isolated Tooling** - Python tools run in isolated virtual environments (no system pollution)
- **📦 Easy Installation** - Single script installs framework into any project
- **🔄 Smart Updates** - Update framework while preserving custom commands and project data
- **🎯 Command-Driven** - All operations via intuitive slash commands

## Quick Start

### Installation

From within your project directory:

```bash
# Clone or download the framework
git clone https://github.com/bursonic/ai-governance-framework.git /tmp/ai-gov-framework

# Run the installer
/tmp/ai-gov-framework/install.sh
```

Or use the one-liner (coming soon):

```bash
curl -fsSL https://raw.githubusercontent.com/bursonic/ai-governance-framework/main/install.sh | bash
```

### Prerequisites

- **Bash** shell
- **Python 3** with venv module (`python3-venv` on Debian/Ubuntu)
- **Git** (for remote installations)
- Write permissions in your project directory

### First Steps

After installation, initialize project memory:

```bash
# For existing projects - auto-discovers metadata
/gov-memory-init

# For new projects - guided input
/gov-memory-create
```

Generate a code structure graph:

```bash
# Creates .ai-gov/code-graph.json
/gov-graph-generate
```

## Architecture

### Directory Structure

The framework maintains clean separation between definitions and runtime artifacts:

```
your-project/
├── .claude/                    # Framework definitions (read-only)
│   ├── commands/               # Slash command definitions
│   ├── templates/              # Reusable templates
│   ├── claude_code.md          # Governance rules
│   └── ai-gov-version.txt      # Version tracking
│
└── .ai-gov/                    # Runtime artifacts (project-managed)
    ├── memory.md               # Project metadata
    ├── code-graph.json         # Code structure model
    └── tools/                  # Python utilities
        ├── graph-generator.py
        ├── run-graph-generator.sh
        ├── requirements.txt
        └── venv/               # Isolated Python environment
```

**Design Principles:**

- **`.claude/`** - Framework files only (commands, templates, rules). All read-only to prevent accidental edits.
- **`.ai-gov/`** - Runtime artifacts (memory, graphs, tools). Project-specific and version-controlled.
- **Isolation** - Python tools run in isolated venv, no system-wide dependencies.

## Available Commands

### Memory Management

#### `/gov-memory-init`

Initialize project memory for **existing repositories**.

**What it does:**
- Explores project basics (README, package files, directory structure)
- Auto-discovers metadata (languages, frameworks, structure)
- Creates `.ai-gov/memory.md` with minimal metadata
- Focuses on high-level project info only

**When to use:** First time working with an existing codebase

**Output:** `.ai-gov/memory.md` with Project Identity, Structure, and Technology Stack

---

#### `/gov-memory-create`

Create project memory via **guided user input** for new projects.

**What it does:**
- Asks structured questions about your project
- Gathers metadata incrementally (2-3 questions at a time)
- Adapts follow-up questions based on answers
- Creates `.ai-gov/memory.md` from responses

**When to use:** New projects where no code exists yet, or when you prefer to describe your project

**Questions asked:**
- Project identity (name, purpose, type)
- Project structure (directories, entry points)
- Technology stack (languages, frameworks, tools)
- Development workflow (setup, build, test commands)
- Team conventions (coding standards, git workflow)

---

#### `/gov-memory-update`

Update existing project memory **incrementally** with new learnings.

**What it does:**
- Reads current `.ai-gov/memory.md`
- Identifies incomplete sections marked `[TBD]`
- Explores ONE metadata section at a time
- Updates only that section, preserves everything else
- Updates "Last Updated" timestamp

**When to use:** Ongoing project updates as you discover new metadata

**Workflow:** Read → Explore → Update (one section at a time)

---

### Code Analysis

#### `/gov-graph-generate`

Generate a **code structure graph model** for knowledge management.

**What it does:**
- Reads memory to understand project structure
- Identifies target files by language patterns
- Parses files using tree-sitter (AST-based analysis)
- Extracts nodes (files, classes, functions) and edges (relationships)
- Outputs JSON graph to `.ai-gov/code-graph.json`

**When to use:** After memory initialization, to create machine-readable code structure

**Supported languages:** Python, JavaScript, TypeScript, Go, Rust, Java

**Output format:**
```json
{
  "nodes": [
    {"id": "...", "type": "file|class|function", "name": "...", "path": "...", "location": {...}}
  ],
  "edges": [
    {"source": "...", "target": "...", "type": "imports|calls|inherits|contains"}
  ],
  "metadata": {
    "generated": "timestamp",
    "language": "...",
    "files_processed": N
  }
}
```

## Memory Structure

Project memory is stored in `.ai-gov/memory.md` with this structure:

```markdown
# Project Memory

## Last Updated
- Date: YYYY-MM-DD
- Context: What was updated and why

## Project Identity
- Name: Your Project Name
- Purpose: What this project does
- Type: web-app | library | cli-tool | service | mobile-app | desktop-app
- Repository: GitHub URL

## Project Structure
- Root Layout: Top-level directories
- Key Directories: Important subdirectories with descriptions
- Entry Points: Main files (server.js, main.py, etc.)

## Technology Stack
- Languages: Primary programming languages
- Frameworks: Major frameworks/libraries
- Package Manager: npm, pip, cargo, etc.
- Tools: Build tools, linters, etc.

## Development Workflow
- Setup: Installation commands
- Development: Local dev server commands
- Build: Production build commands
- Testing: Test execution commands
- Deployment: Deploy process

## Team Conventions
- Code Organization: How code is structured
- Naming Conventions: File/function naming patterns
- Git Workflow: Branch strategy, commit style
- Documentation: Where docs live, format

## Notes
- Additional context and gotchas
```

**Philosophy:** Metadata only, not domain knowledge. High-level project info that helps AI understand structure and workflow.

## Tools

### Graph Generator

**Location:** `.ai-gov/tools/graph-generator.py`

**Technology:** Python 3 with tree-sitter for AST parsing

**Features:**
- Language-agnostic AST parsing
- Extracts code elements (files, classes, functions, methods)
- Tracks relationships (imports, calls, inheritance, containment)
- Generates unique IDs via hashing
- JSON output format

**Usage:** Always via wrapper script (handles venv activation)

```bash
.ai-gov/tools/run-graph-generator.sh <language> [root_path]
```

**Isolation:** Runs in `.ai-gov/tools/venv/` - no system-wide packages required

## Updates

### Updating the Framework

```bash
./update.sh
```

Or (coming soon):

```bash
curl -fsSL https://raw.githubusercontent.com/bursonic/ai-governance-framework/main/update.sh | bash
```

**What gets updated:**
- Commands in `.claude/commands/`
- Templates in `.claude/templates/`
- Rules in `.claude/claude_code.md`
- Tools in `.ai-gov/tools/`
- Version file

**What's preserved:**
- Custom commands (files matching `custom-*` or `*-custom` patterns)
- Project memory (`.ai-gov/memory.md`)
- Code graphs (`.ai-gov/code-graph.json`)
- All other project files

## Customization

### Adding Custom Commands

Create commands with these naming patterns to prevent overwriting during updates:

- `custom-*.md` (e.g., `custom-my-feature.md`)
- `*-custom.md` (e.g., `my-feature-custom.md`)

Place in `.claude/commands/` directory. These files will never be touched by framework updates.

### Modifying Framework Behavior

1. **Don't edit framework files directly** - They're marked read-only and will be overwritten
2. **Create custom commands** - Use custom naming pattern
3. **Extend templates** - Copy templates to project-specific locations
4. **Add project rules** - Create separate rules files in your project

## Development Workflow

### Typical Usage Pattern

1. **Install Framework**
   ```bash
   ./install.sh
   ```

2. **Initialize Memory** (existing project)
   ```bash
   /gov-memory-init
   ```

3. **Fill Gaps** (incremental)
   ```bash
   /gov-memory-update
   ```

4. **Generate Code Graph** (analysis)
   ```bash
   /gov-graph-generate
   ```

5. **Continue Development** (future phases)
   - Specification: `/gov-spec-start`, `/gov-spec-iterate` (planned)
   - Research: `/gov-research` (planned)
   - Planning: `/gov-plan` (planned)
   - Implementation: `/gov-implement` (planned)
   - Testing: `/gov-test` (planned)

### Multi-Phase Development Cycle

```
┌─────────────┐
│   Memory    │  Store project context
└──────┬──────┘
       │
┌──────▼──────┐
│Specification│  Define features iteratively
└──────┬──────┘
       │
┌──────▼──────┐
│  Research   │  Investigate approaches
└──────┬──────┘
       │
┌──────▼──────┐
│  Planning   │  Break down tasks
└──────┬──────┘
       │
┌──────▼──────┐
│Implementaton│  Execute single tasks
└──────┬──────┘
       │
┌──────▼──────┐
│   Testing   │  Verify implementation
└─────────────┘
```

**Current Status:** Memory phase complete (v0.2.0). Other phases planned.

## Version Control

### What to Commit

**DO commit:**
- `.ai-gov/memory.md` - Project metadata
- `.ai-gov/code-graph.json` - Code structure (optional, can regenerate)
- `.ai-gov/TOOLS_README.md` - Tools documentation
- `.ai-gov/tools/*.py`, `.ai-gov/tools/*.sh`, `.ai-gov/tools/*.txt` - Tool files

**DON'T commit:**
- `.ai-gov/tools/venv/` - Virtual environment (in .gitignore)
- `__pycache__/`, `*.pyc` - Python cache (in .gitignore)

**Framework files** (`.claude/` directory):
- Typically committed to share framework setup with team
- Can be gitignored if team members install individually

### .gitignore Template

```gitignore
# IDE
.idea/
.vscode/

# OS
.DS_Store
Thumbs.db

# Python
.ai-gov/tools/venv/
*.pyc
__pycache__/
```

## Troubleshooting

### Installation Issues

**Error: "Python 3 is required but not installed"**
- Install Python 3: `sudo apt install python3` (Ubuntu/Debian)

**Error: "Failed to create virtual environment"**
- Install venv module: `sudo apt install python3-venv` (Ubuntu/Debian)

**Error: "Failed to download framework"**
- Check git is installed: `sudo apt install git`
- Verify repository URL is correct

### Command Issues

**Error: "Framework virtual environment not found"**
- Run `./install.sh` to set up tools
- Check `.ai-gov/tools/venv/` exists

**Error: "Memory file not found"**
- Run `/gov-memory-init` or `/gov-memory-create` first

### Graph Generation Issues

**Error: "Unsupported language"**
- Check language parameter: `python`, `javascript`, `typescript`, `go`, `rust`, `java`
- Supported languages listed in command output

**No nodes found:**
- Check file patterns match your project structure
- Verify excludes aren't filtering out code directories
- Review `.ai-gov/code-graph.json` for details

## Contributing

Contributions welcome! This framework is designed to be extended and improved.

### Areas for Contribution

- **New Commands** - Specification, Research, Planning, Implementation, Testing phases
- **Language Support** - Additional language handlers for graph generation
- **Tools** - New analysis and automation tools
- **Documentation** - Examples, tutorials, best practices
- **Templates** - Reusable templates for different project types

### Development Setup

```bash
# Clone the repository
git clone https://github.com/bursonic/ai-governance-framework.git
cd ai-governance-framework

# Create working docs for your phase
mkdir -p working-docs/0X-your-phase
cd working-docs/0X-your-phase

# Follow the working docs structure
# 1. analysis.md - Problem statement
# 2. design.md - Solution design
# 3. examples.md - Usage examples
# 4. iterations.md - Design iterations

# Create commands, templates, rules
# Test in a sample project
```

## Roadmap

### Phase 1: Memory Management ✅ (v0.2.0)

- [x] `/gov-memory-init` command
- [x] `/gov-memory-create` command
- [x] `/gov-memory-update` command
- [x] `/gov-graph-generate` command
- [x] Memory structure template
- [x] Graph generator tool
- [x] Installation script
- [x] Update script

### Phase 2: Specification (Planned)

- [ ] `/gov-spec-start` command
- [ ] `/gov-spec-iterate` command
- [ ] Feature specification template
- [ ] Specification rules

### Phase 3: Research (Planned)

- [ ] `/gov-research` command
- [ ] Research document template
- [ ] Research rules

### Phase 4: Planning (Planned)

- [ ] `/gov-plan` command
- [ ] Task breakdown template
- [ ] Planning rules

### Phase 5: Implementation (Planned)

- [ ] `/gov-implement` command
- [ ] Implementation rules
- [ ] Code quality checks

### Phase 6: Testing (Planned)

- [ ] `/gov-test` command
- [ ] Test plan template
- [ ] Testing rules

## License

MIT License - See [LICENSE](LICENSE) file for details

## Support

- **Issues:** [GitHub Issues](https://github.com/bursonic/ai-governance-framework/issues)
- **Discussions:** [GitHub Discussions](https://github.com/bursonic/ai-governance-framework/discussions)
- **Documentation:** [Project Wiki](https://github.com/bursonic/ai-governance-framework/wiki)

## Credits

Built for use with [Claude Code](https://claude.com/claude-code) by Anthropic.

Powered by:
- [tree-sitter](https://tree-sitter.github.io/) - Parser generator tool
- [tree-sitter-languages](https://github.com/grantjenks/py-tree-sitter-languages) - Language bindings for Python

---

**Current Version:** 0.2.0
**Last Updated:** 2025-10-27
**Status:** Active Development
