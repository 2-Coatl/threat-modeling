# Arquitectura del Editor Visual de Threat Modeling

## Resumen

Esta guía describe la plataforma drag & drop basada en React Flow que se integra con pytm para generar modelos de amenazas como código. El objetivo es que colaboradores técnicos y no técnicos compartan una misma representación: un lienzo visual con sincronización unidireccional hacia el script Python ejecutable.

- **Frontend:** React + React Flow para manipular nodos, edges y formularios de propiedades.
- **Backend:** Flask expone endpoints REST para persistencia, validación y ejecución de pytm.
- **Automatización:** Un generador convierte el modelo visual (JSON) en código Python alineado con pytm y mantiene el historial en Git.

## Estrategia de implementación

1. **Investigación de librerías**
   - [React Flow](https://reactflow.dev/) habilita editores basados en nodos con soporte nativo para drag & drop, zoom, pan, selección múltiple y personalización de nodos.
   - Herramientas comerciales como IriusRisk demuestran la viabilidad de editors accesibles para perfiles no técnicos, sirviendo como referencia de UX.
2. **Principios**
   - Edición visual primero, con código generado automáticamente y editable bajo demanda.
   - Sincronización automática del lienzo hacia el script generado, evitando asumir retornos desde el código.
   - Persistencia versionada: cada guardado registra el JSON y el Python generado.

El editor Monaco recibe exclusivamente el script producido por el generador y conserva cualquier ajuste manual realizado allí. Una advertencia persistente comunica que dichos cambios no regresan al lienzo, alineando las expectativas del usuario sobre el flujo unidireccional.

## Arquitectura end-to-end

```
┌─────────────────────────────────────────────────────────────┐
│                    FRONTEND (React)                          │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐     │
│  │   Visual Editor (React Flow)                        │     │
│  │   - Drag & Drop elements from palette               │     │
│  │   - Actor, Server, Datastore, Lambda, etc.          │     │
│  │   - Connect elements with dataflows                 │     │
│  │   - Property forms for each element                 │     │
│  └─────────────────┬───────────────────────────────────┘     │
│                    │ Visual Model (JSON)                     │
│  ┌─────────────────▼───────────────────────────────────┐     │
│  │   Python Code Generator                             │     │
│  │   - Convert JSON → pytm Python code                  │     │
│  │   - Validate element properties                     │     │
│  │   - Generate imports and TM setup                    │     │
│  └─────────────────┬───────────────────────────────────┘     │
│                    │ Generated Python Code                  │
│  ┌─────────────────▼───────────────────────────────────┐     │
│  │   Code Editor (Monaco)                              │     │
│  │   - View/Edit generated Python                      │     │
│  │   - Syntax highlighting                             │     │
│  │   - Sincronización unidireccional (lienzo → código) │     │
│  └─────────────────┬───────────────────────────────────┘     │
└────────────────────┼─────────────────────────────────────────┘
                     │ POST /api/pytm/models
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                    BACKEND (Flask)                           │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐     │
│  │   PytmModelController                               │     │
│  │   - Receive visual model + generated code           │     │
│  │   - Validate Python syntax                          │     │
│  │   - Save to Git repository                          │     │
│  └─────────────────┬───────────────────────────────────┘     │
│                    │                                         │
│  ┌─────────────────▼───────────────────────────────────┐     │
│  │   PytmExecutor                                      │     │
│  │   - Execute: python model.py --dfd                  │     │
│  │   - Execute: python model.py --seq                  │     │
│  │   - Execute: python model.py --report               │     │
│  └─────────────────┬───────────────────────────────────┘     │
│        ┌────────────┴────────────┐                           │
│        ▼                         ▼                           │
│  ┌──────────┐           ┌──────────────┐                     │
│  │ Graphviz │           │  PlantUML    │                     │
│  │  (DFD)   │           │   Server     │                     │
│  └──────────┘           └──────────────┘                     │
└─────────────────────────────────────────────────────────────┘
```

## Componentes del editor visual

### 1. Paleta de elementos (`ui/src/components/VisualEditor/ElementPalette.jsx`)

- Contiene la lista canon de elementos pytm (Actor, Server, Datastore, Lambda, Boundary, Dataflow).
- Cada entrada define metadatos (icono, etiqueta) y el esquema de propiedades que alimenta los formularios.
- Al iniciar un drag se serializa el elemento como `application/reactflow` para que React Flow lo interprete al soltarlo.

```jsx
const PYTM_ELEMENTS = [
  {
    type: 'actor',
    label: 'Actor',
    icon: '👤',
    properties: {
      name: { type: 'string', required: true },
      inBoundary: { type: 'boundary', required: false },
      isAdmin: { type: 'boolean', default: false }
    }
  },
  // ...
];
```

### 2. Lienzo React Flow (`ui/src/components/VisualEditor/ThreatModelCanvas.jsx`)

- Usa `useNodesState` y `useEdgesState` para centralizar el estado.
- `onDrop` deserializa el elemento desde `dataTransfer`, asigna posición relativa y crea un nodo con propiedades predeterminadas.
- `onConnect` estandariza los dataflows para mantener atributos de red y sincronizar el generador de código.
- Incluye `Background`, `Controls` y `MiniMap` para UX consistente.

### 3. Generador JSON → Python (`ui/src/services/pytmCodeGenerator.js`)

- Produce un script pytm autónomo: importa clases, crea la instancia `TM`, boundaries, elementos y dataflows.
- `sanitizeName` genera identificadores válidos para variables Python.
- Cada tipo (`Actor`, `Server`, `Datastore`, `Lambda`) aplica sus propiedades opcionales únicamente si el usuario las definió.
- Ordena la salida para que los boundaries se declaren antes del resto de elementos y los dataflows al final.

```js
code += `from pytm import TM, Server, Datastore, Dataflow, Boundary, Actor, Lambda\n\n`;
```

## Flujo funcional de la plataforma

1. **Inicio de sesión** → `POST /api/auth/login` devuelve JWT.
2. **Creación de modelo** → el usuario registra metadatos y recibe un lienzo vacío.
3. **Edición visual** → arrastra nodos, configura propiedades y define dataflows.
4. **Generación de código** → el servicio convierte el JSON en `model.py` sincrónico.
5. **Edición opcional de código** → Monaco permite ajustes manuales (sin retroalimentación al lienzo).
6. **Guardado** → `POST /api/pytm/models` persiste `visualModel` y `pythonCode` (se versiona en Git y base de datos).
7. **Generación de artefactos** → endpoints específicos ejecutan pytm:
   - `POST /api/pytm/generate-dfd`
   - `POST /api/pytm/generate-sequence`
   - `POST /api/pytm/analyze-threats`
8. **Entrega de resultados** → diagramas vía Graphviz/PlantUML, reportes `--report` para hallazgos.

## Esquema de base de datos

```sql
CREATE TABLE pytm_models (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    visual_model JSONB NOT NULL,
    python_code TEXT NOT NULL,
    git_file_path VARCHAR(500),
    git_commit_hash VARCHAR(40),
    author_id UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

- `visual_model` almacena nodos (`id`, `type`, `position`, `data.properties`) y edges con atributos de transporte.
- `python_code` conserva el script generado para reproducir análisis.
- Los campos Git mantienen la trazabilidad con el repositorio y permiten auditoría.

## Consideraciones adicionales

- **Accesibilidad:** el lienzo debe incluir atajos de teclado, foco visible y descripciones para lectores de pantalla.
- **Versionado:** cada guardado crea commits firmados por el backend, anexando nota de cambios.
- **Extensibilidad:** agregar nuevos tipos pytm requiere extender la paleta, los formularios y las reglas del generador.

## Referencias

- [React Flow — Node-based editors](https://reactflow.dev/)
- [OWASP pytm](https://github.com/owasp/pytm)
- Documentación de casos de uso: [`docs/use-cases/ui/UC-UI-001-gestionar-diagramas-versiones.md`](../use-cases/ui/UC-UI-001-gestionar-diagramas-versiones.md)
- Estándares de ingeniería: [`docs/standards/engineering-ruleset.md`](../standards/engineering-ruleset.md)
