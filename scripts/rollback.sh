#!/bin/bash
# ==============================================================================
# Rollback Script — Revierte el tráfico a la instancia estable anterior
# ==============================================================================

FAILED_COLOR=${1:-green}

if [ "$FAILED_COLOR" == "green" ]; then
    STABLE_COLOR="blue"
    STABLE_PORT=8080
    FAILED_PORT=8081
else
    STABLE_COLOR="green"
    STABLE_PORT=8081
    FAILED_PORT=8080
fi

echo "⚠️  [ROLLBACK INICIADO] La instancia '${FAILED_COLOR^^}' falló. Revirtiendo tráfico a '${STABLE_COLOR^^}'..."

# Detener el proceso fallido si existe
if [ -f "/opt/app/${FAILED_COLOR}/app.pid" ]; then
    FAILED_PID=$(cat "/opt/app/${FAILED_COLOR}/app.pid")
    echo "🛑 Deteniendo proceso fallido PID ${FAILED_PID} en puerto ${FAILED_PORT}..."
    sudo kill -9 "$FAILED_PID" 2>/dev/null || true
    sudo rm -f "/opt/app/${FAILED_COLOR}/app.pid"
fi

# Reestablecer Nginx hacia el slot estable
sudo tee /etc/nginx/sites-available/app.conf > /dev/null <<EOF
upstream spring_backend {
    server 127.0.0.1:${STABLE_PORT};
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    location / {
        proxy_pass http://spring_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_connect_timeout 3s;
        proxy_read_timeout 10s;
    }
}
EOF

sudo nginx -t
sudo systemctl reload nginx
echo "$STABLE_COLOR" | sudo tee /opt/app/current_color > /dev/null

echo "✅ [ROLLBACK COMPLETADO] Tráfico seguro y restablecido en '${STABLE_COLOR^^}' (Puerto: ${STABLE_PORT})."
