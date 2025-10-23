"""Core diagram service used by the Flask API."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
import difflib
import hashlib
import json
import os
from pathlib import Path
import threading
from typing import Dict, List, Optional


@dataclass
class DiagramVersion:
    """Metadata about a stored diagram version."""

    commit: str
    diagram_hash: str
    format: str
    author: str
    description: str
    timestamp: str

    def to_dict(self) -> Dict[str, str]:
        return {
            "commit": self.commit,
            "diagram_hash": self.diagram_hash,
            "format": self.format,
            "author": self.author,
            "description": self.description,
            "timestamp": self.timestamp,
        }


class DiagramServiceError(Exception):
    """Raised when the diagram service encounters an unexpected error."""


class PytmDiagramService:
    """Simplified in-process implementation of the diagram service.

    The original project expected a wrapper around PlantUML and git history. For
    the purposes of testing and local development we implement a lightweight
    storage engine that persists diagram history on disk using JSON metadata and
    plain PlantUML files.
    """

    _DEFAULT_SERVER = "http://localhost:8080/plantuml"

    def __init__(
        self,
        history_dir: Optional[Path] = None,
        plantuml_server: Optional[str] = None,
    ) -> None:
        self.plantuml_server = plantuml_server or os.environ.get(
            "PLANTUML_SERVER", self._DEFAULT_SERVER
        )
        history_root = history_dir or Path(
            os.environ.get("DIAGRAM_SERVICE_HISTORY_DIR", "/vagrant/api/history")
        )
        self.history_dir = Path(history_root)
        self.history_dir.mkdir(parents=True, exist_ok=True)
        self._lock = threading.Lock()

    # ------------------------------------------------------------------
    # Public API used by the Flask application
    # ------------------------------------------------------------------
    def generate_diagram(
        self,
        diagram_name: str,
        code: str,
        format: str = "svg",
        save_history: bool = True,
        metadata: Optional[Dict[str, str]] = None,
    ) -> Dict[str, object]:
        if not diagram_name or not code:
            raise ValueError("diagram_name and code are required")

        metadata = metadata or {}
        diagram_hash = hashlib.sha1(code.encode("utf-8")).hexdigest()
        image_bytes = self._render_placeholder_image(code, format)

        commit_hash = None
        if save_history:
            commit_hash = self._store_version(
                diagram_name=diagram_name,
                code=code,
                diagram_hash=diagram_hash,
                format=format,
                author=metadata.get("author", "unknown"),
                description=metadata.get("description", ""),
            )

        return {
            "diagram": diagram_name,
            "commit_hash": commit_hash,
            "diagram_hash": diagram_hash,
            "format": format,
            "image": image_bytes,
            "saved": save_history,
        }

    def get_history(self, diagram_name: str) -> List[Dict[str, str]]:
        metadata = self._load_metadata(diagram_name)
        return [version.to_dict() for version in metadata]

    def get_version(self, diagram_name: str, commit_hash: str) -> str:
        version_path = self._version_path(diagram_name, commit_hash)
        if not version_path.exists():
            raise DiagramServiceError(
                f"Version '{commit_hash}' for diagram '{diagram_name}' not found"
            )
        return version_path.read_text(encoding="utf-8")

    def diff_versions(
        self, diagram_name: str, commit_a: str, commit_b: str
    ) -> str:
        code_a = self.get_version(diagram_name, commit_a).splitlines(keepends=True)
        code_b = self.get_version(diagram_name, commit_b).splitlines(keepends=True)
        diff = difflib.unified_diff(
            code_a,
            code_b,
            fromfile=f"{diagram_name}@{commit_a}",
            tofile=f"{diagram_name}@{commit_b}",
        )
        return "".join(diff)

    def rollback(self, diagram_name: str, commit_hash: str) -> str:
        code = self.get_version(diagram_name, commit_hash)
        versions = self._load_metadata(diagram_name)
        description = f"Rollback to {commit_hash}"
        author = "system"
        return self._store_version(
            diagram_name=diagram_name,
            code=code,
            diagram_hash=hashlib.sha1(code.encode("utf-8")).hexdigest(),
            format=versions[0].format if versions else "svg",
            author=author,
            description=description,
        )

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------
    def _diagram_dir(self, diagram_name: str) -> Path:
        diagram_dir = self.history_dir / diagram_name
        diagram_dir.mkdir(parents=True, exist_ok=True)
        return diagram_dir

    def _metadata_file(self, diagram_name: str) -> Path:
        return self._diagram_dir(diagram_name) / "metadata.json"

    def _versions_dir(self, diagram_name: str) -> Path:
        versions_dir = self._diagram_dir(diagram_name) / "versions"
        versions_dir.mkdir(parents=True, exist_ok=True)
        return versions_dir

    def _version_path(self, diagram_name: str, commit_hash: str) -> Path:
        return self._versions_dir(diagram_name) / f"{commit_hash}.plantuml"

    def _render_placeholder_image(self, code: str, format: str) -> bytes:
        """Return deterministic bytes for the generated image."""

        payload = f"format={format};{code}"
        return payload.encode("utf-8")

    def _store_version(
        self,
        diagram_name: str,
        code: str,
        diagram_hash: str,
        format: str,
        author: str,
        description: str,
    ) -> str:
        timestamp = datetime.now(timezone.utc).isoformat()
        commit_hash = hashlib.sha1(f"{diagram_hash}-{timestamp}".encode("utf-8")).hexdigest()
        version = DiagramVersion(
            commit=commit_hash,
            diagram_hash=diagram_hash,
            format=format,
            author=author,
            description=description,
            timestamp=timestamp,
        )

        with self._lock:
            version_path = self._version_path(diagram_name, commit_hash)
            version_path.write_text(code, encoding="utf-8")

            existing_versions = self._load_metadata(diagram_name)
            updated_versions = [version] + existing_versions
            self._write_metadata(diagram_name, updated_versions)

        return commit_hash

    def _load_metadata(self, diagram_name: str) -> List[DiagramVersion]:
        metadata_path = self._metadata_file(diagram_name)
        if not metadata_path.exists():
            return []

        try:
            payload = json.loads(metadata_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            raise DiagramServiceError(
                f"Metadata for '{diagram_name}' is corrupted: {exc}"
            ) from exc

        versions: List[DiagramVersion] = []
        for item in payload.get("versions", []):
            versions.append(
                DiagramVersion(
                    commit=item["commit"],
                    diagram_hash=item["diagram_hash"],
                    format=item.get("format", "svg"),
                    author=item.get("author", "unknown"),
                    description=item.get("description", ""),
                    timestamp=item.get(
                        "timestamp", datetime.now(timezone.utc).isoformat()
                    ),
                )
            )
        return versions

    def _write_metadata(
        self, diagram_name: str, versions: List[DiagramVersion]
    ) -> None:
        metadata_path = self._metadata_file(diagram_name)
        serialised = {
            "diagram": diagram_name,
            "versions": [version.to_dict() for version in versions],
            "latest": versions[0].to_dict() if versions else None,
        }
        metadata_path.write_text(
            json.dumps(serialised, indent=2, sort_keys=False), encoding="utf-8"
        )
