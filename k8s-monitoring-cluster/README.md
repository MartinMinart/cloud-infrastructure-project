# Kubernetes Monitoring Cluster

Кластер Kubernetes 1.29 (1 master + 2 worker) с мониторингом Prometheus + Grafana.

## 🏗️ Архитектура

```
┌─────────────────┐
│  k8s-master     │  10.0.0.6  · 2 vCPU · 4 GB
│  Control Plane  │
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌────────┐ ┌────────┐
│ worker1│ │ worker2│
│10.0.0.7│ │10.0.0.9│
│1vCPU 2G│ │2vCPU 8G│
└────────┘ └────────┘
```

## 📦 Установленные компоненты

| Компонент | Версия | Назначение |
|-----------|--------|-----------|
| Kubernetes | 1.29 | Оркестрация |
| containerd | 1.7+ | Container runtime |
| Flannel | latest | CNI (overlay network) |
| Helm | 3.x | Пакетный менеджер |
| kube-prometheus-stack | latest | Prometheus + Grafana + Alertmanager |

## 🚀 Сборка кластера

```bash
# На master:
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Flannel CNI
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# На workers:
sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

# Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

## 📊 Мониторинг

**Namespace `monitoring`:**
- `prometheus-server`
- `grafana`
- `alertmanager`
- `kube-state-metrics`
- `node-exporter` (DaemonSet)

**Grafana доступна на NodePort 30000.**

## 📁 Структура

```
k8s-monitoring-cluster/
├── manifests/                   # kubectl get -o yaml
│   ├── all-resources.yaml
│   ├── nodes.yaml
│   ├── namespaces.yaml
│   ├── configmaps.yaml
│   ├── services.yaml
│   ├── storage.yaml
│   ├── helm-releases.yaml
│   └── helm-monitoring-manifest.yaml
├── values/
│   └── helm-monitoring-values.yaml   # Grafana adminPassword → ${GRAFANA_ADMIN_PASSWORD}
├── configs/
│   ├── README_k8s-master.md
│   └── *.sh
├── worker-1/
│   ├── kubelet.log
│   ├── containerd.log
│   └── system_info.txt
└── worker-2/
    ├── kubelet.log
    └── system_info.txt
```

## ✅ Статус кластера

- 3 ноды: **Ready**
- Все pod'ы в `monitoring` — **Running**
- Helm release `monitoring` — **deployed**

## 🔒 Безопасность

- `private-k8s-secrets.yaml` — **не в git** (в `.gitignore`)
- `private-kubeconfig.yaml` — **не в git**
- Helm values используют `${GRAFANA_ADMIN_PASSWORD}`