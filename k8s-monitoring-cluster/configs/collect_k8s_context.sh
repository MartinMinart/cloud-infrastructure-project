#!/bin/bash

OUT="$HOME/k8s_context_$(date +%Y%m%d_%H%M%S).txt"

{
echo "=================================================="
echo "KUBERNETES TECHNICAL SNAPSHOT"
echo "=================================================="
date
hostname
uname -a

echo
echo "=================================================="
echo "OS"
echo "=================================================="
cat /etc/os-release

echo
echo "=================================================="
echo "RESOURCES"
echo "=================================================="
nproc
free -h
df -h

echo
echo "=================================================="
echo "KUBERNETES VERSION"
echo "=================================================="
kubectl version --short 2>&1 || kubectl version 2>&1

echo
echo "=================================================="
echo "HELM"
echo "=================================================="
helm version

echo
echo "=================================================="
echo "NODES"
echo "=================================================="
kubectl get nodes -o wide

echo
echo "=================================================="
echo "NODE DESCRIBE"
echo "=================================================="
kubectl describe nodes

echo
echo "=================================================="
echo "ALL PODS"
echo "=================================================="
kubectl get pods -A -o wide

echo
echo "=================================================="
echo "ALL SERVICES"
echo "=================================================="
kubectl get svc -A

echo
echo "=================================================="
echo "ALL DEPLOYMENTS"
echo "=================================================="
kubectl get deployments -A

echo
echo "=================================================="
echo "ALL DAEMONSETS"
echo "=================================================="
kubectl get daemonsets -A

echo
echo "=================================================="
echo "ALL EVENTS"
echo "=================================================="
kubectl get events -A --sort-by='.lastTimestamp'

echo
echo "=================================================="
echo "FLANNEL"
echo "=================================================="
kubectl get pods -n kube-flannel -o wide 2>&1 || true
kubectl get daemonset -A | grep -i flannel || true

echo
echo "=================================================="
echo "MONITORING"
echo "=================================================="
kubectl get pods -n monitoring -o wide 2>&1 || true
kubectl get svc -n monitoring 2>&1 || true
kubectl get deployments -n monitoring 2>&1 || true

echo
echo "=================================================="
echo "CONTAINER RUNTIME"
echo "=================================================="
containerd --version 2>&1 || true
crictl info 2>&1 | head -100 || true

echo
echo "=================================================="
echo "SYSTEM SERVICES"
echo "=================================================="
systemctl is-active kubelet
systemctl is-active containerd

echo
echo "=================================================="
echo "KUBELET LOG"
echo "=================================================="
sudo journalctl -u kubelet --no-pager -n 150

echo
echo "=================================================="
echo "CONTAINERD LOG"
echo "=================================================="
sudo journalctl -u containerd --no-pager -n 100

echo
echo "=================================================="
echo "END"
echo "=================================================="

} > "$OUT" 2>&1

echo "Snapshot created:"
echo "$OUT"
