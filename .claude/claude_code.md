# Project Rules for Claude Code

## Working Documents Workflow

When developing governance artifacts for this framework, follow this process:

### Directory Structure

Each phase has a working directory under `working-docs/`:
```
working-docs/
├── 01-memory/
├── 02-specification/
├── 03-research/
├── 04-planning/
├── 05-implementation/
└── 06-testing/
```

Each phase directory contains four document types:
- `analysis.md` - Problem statement, requirements, constraints, goals
- `design.md` - Proposed solution, command structure, rules, templates
- `examples.md` - Usage scenarios, command examples, edge cases
- `iterations.md` - Design changes, lessons learned, alternatives

### Workflow for Each Phase

1. **Start with analysis.md**
   - Understand the problem
   - Define requirements and constraints
   - Set goals and success criteria

2. **Draft design.md**
   - Propose solution/approach
   - Design command structure and behavior
   - Define rule definitions
   - Design template structure
   - Identify integration points

3. **Create examples.md**
   - Validate design with real-world scenarios
   - Show command invocation examples
   - Document expected inputs/outputs
   - Cover edge cases

4. **Create final artifacts**
   - Commands in `commands/`
   - Rules in `rules/`
   - Templates in `templates/`

5. **Update iterations.md**
   - Document design changes
   - Record lessons learned
   - Note alternative approaches
   - Suggest future improvements

### Principles

- Work on one phase at a time
- Complete all four working documents before creating final artifacts
- Use examples to validate design decisions
- Keep final artifacts separate from working documents
- Working documents remain in the project for historical context
