# Changelog

Todos los cambios notables de este proyecto se documentan en este archivo.

El formato se basa en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/), y este proyecto se adhiere a [Semantic Versioning](https://semver.org/lang/es/).

---

## [1.3.0] - 2026-09-04
### Añadido
- Endpoint `GET /api/calc/subtract`: expone por HTTP la resta ya existente en `Calculator`.

---

## [1.2.0] - 2026-09-04
### Añadido
- Endpoint `GET /api/uptime`: segundos que lleva corriendo la instancia activa.

---

## [1.1.0] - 2026-09-02
### Añadido
- Estrategia de despliegue **Blue-Green** con Nginx reverse proxy sin tiempo de inactividad (*Zero Downtime*).
- Endpoints de operaciones matemáticas `/api/calc/add` y `/api/calc/multiply`.
- Endpoints de diagnóstico `/api/info` y `/date`.
- Scripts de automatización en carpeta `scripts/` (`deploy.sh`, `health-check.sh`, `switch-traffic.sh`, `rollback.sh`, `traffic-test.sh`).
- Pipeline de publicación automática de GitHub Releases (`release.yml`).
- Aprovisionamiento automatizado de infraestructura con **Vagrant + VirtualBox**.

### Mejorado
- Suite de pruebas unitarias JUnit para la clase `Calculator` alcanzando > 90% de cobertura.
- Configuración de JaCoCo en Maven (`jacoco-maven-plugin`).

---

## [1.0.0] - 2026-09-02
### Añadido
- Inicialización de la aplicación Spring Boot WebAPI.
- Endpoints base:
  - `GET /`: Bienvenida e índice de endpoints.
  - `GET /health`: Health Check (`{"status": "UP"}`).
  - `GET /api/instance`: Identificación de slot activo (`BLUE` / `GREEN`).
- Pipeline de Integración Continua en GitHub Actions (`maven.yml`).
- Pruebas unitarias básicas con MockMvc y JUnit 5.
