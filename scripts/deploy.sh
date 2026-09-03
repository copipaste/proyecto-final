#!/bin/bash
# ==============================================================================
# Deploy Script — Blue-Green Deployment Automatizado
# ==============================================================================

set -e

VERSION=${1:-"v1.0.0"}
TARGET_COLOR=$2

# Detectar slot activo actual si no fue especificado
if [ -z "$TARGET_COLOR" ]; then
    CURRENT_COLOR="blue"
    if [ -f "/opt/app/current_color" ]; then
        CURRENT_COLOR=$(cat /opt/app/current_color)
    fi

    if [ "$CURRENT_COLOR" == "blue" ]; then
        TARGET_COLOR="green"
    else
        TARGET_COLOR="blue"
    fi
fi

if [ "$TARGET_COLOR" == "blue" ]; then
    PORT=8080
else
    PORT=8081
fi

COLOR_UPPER=$(echo "$TARGET_COLOR" | tr '[:lower:]' '[:upper:]')

echo "========================================================================"
echo "🚀 [DEPLOY] Desplegando versión '${VERSION}' en Slot '${COLOR_UPPER}' (Puerto: ${PORT})"
echo "========================================================================"

# Ubicación del artefacto
JAR_SOURCE="/vagrant/target/app.jar"
if [ ! -f "$JAR_SOURCE" ]; then
    if [ -f "./target/app.jar" ]; then
        JAR_SOURCE="./target/app.jar"
    else
        echo "❌ [ERROR] No se encontró el archivo JAR en '$JAR_SOURCE' ni './target/app.jar'."
        echo "Asegúrese de ejecutar 'mvn package' previamente."
        exit 1
    fi
fi

# 1. Preparar directorio y copiar artefacto
mkdir -p "/opt/app/${TARGET_COLOR}"
mkdir -p /var/log/app
cp -f "$JAR_SOURCE" "/opt/app/${TARGET_COLOR}/app.jar"
echo "📦 Artefacto copiado a /opt/app/${TARGET_COLOR}/app.jar"

# 2. Detener proceso anterior en este slot si existe
if [ -f "/opt/app/${TARGET_COLOR}/app.pid" ]; then
    OLD_PID=$(cat "/opt/app/${TARGET_COLOR}/app.pid")
    echo "🛑 Deteniendo instancia anterior en PID ${OLD_PID}..."
    kill -9 "$OLD_PID" 2>/dev/null || true
    rm -f "/opt/app/${TARGET_COLOR}/app.pid"
fi

# Limpiar posibles procesos zombies en el puerto
sudo fuser -k -n tcp "${PORT}" 2>/dev/null || true

# 3. Iniciar nueva instancia Spring Boot en segundo plano
echo "⚡ Iniciando aplicación Spring Boot en puerto ${PORT}..."
nohup java \
    -Dserver.port="${PORT}" \
    -DINSTANCE_NAME="${COLOR_UPPER}" \
    -DAPP_VERSION="${VERSION}" \
    -jar "/opt/app/${TARGET_COLOR}/app.jar" \
    > "/var/log/app/${TARGET_COLOR}.log" 2>&1 &

APP_PID=$!
echo "$APP_PID" > "/opt/app/${TARGET_COLOR}/app.pid"
echo "🟢 Proceso iniciado con PID ${APP_PID}. Logs en /var/log/app/${TARGET_COLOR}.log"

# 4. Ejecutar Health Check
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "🩺 Verificando salud del despliegue..."

if bash "${SCRIPT_DIR}/health-check.sh" "${PORT}" 20 2; then
    echo "🎉 [VERIFICACIÓN PASS] La instancia ${COLOR_UPPER} está saludable."
    
    # 5. Conmutar tráfico en Nginx
    bash "${SCRIPT_DIR}/switch-traffic.sh" "${TARGET_COLOR}"
    
    echo "========================================================================"
    echo "✅ [DEPLOY EXITOSO] Versión '${VERSION}' activa en producción (${COLOR_UPPER} :${PORT})"
    echo "========================================================================"
else
    echo "💥 [VERIFICACIÓN FAIL] Health Check falló en la instancia ${COLOR_UPPER}."
    bash "${SCRIPT_DIR}/rollback.sh" "${TARGET_COLOR}"
    exit 1
fi
