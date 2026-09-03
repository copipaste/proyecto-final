#!/bin/bash
# ==============================================================================
# Health Check Script — CI/CD Blue-Green Deployment
# Verifica que la instancia Spring Boot responda HTTP 200 y status UP en /health
# ==============================================================================

PORT=${1:-8080}
MAX_RETRIES=${2:-20}
DELAY=${3:-2}

HEALTH_URL="http://127.0.0.1:${PORT}/health"

echo "🔍 [HEALTH CHECK] Verificando servicio en ${HEALTH_URL} (Intentos max: ${MAX_RETRIES})..."

for i in $(seq 1 "$MAX_RETRIES"); do
    RESPONSE=$(curl -s -m 2 "$HEALTH_URL" 2>/dev/null || true)
    
    if echo "$RESPONSE" | grep -q '"status":"UP"'; then
        echo "✅ [HEALTH CHECK EXITOSO] Intento ${i}/${MAX_RETRIES}: Instancia en puerto ${PORT} está UP y saludable!"
        exit 0
    else
        echo "⏳ [Intento ${i}/${MAX_RETRIES}] Esperando que el servicio responda UP en puerto ${PORT}..."
        sleep "$DELAY"
    fi
done

echo "❌ [ERROR CRÍTICO] Health Check falló tras ${MAX_RETRIES} intentos en el puerto ${PORT}."
exit 1
