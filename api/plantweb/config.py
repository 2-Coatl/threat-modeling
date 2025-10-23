#!/usr/bin/env python3
"""
Plantweb Module - Configuration Management

Priority (highest to lowest):
1. Explicit parameters in code
2. Environment variables
3. ~/.plantwebrc file
4. Project infrastructure/config/plantweb.json
5. Default values
"""

import os
import json
from pathlib import Path
from typing import Dict, Any, Optional
from .exceptions import ConfigError

# Default configuration
DEFAULT_CONFIG = {
    'server_url': 'http://localhost:8080/plantuml',
    'cache_dir': os.path.expanduser('~/.cache/plantweb'),
    'engine': 'plantuml',
    'format': 'svg',
    'use_cache': True,
    'cache_max_age_days': 30,
    'timeout_seconds': 60,
    'verify_ssl': True,
}

# Global configuration state
_config: Dict[str, Any] = {}
_config_loaded: bool = False


def _load_from_file(filepath: Path) -> Dict[str, Any]:
    """Load configuration from JSON file"""
    if not filepath.exists():
        return {}

    try:
        with open(filepath, 'r') as f:
            data = json.load(f)
            if not isinstance(data, dict):
                return {}
            return data
    except (json.JSONDecodeError, IOError) as e:
        raise ConfigError(f"Failed to load config from {filepath}: {e}")


def _load_from_env() -> Dict[str, Any]:
    """Load configuration from environment variables"""
    env_config = {}

    # Map environment variables to config keys
    env_mapping = {
        'PLANTWEB_SERVER': 'server_url',
        'PLANTWEB_SERVER_URL': 'server_url',
        'PLANTUML_SERVER': 'server_url',
        'PLANTWEB_CACHE_DIR': 'cache_dir',
        'PLANTWEB_ENGINE': 'engine',
        'PLANTWEB_FORMAT': 'format',
        'PLANTWEB_USE_CACHE': 'use_cache',
        'PLANTWEB_TIMEOUT': 'timeout_seconds',
    }

    for env_var, config_key in env_mapping.items():
        value = os.environ.get(env_var)
        if value is not None:
            # Convert boolean strings
            if config_key in ['use_cache', 'verify_ssl']:
                value = value.lower() in ('true', '1', 'yes', 'on')
            # Convert numeric strings
            elif config_key in ['timeout_seconds', 'cache_max_age_days']:
                try:
                    value = int(value)
                except ValueError:
                    continue

            env_config[config_key] = value

    return env_config


def _load_all_sources() -> Dict[str, Any]:
    """Load configuration from all sources with proper priority"""
    config = DEFAULT_CONFIG.copy()

    # 1. Project config file (lowest priority after defaults)
    project_config_path = Path('/vagrant/infrastructure/config/plantweb.json')
    if project_config_path.exists():
        project_config = _load_from_file(project_config_path)
        config.update(project_config)

    # 2. User config file
    user_config_path = Path.home() / '.plantwebrc'
    if user_config_path.exists():
        user_config = _load_from_file(user_config_path)
        config.update(user_config)

    # 3. Environment variables (highest priority)
    env_config = _load_from_env()
    config.update(env_config)

    # Expand paths
    if 'cache_dir' in config:
        config['cache_dir'] = os.path.expanduser(config['cache_dir'])

    return config


def get_config() -> Dict[str, Any]:
    """
    Get current configuration.

    Returns:
        Dict containing current configuration
    """
    global _config, _config_loaded

    if not _config_loaded:
        _config = _load_all_sources()
        _config_loaded = True

    return _config.copy()


def configure(**kwargs) -> None:
    """
    Configure Plantweb settings.

    Args:
        server_url: PlantUML server URL
        cache_dir: Cache directory path
        engine: Default rendering engine (plantuml, graphviz, ditaa)
        format: Default output format (svg, png)
        use_cache: Enable/disable caching
        cache_max_age_days: Maximum age of cached items in days
        timeout_seconds: HTTP timeout in seconds
        verify_ssl: Verify SSL certificates

    Example:
        configure(
            server_url='http://localhost:8080/plantuml',
            format='svg',
            use_cache=True
        )
    """
    global _config, _config_loaded

    # Load defaults if not loaded
    if not _config_loaded:
        _config = _load_all_sources()
        _config_loaded = True

    # Validate and update config
    valid_keys = set(DEFAULT_CONFIG.keys())
    for key, value in kwargs.items():
        if key not in valid_keys:
            raise ConfigError(f"Unknown configuration key: {key}")

        # Expand paths
        if key == 'cache_dir' and isinstance(value, str):
            value = os.path.expanduser(value)

        _config[key] = value


def reset_config() -> None:
    """Reset configuration to defaults"""
    global _config, _config_loaded
    _config = DEFAULT_CONFIG.copy()
    _config_loaded = True


def validate_config(config: Optional[Dict[str, Any]] = None) -> bool:
    """
    Validate configuration.

    Args:
        config: Configuration dict to validate (uses current if None)

    Returns:
        True if valid

    Raises:
        ConfigError: If configuration is invalid
    """
    if config is None:
        config = get_config()

    # Validate server_url
    if not config.get('server_url'):
        raise ConfigError("server_url is required")

    if not isinstance(config['server_url'], str):
        raise ConfigError("server_url must be a string")

    if not config['server_url'].startswith(('http://', 'https://')):
        raise ConfigError("server_url must start with http:// or https://")

    # Validate cache_dir
    if not config.get('cache_dir'):
        raise ConfigError("cache_dir is required")

    # Validate engine
    valid_engines = ('plantuml', 'graphviz', 'ditaa', 'auto')
    if config.get('engine') not in valid_engines:
        raise ConfigError(f"engine must be one of: {valid_engines}")

    # Validate format
    valid_formats = ('svg', 'png', 'txt', 'auto')
    if config.get('format') not in valid_formats:
        raise ConfigError(f"format must be one of: {valid_formats}")

    # Validate numeric values
    if not isinstance(config.get('timeout_seconds', 0), (int, float)):
        raise ConfigError("timeout_seconds must be numeric")

    if config.get('timeout_seconds', 0) <= 0:
        raise ConfigError("timeout_seconds must be positive")

    return True


def get_server_url() -> str:
    """Get configured PlantUML server URL"""
    return get_config()['server_url']


def get_cache_dir() -> str:
    """Get configured cache directory"""
    return get_config()['cache_dir']


def is_cache_enabled() -> bool:
    """Check if caching is enabled"""
    return get_config()['use_cache']
