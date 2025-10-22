#!/usr/bin/env python3
"""
Plantweb Module - Rendering Engine

Handles communication with PlantUML Server and diagram rendering.
"""

import zlib
import base64
import requests
from pathlib import Path
from typing import Union, Optional
from .config import get_config, validate_config
from .exceptions import RenderError, ServerError
from .cache import get_cached, save_to_cache


def encode_plantuml(text: str) -> str:
    """
    Encode PlantUML text to URL-safe format.

    This uses PlantUML's custom encoding scheme based on deflate + custom base64.
    Based on: https://plantuml.com/text-encoding

    Args:
        text: PlantUML diagram text

    Returns:
        Encoded string suitable for URL
    """
    # Compress with deflate
    compressed = zlib.compress(text.encode('utf-8'), 9)[2:-4]

    # Custom base64 alphabet for PlantUML
    alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_'

    # Convert to custom base64
    result = []
    for i in range(0, len(compressed), 3):
        if i + 2 < len(compressed):
            b1, b2, b3 = compressed[i], compressed[i + 1], compressed[i + 2]
            result.append(alphabet[(b1 >> 2) & 0x3F])
            result.append(alphabet[((b1 & 0x3) << 4) | ((b2 >> 4) & 0xF)])
            result.append(alphabet[((b2 & 0xF) << 2) | ((b3 >> 6) & 0x3)])
            result.append(alphabet[b3 & 0x3F])
        elif i + 1 < len(compressed):
            b1, b2 = compressed[i], compressed[i + 1]
            result.append(alphabet[(b1 >> 2) & 0x3F])
            result.append(alphabet[((b1 & 0x3) << 4) | ((b2 >> 4) & 0xF)])
            result.append(alphabet[((b2 & 0xF) << 2)])
        else:
            b1 = compressed[i]
            result.append(alphabet[(b1 >> 2) & 0x3F])
            result.append(alphabet[((b1 & 0x3) << 4)])

    return ''.join(result)


def detect_engine(content: str) -> str:
    """
    Detect diagram engine from content.

    Args:
        content: Diagram content

    Returns:
        Engine name: 'plantuml', 'graphviz', or 'ditaa'
    """
    content_lower = content.lower().strip()

    if '@startuml' in content_lower:
        return 'plantuml'
    elif '@startdot' in content_lower:
        return 'graphviz'
    elif '@startditaa' in content_lower:
        return 'ditaa'
    elif 'digraph' in content_lower or 'graph' in content_lower:
        return 'graphviz'
    else:
        return 'plantuml'  # Default


def render(
        content: str,
        output_path: Union[str, Path],
        format: Optional[str] = None,
        engine: Optional[str] = None,
        use_cache: Optional[bool] = None
) -> Path:
    """
    Render diagram content to file.

    Args:
        content: PlantUML/Graphviz/Ditaa diagram content
        output_path: Path to save rendered diagram
        format: Output format ('svg', 'png', 'txt'). Uses config default if None
        engine: Rendering engine ('plantuml', 'graphviz', 'ditaa', 'auto').
                Uses config default if None
        use_cache: Enable caching. Uses config default if None

    Returns:
        Path to rendered file

    Raises:
        RenderError: If rendering fails
        ServerError: If server communication fails

    Example:
        render(
            "@startuml\\nAlice -> Bob\\n@enduml",
            "diagram.svg",
            format="svg"
        )
    """
    # Load config
    config = get_config()
    validate_config(config)

    # Use config defaults if not specified
    if format is None:
        format = config['format']
    if engine is None:
        engine = config['engine']
    if use_cache is None:
        use_cache = config['use_cache']

    # Auto-detect engine
    if engine == 'auto':
        engine = detect_engine(content)

    # Normalize format
    format = format.lower()
    if format not in ('svg', 'png', 'txt'):
        raise RenderError(f"Unsupported format: {format}")

    # Check cache
    if use_cache:
        cached_data = get_cached(content, format)
        if cached_data is not None:
            output_path = Path(output_path)
            output_path.parent.mkdir(parents=True, exist_ok=True)

            with open(output_path, 'wb') as f:
                f.write(cached_data)

            return output_path

    # Encode content
    try:
        encoded = encode_plantuml(content)
    except Exception as e:
        raise RenderError(f"Failed to encode content: {e}")

    # Build URL
    server_url = config['server_url'].rstrip('/')
    url = f"{server_url}/{format}/{encoded}"

    # Make request
    try:
        timeout = config['timeout_seconds']
        verify_ssl = config['verify_ssl']

        response = requests.get(url, timeout=timeout, verify=verify_ssl)
        response.raise_for_status()

    except requests.exceptions.Timeout:
        raise ServerError(f"Request timeout after {timeout}s")
    except requests.exceptions.ConnectionError as e:
        raise ServerError(f"Failed to connect to server: {e}")
    except requests.exceptions.HTTPError as e:
        raise ServerError(f"Server returned error: {e}")
    except Exception as e:
        raise ServerError(f"Request failed: {e}")

    # Check response
    if len(response.content) < 100:
        raise RenderError(f"Response too small ({len(response.content)} bytes), likely an error")

    # Save to cache
    if use_cache:
        try:
            save_to_cache(content, format, response.content)
        except Exception as e:
            # Cache errors are not fatal
            pass

    # Write to output file
    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, 'wb') as f:
        f.write(response.content)

    return output_path


def render_file(
        input_path: Union[str, Path],
        output_path: Optional[Union[str, Path]] = None,
        format: Optional[str] = None,
        engine: Optional[str] = None,
        use_cache: Optional[bool] = None
) -> Path:
    """
    Render diagram from file.

    Args:
        input_path: Path to input diagram file
        output_path: Path to save output. If None, uses input path with new extension
        format: Output format ('svg', 'png', 'txt')
        engine: Rendering engine ('plantuml', 'graphviz', 'ditaa', 'auto')
        use_cache: Enable caching

    Returns:
        Path to rendered file

    Example:
        render_file("diagram.uml", "diagram.svg", format="svg")
    """
    input_path = Path(input_path)

    if not input_path.exists():
        raise RenderError(f"Input file not found: {input_path}")

    if not input_path.is_file():
        raise RenderError(f"Input is not a file: {input_path}")

    # Read content
    try:
        with open(input_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        raise RenderError(f"Failed to read input file: {e}")

    # Determine output path
    if output_path is None:
        if format is None:
            format = get_config()['format']
        output_path = input_path.with_suffix(f'.{format}')
    else:
        output_path = Path(output_path)

    return render(content, output_path, format, engine, use_cache)


def render_batch(
        input_paths: list,
        output_dir: Union[str, Path],
        format: Optional[str] = None,
        engine: Optional[str] = None,
        use_cache: Optional[bool] = None
) -> dict:
    """
    Render multiple diagram files.

    Args:
        input_paths: List of input file paths
        output_dir: Directory to save outputs
        format: Output format
        engine: Rendering engine
        use_cache: Enable caching

    Returns:
        Dict mapping input paths to output paths

    Example:
        results = render_batch(
            ["diagram1.uml", "diagram2.uml"],
            "output/",
            format="svg"
        )
    """
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    results = {}

    for input_path in input_paths:
        input_path = Path(input_path)

        # Determine output filename
        if format is None:
            format = get_config()['format']

        output_filename = input_path.stem + f'.{format}'
        output_path = output_dir / output_filename

        try:
            result_path = render_file(
                input_path,
                output_path,
                format,
                engine,
                use_cache
            )
            results[input_path] = result_path
        except Exception as e:
            # Continue on error, store exception
            results[input_path] = e

    return results