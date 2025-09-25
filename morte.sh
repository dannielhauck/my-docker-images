#!/usr/bin/env bash
set -euo pipefail

echo "=== Verificando processos nas portas 80 e 443 ==="
sudo lsof -i :80 -i :443 || true
echo

echo "=== Parando containers Docker que usam 80/443 ==="
CONTAINERS=$(docker ps -q --filter "publish=80" --filter "publish=443")
if [ -n "$CONTAINERS" ]; then
  echo "Parando e removendo containers: $CONTAINERS"
  docker stop $CONTAINERS
  docker rm -f $CONTAINERS
else
  echo "Nenhum container expondo 80/443 encontrado."
fi
echo

echo "=== Matando processos que ainda usam 80/443 ==="
PIDS=$(sudo lsof -t -i :80 -i :443 || true)
if [ -n "$PIDS" ]; then
  echo "Matando PIDs: $PIDS"
  sudo kill -9 $PIDS
else
  echo "Nenhum processo ocupando 80/443."
fi
echo

echo "=== Reiniciando Apache ==="
sudo systemctl restart apache2
sudo systemctl enable apache2
echo

echo "=== Status do Apache ==="
sudo systemctl status apache2 --no-pager