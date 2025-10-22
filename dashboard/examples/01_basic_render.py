#!/usr/bin/env python3
"""
Example 1: Basic Rendering with Plantweb

This example shows how to render a simple PlantUML diagram
using the Plantweb module.
"""

import sys
from pathlib import Path

# Add project to path
sys.path.insert(0, '/vagrant')

from dashboard.plantweb import render, configure


def main():
    print("=" * 60)
    print("  Example 1: Basic Rendering")
    print("=" * 60)
    print()

    # Configure Plantweb (optional, uses defaults if not called)
    configure(
        server_url="http://localhost:8080/plantuml/",
        format="svg",
        use_cache=True
    )

    print("Configuration:")
    print("  Server: http://localhost:8080/plantuml/")
    print("  Format: svg")
    print("  Cache: enabled")
    print()

    # Simple PlantUML diagram
    plantuml_code = """
@startuml
Alice -> Bob: Authentication Request
Bob --> Alice: Authentication Response

Alice -> Bob: Another authentication Request
Alice <-- Bob: Another authentication Response
@enduml
"""

    # Output path
    output_path = Path("/vagrant/dashboard/output/diagrams/example_basic.svg")

    print("Rendering diagram...")
    print(f"  Input: PlantUML code ({len(plantuml_code)} chars)")
    print(f"  Output: {output_path}")
    print()

    try:
        # Render the diagram
        result = render(plantuml_code, output_path, format='svg')

        print("[SUCCESS] Diagram rendered")
        print(f"  Diagram saved to: {result}")
        print(f"  File size: {result.stat().st_size} bytes")
        print()
        print("View in browser:")
        print("  http://localhost:8080/outputs/diagrams/example_basic.svg")

    except Exception as e:
        print(f"[ERROR] Rendering failed: {e}")
        return 1

    return 0


if __name__ == '__main__':
    sys.exit(main())