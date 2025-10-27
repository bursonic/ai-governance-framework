# Iterative Code Graph Enrichment - PoC

> **Note**: This PoC has been extracted into a standalone tool repository as of 2025-10-27.
> See `EXTRACTED-TOOLS.md` for details on using the standalone version.
> This document is preserved for historical reference and design documentation.

## Overview
Successfully implemented a proof-of-concept for iterative/recursive enrichment of code graphs. The system performs multiple passes of analysis, where each layer builds upon previous layers to progressively extract deeper knowledge.

## Architecture

### Core Components

**1. IterativeEnricher** (`iterative_enricher.py`)
- Orchestrates the enrichment pipeline
- Manages multiple enrichment passes
- Handles convergence detection
- Saves intermediate artifacts and indexes
- Provides statistics about enrichment

**2. EnricherPass Base Class**
- Abstract base for all enrichment layers
- Defines interface: `enrich_node()` and `enrich_edge()`
- Each pass receives full graph and context from previous layers

**3. Layer Implementations**

#### Layer 1: Structural Enrichment (`layer1_structural.py`)
Extracts:
- **Classification**: domain vs infrastructure vs mixed
  - Uses naming patterns (e.g., "user", "product" = domain)
  - Analyzes imports (stdlib = infrastructure, local = domain)
- **Complexity metrics**: LOC, nesting depth, parameter count
- **Dependency information**: import depth, import list

#### Layer 2: Semantic Enrichment (`layer2_semantic.py`)
Extracts:
- **Pattern detection**: Entity, Service, Repository, Factory, ValueObject, DTO
- **Naming analysis**:
  - Extracted terms (split by snake_case or camelCase)
  - Convention detection (snake_case, camelCase, PascalCase)
  - Role indicators (get, set, calculate, validate, etc.)
- **Method roles**: getter, setter, validator, calculator, transformer, creator, mutator
- **API surface**: public, private, protected

#### Layer 3: Domain Enrichment (`layer3_domain.py`)
Extracts:
- **Domain concepts**: Entity names extracted from patterns and naming
- **Business rules**: Identified from validators, calculators, constraint functions
- **Workflow participation**: Authentication, registration, checkout, payment, etc.
- **Entity relationships**: HAS_MANY, HAS_ONE, USES (inferred from method signatures)

### Intermediate Artifacts

The enrichment process generates structured outputs:

```
.ai-gov/
├── code-graph.json                    # Original graph (input)
├── code-graph-enriched.json          # Final enriched graph
└── enrichment/
    ├── l1-structural.json            # After Layer 1
    ├── l2-semantic.json              # After Layer 2
    ├── l3-domain.json                # After Layer 3
    └── indexes/
        └── entity-index.json         # Quick lookup by entity ID
```

Each layer file contains the full graph with all enrichments up to that point, allowing:
- **Debugging**: Inspect what each layer contributed
- **Incremental processing**: Resume from any layer
- **Comparison**: See how enrichment evolves

## Iterative/Recursive Nature

### How It Works

1. **Multiple Iterations**: The pipeline can run multiple times (default: 2 iterations)
2. **Layer Uses Context**: Each layer receives `context` - list of all previous iteration results
3. **Convergence Detection**: Stops early if enrichment stabilizes (hash unchanged)
4. **Progressive Refinement**: Later layers use earlier layer results

### Example of Recursive Refinement

```
Iteration 1:
  Layer 1: User class → classified as "domain" (name-based)
  Layer 2: User class → detected as "Entity" pattern (uses Layer 1 classification)
  Layer 3: User.get_orders() → infers User HAS_MANY Order (uses Layer 2 pattern)

Iteration 2:
  Layer 3: Validates Order entity exists, confirms relationship
  (If new info discovered, could trigger Iteration 3)
```

### Benefits of Iteration

- **Cross-validation**: Multiple signals confirm inferences
- **Relationship discovery**: Find connections between entities
- **Pattern refinement**: Improve pattern detection with more context
- **Confidence scoring**: Repeated detection increases confidence

