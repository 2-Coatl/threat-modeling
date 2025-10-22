#!/usr/bin/env python3
"""
Flask Diagram Service - Web UI for PlantUML with versioning

Usage:
    python3 app.py

Access:
    http://localhost:5000
"""

from flask import Flask, render_template, request, jsonify, send_file
from pathlib import Path
import sys
import io

# Import diagram service
sys.path.insert(0, str(Path(__file__).parent))
from diagram_service import PytmDiagramService

# Initialize Flask
app = Flask(__name__)
app.config['SECRET_KEY'] = 'threat-modeling-secret-key'
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max upload

# Initialize diagram service
diagram_service = PytmDiagramService()


# ============================================================================
# WEB ROUTES (HTML Pages)
# ============================================================================

@app.route('/')
def index():
    """Main page - Diagram editor"""
    return render_template('index.html')


@app.route('/diagrams')
def list_diagrams_page():
    """List all diagrams"""
    diagrams = get_all_diagrams()
    return render_template('diagrams.html', diagrams=diagrams)


@app.route('/diagram/<name>')
def diagram_detail(name):
    """Diagram detail page with history"""
    try:
        history = diagram_service.get_history(name)
        return render_template('history.html',
                               diagram_name=name,
                               history=history)
    except Exception as e:
        return f"Error: {str(e)}", 404


# ============================================================================
# API ROUTES (JSON responses)
# ============================================================================

@app.route('/api/diagram/generate', methods=['POST'])
def api_generate_diagram():
    """
    Generate diagram from PlantUML code

    POST JSON:
    {
        "name": "my_diagram",
        "code": "@startuml\\n...\\n@enduml",
        "format": "svg",
        "author": "john@example.com",
        "description": "My custom diagram"
    }
    """
    try:
        data = request.get_json()

        if not data or 'name' not in data or 'code' not in data:
            return jsonify({
                'success': False,
                'error': 'Missing required fields: name and code'
            }), 400

        name = data['name']
        code = data['code']
        format = data.get('format', 'svg')
        author = data.get('author', 'anonymous')
        description = data.get('description', f'Generated {name}')

        # Generate with history
        metadata = {
            'author': author,
            'description': description
        }

        result = diagram_service.generate_diagram(
            diagram_name=name,
            code=code,
            format=format,
            save_history=True,
            metadata=metadata
        )

        return jsonify({
            'success': True,
            'commit_hash': result['commit_hash'],
            'diagram_hash': result['diagram_hash'],
            'format': result['format'],
            'message': f"Diagram '{name}' generated and saved"
        })

    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/diagram/preview', methods=['POST'])
def api_preview_diagram():
    """
    Preview diagram without saving to history

    POST JSON:
    {
        "code": "@startuml\\n...\\n@enduml",
        "format": "svg"
    }
    """
    try:
        data = request.get_json()

        if not data or 'code' not in data:
            return jsonify({
                'success': False,
                'error': 'Missing required field: code'
            }), 400

        code = data['code']
        format = data.get('format', 'svg')

        # Generate without saving
        result = diagram_service.generate_diagram(
            diagram_name='preview',
            code=code,
            format=format,
            save_history=False
        )

        # Return image as base64 or file
        import base64
        image_b64 = base64.b64encode(result['image']).decode('utf-8')

        return jsonify({
            'success': True,
            'image': f"data:image/{format};base64,{image_b64}",
            'format': format
        })

    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/diagram/<name>/history')
def api_get_history(name):
    """Get version history for a diagram"""
    try:
        history = diagram_service.get_history(name)
        return jsonify({
            'success': True,
            'diagram': name,
            'versions': history,
            'total': len(history)
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 404


@app.route('/api/diagram/<name>/version/<commit_hash>')
def api_get_version(name, commit_hash):
    """Get PlantUML code for a specific version"""
    try:
        code = diagram_service.get_version(name, commit_hash)
        return jsonify({
            'success': True,
            'diagram': name,
            'commit': commit_hash,
            'code': code
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 404


@app.route('/api/diagram/<name>/diff')
def api_diff_versions(name):
    """
    Get diff between two versions
    Query params: ?commit1=abc123&commit2=def456
    """
    try:
        commit1 = request.args.get('commit1')
        commit2 = request.args.get('commit2')

        if not commit1 or not commit2:
            return jsonify({
                'success': False,
                'error': 'Missing commit1 or commit2 parameters'
            }), 400

        diff = diagram_service.diff_versions(name, commit1, commit2)

        return jsonify({
            'success': True,
            'diagram': name,
            'from': commit1,
            'to': commit2,
            'diff': diff
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/diagram/rollback', methods=['POST'])
def api_rollback():
    """
    Rollback diagram to specific version

    POST JSON:
    {
        "name": "my_diagram",
        "commit_hash": "abc123"
    }
    """
    try:
        data = request.get_json()

        if not data or 'name' not in data or 'commit_hash' not in data:
            return jsonify({
                'success': False,
                'error': 'Missing required fields: name and commit_hash'
            }), 400

        name = data['name']
        commit_hash = data['commit_hash']

        new_commit = diagram_service.rollback(name, commit_hash)

        return jsonify({
            'success': True,
            'diagram': name,
            'rolled_back_to': commit_hash,
            'new_commit': new_commit,
            'message': f"Rolled back '{name}' to {commit_hash}"
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/diagrams')
def api_list_diagrams():
    """List all diagrams with their metadata"""
    try:
        diagrams = get_all_diagrams()
        return jsonify({
            'success': True,
            'diagrams': diagrams,
            'total': len(diagrams)
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def get_all_diagrams():
    """Get list of all diagrams with metadata"""
    history_dir = Path('/vagrant/dashboard/history')

    if not history_dir.exists():
        return []

    diagrams = []
    for diagram_dir in history_dir.iterdir():
        if diagram_dir.is_dir() and diagram_dir.name != '.git':
            metadata_file = diagram_dir / 'metadata.json'
            if metadata_file.exists():
                import json
                try:
                    metadata = json.loads(metadata_file.read_text())
                    diagrams.append({
                        'name': diagram_dir.name,
                        'versions': len(metadata.get('versions', [])),
                        'latest': metadata.get('latest', {})
                    })
                except:
                    pass

    return diagrams


# ============================================================================
# HEALTH CHECK
# ============================================================================

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'diagram-service',
        'plantuml_server': diagram_service.plantuml_server
    })


# ============================================================================
# ERROR HANDLERS
# ============================================================================

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'success': False,
        'error': 'Not found'
    }), 404


@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        'success': False,
        'error': 'Internal server error'
    }), 500


# ============================================================================
# MAIN
# ============================================================================

if __name__ == '__main__':
    # Development server
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True
    )