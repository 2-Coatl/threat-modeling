#!/usr/bin/env python3
"""
Plantweb Module - Command Line Interface

Provides CLI wrapper for the Plantweb module.
"""

import sys
import argparse
from pathlib import Path
from typing import List, Optional
from .config import configure, get_config, reset_config
from .renderer import render_file, render_batch
from .cache import clear_cache, get_cache_stats, prune_cache
from .exceptions import PlantwebError


def parse_arguments(args: Optional[List[str]] = None) -> argparse.Namespace:
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(
        prog='plantweb-render',
        description='Render PlantUML/Graphviz/Ditaa diagrams using PlantUML Server',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Render single file
  plantweb-render diagram.uml

  # Specify format
  plantweb-render --format png diagram.uml

  # Batch rendering
  plantweb-render --batch models/*.uml

  # Custom server
  plantweb-render --server http://localhost:8080/plantuml diagram.uml

  # View configuration
  plantweb-render --config

  # Clear cache
  plantweb-render --clear-cache

  # Cache statistics
  plantweb-render --stats
        """
    )

    # Main arguments
    parser.add_argument(
        'files',
        nargs='*',
        help='Diagram files to render'
    )

    # Rendering options
    parser.add_argument(
        '--format', '-f',
        choices=['svg', 'png', 'txt'],
        help='Output format (default: from config)'
    )

    parser.add_argument(
        '--engine', '-e',
        choices=['auto', 'plantuml', 'graphviz', 'ditaa'],
        help='Rendering engine (default: auto-detect)'
    )

    parser.add_argument(
        '--output', '-o',
        help='Output file path (for single file)'
    )

    parser.add_argument(
        '--output-dir', '-d',
        help='Output directory (for batch)'
    )

    # Server configuration
    parser.add_argument(
        '--server', '-s',
        help='PlantUML server URL'
    )

    parser.add_argument(
        '--no-cache',
        action='store_true',
        help='Disable caching'
    )

    # Batch mode
    parser.add_argument(
        '--batch', '-b',
        action='store_true',
        help='Batch mode: render multiple files'
    )

    # Configuration commands
    parser.add_argument(
        '--config',
        action='store_true',
        help='Show current configuration'
    )

    parser.add_argument(
        '--reset-config',
        action='store_true',
        help='Reset configuration to defaults'
    )

    # Cache commands
    parser.add_argument(
        '--clear-cache',
        action='store_true',
        help='Clear all cached diagrams'
    )

    parser.add_argument(
        '--stats',
        action='store_true',
        help='Show cache statistics'
    )

    parser.add_argument(
        '--prune-cache',
        type=int,
        metavar='DAYS',
        help='Remove cache entries older than DAYS'
    )

    # General options
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Verbose output'
    )

    parser.add_argument(
        '--version',
        action='version',
        version='%(prog)s 1.0.0'
    )

    return parser.parse_args(args)


def show_config() -> int:
    """Show current configuration"""
    config = get_config()

    print("Current Plantweb Configuration:")
    print("=" * 50)

    for key, value in sorted(config.items()):
        print(f"  {key:20s}: {value}")

    print("=" * 50)

    return 0


def show_stats() -> int:
    """Show cache statistics"""
    stats = get_cache_stats()

    print("Plantweb Cache Statistics:")
    print("=" * 50)
    print(f"  Enabled:       {stats['enabled']}")
    print(f"  Cache Dir:     {stats['cache_dir']}")
    print(f"  Total Files:   {stats['total_files']}")
    print(f"  Total Size:    {stats['total_size_mb']:.2f} MB")
    print()

    if stats['engines']:
        print("By Engine:")
        for engine, engine_stats in stats['engines'].items():
            print(f"  {engine}:")
            print(f"    Files:  {engine_stats['files']}")
            print(f"    Size:   {engine_stats['size_mb']:.2f} MB")

            if engine_stats['formats']:
                print(f"    Formats:")
                for fmt, fmt_stats in engine_stats['formats'].items():
                    print(f"      {fmt}: {fmt_stats['count']} files")

    print("=" * 50)

    return 0


def handle_clear_cache() -> int:
    """Clear cache"""
    try:
        count = clear_cache()
        print(f"Cleared {count} cached files")
        return 0
    except Exception as e:
        print(f"Error clearing cache: {e}", file=sys.stderr)
        return 1


def handle_prune_cache(days: int) -> int:
    """Prune old cache entries"""
    try:
        count = prune_cache(max_age_days=days)
        print(f"Removed {count} cache entries older than {days} days")
        return 0
    except Exception as e:
        print(f"Error pruning cache: {e}", file=sys.stderr)
        return 1


def handle_reset_config() -> int:
    """Reset configuration"""
    try:
        reset_config()
        print("Configuration reset to defaults")
        return 0
    except Exception as e:
        print(f"Error resetting config: {e}", file=sys.stderr)
        return 1


def handle_render_single(
        input_file: str,
        output_file: Optional[str],
        format: Optional[str],
        engine: Optional[str],
        use_cache: bool,
        verbose: bool
) -> int:
    """Render single file"""
    try:
        if verbose:
            print(f"Rendering: {input_file}")

        result = render_file(
            input_file,
            output_file,
            format=format,
            engine=engine,
            use_cache=use_cache
        )

        print(f"Rendered: {result}")
        return 0

    except PlantwebError as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        if verbose:
            import traceback
            traceback.print_exc()
        return 1


def handle_render_batch(
        input_files: List[str],
        output_dir: Optional[str],
        format: Optional[str],
        engine: Optional[str],
        use_cache: bool,
        verbose: bool
) -> int:
    """Render multiple files"""
    if not output_dir:
        output_dir = '.'

    try:
        if verbose:
            print(f"Rendering {len(input_files)} files to: {output_dir}")

        results = render_batch(
            input_files,
            output_dir,
            format=format,
            engine=engine,
            use_cache=use_cache
        )

        success_count = 0
        error_count = 0

        for input_path, result in results.items():
            if isinstance(result, Exception):
                print(f"✗ {input_path}: {result}", file=sys.stderr)
                error_count += 1
            else:
                print(f"✓ {input_path} -> {result}")
                success_count += 1

        print()
        print(f"Summary: {success_count} succeeded, {error_count} failed")

        return 0 if error_count == 0 else 1

    except Exception as e:
        print(f"Batch rendering failed: {e}", file=sys.stderr)
        if verbose:
            import traceback
            traceback.print_exc()
        return 1


def main(args: Optional[List[str]] = None) -> int:
    """Main entry point"""
    parsed_args = parse_arguments(args)

    # Apply configuration overrides
    config_overrides = {}

    if parsed_args.server:
        config_overrides['server_url'] = parsed_args.server

    if parsed_args.format:
        config_overrides['format'] = parsed_args.format

    if parsed_args.engine:
        config_overrides['engine'] = parsed_args.engine

    if parsed_args.no_cache:
        config_overrides['use_cache'] = False

    if config_overrides:
        configure(**config_overrides)

    # Handle configuration commands
    if parsed_args.config:
        return show_config()

    if parsed_args.reset_config:
        return handle_reset_config()

    # Handle cache commands
    if parsed_args.clear_cache:
        return handle_clear_cache()

    if parsed_args.stats:
        return show_stats()

    if parsed_args.prune_cache is not None:
        return handle_prune_cache(parsed_args.prune_cache)

    # Handle rendering
    if not parsed_args.files:
        print("Error: No input files specified", file=sys.stderr)
        print("Use --help for usage information")
        return 1

    use_cache = not parsed_args.no_cache

    if parsed_args.batch or len(parsed_args.files) > 1:
        return handle_render_batch(
            parsed_args.files,
            parsed_args.output_dir,
            parsed_args.format,
            parsed_args.engine,
            use_cache,
            parsed_args.verbose
        )
    else:
        return handle_render_single(
            parsed_args.files[0],
            parsed_args.output,
            parsed_args.format,
            parsed_args.engine,
            use_cache,
            parsed_args.verbose
        )


if __name__ == '__main__':
    sys.exit(main())