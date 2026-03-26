#!/bin/bash
# setup.sh — One-shot setup script for the Sensor Monitoring project
# Run: bash setup.sh

set -e

echo "========================================"
echo " Sensor Monitoring System - Setup"
echo "========================================"

# 1) DB 초기화
echo ""
echo "[1/3] Initializing MySQL database..."
sudo mysql < setup_db.sql
echo "      Done: sensor_db created."

# 2) Python 의존성 확인
echo ""
echo "[2/3] Checking Python dependencies..."
python3 -c "import mysql.connector" 2>/dev/null && echo "      mysql-connector-python: OK" || {
    echo "      Installing mysql-connector-python..."
    python3 -m pip install mysql-connector-python
}

# 3) Node-RED 의존성 확인 (선택)
echo ""
echo "[3/3] Checking Node-RED (optional)..."
if command -v node-red &>/dev/null; then
    echo "      node-red: OK"
    # 필요한 노드 설치
    NODERED_HOME="${HOME}/.node-red"
    mkdir -p "$NODERED_HOME"
    cd "$NODERED_HOME"
    npm install --save node-red-dashboard node-red-node-mysql 2>/dev/null \
        && echo "      node-red-dashboard, node-red-node-mysql: installed" \
        || echo "      [WARN] npm install failed — install manually"
    cd - > /dev/null
else
    echo "      [INFO] node-red not found. Install with:"
    echo "             sudo npm install -g node-red node-red-dashboard node-red-node-mysql"
fi

echo ""
echo "========================================"
echo " Setup complete!"
echo ""
echo " Next steps:"
echo "   python3 injector.py          # Start data injection"
echo "   node-red                     # Start Node-RED (new terminal)"
echo "   Dashboard: http://localhost:1880/ui"
echo "   Grafana  : http://localhost:3000"
echo "========================================"
