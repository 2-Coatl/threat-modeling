"""Integration tests for the Flask diagram API."""

from __future__ import annotations

import base64
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from api import app as app_module


@pytest.fixture()
def client(tmp_path, monkeypatch):
    service = app_module.PytmDiagramService(history_dir=tmp_path / "history")
    monkeypatch.setattr(app_module, "diagram_service", service)
    testing_app = app_module.app
    testing_app.config.update(TESTING=True)
    return testing_app.test_client()


def test_generate_diagram_persists_history(client):
    payload = {
        "name": "sample",
        "code": "@startuml\nAlice -> Bob : hello\n@enduml",
        "format": "svg",
        "author": "tester@example.com",
        "description": "Initial version",
    }

    response = client.post("/api/diagram/generate", json=payload)
    assert response.status_code == 200
    body = response.get_json()
    assert body["success"] is True
    assert body["commit_hash"]
    assert body["format"] == "svg"

    history_response = client.get("/api/diagram/sample/history")
    assert history_response.status_code == 200
    history_body = history_response.get_json()
    assert history_body["success"] is True
    assert history_body["total"] == 1
    assert history_body["versions"][0]["author"] == "tester@example.com"


def test_preview_diagram_returns_inline_image(client):
    payload = {
        "code": "@startuml\nAlice -> Bob : ping\n@enduml",
        "format": "png",
    }
    response = client.post("/api/diagram/preview", json=payload)
    assert response.status_code == 200
    body = response.get_json()
    assert body["success"] is True
    assert body["format"] == "png"
    assert body["image"].startswith("data:image/png;base64,")

    encoded = body["image"].split(",", 1)[1]
    decoded = base64.b64decode(encoded)
    assert decoded.startswith(b"format=png;")

    history_response = client.get("/api/diagram/preview/history")
    assert history_response.status_code == 200
    history_body = history_response.get_json()
    assert history_body["success"] is True
    assert history_body["total"] == 0


def test_generate_diagram_missing_fields_returns_400(client):
    response = client.post("/api/diagram/generate", json={})
    assert response.status_code == 400
    body = response.get_json()
    assert body["success"] is False
    assert "Missing required fields" in body["error"]


def test_history_endpoint_returns_multiple_versions(client):
    base_payload = {
        "name": "workflow",
        "code": "@startuml\nAlice -> Bob : hello\n@enduml",
    }

    first = client.post("/api/diagram/generate", json=base_payload)
    assert first.status_code == 200

    updated_payload = dict(base_payload)
    updated_payload["code"] = "@startuml\nAlice -> Bob : updated\n@enduml"
    second = client.post("/api/diagram/generate", json=updated_payload)
    assert second.status_code == 200

    history_response = client.get("/api/diagram/workflow/history")
    history_body = history_response.get_json()
    assert history_body["success"] is True
    assert history_body["total"] == 2
    commits = [item["commit"] for item in history_body["versions"]]
    assert len(set(commits)) == 2
