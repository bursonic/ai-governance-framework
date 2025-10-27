# Extracted Tools

This document tracks tools that have been extracted from this project into standalone repositories.

## Code Graph Enricher

**Extracted**: 2025-10-27
**Version**: 0.1.0
**Status**: ✅ Moved to separate repository

### What It Does

Iterative enrichment of code graphs with structural, semantic, and domain knowledge through multiple analysis layers.

### Features

- **Layer 1**: Structural analysis (classification, complexity, dependencies)
- **Layer 2**: Semantic analysis (patterns, naming conventions, method roles)
- **Layer 3**: Domain analysis (entities, business rules, workflows, relationships)
- **Iterative refinement**: Multiple passes with convergence detection
- **Intermediate artifacts**: Saves each layer for debugging
- **Zero dependencies**: Pure Python stdlib

### Files That Were Part of This Tool

Originally developed in:
- `.ai-gov/tools/iterative_enricher.py`
- `.ai-gov/tools/layer1_structural.py`
- `.ai-gov/tools/layer2_semantic.py`
- `.ai-gov/tools/layer3_domain.py`
- `.ai-gov/tools/enrichment_schemas.py`
- `.ai-gov/tools/enrich-graph.py`
- `.ai-gov/tools/run-enrich-graph.sh`

### Documentation

Design documentation preserved in this project:
- `working-docs/01-memory/iterative-enrichment-poc.md` - Original PoC design
- `working-docs/01-memory/code-graph-knowledge-extraction.md` - Conceptual foundation

### Integration

To use the extracted tool with this project:

```bash
# Install from separate repo
pip install git+https://github.com/yourusername/code-graph-enricher.git

# Generate base graph (using tools in this project)
.ai-gov/tools/run-graph-generator.sh python /path/to/code

# Enrich the graph (using extracted tool)
enrich-graph /path/to/code/.ai-gov/code-graph.json /path/to/code
```

### Successor in This Project

The enricher functionality has been fully extracted. The remaining tools in `.ai-gov/tools/` are:
- `graph-generator.py` - Base code graph generation (uses tree-sitter)
- `run-graph-generator.sh` - Wrapper for graph generator

Future domain extraction tools will use the enriched graphs from the standalone enricher.

---

## Future Extractions

Tools planned for extraction:
- [ ] Domain Knowledge Extractor (to be built)
- [ ] Code Graph Visualizer (future)
- [ ] Graph Query Engine (future)
