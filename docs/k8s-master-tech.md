# ☸️ k8s-master — Kubernetes Control Plane


**Роль:** Control Plane для аналитического кластера
**IP:** 85.208.87.114
**ОС:** Ubuntu 22.04.5 LTS
**Ресурсы:** 2 vCPU, 4 ГБ RAM, 30 ГБ SSD
**SSH:** ed25519 (единый ключ на всех трёх ВМ)

---

## 🎯 Назначение ВМ

`k8s-master` — управляющая нода Kubernetes-кластера v1.29, развёрнутого
для практики Platform/DevOps-инженерии и мониторинга инфраструктуры
через `kube-prometheus-stack` (Helm). Кластер используется как учебный
полигон: на нём отрабатывались `kubeadm`, Flannel CNI, Helm, Prometheus, Grafana.

**Что размещено на master:**

- API-server Kubernetes
- etcd (хранилище состояния кластера)
- controller-manager, scheduler
- Flannel CNI (DaemonSet)
- Prometheus + Grafana + Alertmanager (namespace `monitoring`)
- node-exporter, kube-state-metrics

---

## 📋 Состояние кластера

Проверяем ноды:

```bash
kubectl get nodes
```

На 25.08.2026 все три ноды в статусе `Ready`:

| Нода | Роль | Возраст | Версия |
|---|---|---|---|
| devops-k8s-master | control-plane | 29d | v1.29.15 |
| devops-k8s-worker-1 | worker | 29d | v1.29.15 |
| devops-k8s-worker-2 | worker | 14d | v1.29.15 |

---

## 📦 Установленные компоненты

| Компонент | Версия | Статус | Назначение |
|---|---|---|---|
| Kubernetes | v1.29.15 | ✅ Running | Control plane |
| kubectl | v1.29.15 | ✅ Установлен | CLI |
| kubeadm | v1.29.15 | ✅ Установлен | Bootstrap кластера |
| Helm | v3.21.3 | ✅ Установлен | Пакетный менеджер |
| Docker | 29.6.2 | ✅ Установлен | Используется до containerd |
| containerd | v2.3.3 | ✅ Running | Container runtime |
| Flannel (CNI) | latest | ✅ Running | Overlay-сеть |
| kube-prometheus-stack | latest | ✅ Running | Мониторинг |

---

## 📊 Мониторинг (kube-prometheus-stack)

Установлен через Helm в namespace `monitoring`:

| Компонент | Статус | Назначение |
|---|---|---|
| Prometheus | ✅ Running | Сбор метрик |
| Grafana | ✅ Running | Дашборды |
| Alertmanager | ✅ Running | Алерты |
| Node Exporter | ✅ Running | Метрики нод (DaemonSet) |
| kube-state-metrics | ✅ Running | Метрики объектов K8s |

### Доступ к Grafana

Пробрасываем порт на локальную машину:

```bash
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80
```

**URL:** http://localhost:3000
**Логин:** `admin`
**Пароль:** получаем из Kubernetes Secret.

### Доступ к Prometheus

```bash
kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n monitoring 9090:9090
```

**URL:** http://localhost:9090

---

## 🔧 Полезные команды

### Статус кластера

```bash
# Все ноды
kubectl get nodes

# Все поды во всех namespace
kubectl get pods -A

# Все сервисы
kubectl get svc -A

# Поды мониторинга
kubectl get pods -n monitoring
```

### Логи и описание

```bash
# Логи пода
kubectl logs -f <pod-name> -n <namespace>

# Описание ноды
kubectl describe node <node-name>

# Описание пода
kubectl describe pod <pod-name> -n <namespace>
```

### Тестовый деплой (проверка работоспособности)

```bash
# Создаём nginx
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort

# Проверяем
kubectl get pods
kubectl get svc

# Убираем за собой
kubectl delete deployment nginx
kubectl delete svc nginx
```

---

## 📁 Структура на master

```
~/
├── .kube/
│   └── config              # kubeconfig (конфиденциально!)
├── .ssh/
│   ├── authorized_keys     # Публичные ключи для SSH
│   └── known_hosts
├── docs/
│   ├── commands.txt        # Шпаргалка команд
│   └── step-by-step.md     # Пошаговая установка
├── check_all.sh            # Скрипт проверки статуса кластера
├── get_helm.sh             # Установщик Helm
└── README.md               # Локальный README
```

---

## 🔑 Подключение

### Из PowerShell

```powershell
ssh -i C:\Users\MI\.ssh\id_ed25519 user1@85.208.87.114
```

### Из VS Code

```
F1 → Remote-SSH: Connect to Host... → k8s-master
```

### Из WinSCP

Сессия `k8s-master` (см. [`winscp-guide.md`](./winscp-guide.md)).

---

## 🔗 Связанные ВМ

| ВМ | IP | Роль |
|---|---|---|
| devops-main | 213.171.26.123 | BI-стек (Docker Compose, 14 сервисов) |
| k8s-worker-1 | 82.202.158.28 | Kubernetes Worker |
| k8s-worker-2 | 176.108.248.13 | Kubernetes Worker |

---

## 📅 История

| Дата | Событие |
|---|---|
| 2026-07-12 | Создана ВМ |
| 2026-07-26 | Инициализирован Kubernetes-кластер (`kubeadm init`) |
| 2026-07-26 | Подключён worker-1 (`kubeadm join`) |
| 2026-07-26 | Установлен Flannel (CNI) |
| 2026-07-26 | Установлен Helm |
| 2026-07-26 | Развёрнут мониторинг (Prometheus + Grafana) |
| 2026-08-07 | Заменён SSH-ключ на ed25519 |
| 2026-08-11 | Подключён новый worker-2 (176.108.248.13) |
| 2026-09-28 | Кластер задокументирован, ВМ выключены |

---

## 🔐 Безопасность

- **Все пароли вынесены в Helm values** (`${GRAFANA_ADMIN_PASSWORD}`),
  реальные значения — в приватной папке вне git.
- **kubeconfig не коммитится** — содержит сертификат администратора кластера.
- **base64-пароль Grafana в манифестах** заменён на `<BASE64_GRAFANA_PASSWORD>`.
- **kubeadm join-токен** в документации заменён на плейсхолдеры `<TOKEN>`, `<CA_CERT_HASH>`.

---

## 📚 См. также

- [k8s-cluster-setup.md](./k8s-cluster-setup.md) — пошаговая установка кластера
- [k8s-commands.md](./k8s-commands.md) — шпаргалка команд
- [../k8s-monitoring-cluster/README.md](../k8s-monitoring-cluster/README.md) — обзор кейса

---

**Автор:** Артур Минин (MartinMinart)
**Обновлено:** 2026-09-28
