#!/usr/bin/env python3
"""
Plantweb Module - Cache Management

Provides caching functionality to avoid re-rendering identical diagrams.
"""

import hashlib
import time
from pathlib import Path
from typing import Optional, Dict, Any
from datetime import datetime, timedelta
from .config import get_cache_dir, is_cache_enabled
from .exceptions import CacheError


def _compute_hash(content: str) -> str:
    """
    Compute SHA256 hash of content.

    Args:
        content: Diagram content

    Returns:
        Hex digest of hash
    """
    # Normalize content (remove extra whitespace, normalize line endings)
    normalized = content.strip()
    normalized = normalized.replace('\r\n', '\n')
    normalized = '\n'.join(line.strip() for line in normalized.split('\n'))

    return hashlib.sha256(normalized.encode('utf-8')).hexdigest()


def _get_cache_path(content_hash: str, format: str, engine: str = 'plantuml') -> Path:
    """
    Get cache file path for given content hash and format.

    Args:
        content_hash: SHA256 hash of content
        format: Output format (svg, png, txt)
        engine: Rendering engine

    Returns:
        Path to cache file
    """
    cache_dir = Path(get_cache_dir())
    engine_dir = cache_dir / engine

    return engine_dir / f"{content_hash}.{format}"


def _is_cache_valid(cache_file: Path, max_age_days: int = 30) -> bool:
    """
    Check if cache file is still valid.

    Args:
        cache_file: Path to cache file
        max_age_days: Maximum age in days

    Returns:
        True if cache is valid
    """
    if not cache_file.exists():
        return False

    # Check file age
    mtime = cache_file.stat().st_mtime
    age_seconds = time.time() - mtime
    age_days = age_seconds / (24 * 3600)

    if age_days > max_age_days:
        return False

    # Check file size
    if cache_file.stat().st_size < 100:
        return False

    return True


def get_cached(
        content: str,
        format: str,
        engine: str = 'plantuml',
        max_age_days: int = 30
) -> Optional[bytes]:
    """
    Get cached diagram if available.

    Args:
        content: Diagram content
        format: Output format
        engine: Rendering engine
        max_age_days: Maximum age of cache in days

    Returns:
        Cached diagram bytes or None if not cached
    """
    if not is_cache_enabled():
        return None

    content_hash = _compute_hash(content)
    cache_file = _get_cache_path(content_hash, format, engine)

    if not _is_cache_valid(cache_file, max_age_days):
        return None

    try:
        with open(cache_file, 'rb') as f:
            return f.read()
    except Exception:
        return None


def save_to_cache(
        content: str,
        format: str,
        data: bytes,
        engine: str = 'plantuml'
) -> bool:
    """
    Save diagram to cache.

    Args:
        content: Diagram content
        format: Output format
        data: Rendered diagram bytes
        engine: Rendering engine

    Returns:
        True if saved successfully

    Raises:
        CacheError: If cache operation fails
    """
    if not is_cache_enabled():
        return False

    content_hash = _compute_hash(content)
    cache_file = _get_cache_path(content_hash, format, engine)

    try:
        # Create directory if needed
        cache_file.parent.mkdir(parents=True, exist_ok=True)

        # Write to temporary file first
        temp_file = cache_file.with_suffix('.tmp')
        with open(temp_file, 'wb') as f:
            f.write(data)

        # Atomic rename
        temp_file.rename(cache_file)

        return True

    except Exception as e:
        raise CacheError(f"Failed to save to cache: {e}")


def clear_cache(engine: Optional[str] = None, format: Optional[str] = None) -> int:
    """
    Clear cache.

    Args:
        engine: Clear only specific engine cache (None = all)
        format: Clear only specific format (None = all)

    Returns:
        Number of files removed
    """
    cache_dir = Path(get_cache_dir())

    if not cache_dir.exists():
        return 0

    count = 0

    if engine is not None:
        # Clear specific engine
        engine_dir = cache_dir / engine
        if engine_dir.exists():
            pattern = f"*.{format}" if format else "*"
            for cache_file in engine_dir.glob(pattern):
                try:
                    cache_file.unlink()
                    count += 1
                except Exception:
                    pass
    else:
        # Clear all engines
        for engine_dir in cache_dir.iterdir():
            if engine_dir.is_dir():
                pattern = f"*.{format}" if format else "*"
                for cache_file in engine_dir.glob(pattern):
                    try:
                        cache_file.unlink()
                        count += 1
                    except Exception:
                        pass

    return count


def get_cache_stats() -> Dict[str, Any]:
    """
    Get cache statistics.

    Returns:
        Dict with cache statistics
    """
    cache_dir = Path(get_cache_dir())

    stats = {
        'enabled': is_cache_enabled(),
        'cache_dir': str(cache_dir),
        'exists': cache_dir.exists(),
        'total_files': 0,
        'total_size_bytes': 0,
        'total_size_mb': 0.0,
        'engines': {},
    }

    if not cache_dir.exists():
        return stats

    for engine_dir in cache_dir.iterdir():
        if not engine_dir.is_dir():
            continue

        engine_name = engine_dir.name
        engine_stats = {
            'files': 0,
            'size_bytes': 0,
            'formats': {},
        }

        for cache_file in engine_dir.iterdir():
            if not cache_file.is_file():
                continue

            file_size = cache_file.stat().st_size
            file_format = cache_file.suffix.lstrip('.')

            engine_stats['files'] += 1
            engine_stats['size_bytes'] += file_size

            if file_format not in engine_stats['formats']:
                engine_stats['formats'][file_format] = {
                    'count': 0,
                    'size_bytes': 0
                }

            engine_stats['formats'][file_format]['count'] += 1
            engine_stats['formats'][file_format]['size_bytes'] += file_size

        engine_stats['size_mb'] = engine_stats['size_bytes'] / (1024 * 1024)
        stats['engines'][engine_name] = engine_stats

        stats['total_files'] += engine_stats['files']
        stats['total_size_bytes'] += engine_stats['size_bytes']

    stats['total_size_mb'] = stats['total_size_bytes'] / (1024 * 1024)

    return stats


def prune_cache(max_age_days: int = 30) -> int:
    """
    Remove old cache entries.

    Args:
        max_age_days: Remove files older than this

    Returns:
        Number of files removed
    """
    cache_dir = Path(get_cache_dir())

    if not cache_dir.exists():
        return 0

    cutoff_time = time.time() - (max_age_days * 24 * 3600)
    count = 0

    for engine_dir in cache_dir.iterdir():
        if not engine_dir.is_dir():
            continue

        for cache_file in engine_dir.iterdir():
            if not cache_file.is_file():
                continue

            try:
                if cache_file.stat().st_mtime < cutoff_time:
                    cache_file.unlink()
                    count += 1
            except Exception:
                pass

    return count