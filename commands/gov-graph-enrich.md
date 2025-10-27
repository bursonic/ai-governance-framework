---
description: Enrich the code graph with structural, semantic, and domain knowledge layers
---

# Graph Enrich - Multi-Layer Knowledge Extraction

You are enriching a previously generated code graph with progressive layers of semantic and domain knowledge.

## Purpose

Transform a basic code graph (nodes + edges) into an enriched knowledge graph with:
- **Layer 1 (Structural)**: Classification (domain vs infrastructure), complexity metrics, dependencies
- **Layer 2 (Semantic)**: Design patterns, naming analysis, method roles, API surface
- **Layer 3 (Domain)**: Domain concepts, business rules, workflows, entity relationships

This enriched graph serves as a rich knowledge source for AI context and understanding.

## Prerequisites

- Code graph exists at `.ai-gov/code-graph.json` (run `/gov-graph-generate` if needed)
- Framework tools installed with `code-graph-enricher` package
- Graph should contain nodes (files, classes, functions) and edges (imports, calls, etc.)

## Your Task

**Step 1 - Verify Prerequisites**
1. Check that `.ai-gov/code-graph.json` exists
2. Verify the enricher is available:
   ```bash
   .ai-gov/tools/venv/bin/enrich-graph -h
   ```
3. If enricher is not available, inform user that framework installation may be incomplete

**Step 2 - Run Enrichment**
1. Execute the enricher on the code graph:
   ```bash
   .ai-gov/tools/venv/bin/enrich-graph .ai-gov/code-graph.json .
   ```

2. The tool will:
   - Load the base code graph
   - Run 3 layers of enrichment iteratively
   - Detect convergence (stops when no new information is added)
   - Save enriched graph to `.ai-gov/code-graph-enriched.json`
   - Save intermediate layer artifacts to `.ai-gov/enrichment/l1-structural.json`, `l2-semantic.json`, `l3-domain.json`
   - Create entity index at `.ai-gov/enrichment/indexes/entity-index.json`

**Step 3 - Verify Output**
1. Check that enrichment completed successfully
2. Verify output files exist:
   - `.ai-gov/code-graph-enriched.json` (main output)
   - `.ai-gov/enrichment/l1-structural.json`
   - `.ai-gov/enrichment/l2-semantic.json`
   - `.ai-gov/enrichment/l3-domain.json`
   - `.ai-gov/enrichment/indexes/entity-index.json`

**Step 4 - Generate Summary Report**

Parse the enriched graph and report to the user:

1. **Enrichment Statistics**:
   - Total nodes enriched
   - Number of iterations until convergence
   - Processing time

2. **Layer 1 - Structural Analysis**:
   - Classification breakdown (domain vs infrastructure vs mixed vs unknown)
   - Average complexity metrics
   - Dependency depth distribution

3. **Layer 2 - Semantic Analysis**:
   - Patterns detected (Entity, Service, Repository, Factory, etc.)
   - Common naming conventions found
   - API surface breakdown (public/private/protected)

4. **Layer 3 - Domain Analysis**:
   - Domain concepts identified
   - Number of business rules found
   - Workflows detected
   - Entity relationships inferred

5. **Key Entities**:
   - List top 5-10 domain entities with their patterns and relationships

## Enrichment Layers Explained

### Layer 1: Structural Enrichment
Extracts code structure metadata:
- **Classification**: Determines if code is domain logic, infrastructure, or mixed
- **Complexity**: Lines of code, nesting depth, parameter count
- **Dependencies**: Import depth, number of imports

### Layer 2: Semantic Enrichment
Analyzes code semantics and patterns:
- **Patterns**: Detects Entity, Service, Repository, Factory, ValueObject, DTO patterns
- **Naming**: Extracts domain terms, detects naming conventions
- **Method Roles**: Classifies methods as getters, setters, validators, calculators, etc.
- **API Surface**: Determines if methods are public, private, or protected

### Layer 3: Domain Enrichment
Extracts domain knowledge:
- **Domain Concepts**: Entity names and domain terms
- **Business Rules**: Validation logic, constraints, calculations
- **Workflows**: Authentication, checkout, payment, registration flows
- **Relationships**: HAS_MANY, HAS_ONE, USES relationships between entities

## Iterative Refinement

The enricher runs multiple iterations (typically 2-3):
- Each layer builds on previous layers' findings
- Later iterations validate and refine earlier findings
- Convergence detection stops when no new information is added
- Cross-validation increases confidence in extracted knowledge

## Output Structure

```
.ai-gov/
├── code-graph.json              # Input (from /gov-graph-generate)
├── code-graph-enriched.json     # Final enriched output
└── enrichment/
    ├── l1-structural.json       # After Layer 1
    ├── l2-semantic.json         # After Layer 2
    ├── l3-domain.json           # After Layer 3
    └── indexes/
        └── entity-index.json    # Fast lookup index
```

Each node in the enriched graph has this structure:
```json
{
  "id": "...",
  "name": "...",
  "type": "class|function|file",
  "enrichment": {
    "layer1": {
      "classification": "domain|infrastructure|mixed|unknown",
      "complexity": {...},
      "dependencies": {...}
    },
    "layer2": {
      "patterns": ["Entity", "Service", ...],
      "naming_analysis": {...},
      "method_roles": [...],
      "api_surface": "public|private|protected"
    },
    "layer3": {
      "domain_concepts": [...],
      "business_rules": [...],
      "workflow_participation": [...],
      "entity_relationships": [...]
    }
  }
}
```

## Example Summary Report Format

```
Enrichment Complete
===================

Statistics:
- Nodes enriched: 145
- Iterations: 2 (converged)
- Processing time: 3.2s

Layer 1 - Structural:
- Domain: 42 nodes (29%)
- Infrastructure: 68 nodes (47%)
- Mixed: 12 nodes (8%)
- Unknown: 23 nodes (16%)

Layer 2 - Semantic:
- Patterns detected:
  * Entity: 8
  * Service: 5
  * Repository: 3
  * Factory: 2
- Naming conventions: snake_case (Python), PascalCase (classes)

Layer 3 - Domain:
- Domain concepts: 12 unique concepts
- Business rules: 18 rules identified
- Workflows: Authentication, Checkout, Payment
- Entity relationships: 15 relationships

Key Entities:
1. User (Entity) - HAS_MANY Order, HAS_ONE Profile
2. Product (Entity) - USES Inventory
3. Order (Entity) - HAS_MANY OrderItem, USES Payment
4. ShoppingCart (domain) - USES Product, USES User
5. PaymentService (Service) - USES Payment, USES Order

Files saved:
- .ai-gov/code-graph-enriched.json (42KB)
- .ai-gov/enrichment/l1-structural.json (38KB)
- .ai-gov/enrichment/l2-semantic.json (40KB)
- .ai-gov/enrichment/l3-domain.json (42KB)
- .ai-gov/enrichment/indexes/entity-index.json (8KB)
```

## Success Criteria

- `.ai-gov/code-graph-enriched.json` exists with valid enrichment data
- All intermediate layer files created
- Entity index generated
- User sees comprehensive summary with statistics and key findings
- Enrichment converged (no infinite loops)

## Next Steps

After enrichment, the enriched graph can be used for:
- Domain knowledge extraction and documentation
- Architecture visualization
- Code quality analysis
- Enhanced AI context for future development
- Relationship mapping and impact analysis
