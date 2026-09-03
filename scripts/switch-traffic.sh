#!/bin/bash
# ==============================================================================
# Switch Traffic Script — Conmuta el upstream de Nginx hacia el slot destino
# ==============================================================================

set -e

TARGET_COLOR=${1:-blue}

if [ "$TARGET_COLOR" == "blue" ]; then
    TARGET_PORT=8080
elif [ "$TARGET_COLOR" == "green" ]; then
    TARGET_PORT=8081
else
    echo "❌ [ERROR] Color no reconocido: '$TARGET_COLOR'. Use 'blue' o 'green'."
    exit 1
fi

echo "🔀 [SWITCH TRAFFIC] Conmutando tráfico de Nginx hacia '${TARGET_COLOR^^}' (Puerto: ${TARGET_PORT})..."

# Actualizar la configuración de Nginx
sudo tee /etc/nginx/sites-available/app.conf > /dev/null <<EOF
upstream spring_backend {
    server 127.0.0.1:${TARGET_PORT};
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

# Validar y recargar Nginx sin tiempo de inactividad
sudo nginx -t
sudo systemctl reload nginx

# Guardar estado actual
echo "$TARGET_COLOR" | sudo tee /opt/app/current_color > /dev/null

echo "✅ [TRAFICO CONMUTADO] Nginx ahora redirige el 100% del tráfico al puerto ${TARGET_PORT} (${TARGET_COLOR^^})."
