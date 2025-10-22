# Threat Models

Place your pytm threat model Python files here.

## Naming Convention
- Files must end with `_model.py`
- Example: `auth_model.py`, `api_model.py`

## Usage

```bash
# Generate all models
./bin/generate

# Generate specific model
./bin/generate dashboard/models/auth_model.py

# List available models
./bin/generate --list
```

## Model Structure

```python
#!/usr/bin/env python3
from pytm import TM, Server, Actor, Dataflow

tm = TM("My System")
tm.description = "System description"
tm.isOrdered = True

# Define components
user = Actor("User")
server = Server("Server")

# Define flows
flow = Dataflow(user, server, "Request")

# Process
if __name__ == "__main__":
    tm.process()
```
