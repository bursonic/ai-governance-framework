# Domain Knowledge & Business Logic Extraction - Design

## Goal
Extract domain knowledge and business logic from codebases into structured JSON format, leveraging the ASL graph as a foundation.

## Problem Analysis

### What is "Domain Knowledge"?
- **Domain Entities**: Core business objects (User, Product, Order, Invoice, etc.)
- **Business Rules**: Validation logic, constraints, state transitions
- **Workflows**: Multi-step processes (checkout flow, approval process)
- **Relationships**: How entities relate to each other (1-to-many, many-to-many)
- **Domain Events**: Significant occurrences (order placed, payment processed)
- **Invariants**: Rules that must always be true
- **Policies**: Business policies encoded in code

### What is "Business Logic"?
- **Calculations**: Pricing, taxes, discounts, scoring algorithms
- **Decision Logic**: Conditional branching based on business rules
- **State Management**: Entity lifecycle, status transitions
- **Validation Rules**: What makes an entity valid
- **Side Effects**: Database writes, API calls, event emissions
- **Error Handling**: Business exceptions vs technical errors

## Challenges

### 1. Signal vs Noise
- Code contains infrastructure/technical concerns mixed with domain logic
- Need to separate "what" (domain) from "how" (implementation)
- Framework code vs business code

### 2. Implicit Knowledge
- Not all domain knowledge is explicit in code
- Relationships may be implicit (naming conventions, patterns)
- Business rules scattered across multiple functions

### 3. Context Requirements
- Understanding requires broader context than single functions
- Need to trace through call chains
- Cross-cutting concerns

### 4. Language & Framework Variations
- Different patterns in different languages
- OOP vs functional approaches
- Framework-specific patterns (Django models, Spring beans, etc.)

## Proposed Architecture

### Two-Phase Approach

#### Phase 1: Graph Preprocessing & Enrichment
Transform raw ASL graph into a domain-aware knowledge graph

#### Phase 2: Domain Knowledge Extraction
Extract structured domain information from enriched graph

---

## Phase 1: Graph Preprocessing & Enrichment

### Step 1.1: Classify Nodes by Role

**Technical Classification**
- Infrastructure: Database connections, HTTP clients, loggers
- Framework: Controllers, middleware, decorators
- Utilities: String helpers, date formatters
- Domain: Business entities and logic

**Heuristics for Classification**
```python
Domain indicators:
- Located in specific directories: models/, domain/, entities/, services/
- Naming patterns: *Service, *Repository, *Entity, *Model
- Low coupling to frameworks (few framework imports)
- Contains business vocabulary

Infrastructure indicators:
- Imports from infrastructure libraries
- Names like: *Client, *Connection, *Adapter
- High I/O operations (file, network, DB)

Utility indicators:
- Pure functions (no side effects)
- Generic names: format_*, parse_*, validate_*
- No domain vocabulary
```

### Step 1.2: Extract Semantic Information

**From Function/Class Names**
- Parse camelCase/snake_case into tokens
- Build vocabulary of domain terms
- Identify verbs (actions) vs nouns (entities)

Example:
```
calculateOrderTotal → Action: calculate, Entity: Order, Aspect: total
getUserByEmail → Action: get, Entity: User, Criteria: email
validatePaymentMethod → Action: validate, Entity: Payment, Aspect: method
```

**From Code Comments & Docstrings**
- Extract documentation
- Identify business rules in comments
- Parse structured docs (Args, Returns, Raises)

**From Type Annotations**
- Parameter types reveal entity relationships
- Return types show data flow
- Generic types show collections/containment

### Step 1.3: Identify Domain Patterns

**Entity Pattern Detection**
- Classes with data fields + methods
- Presence of constructors, validators
- CRUD-related methods
- Serialization/deserialization

**Service Pattern Detection**
- Stateless classes (no instance variables)
- Methods that coordinate multiple entities
- Transaction boundaries
- External integrations

**Repository Pattern Detection**
- Database query methods
- CRUD operations for specific entity
- Query builders

**Value Object Pattern Detection**
- Immutable classes
- Equality based on values
- No identity field (ID)

### Step 1.4: Build Enhanced Graph

**New Node Types**
- DomainEntity
- DomainService
- BusinessRule
- ValueObject
- DomainEvent
- Repository

**New Edge Types**
- `uses_entity`: Service → Entity
- `validates`: Function → Entity
- `transforms`: Function → Entity (input) → Entity (output)
- `emits_event`: Function → Event
- `enforces_rule`: Function → BusinessRule
- `persists`: Repository → Entity

**Node Enrichment**
Add properties:
- `domain_role`: entity, service, repository, value_object
- `domain_terms`: [extracted, vocabulary, terms]
- `business_importance`: score based on centrality + naming
- `entity_type`: null or entity name
- `has_validation`: boolean
- `has_side_effects`: boolean

