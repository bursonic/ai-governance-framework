# Project Structure Draft

## Overview
Framework for AI-driven software development governance using Claude Code commands and rules.

## Proposed Directory Structure

```
mem-spec-res-plan-do/
├── commands/               # Custom slash commands for each phase (to be copied to .claude/commands/)
│   ├── memory-init.md
│   ├── memory-update.md
│   ├── spec-start.md
│   ├── spec-iterate.md
│   ├── research.md
│   ├── plan.md
│   ├── implement.md
│   └── test.md
├── rules/                  # Governance rules and policies
│   ├── memory-management.md
│   ├── specification.md
│   ├── research.md
│   ├── planning.md
│   ├── implementation.md
│   └── testing.md
├── templates/              # Templates for each phase
│   ├── memory-structure.md
│   ├── feature-spec.md
│   ├── research-doc.md
│   ├── task-breakdown.md
│   └── test-plan.md
├── project-structure-draft.md  # This file
└── README.md
```

## Phase Breakdown

### 1. Memory Management
- Commands: `/memory-init`, `/memory-update`
- Purpose: Manage context window with project memory storage and iterative updates
- Artifacts: memory-structure.md template, memory-management.md rules

### 2. Specification
- Commands: `/spec-start`, `/spec-iterate`
- Purpose: Conduct iterative specification of new features
- Artifacts: feature-spec.md template, specification.md rules

### 3. Research
- Commands: `/research`
- Purpose: Conduct research using memory and spec
- Artifacts: research-doc.md template, research.md rules

### 4. Planning
- Commands: `/plan`
- Purpose: Task breakdown and planning
- Artifacts: task-breakdown.md template, planning.md rules

### 5. Implementation
- Commands: `/implement`
- Purpose: Single task implementation
- Artifacts: implementation.md rules

### 6. Testing
- Commands: `/test`
- Purpose: Conduct testing
- Artifacts: test-plan.md template, testing.md rules

## Notes

- The `commands/` folder contains command files that should be copied to `.claude/commands/` in actual projects
- Each phase has corresponding rules and templates
- This framework is designed to be reusable across different projects
