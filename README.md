# Sistema de Threat Modeling con pytm

Sistema automatizado para modelado de amenazas utilizando el framework OWASP pytm, Apache Tomcat y PlantUML Server para generación de diagramas y reportes de seguridad.

## Inicio Rápido

```bash
# 1. Iniciar VM
vagrant up

# 2. Acceder a la VM
vagrant ssh

# 3. Generar modelos de amenazas
tm-generate

# 4. Ver resultados en el navegador
# Abrir: http://localhost:8080/outputs/
```

## Tabla de Contenidos

- [Descripción General](#descripción-general)
- [Arquitectura](#arquitectura)
- [Características](#características)
- [Requisitos del Sistema](#requisitos-del-sistema)
- [Instalación](#instalación)
- [Uso](#uso)
- [Acceso Web](#acceso-web)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Creación de Modelos](#creación-de-modelos)
- [Ejemplos Incluidos](#ejemplos-incluidos)
- [Comandos Disponibles](#comandos-disponibles)
- [Gestión de Servicios](#gestión-de-servicios)
- [Solución de Problemas](#solución-de-problemas)
- [Configuración](#configuración)
- [Permisos y Seguridad](#permisos-y-seguridad)
- [Desarrollo](#desarrollo)
- [Referencias](#referencias)

---

## Descripción General

### Qué es este sistema

Un entorno automatizado para **Threat Modeling as Code** usando el framework OWASP pytm con acceso web integrado. Este sistema permite:

- Definir modelos de amenazas como código Python ejecutable
- Generar automáticamente Diagramas de Flujo de Datos (DFD)
- Crear Diagramas de Secuencia para flujos de interacción
- Producir reportes HTML completos con amenazas identificadas
- Acceder a todos los outputs vía navegador web
- Utilizar PlantUML Server para generación de diagramas

### Filosofía

> **"Threat Modeling WITH Code"** - Los modelos SON código Python ejecutable que genera automáticamente diagramas y reportes.

Esto asegura:
- Control de versiones para modelos de amenazas
- Consistencia entre miembros del equipo
- Análisis de seguridad reproducible
- Integración con flujos de trabajo de desarrollo
- Acceso web a outputs para compartir fácilmente

---

## Arquitectura

```
┌────────────────────────────────────────────────────────┐
│                  Interfaz de Usuario                   │
│  Navegador: http://localhost:8080/                    │
│    ├─ /plantuml/        (PlantUML Server)             │
│    └─ /outputs/         (Diagramas/Reportes)          │
└────────────────────────────────────────────────────────┘
                          │
                          ▼
┌────────────────────────────────────────────────────────┐
│             Apache Tomcat 10.1.47                      │
│    Puerto: 8080    Usuario: tomcat                    │
│    ├─ PlantUML WAR (diagramas de secuencia)           │
│    └─ Outputs Context (archivos estáticos)            │
└────────────────────────────────────────────────────────┘
                          │
                          ▼
┌────────────────────────────────────────────────────────┐
│           Generación de Modelos de Amenazas           │
│    Usuario: threatmodel    Tool: bin/generate         │
│    ├─ pytm (DFD via Graphviz)                         │
│    ├─ PlantUML Server (Sequence via HTTP)             │
│    └─ Pandoc (Reportes HTML)                          │
└────────────────────────────────────────────────────────┘
                          │
                          ▼
┌────────────────────────────────────────────────────────┐
│              Almacenamiento de Outputs                 │
│    /vagrant/dashboard/output/                          │
│    ├─ diagrams/ (archivos PNG)                        │
│    └─ reports/  (archivos HTML)                       │
└────────────────────────────────────────────────────────┘
```

---

## Características

### Capacidades Principales

- **Instalación Idempotente**: Ejecuta el setup múltiples veces de forma segura
- **Auto-descubrimiento**: Encuentra y procesa automáticamente todos los modelos
- **Auto-reparación**: Detecta componentes rotos y reinstala automáticamente
- **Acceso Web**: Navega outputs vía HTTP sin necesidad de filesystem
- **PlantUML Server**: Generación de diagramas vía servicio web
- **Usuario Dedicado**: Separación de privilegios con usuario `threatmodel`
- **Servicio Systemd**: PlantUML/Tomcat como servicio del sistema
- **Sin Fallas Silenciosas**: Todas las operaciones son verificadas y reportadas

### Características de Seguridad

- Usuario dedicado del sistema con permisos limitados
- Acceso de solo lectura a outputs vía web
- PlantUML con perfil de seguridad INTERNET (restringido)
- No se permiten includes remotos en PlantUML
- Logging completo de todas las operaciones

### Generación de Outputs

- **Diagramas de Flujo de Datos (DFD)**: Imágenes PNG mostrando la arquitectura
- **Diagramas de Secuencia**: Imágenes PNG mostrando flujos de interacción
- **Reportes HTML**: Análisis completo de amenazas con metodología STRIDE

---

## Requisitos del Sistema

### Máquina Host

- **SO**: Windows, macOS o Linux
- **RAM**: 4GB mínimo (8GB recomendado)
- **Disco**: 10GB de espacio libre
- **Software**:
  - Vagrant 2.2+
  - VirtualBox 6.0+

### VM (Configurada Automáticamente)

- Ubuntu 20.04 LTS
- Python 3.8+
- Java 11 (OpenJDK)
- Graphviz
- Apache Tomcat 10.1.47
- PlantUML Server v1.2025.7
- pandoc

---

## Instalación

### Paso 1: Clonar Repositorio

```bash
git clone https://github.com/NestorMonroy/threat-modeling-project
cd threat-modeling-project
```

### Paso 2: Iniciar VM

```bash
vagrant up
```

Esto ejecutará automáticamente:
- Creación del usuario `threatmodel`
- Instalación de dependencias del sistema
- Instalación del framework pytm
- Instalación de Apache Tomcat
- Instalación de PlantUML Server
- Configuración de servicios systemd
- Configuración de permisos
- Creación de estructura del proyecto
- Configuración de aliases de shell

**Tiempo estimado**: 5-10 minutos en la primera ejecución

### Paso 3: Verificar Instalación

```bash
vagrant ssh

# Verificar Python y pytm
python3 --version
python3 -c "from pytm import TM; print('pytm OK')"

# Verificar servicios web
curl http://localhost:8080/plantuml/
curl http://localhost:8080/outputs/

# Verificar servicio systemd
sudo systemctl status plantuml

# Verificar usuario dedicado
id threatmodel
```

### Fases de Instalación

El bootstrap ejecuta estas fases automáticamente:

1. **Phase 0**: Crear usuario threatmodel
2. **Phase 1**: Instalar dependencias del sistema
3. **Phase 2**: Instalar framework pytm
4. **Phase 3**: Instalar Apache Tomcat
5. **Phase 4**: Instalar PlantUML Server
6. **Phase 5**: Configurar servicio systemd de PlantUML
7. **Phase 6**: Configurar permisos
8. **Phase 6.5**: Configurar acceso web a outputs
9. **Phase 7**: Crear estructura del proyecto
10. **Phase 8**: Verificación final (8 checks)

---

## Uso

### Comandos Básicos

```bash
# Acceder a la VM
vagrant ssh

# Generar todos los modelos
tm-generate

# Listar modelos disponibles
tm-list

# Ver logs en tiempo real
tm-logs

# Navegar a directorios
tm-models    # Va a modelos
tm-output    # Va a outputs
tm-root      # Va a raíz del proyecto
```

### Generar Modelos Específicos

```bash
# Generar un modelo específico
tm-generate dashboard/models/auth_model.py

# O usando sudo directamente
sudo -u threatmodel /vagrant/bin/generate dashboard/models/auth_model.py
```

### Ver Resultados

```bash
# Opción 1: Vía navegador web (RECOMENDADO)
# Abrir en tu navegador del host:
# http://localhost:8080/outputs/diagrams/
# http://localhost:8080/outputs/reports/

# Opción 2: Desde línea de comandos
ls -lh /vagrant/dashboard/output/diagrams/
ls -lh /vagrant/dashboard/output/reports/
```

---

## Acceso Web

### Desde la Máquina Host

Después de ejecutar `vagrant up`, estas URLs están disponibles:

#### PlantUML Server

```
http://localhost:8080/plantuml/
```

**Características**:
- Editor interactivo de diagramas
- Vista previa en tiempo real
- Múltiples formatos de salida (PNG, SVG, TXT)

#### Outputs Generados

```
# Todos los outputs
http://localhost:8080/outputs/

# Solo diagramas
http://localhost:8080/outputs/diagrams/

# Solo reportes
http://localhost:8080/outputs/reports/

# Archivo específico
http://localhost:8080/outputs/diagrams/auth_model_dfd.png
http://localhost:8080/outputs/reports/auth_model_report.html
```

### Acceso Alternativo (Red Privada)

```
http://192.168.56.10:8080/plantuml/
http://192.168.56.10:8080/outputs/
```

### Desde Dentro de la VM

```bash
curl http://localhost:8080/plantuml/
curl http://localhost:8080/outputs/
```

---

## Estructura del Proyecto

```
threat-modeling-project/
├── bin/
│   ├── generate              # Script principal de generación
│   └── setup                 # Ejecuta instalación
│
├── bootstrap.sh              # Orquestador maestro
│
├── config/
│   └── variables.sh          # Configuración global
│
├── dashboard/
│   ├── models/               # Modelos de amenazas
│   │   ├── auth_model.py
│   │   ├── comms_model.py
│   │   ├── ticket_model.py
│   │   └── README.md
│   │
│   ├── output/               # Outputs generados
│   │   ├── diagrams/         # Archivos PNG
│   │   ├── reports/          # Archivos HTML
│   │   └── README.md
│   │
│   └── templates/
│       └── report_template.md
│
├── infrastructure/
│   └── utils/
│       ├── core.sh           # Funciones centrales
│       ├── logging.sh        # Sistema de logging
│       └── validation.sh     # Validaciones
│
├── scripts/
│   ├── installation/
│   │   ├── install-system-dependencies.sh
│   │   ├── install-pytm-framework.sh
│   │   ├── install-tomcat.sh
│   │   └── install-plantuml-server.sh
│   │
│   └── setup/
│       ├── create-threatmodel-user.sh
│       ├── configure-permissions.sh
│       ├── configure-plantuml-service.sh
│       └── configure-tomcat-outputs.sh
│
├── Vagrantfile               # Configuración de VM
└── README.md                 # Este archivo
```

---

## Creación de Modelos

### Paso 1: Crear Archivo de Modelo

Crea un archivo en `dashboard/models/` que termine con `_model.py`:

```bash
cd /vagrant/dashboard/models
vim mi_sistema_model.py
```

### Paso 2: Escribir el Modelo

Estructura básica de un modelo pytm:

```python
#!/usr/bin/env python3
"""
Mi Sistema - Modelo de Amenazas
Descripción del sistema y su contexto
"""

from pytm import (
    TM,
    Server,
    Actor,
    Dataflow,
    Boundary,
    Datastore,
    Data,
    Classification
)

# Definir el modelo de amenazas
tm = TM("Mi Sistema")
tm.description = "Descripción detallada del sistema"
tm.isOrdered = True  # Habilitar diagramas de secuencia

# Definir boundaries (zonas de confianza)
internet = Boundary("Internet")
dmz = Boundary("DMZ")

# Definir actores
usuario = Actor("Usuario Final")
usuario.inBoundary = internet

# Definir servidores
servidor_web = Server("Servidor Web")
servidor_web.inBoundary = dmz
servidor_web.providesAuthentication = True
servidor_web.protocol = "HTTPS"

# Definir flujos de datos
peticion = Dataflow(usuario, servidor_web, "Petición HTTP")
peticion.protocol = "HTTPS"
peticion.isEncrypted = True
peticion.order = 1

# Procesar el modelo
if __name__ == "__main__":
    tm.process()
```

### Paso 3: Generar Outputs

```bash
cd /vagrant

# Generar este modelo específico
tm-generate dashboard/models/mi_sistema_model.py

# O generar todos los modelos
tm-generate
```

### Paso 4: Ver Resultados

```bash
# En el navegador
http://localhost:8080/outputs/diagrams/mi_sistema_model_dfd.png
http://localhost:8080/outputs/diagrams/mi_sistema_model_seq.png
http://localhost:8080/outputs/reports/mi_sistema_model_report.html
```

---

## Ejemplos Incluidos

El sistema incluye tres modelos completos como referencia:

### 1. auth_model.py - Sistema de Autenticación

**Componentes:**
- Actor: Agente del call center
- Boundaries: Internet, DMZ, Red Interna
- Servidores: Aplicación Web, Servicio de Autenticación
- Datastores: Base de datos de usuarios, Cache de sesiones

**Aprende:**
- Cómo modelar autenticación
- Uso de boundaries
- Clasificación de datos (SECRET, RESTRICTED)
- Flujos ordenados para sequence diagrams

### 2. comms_model.py - Sistema de Comunicaciones

**Componentes:**
- Actores: Cliente, Agente
- Sistemas: Gateway VoIP, Servidor de Chat, Servicio de Grabación
- Storage: Logs de conversación, Almacenamiento de grabaciones

**Aprende:**
- Modelar sistemas de tiempo real
- Protocolos múltiples (SIP, WebSocket, RTP)
- Almacenamiento de datos sensibles
- Logging y auditoría

### 3. ticket_model.py - Gestión de Tickets

**Componentes:**
- Actores: Cliente, Agente, Supervisor
- API: Servicio REST de tickets
- Storage: Base de datos, Almacenamiento de adjuntos
- Notificaciones: Servicio de email/SMS

**Aprende:**
- Ciclo de vida completo de un proceso
- Gestión de archivos
- Notificaciones asíncronas
- Múltiples roles de usuario

---

## Comandos Disponibles

### Aliases de Shell

Después de ejecutar `vagrant ssh`:

| Alias | Descripción | Equivalente |
|-------|-------------|-------------|
| `tm-generate` | Genera todos los modelos | `sudo -u threatmodel /vagrant/bin/generate` |
| `tm-list` | Lista modelos disponibles | `sudo -u threatmodel /vagrant/bin/generate --list` |
| `tm-models` | Va a directorio de modelos | `cd /vagrant/dashboard/models` |
| `tm-output` | Va a directorio de outputs | `cd /vagrant/dashboard/output` |
| `tm-root` | Va a raíz del proyecto | `cd /vagrant` |
| `tm-logs` | Ver logs en tiempo real | `sudo tail -f /var/log/dashboard/threatmodel.log` |

### Aliases de PlantUML/Tomcat

| Alias | Descripción |
|-------|-------------|
| `plantuml-start` | Iniciar servicio PlantUML |
| `plantuml-stop` | Detener servicio PlantUML |
| `plantuml-restart` | Reiniciar servicio PlantUML |
| `plantuml-status` | Ver estado del servicio |
| `plantuml-logs` | Ver logs de PlantUML |
| `plantuml-url` | Mostrar URL del servidor |

---

## Gestión de Servicios

### PlantUML/Tomcat Service

```bash
# Iniciar servicio
sudo systemctl start plantuml

# Detener servicio
sudo systemctl stop plantuml

# Reiniciar servicio
sudo systemctl restart plantuml

# Ver estado
sudo systemctl status plantuml

# Habilitar al inicio
sudo systemctl enable plantuml

# Ver logs
sudo journalctl -u plantuml -f
sudo tail -f /opt/tomcat/logs/catalina.out
```

### Verificar Servicios

```bash
# Verificar puerto 8080
sudo ss -tulpn | grep 8080

# Verificar proceso de Tomcat
ps aux | grep tomcat

# Test de conectividad
curl http://localhost:8080/plantuml/
curl http://localhost:8080/outputs/
```

---

## Solución de Problemas

### PlantUML Server No Accesible

```bash
# Verificar estado del servicio
sudo systemctl status plantuml

# Ver logs
sudo journalctl -u plantuml -n 50

# Reiniciar servicio
sudo systemctl restart plantuml

# Verificar puerto
sudo ss -tulpn | grep 8080

# Test desde VM
curl http://localhost:8080/plantuml/
```

### Generación Falla

```bash
# Verificar dependencias
/vagrant/bin/generate --help

# Ver logs de generación
sudo tail -f /var/log/dashboard/threatmodel.log

# Ejecutar como usuario correcto
sudo -u threatmodel /vagrant/bin/generate

# Verificar permisos
ls -la /vagrant/dashboard/output/
```

### Outputs No Visibles en Navegador

```bash
# Verificar contexto de Tomcat
ls -la /opt/tomcat/conf/Catalina/localhost/outputs.xml

# Verificar permisos
ls -la /vagrant/dashboard/output/

# Reconfigurar acceso a outputs
sudo /vagrant/scripts/setup/configure-tomcat-outputs.sh

# Reiniciar Tomcat
sudo systemctl restart plantuml
```

### Problemas de Red en VM

```bash
# Test desde dentro de VM
vagrant ssh
curl http://localhost:8080/plantuml/

# Desde host, verificar port forwarding
vagrant reload

# Verificar en VirtualBox
# Devices -> Network -> Adapter 1 -> Port Forwarding
```

### Verificar Componentes

```bash
# Python y pytm
python3 --version
python3 -c "from pytm import TM; print('pytm OK')"

# Graphviz
dot -V

# Java
java -version

# Pandoc
pandoc --version

# PlantUML Server
curl http://localhost:8080/plantuml/
```

### Forzar Reinstalación Completa

```bash
# Opción 1: Limpiar estado y re-ejecutar
sudo rm -rf /var/lib/dashboard/state/
sudo /vagrant/bin/setup

# Opción 2: Destruir VM completamente
exit  # Salir de la VM
vagrant destroy -f
vagrant up
```

---

## Configuración

### Archivo Principal de Configuración

Ubicación: `config/variables.sh`

#### Variables Clave

```bash
# Proyecto
PROJECT_NAME="dashboard"

# Usuarios
THREAT_MODEL_USER="threatmodel"

# Tomcat
TOMCAT_VERSION="10.1.47"
TOMCAT_HOME="/opt/tomcat"
TOMCAT_PORT="8080"

# PlantUML
PLANTUML_WAR_VERSION="v1.2025.7"
PLANTUML_SERVER="http://localhost:8080/plantuml"

# Rutas
MODELS_DIR="/vagrant/dashboard/models"
OUTPUT_DIR="/vagrant/dashboard/output"
DIAGRAMS_DIR="/vagrant/dashboard/output/diagrams"
REPORTS_DIR="/vagrant/dashboard/output/reports"
```

### Variables de Entorno

```bash
# Servidor PlantUML personalizado (opcional)
export PLANTUML_SERVER="http://custom-server:8080/plantuml"

# Luego generar
tm-generate
```

---

## Permisos y Seguridad

### Usuario Dedicado: threatmodel

El sistema utiliza un usuario dedicado para todas las operaciones:

```
Usuario: threatmodel
UID: (asignado por sistema)
Grupo primario: threatmodel
Grupos secundarios: adm
Home: /home/threatmodel
Shell: /bin/bash
```

### Configuración de Sudoers

Archivo: `/etc/sudoers.d/threatmodel`

```bash
# Usuario vagrant puede ejecutar como threatmodel sin password
vagrant ALL=(threatmodel) NOPASSWD: /vagrant/bin/generate
vagrant ALL=(threatmodel) NOPASSWD: /usr/bin/python3

# Deshabilitar requiretty para threatmodel
Defaults:threatmodel !requiretty
```

### Matriz de Permisos

| Ruta | Owner | Group | Permisos | Descripción |
|------|-------|-------|----------|-------------|
| `/var/log/dashboard/` | threatmodel | threatmodel | 755 | Logs del sistema |
| `/var/lib/dashboard/state/` | threatmodel | threatmodel | 755 | Estado de instalación |
| `/opt/tomcat/` | tomcat | tomcat | 755 | Instalación de Tomcat |
| `/vagrant/dashboard/output/` | threatmodel | threatmodel | 775 | Outputs generados |

### Usuarios del Sistema

| Usuario | Propósito | Home | Shell |
|---------|-----------|------|-------|
| vagrant | Acceso a VM | /home/vagrant | /bin/bash |
| threatmodel | Generación de modelos | /home/threatmodel | /bin/bash |
| tomcat | Servicio Tomcat | /home/tomcat | /bin/false |

---

## Desarrollo

### Agregar Nuevos Modelos

1. Crear archivo en `dashboard/models/mi_modelo_model.py`
2. Seguir estructura de ejemplos
3. Ejecutar `tm-generate`
4. Verificar en `http://localhost:8080/outputs/`
5. Commit del modelo (NO de los outputs)

### Modificar Scripts

Todos los scripts siguen estos principios:

- **Sin Emojis**: Salida solo texto para compatibilidad
- **Idempotente**: Seguro ejecutar múltiples veces
- **Sin Fallas Silenciosas**: Manejo explícito de errores
- **Principios SOLID**: Responsabilidad única por script

### Probar Cambios

```bash
# Probar script específico
sudo /vagrant/scripts/installation/install-tomcat.sh

# Probar solo generación
tm-generate

# Prueba completa del sistema
sudo /vagrant/bootstrap.sh
```

---

## Referencias

### pytm

- [Repositorio GitHub](https://github.com/izar/pytm)
- [Ejemplos de pytm](https://github.com/izar/pytm/tree/master/examples)
- [Documentación de API](https://github.com/izar/pytm/blob/master/README.md)

### Threat Modeling

- [OWASP Threat Modeling](https://owasp.org/www-community/Threat_Modeling)
- [Metodología STRIDE](https://en.wikipedia.org/wiki/STRIDE_(security))
- [Threat Modeling Manifesto](https://www.threatmodelingmanifesto.org/)

### Apache Tomcat

- [Documentación oficial](https://tomcat.apache.org/tomcat-10.1-doc/)
- [PlantUML Server](https://plantuml.com/server)

---

## Información del Sistema

### Versiones

- **OS**: Ubuntu 20.04 LTS (Focal)
- **Python**: 3.8+
- **Java**: OpenJDK 11
- **Tomcat**: 10.1.47
- **PlantUML Server**: v1.2025.7
- **pytm**: Latest from PyPI

### Puertos

| Puerto | Servicio | Acceso |
|--------|----------|--------|
| 8080 | Tomcat (PlantUML + Outputs) | http://localhost:8080 |
| 8005 | Tomcat Shutdown | Solo interno |

### Directorios

| Ruta | Owner | Propósito |
|------|-------|-----------|
| /vagrant | vagrant | Carpeta sincronizada (host <-> VM) |
| /opt/tomcat | tomcat | Instalación de Tomcat |
| /var/log/dashboard | threatmodel | Logs de generación |
| /var/lib/dashboard | threatmodel | Archivos de estado |

---

## Changelog

### Version 2.0.0 (Actual)

**Agregado**:
- Integración con Apache Tomcat 10.1.47
- PlantUML Server v1.2025.7 (basado en web)
- Acceso web a outputs generados vía HTTP
- Servicio systemd para PlantUML
- Verificación automática de checksums SHA512
- Configuración de port forwarding (8080)
- Acceso por red privada (192.168.56.10)

**Cambiado**:
- Diagramas de secuencia ahora usan servicio web PlantUML
- bin/generate usa API HTTP para PlantUML
- Proceso bootstrap incluye setup de Tomcat (8 fases)

**Mejorado**:
- Scripts de instalación idempotentes
- Mejor manejo de errores
- Salida profesional (sin emojis)
- Logging completo
- Sistema de verificación de 8 puntos

### Version 1.1.0

**Correcciones Críticas**:
- Corregido problema con expresiones aritméticas en bash
- Actualizado script bin/generate para POSIX compliance
- Template de reportes simplificado
- Eliminadas variables no soportadas del template

**Características Validadas**:
- Generación correcta de DFD
- Generación correcta de Sequence Diagrams
- Generación correcta de reportes HTML
- Auto-descubrimiento funcional
- Usuario threatmodel funcionando correctamente

### Version 1.0.0

**Características Iniciales**:
- Usuario dedicado threatmodel
- Separación de privilegios con sudo
- Auto-detección y re-ejecución
- 3 modelos de ejemplo completos
- Idempotencia y auto-reparación
- Sistema de logging robusto

---

## Licencia

MIT License

## Soporte

Para problemas o preguntas:
- Revisar logs: `/var/log/dashboard/threatmodel.log`
- Ver logs de Tomcat: `/opt/tomcat/logs/catalina.out`
- Verificar estado: `sudo systemctl status plantuml`
- Abrir issue en el repositorio

---

**Última actualización**: 2025-10-12

**Versión**: 2.0.0