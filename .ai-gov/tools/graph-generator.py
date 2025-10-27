#!/usr/bin/env python3
"""
Code Graph Generator
Extracts code structure (files, classes, functions) and relationships (imports, inheritance)
into a graph model for knowledge management.
"""

import json
import sys
from pathlib import Path
from typing import Dict, List, Set, Optional, Any
from dataclasses import dataclass, asdict
from datetime import datetime
import hashlib

try:
    from tree_sitter_languages import get_parser, get_language
except ImportError:
    print("Error: tree-sitter-languages not installed. Run: pip install tree-sitter-languages")
    sys.exit(1)


@dataclass
class Node:
    id: str
    type: str  # file, class, function, method
    name: str
    path: str
    location: Dict[str, int]  # line, column
    metadata: Dict[str, Any] = None

    def to_dict(self):
        return asdict(self)


@dataclass
class Edge:
    source: str
    target: str
    type: str  # imports, contains, calls, inherits

    def to_dict(self):
        return asdict(self)


class CodeGraphGenerator:
    def __init__(self, root_path: str, language: str, exclude_patterns: Optional[List[str]] = None):
        self.root_path = Path(root_path).resolve()
        self.language = language
        self.parser = get_parser(language)
        self.lang_obj = get_language(language)
        self.nodes: List[Node] = []
        self.edges: List[Edge] = []
        self.exclude_patterns = exclude_patterns or [
            'node_modules', 'venv', 'dist', 'build', '.git',
            '__pycache__', '.pytest_cache', 'target', '.idea'
        ]

    def generate_id(self, type: str, path: str, name: str, line: int) -> str:
        """Generate unique ID for a node"""
        content = f"{type}:{path}:{name}:{line}"
        return hashlib.md5(content.encode()).hexdigest()[:16]

    def should_exclude(self, path: Path) -> bool:
        """Check if path should be excluded"""
        parts = path.parts
        return any(pattern in parts for pattern in self.exclude_patterns)

    def find_files(self, patterns: List[str]) -> List[Path]:
        """Find all files matching patterns"""
        files = []
        for pattern in patterns:
            for file_path in self.root_path.rglob(pattern):
                if file_path.is_file() and not self.should_exclude(file_path):
                    files.append(file_path)
        return files

    def extract_python_nodes(self, tree, file_path: Path, content: bytes):
        """Extract nodes from Python file"""
        relative_path = str(file_path.relative_to(self.root_path))

        # Add file node
        file_id = self.generate_id("file", relative_path, file_path.name, 0)
        self.nodes.append(Node(
            id=file_id,
            type="file",
            name=file_path.name,
            path=relative_path,
            location={"line": 0, "column": 0},
            metadata={"language": self.language}
        ))

        # Query for classes and functions
        class_query = self.lang_obj.query("""
            (class_definition
                name: (identifier) @class.name
            ) @class.def
        """)

        function_query = self.lang_obj.query("""
            (function_definition
                name: (identifier) @func.name
            ) @func.def
        """)

        import_query = self.lang_obj.query("""
            (import_statement
                name: (dotted_name) @import.name
            )
            (import_from_statement
                module_name: (dotted_name) @import.name
            )
        """)

        # Extract classes
        for match in class_query.captures(tree.root_node):
            node, capture_name = match
            if capture_name == "class.def":
                class_name_node = node.child_by_field_name("name")
                if class_name_node:
                    class_name = content[class_name_node.start_byte:class_name_node.end_byte].decode('utf8')
                    class_id = self.generate_id("class", relative_path, class_name, node.start_point[0])

                    self.nodes.append(Node(
                        id=class_id,
                        type="class",
                        name=class_name,
                        path=relative_path,
                        location={"line": node.start_point[0] + 1, "column": node.start_point[1]},
                        metadata={}
                    ))

                    # Add contains edge from file to class
                    self.edges.append(Edge(source=file_id, target=class_id, type="contains"))

        # Extract functions
        for match in function_query.captures(tree.root_node):
            node, capture_name = match
            if capture_name == "func.def":
                func_name_node = node.child_by_field_name("name")
                if func_name_node:
                    func_name = content[func_name_node.start_byte:func_name_node.end_byte].decode('utf8')
                    func_id = self.generate_id("function", relative_path, func_name, node.start_point[0])

                    self.nodes.append(Node(
                        id=func_id,
                        type="function",
                        name=func_name,
                        path=relative_path,
                        location={"line": node.start_point[0] + 1, "column": node.start_point[1]},
                        metadata={}
                    ))

                    # Add contains edge from file to function
                    self.edges.append(Edge(source=file_id, target=func_id, type="contains"))

        # Extract imports (simplified - just capture import statements)
        imports = []
        for match in import_query.captures(tree.root_node):
            node, capture_name = match
            if "import.name" in capture_name:
                import_name = content[node.start_byte:node.end_byte].decode('utf8')
                imports.append(import_name)

        # Store imports in file metadata
        if imports:
            for node in self.nodes:
                if node.id == file_id:
                    node.metadata['imports'] = imports
                    break

    def generate(self, file_patterns: List[str]) -> Dict[str, Any]:
        """Generate the code graph"""
        files = self.find_files(file_patterns)
        print(f"Found {len(files)} files to process")

        for file_path in files:
            try:
                content = file_path.read_bytes()
                tree = self.parser.parse(content)

                if self.language == "python":
                    self.extract_python_nodes(tree, file_path, content)
                # Add more language handlers here

            except Exception as e:
                print(f"Error processing {file_path}: {e}", file=sys.stderr)

        return {
            "nodes": [node.to_dict() for node in self.nodes],
            "edges": [edge.to_dict() for edge in self.edges],
            "metadata": {
                "generated": datetime.now().isoformat(),
                "language": self.language,
                "root_path": str(self.root_path),
                "files_processed": len(files),
                "node_count": len(self.nodes),
                "edge_count": len(self.edges)
            }
        }

    def get_statistics(self) -> Dict[str, Any]:
        """Get graph statistics"""
        node_types = {}
        edge_types = {}

        for node in self.nodes:
            node_types[node.type] = node_types.get(node.type, 0) + 1

        for edge in self.edges:
            edge_types[edge.type] = edge_types.get(edge.type, 0) + 1

        # Calculate node connectivity
        connectivity = {}
        for edge in self.edges:
            connectivity[edge.source] = connectivity.get(edge.source, 0) + 1
            connectivity[edge.target] = connectivity.get(edge.target, 0) + 1

        # Get top connected nodes
        top_nodes = sorted(connectivity.items(), key=lambda x: x[1], reverse=True)[:5]
        top_connected = []
        for node_id, count in top_nodes:
            node = next((n for n in self.nodes if n.id == node_id), None)
            if node:
                top_connected.append({
                    "name": node.name,
                    "type": node.type,
                    "path": node.path,
                    "connections": count
                })

        return {
            "node_types": node_types,
            "edge_types": edge_types,
            "top_connected": top_connected
        }