### Step 1.5: Compute Graph Metrics

**Domain-Specific Metrics**
- Entity centrality: How many services/functions use this entity
- Business complexity: Cyclomatic complexity weighted by domain importance
- Rule concentration: Number of validation rules per entity
- Domain cohesion: How tightly related are domain terms in a module

**Store in Graph**
Add as node properties for fast querying

---

## Phase 2: Domain Knowledge Extraction

### Extraction Queries & Strategies

#### 2.1: Entity Extraction

**Strategy**
1. Find all nodes classified as DomainEntity
2. For each entity, traverse to find:
   - Fields/properties (from AST)
   - Methods (behavior)
   - Relationships (from type annotations and function signatures)
   - Validations (functions that check constraints)
   - Events (emitted or handled)

**Output Schema**
```json
{
  "entities": [
    {
      "name": "Order",
      "type": "entity",
      "file": "models/order.py",
      "location": {"line": 15, "column": 0},
      "description": "Represents a customer order",
      "fields": [
        {
          "name": "id",
          "type": "UUID",
          "nullable": false,
          "description": "Unique order identifier"
        },
        {
          "name": "customer_id",
          "type": "UUID",
          "nullable": false,
          "relationship": {
            "type": "belongs_to",
            "target": "Customer"
          }
        },
        {
          "name": "status",
          "type": "OrderStatus",
          "nullable": false,
          "description": "Current order status",
          "values": ["pending", "confirmed", "shipped", "delivered", "cancelled"]
        },
        {
          "name": "total",
          "type": "Decimal",
          "nullable": false,
          "computed": true
        }
      ],
      "methods": [
        {
          "name": "calculate_total",
          "type": "calculation",
          "returns": "Decimal",
          "description": "Calculates order total including tax and shipping"
        },
        {
          "name": "can_cancel",
          "type": "rule",
          "returns": "bool",
          "description": "Checks if order can be cancelled"
        }
      ],
      "business_rules": [
        {
          "rule": "Order total must be positive",
          "location": "validate_total:23"
        },
        {
          "rule": "Cannot cancel shipped orders",
          "location": "can_cancel:45"
        }
      ],
      "relationships": [
        {
          "type": "has_many",
          "target": "OrderItem",
          "description": "Items in the order"
        },
        {
          "type": "belongs_to",
          "target": "Customer",
          "description": "Customer who placed the order"
        }
      ],
      "events": [
        {
          "name": "OrderPlaced",
          "when": "on_create",
          "location": "place_order:67"
        },
        {
          "name": "OrderCancelled",
          "when": "status_change",
          "location": "cancel:89"
        }
      ],
      "importance_score": 0.92
    }
  ]
}
```

#### 2.2: Business Rule Extraction

**Strategy**
1. Identify validation functions (names like `validate_*`, `check_*`, `is_valid_*`)
2. Extract conditional logic (if statements with business-meaningful conditions)
3. Find constraint checks (assertions, raises exceptions)
4. Parse docstrings for explicit rule statements

**Pattern Recognition**
```python
# Pattern 1: Validation function
def validate_order(order):
    if order.total < 0:
        raise ValidationError("Order total must be positive")
    if order.items.empty():
        raise ValidationError("Order must contain at least one item")

# Extract:
# Rule: "Order total must be positive"
# Rule: "Order must contain at least one item"

# Pattern 2: State transition guard
def can_ship(order):
    return order.status == "confirmed" and order.payment_received

# Extract:
# Rule: "Order can only be shipped if confirmed and payment received"

# Pattern 3: Business calculation
def calculate_discount(order):
    if order.total > 1000:
        return order.total * 0.1
    elif order.customer.is_premium:
        return order.total * 0.05
    return 0

# Extract:
# Rule: "Orders over $1000 get 10% discount"
# Rule: "Premium customers get 5% discount"
```

**Output Schema**
```json
{
  "business_rules": [
    {
      "id": "rule_001",
      "name": "Minimum order total",
      "description": "Order total must be positive",
      "category": "validation",
      "entity": "Order",
      "location": {
        "file": "models/order.py",
        "function": "validate_order",
        "line": 23
      },
      "expression": "order.total < 0",
      "severity": "error",
      "enforcement": "pre_save"
    },
    {
      "id": "rule_002",
      "name": "Discount eligibility",
      "description": "Orders over $1000 get 10% discount",
      "category": "calculation",
      "entity": "Order",
      "location": {
        "file": "services/pricing.py",
        "function": "calculate_discount",
        "line": 45
      },
      "condition": "order.total > 1000",
      "result": "10% discount",
      "priority": 1
    }
  ]
}
```

#### 2.3: Workflow Extraction

**Strategy**
1. Find orchestrator functions (high fan-out, calls multiple services)
2. Trace execution paths through graph
3. Identify state transitions
4. Map decision points

