#!/bin/bash
# ==============================================================================
# Traffic Test Script — Demostración de tráfico en vivo y balanceo Blue-Green
# ==============================================================================

HOST=${1:-"http://localhost"}
COUNT=${2:-20}
DELAY=${3:-0.5}

echo "========================================================================"
echo "📊 [TRAFFIC TEST] Enviando ${COUNT} peticiones continuas a ${HOST}/api/instance"
echo "========================================================================"
printf "%-5s | %-10s | %-12s | %-8s | %-8s | %-10s\n" "REQ" "HORA" "STATUS" "SLOT" "PUERTO" "VERSIÓN"
echo "------------------------------------------------------------------------"

for i in $(seq 1 "$COUNT"); do
    TIME=$(date +"%H:%M:%S")
    RES=$(curl -s -m 2 "${HOST}/api/instance" 2>/dev/null || echo '{"error":"CONNECTION_FAILED"}')
    
    INSTANCE=$(echo "$RES" | grep -o '"instance":"[^"]*' | cut -d'"' -f4)
    PORT=$(echo "$RES" | grep -o '"port":"[^"]*' | cut -d'"' -f4)
    VERSION=$(echo "$RES" | grep -o '"version":"[^"]*' | cut -d'"' -f4)
    STATUS=$(echo "$RES" | grep -o '"status":"[^"]*' | cut -d'"' -f4)
    
    if [ -z "$INSTANCE" ]; then
        INSTANCE="ERR"
        PORT="ERR"
        VERSION="ERR"
        STATUS="DOWN"
    fi
    
    printf "%-5s | %-10s | %-12s | %-8s | %-8s | %-10s\n" "#$i" "$TIME" "$STATUS" "$INSTANCE" "$PORT" "$VERSION"
    sleep "$DELAY"
done

echo "========================================================================"
echo "🏁 [FIN TRAFFIC TEST] Verificación de tráfico completada."
echo "========================================================================"
