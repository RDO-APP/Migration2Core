#!/bin/bash
# Executado NA EC2 Linux via SSM (homolog Core L1 only).
# Uso: bash ec2-apply-rdoapp-core-linux.sh --presigned-url 'https://...' [--site-path /var/www/rdoapp_core] [--port 5081]
set -euo pipefail

SITE_PATH="/var/www/rdoapp_core"
SMOKE_PORT=5081
PRESIGNED_URL=""
SERVICE_NAME="rdoapp-core-homolog"
STAGING_NAME="appsettings.Staging.json"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --presigned-url) PRESIGNED_URL="$2"; shift 2 ;;
    --site-path) SITE_PATH="$2"; shift 2 ;;
    --port) SMOKE_PORT="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$PRESIGNED_URL" ]]; then
  echo "Missing --presigned-url" >&2
  exit 1
fi

case "$SITE_PATH" in
  /var/www/rdoapp|/var/www/rdoapp/*)
    echo "Refusing production-like path: $SITE_PATH" >&2
    exit 1
    ;;
esac

mkdir -p "$SITE_PATH"
# AL2023: curl-minimal ja existe — nao instalar pacote "curl" (conflito dnf).
# .NET self-contained ainda exige ICU no host.
dnf install -y unzip libicu >/dev/null
command -v unzip >/dev/null
command -v curl >/dev/null || { echo "curl/curl-minimal missing" >&2; exit 1; }

STAGING_PATH="$SITE_PATH/$STAGING_NAME"
STAGING_BAK="/tmp/rdoapp_core-${STAGING_NAME}.bak"
if [[ -f "$STAGING_PATH" ]]; then
  cp -a "$STAGING_PATH" "$STAGING_BAK"
  echo "Backed up $STAGING_NAME"
fi

ZIP_PATH="/tmp/rdoapp_core-deploy-linux.zip"
EXTRACT_ROOT="/tmp/rdoapp_core_extract_linux"
rm -f "$ZIP_PATH"
rm -rf "$EXTRACT_ROOT"
mkdir -p "$EXTRACT_ROOT"

echo "Downloading deploy zip via presigned URL ..."
curl -fsSL --max-time 900 -o "$ZIP_PATH" "$PRESIGNED_URL"
echo "Expand zip ..."
unzip -qo "$ZIP_PATH" -d "$EXTRACT_ROOT"
echo "Expand OK"

echo "Stopping $SERVICE_NAME (if present) ..."
systemctl stop "$SERVICE_NAME" 2>/dev/null || true
pkill -f '/var/www/rdoapp_core/RdoApp.Core' 2>/dev/null || true
sleep 2

echo "Copy binaries -> $SITE_PATH ..."
# Preserva Staging se ainda nao restauramos: remove so arquivos do extract
shopt -s dotglob nullglob
cp -a "$EXTRACT_ROOT"/* "$SITE_PATH"/
shopt -u dotglob nullglob
echo "Copy OK"

if [[ -f "$STAGING_BAK" ]]; then
  cp -a "$STAGING_BAK" "$STAGING_PATH"
  rm -f "$STAGING_BAK"
  echo "Restored $STAGING_NAME from backup"
fi

CORE_BIN="$SITE_PATH/RdoApp.Core"
if [[ ! -f "$CORE_BIN" ]]; then
  echo "RdoApp.Core binary not found under $SITE_PATH" >&2
  ls -la "$SITE_PATH" | head -n 40 >&2
  exit 1
fi
chmod +x "$CORE_BIN"
# Native libs next to binary often need +x
find "$SITE_PATH" -maxdepth 1 -type f -name '*.so' -exec chmod +x {} \; 2>/dev/null || true

UNIT_PATH="/etc/systemd/system/${SERVICE_NAME}.service"
if [[ ! -f "$UNIT_PATH" ]]; then
  cat > "$UNIT_PATH" <<EOF
[Unit]
Description=RdoApp.Core homolog (Kestrel ${SMOKE_PORT})
After=network.target

[Service]
WorkingDirectory=${SITE_PATH}
ExecStart=${CORE_BIN}
Restart=always
RestartSec=5
Environment=ASPNETCORE_ENVIRONMENT=Staging
Environment=ASPNETCORE_URLS=http://0.0.0.0:${SMOKE_PORT}
KillSignal=SIGINT
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  systemctl enable "$SERVICE_NAME"
  echo "Created unit $UNIT_PATH"
fi

systemctl daemon-reload
systemctl restart "$SERVICE_NAME"
sleep 3
systemctl --no-pager --full status "$SERVICE_NAME" || true

smoke_get() {
  local url="$1"
  local label="$2"
  local ok=0
  local i
  for i in $(seq 1 15); do
    code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "$url" || true)
    echo "$label status: $code (attempt $i)"
    if [[ "$code" == "200" ]]; then
      ok=1
      break
    fi
    if ! systemctl is-active --quiet "$SERVICE_NAME"; then
      echo "$SERVICE_NAME not active" >&2
      journalctl -u "$SERVICE_NAME" -n 40 --no-pager >&2 || true
      return 1
    fi
    sleep 4
  done
  [[ "$ok" -eq 1 ]]
}

SMOKE_URL="http://127.0.0.1:${SMOKE_PORT}/Account/Login"
echo "Smoke GET $SMOKE_URL"
if ! smoke_get "$SMOKE_URL" "Smoke"; then
  journalctl -u "$SERVICE_NAME" -n 80 --no-pager >&2 || true
  exit 1
fi

PRIVATE_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [[ -z "${PRIVATE_IP:-}" ]]; then
  PRIVATE_IP=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/local-ipv4 || true)
fi
if [[ -z "${PRIVATE_IP:-}" ]]; then
  echo "ALB smoke SKIP: no private IPv4"
  exit 1
fi

ALB_URL="http://${PRIVATE_IP}:${SMOKE_PORT}/Account/Login"
echo "Smoke GET $ALB_URL (ALB/TG path)"
if ! smoke_get "$ALB_URL" "ALB smoke"; then
  echo "ALB smoke FAILED — Kestrel must listen 0.0.0.0:${SMOKE_PORT}" >&2
  exit 1
fi

echo "Deploy homolog Core Linux OK"
exit 0
