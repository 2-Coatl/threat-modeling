#!/usr/bin/env python3
"""
Plantweb Module - pytm Integration

Provides integration with pytm threat modeling framework.
Extracts PlantUML code from pytm models and renders using PlantUML Server.
"""

import sys
import io
from pathlib import Path
from typing import Union, List, Optional
from .renderer import render
from .exceptions import PytmError, RenderError


def extract_plantuml_from_pytm(tm_model, diagram_type: str = 'seq') -> str:
    """
    Extract PlantUML code from pytm model.

    Args:
        tm_model: pytm TM object
        diagram_type: Type of diagram ('seq' for sequence, 'dfd' for data flow)

    Returns:
        PlantUML diagram code as string

    Raises:
        PytmError: If extraction fails
    """
    if not hasattr(tm_model, 'seq') and not hasattr(tm_model, 'dfd'):
        raise PytmError("Invalid pytm model: missing seq() or dfd() method")

    # Capture stdout
    old_stdout = sys.stdout
    sys.stdout = captured_output = io.StringIO()

    try:
        if diagram_type == 'seq':
            if not hasattr(tm_model, 'seq'):
                raise PytmError("Model does not support sequence diagrams")
            tm_model.seq()
        elif diagram_type == 'dfd':
            if not hasattr(tm_model, 'dfd'):
                raise PytmError("Model does not support data flow diagrams")
            tm_model.dfd()
        else:
            raise PytmError(f"Unknown diagram type: {diagram_type}")

        # Get captured output
        output = captured_output.getvalue()

    except Exception as e:
        raise PytmError(f"Failed to extract PlantUML from pytm: {e}")

    finally:
        # Restore stdout
        sys.stdout = old_stdout

    if not output or len(output) < 10:
        raise PytmError("No PlantUML code generated from pytm model")

    return output


def render_pytm_dfd(
        tm_model,
        output_path: Union[str, Path],
        format: str = 'png',
        use_cache: Optional[bool] = None
) -> Path:
    """
    Render Data Flow Diagram from pytm model.

    Note: DFD uses Graphviz directly (dot), not PlantUML Server.
    This function maintains compatibility but uses pytm's native rendering.

    Args:
        tm_model: pytm TM object
        output_path: Path to save diagram
        format: Output format (png recommended for DFD)
        use_cache: Enable caching

    Returns:
        Path to rendered diagram
    """
    # DFD is rendered using Graphviz directly by pytm
    # We extract the dot output and use dot command

    try:
        plantuml_code = extract_plantuml_from_pytm(tm_model, 'dfd')
    except PytmError:
        # If extraction fails, fall back to pytm native rendering
        raise PytmError(
            "DFD rendering through Plantweb not supported. "
            "Use pytm's native dfd() method with dot command."
        )

    # For DFD, we should use dot directly, not PlantUML server
    raise PytmError(
        "DFD rendering should use Graphviz dot directly. "
        "This is already handled by bin/generate script."
    )


def render_pytm_seq(
        tm_model,
        output_path: Union[str, Path],
        format: str = 'svg',
        use_cache: Optional[bool] = None
) -> Path:
    """
    Render Sequence Diagram from pytm model using PlantUML Server.

    Args:
        tm_model: pytm TM object
        output_path: Path to save diagram
        format: Output format ('svg' or 'png')
        use_cache: Enable caching

    Returns:
        Path to rendered diagram

    Example:
        from pytm import TM
        from dashboard.plantweb import render_pytm_seq

        tm = TM("My Model")
        # ... define model ...

        render_pytm_seq(tm, "output/diagram_seq.svg")
    """
    try:
        plantuml_code = extract_plantuml_from_pytm(tm_model, 'seq')
    except PytmError as e:
        raise PytmError(f"Failed to extract sequence diagram: {e}")

    try:
        return render(
            plantuml_code,
            output_path,
            format=format,
            engine='plantuml',
            use_cache=use_cache
        )
    except RenderError as e:
        raise PytmError(f"Failed to render sequence diagram: {e}")


def render_pytm_model(
        tm_model,
        output_dir: Union[str, Path],
        formats: Optional[List[str]] = None,
        use_cache: Optional[bool] = None
) -> dict:
    """
    Render complete pytm model (all diagrams).

    This renders sequence diagrams using PlantUML Server.
    DFD diagrams should still use the native pytm/dot rendering.

    Args:
        tm_model: pytm TM object
        output_dir: Directory to save diagrams
        formats: List of output formats (default: ['svg'])
        use_cache: Enable caching

    Returns:
        Dict mapping diagram types to output paths

    Example:
        from pytm import TM
        from dashboard.plantweb import render_pytm_model

        tm = TM("My Model")
        # ... define model ...

        results = render_pytm_model(
            tm,
            output_dir="output/diagrams",
            formats=['svg', 'png']
        )
    """
    if formats is None:
        formats = ['svg']

    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Get model name for file naming
    model_name = getattr(tm_model, 'name', 'model')
    model_name = model_name.lower().replace(' ', '_')

    results = {}

    # Render sequence diagram (using PlantUML Server)
    for format in formats:
        seq_filename = f"{model_name}_seq.{format}"
        seq_path = output_dir / seq_filename

        try:
            rendered_path = render_pytm_seq(
                tm_model,
                seq_path,
                format=format,
                use_cache=use_cache
            )
            results[f'seq_{format}'] = rendered_path
        except Exception as e:
            results[f'seq_{format}'] = e

    # Note: DFD rendering should continue using native pytm + dot
    # We don't render DFD here as it's better handled by the existing
    # bin/generate script using dot directly

    return results


def get_pytm_plantuml_code(tm_model) -> dict:
    """
    Get all PlantUML code from pytm model without rendering.

    Args:
        tm_model: pytm TM object

    Returns:
        Dict with 'seq' and 'dfd' PlantUML code

    Example:
        code = get_pytm_plantuml_code(tm)
        print(code['seq'])
    """
    results = {}

    # Try to get sequence diagram code
    try:
        results['seq'] = extract_plantuml_from_pytm(tm_model, 'seq')
    except Exception as e:
        results['seq'] = None
        results['seq_error'] = str(e)

    # Try to get DFD code (though DFD is Graphviz, not PlantUML)
    try:
        results['dfd'] = extract_plantuml_from_pytm(tm_model, 'dfd')
    except Exception as e:
        results['dfd'] = None
        results['dfd_error'] = str(e)

    return results