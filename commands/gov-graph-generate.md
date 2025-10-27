---
description: Generate a code graph model from the codebase using memory metadata
---

# Graph Generate - Code Structure Model

You are generating a graph representation of the codebase for use as a knowledge source.

## Purpose

Create a structured graph model with:
- **Nodes**: Files, classes, functions, methods
- **Edges**: Imports, calls, inheritance, composition relationships

This graph will be stored as structured data (JSON) for later use in understanding code relationships.

## Prerequisites

- Memory file exists at `.ai-gov/memory.md` (run `/gov-memory-init` if needed)
- Framework tools installed (automatic during framework installation)

## Your Task

**Step 1 - Read Memory Metadata**
1. Read `.ai-gov/memory.md` to understand:
   - Project structure and key directories
   - Primary languages used
   - Sub-repositories if any are mentioned
   - Entry points

**Step 2 - Identify Target Files**
1. Based on memory metadata, identify directories to scan:
   - Use Project Structure > Key Directories
   - If sub-repos are mentioned, include them
   - Exclude: `node_modules/`, `venv/`, `dist/`, `build/`, `.git/`, `__pycache__/`
2. Determine file patterns based on languages in Technology Stack:
   - Python: `**/*.py`
   - JavaScript/TypeScript: `**/*.js`, `**/*.ts`, `**/*.jsx`, `**/*.tsx`
   - Go: `**/*.go`
   - Rust: `**/*.rs`
   - Java: `**/*.java`
   - etc.

**Step 3 - Generate Graph Model**
1. Use the framework's graph generator tool (already installed):
   ```bash
   .ai-gov/tools/run-graph-generator.sh <language> [root_path]
   ```

2. The tool will:
   - Parses each file using tree-sitter
   - Extracts nodes:
     - File-level: file path, language
     - Class-level: class name, location, parent classes
     - Function-level: function name, location, parameters
   - Extracts edges:
     - Import relationships (file → file)
     - Call relationships (function → function)
     - Inheritance (class → class)
     - Contains (file → class → function)
   - Outputs JSON graph format with nodes and edges
   - Saves output to `.ai-gov/code-graph.json`

**Graph Format:**
```json
{
  "nodes": [
    {"id": "unique-id", "type": "file|class|function", "name": "...", "path": "...", "location": {"line": N}},
    ...
  ],
  "edges": [
    {"source": "id1", "target": "id2", "type": "imports|calls|inherits|contains"},
    ...
  ],
  "metadata": {
    "generated": "timestamp",
    "language": "...",
    "root_path": "..."
  }
}

**Step 4 - Generate Summary**
1. Count nodes by type (files, classes, functions)
2. Count edges by type (imports, calls, etc.)
3. Identify key files (highest connectivity)
4. Output summary to user

## Implementation Steps

1. **Read memory** to determine the primary language and project structure
2. **Determine language parameter** for the tool:
   - Python: `python`
   - JavaScript: `javascript`
   - TypeScript: `typescript`
   - Go: `go`
   - Rust: `rust`
   - Java: `java`
3. **Run the graph generator**:
   ```bash
   .ai-gov/tools/run-graph-generator.sh <language> .
   ```
4. **Parse the output** and report statistics to the user

## Output Format

Inform the user:
1. Files scanned
2. Nodes extracted (breakdown by type)
3. Edges extracted (breakdown by type)
4. Graph saved to `.ai-gov/code-graph.json`
5. Show top 5 most connected nodes

## Success Criteria

- `.ai-gov/code-graph.json` exists
- Valid JSON with nodes and edges arrays
- Nodes have unique IDs and types
- Edges reference valid node IDs
- User sees summary of graph statistics

## Next Steps

After generating the base code graph, you can enrich it with semantic and domain knowledge:

```
Use /gov-graph-enrich command to add:
- Layer 1: Structural analysis (classification, complexity, dependencies)
- Layer 2: Semantic analysis (patterns, naming, method roles)
- Layer 3: Domain analysis (concepts, business rules, relationships)
```

The enriched graph provides deeper insights for AI context and code understanding.