**Pattern Recognition**
```python
def checkout_workflow(cart, payment_info):
    # Step 1
    order = create_order(cart)

    # Step 2
    if not validate_payment(payment_info):
        return {"error": "Invalid payment"}

    # Step 3
    payment = process_payment(order, payment_info)

    # Step 4
    if payment.successful:
        order.confirm()
        send_confirmation_email(order)
        emit_event("OrderPlaced", order)
    else:
        order.cancel()

    return order

# Extract workflow:
# 1. Create order
# 2. Validate payment
# 3. Process payment
# 4. If successful: confirm + notify
#    If failed: cancel
```

**Output Schema**
```json
{
  "workflows": [
    {
      "name": "checkout_workflow",
      "description": "Complete order checkout process",
      "entry_point": "services/checkout.py:checkout_workflow:10",
      "steps": [
        {
          "order": 1,
          "name": "Create order",
          "function": "create_order",
          "inputs": ["cart"],
          "outputs": ["order"]
        },
        {
          "order": 2,
          "name": "Validate payment",
          "function": "validate_payment",
          "inputs": ["payment_info"],
          "outputs": ["validation_result"],
          "decision_point": true
        },
        {
          "order": 3,
          "name": "Process payment",
          "function": "process_payment",
          "inputs": ["order", "payment_info"],
          "outputs": ["payment"],
          "conditional": "if validation_result.valid"
        },
        {
          "order": 4,
          "name": "Confirm order",
          "function": "order.confirm",
          "conditional": "if payment.successful"
        },
        {
          "order": 5,
          "name": "Send notification",
          "function": "send_confirmation_email",
          "conditional": "if payment.successful",
          "side_effect": "email"
        }
      ],
      "decision_points": [
        {
          "step": 2,
          "condition": "payment is valid",
          "success_path": [3, 4, 5],
          "failure_path": ["return error"]
        },
        {
          "step": 3,
          "condition": "payment successful",
          "success_path": [4, 5],
          "failure_path": ["cancel order"]
        }
      ],
      "side_effects": ["database_write", "external_api_call", "email"],
      "events_emitted": ["OrderPlaced"]
    }
  ]
}
```

#### 2.4: Domain Vocabulary Extraction

**Strategy**
1. Collect all domain terms from entity names, method names
2. Group by semantic similarity
3. Build synonym/related terms map
4. Extract from comments and documentation

**Output Schema**
```json
{
  "vocabulary": {
    "entities": [
      "Order", "Customer", "Product", "Payment", "Invoice", "Shipment"
    ],
    "actions": [
      "place", "cancel", "ship", "deliver", "refund", "process"
    ],
    "states": [
      "pending", "confirmed", "shipped", "delivered", "cancelled"
    ],
    "concepts": {
      "Order": {
        "synonyms": ["purchase", "request"],
        "related": ["OrderItem", "Invoice", "Shipment"],
        "description": "Customer purchase request",
        "usage_count": 145
      }
    }
  }
}
```

#### 2.5: Relationship Map

**Strategy**
1. Extract relationships from:
   - Type annotations (User → List[Order])
   - Foreign keys (order.customer_id)
   - Method signatures (get_orders_for_customer(customer: Customer))
   - Database schema (if available)

**Output Schema**
```json
{
  "relationships": [
    {
      "source": "Customer",
      "target": "Order",
      "type": "one_to_many",
      "description": "Customer can have multiple orders",
      "evidence": [
        "Order.customer_id field",
        "Customer.get_orders() method",
        "Type annotation: Customer → List[Order]"
      ]
    },
    {
      "source": "Order",
      "target": "OrderItem",
      "type": "one_to_many",
      "description": "Order contains multiple items",
      "cascade_delete": true
    }
  ]
}
```

---

## Implementation Strategy

### Storage Format for Enriched Graph

**Option 1: Extended JSON Format**
Keep graph in JSON but add enrichment fields
- Pros: Simple, no new dependencies
- Cons: Querying is inefficient, no indexing

**Option 2: SQLite Database**
Store graph in relational DB with indexes
- Pros: Fast queries, ACID, embedded (no server)
- Cons: Schema changes harder, not ideal for graph traversal

**Option 3: Graph Database (Neo4j, ArangoDB)**
Use proper graph database
- Pros: Optimal for graph queries, visual exploration
- Cons: Extra dependency, setup complexity

**Option 4: Hybrid (Recommended for MVP)**
- Primary: Enhanced JSON with computed indexes
- Cache: In-memory graph structure for queries
- Future: Migrate to graph DB if needed

