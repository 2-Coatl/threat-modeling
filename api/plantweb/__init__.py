#!/usr/bin/env python3
"""
Plantweb Integration Module
============================

Cliente Python para PlantUML Server con integración para pytm.

Este módulo proporciona una interfaz Python para renderizar diagramas
PlantUML, Graphviz y Ditaa usando un servidor PlantUML en lugar del
JAR local. Incluye integración específica para pytm (Python Threat
Modeling).

Uso básico:
    from api.plantweb import render, configure

    # Configurar (opcional)
    configure(server_url="http://localhost:8080/plantuml/")

    # Renderizar contenido directo
    render("@startuml\\nAlice -> Bob\\n@enduml", "output.svg")

Uso con pytm:
    from api.plantweb import render_pytm_model
    from api.models.auth_model import tm

    # Renderizar modelo completo
    render_pytm_model(tm, output_dir="./diagrams")

API Principal:
    - render(): Renderizar contenido PlantUML directo
    - render_file(): Renderizar desde archivo
    - render_batch(): Renderizar múltiples archivos
    - render_pytm_model(): Renderizar modelo pytm completo
    - render_pytm_seq(): Renderizar solo sequence diagram de pytm
    - configure(): Configurar el módulo
    - get_config(): Obtener configuración actual
    - clear_cache(): Limpiar caché
    - get_cache_stats(): Obtener estadísticas de caché

Características:
    - Sistema de caché automático
    - Soporte para múltiples formatos (SVG, PNG)
    - Integración nativa con pytm
    - Detección automática de engine
    - Configuración flexible por archivo, env vars o código

Autor: Threat Modeling System
Versión: 1.0.0
"""

# Import main rendering functions
from .renderer import render, render_file, render_batch, encode_plantuml

# Import pytm integration
from .pytm_adapter import (
    render_pytm_model,
    render_pytm_seq,
    extract_plantuml_from_pytm,
    get_pytm_plantuml_code,
)

# Import configuration
from .config import (
    configure,
    get_config,
    reset_config,
    validate_config,
    get_server_url,
    get_cache_dir,
    is_cache_enabled,
)

# Import cache management
from .cache import (
    clear_cache,
    get_cache_stats,
    prune_cache,
)

# Import exceptions
from .exceptions import (
    PlantwebError,
    RenderError,
    ConfigError,
    ServerError,
    CacheError,
    PytmError,
)

__version__ = "1.0.0"
__author__ = "Threat Modeling System"
__license__ = "Apache-2.0"

# Public API
__all__ = [
    # Core rendering
    "render",
    "render_file",
    "render_batch",
    "encode_plantuml",

    # pytm integration
    "render_pytm_model",
    "render_pytm_seq",
    "extract_plantuml_from_pytm",
    "get_pytm_plantuml_code",

    # Configuration
    "configure",
    "get_config",
    "reset_config",
    "validate_config",
    "get_server_url",
    "get_cache_dir",
    "is_cache_enabled",

    # Cache management
    "clear_cache",
    "get_cache_stats",
    "prune_cache",

    # Exceptions
    "PlantwebError",
    "RenderError",
    "ConfigError",
    "ServerError",
    "CacheError",
    "PytmError",
]


def _check_dependencies():
    """Check if required dependencies are available"""
    try:
        import requests
    except ImportError:
        raise ImportError(
            "requests library is required. Install with: pip3 install requests"
        )


# Check dependencies on import
_check_dependencies()