## CLI Tool

**Command**: `run-enrich-graph.sh <graph_path> [root_code_path]`

**Example**:
```bash
./run-enrich-graph.sh ../test-code-data/.ai-gov/code-graph.json ../test-code-data
```

**Output**:
- Enriched graph with 3 layers of metadata
- Intermediate layer artifacts
- Entity index for fast lookup
- Statistics about classification and patterns

## Test Results

Successfully tested on test-code-data:
- **Input**: 23 nodes, 20 edges
- **Output**: All 23 nodes enriched across 3 layers
- **Classifications**: 6 domain, 5 infrastructure, 2 mixed, 10 unknown
- **Patterns detected**: 2 Entities (User, Product)
- **Convergence**: Achieved after 2 iterations

### Sample Enrichment (User class)

```json
{
  "name": "User",
  "type": "class",
  "enrichment": {
    "layer1": {
      "classification": "domain",
      "complexity": {"loc": 10, "num_methods": 0},
      "dependencies": {"import_depth": 0, "num_imports": 0}
    },
    "layer2": {
      "patterns": ["Entity"],
      "naming_analysis": {
        "terms": ["user"],
        "conventions": "PascalCase"
      },
      "api_surface": "public"
    },
    "layer3": {
      "domain_concepts": ["User"],
      "business_rules": [],
      "workflow_participation": [],
      "entity_relationships": []
    }
  }
}
```

## Key Design Decisions

### 1. **Layered Architecture**
Each layer has specific responsibility, can be developed/tested independently

### 2. **Immutable Enrichment**
Original graph unchanged, enrichment added in separate `enrichment` key

### 3. **Artifact Preservation**
All intermediate states saved, enabling debugging and incremental processing

### 4. **Convergence Optional**
Can run fixed iterations or stop when stable

### 5. **Context Passing**
Each layer receives history of all previous iterations for cross-validation

## Limitations & Future Enhancements

### Current Limitations
- **Simple heuristics**: Rule-based pattern detection (not ML)
- **No call graph analysis**: Would need runtime or deeper AST analysis
- **Limited relationship inference**: Only from method signatures
- **No cross-file analysis**: Doesn't follow imports deeply

### Potential Enhancements

1. **Layer 4: Cross-Reference Enrichment**
   - Validate relationships across multiple files
   - Build concept clusters
   - Calculate confidence scores

2. **LLM-Assisted Analysis**
   - Use LLM to analyze function bodies for business rules
   - Semantic understanding of domain concepts
   - Better classification with context

3. **Call Graph Integration**
   - Add "calls" edges to graph
   - Trace execution flows
   - Build complete workflows

4. **Incremental Updates**
   - Only re-enrich changed nodes
   - Propagate changes through layers
   - Maintain consistency

5. **Visualization**
   - Generate diagrams from enriched graph
   - Interactive exploration of layers
   - Diff visualization between iterations

## Integration Path

This enrichment system fits into the larger domain knowledge extraction pipeline:

```
Code Files
    ↓
graph-generator.py (existing)
    ↓
code-graph.json
    ↓
enrich-graph.py (NEW - this PoC)
    ↓
code-graph-enriched.json + layers + indexes
    ↓
extract-domain-knowledge.py (future)
    ↓
domain-knowledge.json
```

The enriched graph provides a rich foundation for the domain extraction tool, which can leverage:
- Classifications to focus on domain code
- Patterns to identify entities/services/repositories
- Business rules for validation logic
- Relationships for entity modeling
- Workflows for process documentation

## Conclusion

The PoC demonstrates that iterative/recursive enrichment is:
- ✅ **Feasible**: Successfully implemented with 3 layers
- ✅ **Useful**: Extracts progressively deeper knowledge
- ✅ **Debuggable**: Intermediate artifacts enable inspection
- ✅ **Extensible**: Easy to add new layers
- ✅ **Efficient**: Converges quickly (2 iterations in test)

The recursive nature allows each layer to refine and validate findings from previous layers, creating a robust foundation for domain knowledge extraction.