**Enriched Graph Schema**
```json
{
  "nodes": [...],  // Original nodes
  "edges": [...],  // Original edges
  "enrichment": {
    "domain_classification": {
      "node_id": {
        "role": "domain_entity",
        "entity_type": "Order",
        "importance_score": 0.92,
        "domain_terms": ["order", "total", "customer"],
        "patterns": ["entity", "validation"]
      }
    },
    "indexes": {
      "by_type": {
        "domain_entity": ["node_id_1", "node_id_2"],
        "service": ["node_id_3"]
      },
      "by_entity": {
        "Order": ["node_id_1", "node_id_4"],
        "Customer": ["node_id_2"]
      },
      "by_importance": ["node_id_1", "node_id_2", ...]  // Sorted
    },
    "vocabulary": {
      "terms": ["order", "customer", "payment", ...],
      "term_to_nodes": {
        "order": ["node_id_1", "node_id_4", ...]
      }
    }
  },
  "metadata": {
    "enrichment_timestamp": "2025-10-27T...",
    "domain_node_count": 45,
    "infrastructure_node_count": 120
  }
}
```

### Command Line Interface

```bash
# Step 1: Generate base graph (already exists)
.ai-gov/tools/run-graph-generator.sh python ./src

# Step 2: Enrich graph with domain knowledge
.ai-gov/tools/enrich-graph.sh

# Step 3: Extract domain knowledge
.ai-gov/tools/extract-domain-knowledge.sh [options]

Options:
  --entities          Extract entity definitions
  --rules            Extract business rules
  --workflows        Extract business workflows
  --vocabulary       Extract domain vocabulary
  --relationships    Extract entity relationships
  --all              Extract everything (default)
  --output <file>    Output file (default: .ai-gov/domain-knowledge.json)
  --format <json|yaml>  Output format
```

### Implementation Plan

**Tool 1: `enrich-graph.py`**
Input: `.ai-gov/code-graph.json`
Output: `.ai-gov/enriched-graph.json`

Tasks:
1. Load code graph
2. Classify nodes (domain vs infrastructure)
3. Extract semantic information
4. Detect domain patterns
5. Build indexes
6. Compute metrics
7. Save enriched graph

**Tool 2: `extract-domain-knowledge.py`**
Input: `.ai-gov/enriched-graph.json`
Output: `.ai-gov/domain-knowledge.json`

Tasks:
1. Load enriched graph
2. Run extraction queries based on options
3. Apply extraction strategies
4. Structure output according to schema
5. Validate and save

---

## Advanced Considerations

### LLM-Assisted Extraction

Some domain knowledge is hard to extract with rules alone. Consider LLM-assisted extraction:

**Hybrid Approach**
1. Rule-based: Extract structural information (fast, reliable)
2. LLM-based: Extract semantic meaning (slower, more accurate)

**LLM Tasks**
- Summarize business logic in natural language
- Infer implicit relationships
- Classify ambiguous functions
- Extract business rules from complex conditionals
- Generate entity descriptions

**Prompt Template**
```
Given this function:
[function code]

And its context:
[related entities, callers, callees]

Answer:
1. Is this a domain function or infrastructure?
2. What business rule(s) does it enforce?
3. What domain entities does it operate on?
4. Summarize its business purpose in one sentence.
```

### Incremental Updates

For large codebases, full regeneration is expensive:
- Track file modification times
- Only re-process changed files
- Update affected graph sections
- Recompute metrics for changed subgraphs

### Validation & Confidence Scores

Not all extractions are equally confident:
- Add confidence scores to extracted knowledge
- Mark ambiguous cases for human review
- Provide evidence/reasoning for extractions

### Integration with Existing Tools

- Export to OpenAPI/Swagger for API documentation
- Generate PlantUML diagrams
- Create Mermaid workflow diagrams
- Export to data modeling tools (DBDiagram, etc.)

---

## Success Metrics

How do we know the extraction is good?

1. **Coverage**: % of domain code that's been classified
2. **Accuracy**: Manual review of sample extractions
3. **Completeness**: All expected entities/rules found
4. **Usefulness**: Can it answer key questions?
   - "What are all the entities in this system?"
   - "What business rules apply to Orders?"
   - "How does the checkout workflow work?"
5. **Consistency**: Multiple runs produce same results

---

## Next Steps

1. **Validate approach**: Does this align with your vision?
2. **Prioritize features**: Which extractions are most valuable?
3. **Choose storage format**: SQLite, JSON, or graph DB?
4. **Start with MVP**: Implement simplest version first
   - Entity extraction only
   - Rule-based (no LLM initially)
   - JSON output
5. **Iterate**: Add more sophisticated extraction as needed

## Questions for Discussion

1. What programming languages/frameworks are primary targets?
2. What's the typical codebase size we're dealing with?
3. Are there specific domain patterns you want to detect? (DDD, Clean Architecture, etc.)
4. Should we integrate LLMs from the start or keep it rule-based initially?
5. What's the end goal? (Documentation, AI context, code generation, analysis?)
