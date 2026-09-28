# ☸️ Установка Kubernetes-кластера (1 master + 2 worker)

Пошаговая инструкция: как я собрал K8s-кластер v1.29 на Cloud.ru Evolution
для мониторинга инфраструктуры (Prometheus + Grafana через Helm).

**Дата развёртывания:** июль 2026
**Версия Kubernetes:** v1.29.15
**CNI:** Flannel
**Runtime:** containerd

---

## 📋 Предварительные требования

- 3 ВМ с Ubuntu 22.04 LTS:
  - master: 2 vCPU, 4 ГБ RAM, 30 ГБ SSD
  - worker-1: 1 vCPU, 2 ГБ RAM, 30 ГБ SSD
  - worker-2: 2 vCPU, 8 ГБ RAM, 30 ГБ SSD
- Все ВМ в одной подсети (Default VPC, 10.0.0.0/24)
- SSH-доступ под `user1`
- Открыты порты: 22, 6443, 10250, 8472/UDP

---

## 🔧 Этап 1. Подготовка всех ВМ

Выполняем **на каждой из трёх ВМ** (master, worker-1, worker-2).

### 1.1. Отключаем swap

Kubelet требует, чтобы swap был выключен:

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

Проверяем:

```bash
free -h
# Swap должно быть 0B
```

### 1.2. Загружаем модули ядра

```bash
sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
```

### 1.3. Настраиваем sysctl

```bash
sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

### 1.4. Устанавливаем containerd

```bash
sudo apt-get update
sudo apt-get install -y containerd

# Генерируем конфиг
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Включаем SystemdCgroup
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Перезапускаем
sudo systemctl restart containerd
sudo systemctl enable containerd
```

### 1.5. Устанавливаем kubelet, kubeadm, kubectl

```bash
# Ключ репозитория
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Репозиторий
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Установка
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Проверка
kubeadm version
kubectl version --client
```

---

## 🎯 Этап 2. Инициализация control-plane (master)

Выполняем **только на master** (85.208.87.114).

### 2.1. Инициализируем кластер

```bash
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address=10.0.0.6
```

**Важно:** сохрани вывод команды — там будет `kubeadm join ...` для worker-ов.

### 2.2. Настраиваем kubeconfig для пользователя

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Проверяем:

```bash
kubectl get nodes
# Должна быть одна нода в статусе NotReady
```

### 2.3. Устанавливаем Flannel (CNI)

```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

Ждём 1–2 минуты, проверяем:

```bash
kubectl get nodes
# Нода должна стать Ready
```

### 2.4. Проверяем поды в kube-system

```bash
kubectl get pods -n kube-system
```

Все поды должны быть в статусе `Running` (или `Completed` для одноразовых).

---

## 🔗 Этап 3. Подключение worker-нод

Выполняем **на каждой worker-ноде** (worker-1, worker-2).

### 3.1. Получаем команду join на master

На master:

```bash
kubeadm token create --print-join-command
```

Вывод будет вида:

```
kubeadm join 10.0.0.6:6443 --token <TOKEN> \
        --discovery-token-ca-cert-hash sha256:<CA_CERT_HASH>
```

### 3.2. Выполняем join на worker

На каждой worker-ноде:

```bash
sudo kubeadm join 10.0.0.6:6443 --token <TOKEN> \
        --discovery-token-ca-cert-hash sha256:<CA_CERT_HASH>
```

**⚠️ Токены одноразовые** — если просрочен, создаём новый на master.

### 3.3. Проверяем на master

```bash
kubectl get nodes
```

Все 3 ноды должны быть `Ready`:

```
NAME                  STATUS   ROLES           AGE   VERSION
devops-k8s-master     Ready    control-plane   5m    v1.29.15
devops-k8s-worker-1   Ready    <none>          1m    v1.29.15
devops-k8s-worker-2   Ready    <none>          1m    v1.29.15
```

---

## 📦 Этап 4. Установка Helm (master)

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

helm version
# v3.21.3
```

---

## 📊 Этап 5. Установка kube-prometheus-stack

Выполняем **на master**.

### 5.1. Добавляем Helm-репозиторий

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### 5.2. Устанавливаем стек

```bash
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

Ждём 3–5 минут, пока все поды поднимутся.

### 5.3. Проверяем

```bash
kubectl get pods -n monitoring
```

Должны быть `Running`:

| Под | Роль |
|---|---|
| monitoring-grafana | Графана |
| monitoring-kube-prometheus-operator | Оператор |
| monitoring-kube-state-metrics | Метрики K8s |
| monitoring-prometheus-node-exporter | Метрики нод |
| alertmanager-monitoring-... | Алерты |
| prometheus-monitoring-... | Prometheus |

### 5.4. Доступ к Grafana

Пробрасываем порт:

```bash
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80
```

Логин: `admin`
Пароль:

```bash
kubectl get secret -n monitoring \
  -l app.kubernetes.io/component=admin-secret \
  -o jsonpath="{.items[0].data.admin-password}" | base64 --decode ; echo
```

Открываем http://localhost:3000 → дашборды для K8s.

---

## ✅ Этап 6. Проверка кластера

### 6.1. Все ноды Ready

```bash
kubectl get nodes
```

### 6.2. Все системные поды Running

```bash
kubectl get pods -A
```

### 6.3. Тестовый деплой

```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort

kubectl get pods
kubectl get svc
```

---

## 🚨 Типичные проблемы

| Проблема | Решение |
|---|---|
| `kubeadm init` падает с `swap is on` | `sudo swapoff -a` + убрать строку в `/etc/fstab` |
| Нода в статусе `NotReady` | Проверить Flannel: `kubectl get pods -n kube-flannel` |
| `kubeadm join` — токен просрочен | На master: `kubeadm token create --print-join-command` |
| Pod в `CrashLoopBackOff` | `kubectl logs <pod> -n <ns>` + `kubectl describe pod <pod>` |
| Grafana не открывается | Проверить `kubectl get svc -n monitoring`, port-forward |

---

## 📁 Связанные документы

- [k8s-master-tech.md](./k8s-master-tech.md) — техничка master
- [k8s-commands.md](./k8s-commands.md) — шпаргалка команд
- [../k8s-monitoring-cluster/README.md](../k8s-monitoring-cluster/README.md) — обзор кейса

---

**Автор:** Артур Минин (MartinMinart)
**Обновлено:** 2026-09-28