def main():
    if len(sys.argv) < 2:
        print("Usage: graph-generator.py <language> [root_path]")
        print("Example: graph-generator.py python .")
        sys.exit(1)

    language = sys.argv[1]
    root_path = sys.argv[2] if len(sys.argv) > 2 else "."

    # Determine file patterns based on language
    patterns_map = {
        "python": ["**/*.py"],
        "javascript": ["**/*.js", "**/*.jsx"],
        "typescript": ["**/*.ts", "**/*.tsx"],
        "go": ["**/*.go"],
        "rust": ["**/*.rs"],
        "java": ["**/*.java"],
    }

    if language not in patterns_map:
        print(f"Error: Unsupported language '{language}'")
        print(f"Supported: {', '.join(patterns_map.keys())}")
        sys.exit(1)

    patterns = patterns_map[language]

    print(f"Generating code graph for {language} files...")
    print(f"Root path: {root_path}")
    print(f"Patterns: {patterns}")
    print()

    generator = CodeGraphGenerator(root_path, language)
    graph = generator.generate(patterns)
    stats = generator.get_statistics()

    # Save graph
    output_path = Path(root_path) / ".ai-gov" / "code-graph.json"
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, "w") as f:
        json.dump(graph, f, indent=2)

    print(f"\n✓ Graph saved to {output_path}")
    print(f"\nStatistics:")
    print(f"  Files processed: {graph['metadata']['files_processed']}")
    print(f"  Total nodes: {graph['metadata']['node_count']}")
    print(f"  Total edges: {graph['metadata']['edge_count']}")
    print(f"\n  Nodes by type:")
    for node_type, count in stats['node_types'].items():
        print(f"    {node_type}: {count}")
    print(f"\n  Edges by type:")
    for edge_type, count in stats['edge_types'].items():
        print(f"    {edge_type}: {count}")

    if stats['top_connected']:
        print(f"\n  Top connected nodes:")
        for node in stats['top_connected']:
            print(f"    {node['name']} ({node['type']}) - {node['connections']} connections")
            print(f"      {node['path']}")


if __name__ == "__main__":
    main()
