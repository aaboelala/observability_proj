#!/bin/bash
set -e

# Configuration
NS="observability-ns"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${RED}[WARN]${NC} $1"; }

echo "=================================================="
echo -e "${RED}    Observability Stack Uninstallation${NC}"
echo "=================================================="

read -p "Are you sure you want to uninstall the observability stack? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

log "Uninstalling Prometheus Stack..."
helm uninstall prometheus -n $NS 2>/dev/null || warn "Prometheus stack not found"

log "Uninstalling Tempo..."
helm uninstall tempo -n $NS 2>/dev/null || warn "Tempo not found"

log "Uninstalling Grafana Alloy..."
helm uninstall alloy -n $NS 2>/dev/null || warn "Alloy not found"

log "Uninstalling Loki..."
helm uninstall loki -n $NS 2>/dev/null || warn "Loki not found"

log "Cleaning up ConfigMaps..."
kubectl delete configmap grafana-dashboards -n $NS 2>/dev/null || true

log "Cleaning up namespace..."
read -p "Do you want to delete the namespace '$NS'? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl delete ns $NS --wait=false
    success "Namespace deletion initiated"
else
    success "Namespace preserved"
fi

echo ""
echo "=================================================="
echo -e "${GREEN}       UNINSTALLATION COMPLETE${NC}"
echo "=================================================="
echo ""
