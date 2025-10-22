#!/usr/bin/env python3
"""
Plantweb Module - Custom Exceptions
"""


class PlantwebError(Exception):
    """Base exception for all Plantweb errors"""
    pass


class RenderError(PlantwebError):
    """Error during diagram rendering"""
    pass


class ConfigError(PlantwebError):
    """Error in configuration"""
    pass


class ServerError(PlantwebError):
    """Error communicating with PlantUML server"""
    pass


class CacheError(PlantwebError):
    """Error in cache operations"""
    pass


class PytmError(PlantwebError):
    """Error extracting PlantUML from pytm models"""
    pass