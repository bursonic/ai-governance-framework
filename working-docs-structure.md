# Working Documents Structure

## Purpose
Supporting/temporary documents to design and iterate on each governance aspect before creating final artifacts.

## Proposed Structure

```
mem-spec-res-plan-do/
├── working-docs/          # Design and analysis documents (temporary/supporting)
│   ├── 01-memory/
│   │   ├── analysis.md           # Problem analysis and requirements
│   │   ├── design.md             # Design decisions and approach
│   │   ├── examples.md           # Usage examples and scenarios
│   │   └── iterations.md         # Design iterations and learnings
│   ├── 02-specification/
│   │   ├── analysis.md
│   │   ├── design.md
│   │   ├── examples.md
│   │   └── iterations.md
│   ├── 03-research/
│   │   ├── analysis.md
│   │   ├── design.md
│   │   ├── examples.md
│   │   └── iterations.md
│   ├── 04-planning/
│   │   ├── analysis.md
│   │   ├── design.md
│   │   ├── examples.md
│   │   └── iterations.md
│   ├── 05-implementation/
│   │   ├── analysis.md
│   │   ├── design.md
│   │   ├── examples.md
│   │   └── iterations.md
│   └── 06-testing/
│       ├── analysis.md
│       ├── design.md
│       ├── examples.md
│       └── iterations.md
├── commands/              # Final governance artifacts
├── rules/
├── templates/
└── ...
```

## Document Types

### analysis.md
- Problem statement
- Current challenges in AI-driven development for this phase
- Requirements and constraints
- Goals and success criteria

### design.md
- Proposed solution/approach
- Command structure and behavior
- Rule definitions
- Template structure
- Integration points with other phases

### examples.md
- Real-world usage scenarios
- Command invocation examples
- Expected inputs and outputs
- Edge cases

### iterations.md
- Design changes and why
- Lessons learned
- Alternative approaches considered
- Future improvements

## Workflow

1. Start with `analysis.md` - understand the problem
2. Draft `design.md` - propose solution
3. Create `examples.md` - validate design with scenarios
4. Create final artifacts in `commands/`, `rules/`, `templates/`
5. Update `iterations.md` - document learnings

## Benefits

- Separate thinking/design space from final artifacts
- Track evolution of ideas
- Reusable examples for documentation
- Historical context for future improvements
