# ⚙️ K8S-WORKER-1 — KUBERNETES WORKER NODE

**Роль:** Worker-нода для аналитического кластера  
**IP:** 82.202.158.28  
**ОС:** Ubuntu 22.04.5 LTS  
**Ресурсы:** 1 vCPU, 2 ГБ RAM, 30 ГБ SSD  
**SSH-ключ:** ed25519 ✅

---

## 📋 СТАТУС

```bash
# Проверка статуса ноды (с master)
kubectl get nodes
```

**Результат:**
```
NAME                    STATUS   ROLES           AGE   VERSION
devops-k8s-master       Ready    control-plane   15d   v1.29.15
devops-k8s-worker-1     Ready    <none>          15d   v1.29.15
devops-k8s-worker-2     Ready    <none>          1h    v1.29.15
```

---

## 📦 УСТАНОВЛЕННЫЕ КОМПОНЕНТЫ

| Компонент | Версия | Статус |
|-----------|--------|--------|
| **kubelet** | v1.29.15 | ✅ Running |
| **kubeadm** | v1.29.15 | ✅ Установлен |
| **kubectl** | v1.29.15 | ✅ Установлен |
| **Docker** | 29.6.2 | ✅ Установлен |
| **containerd** | v2.3.3 | ✅ Running |
| **Flannel (CNI)** | latest | ✅ Running |

---

## 🔧 ПОЛЕЗНЫЕ КОМАНДЫ

### Проверка статуса

```bash
# Статус kubelet
sudo systemctl status kubelet

# Статус containerd
sudo systemctl status containerd

# Статус Docker
sudo systemctl status docker
```

### Логи

```bash
# Логи kubelet
sudo journalctl -u kubelet -f

# Логи containerd
sudo journalctl -u containerd -f
```

---

## 🔑 ПОДКЛЮЧЕНИЕ

### Из PowerShell

```powershell
ssh -i C:\Users\MI\.ssh\id_ed25519 user1@82.202.158.28
```

### Из VS Code

```
F1 → Remote-SSH: Connect to Host... → k8s-worker-1
```

---

## 🔗 СВЯЗАННЫЕ ВМ

| ВМ | IP | Роль |
|----|----|----|
| **devops-main** | 213.171.26.123 | BI-стек (Docker Compose) |
| **k8s-master** | 85.208.87.114 | Kubernetes Control Plane |
| **k8s-worker-2** | 176.108.248.13 | Kubernetes Worker |

---

## 📅 ИСТОРИЯ

| Дата | Событие |
|------|---------|
| 2026-07-12 | Создана ВМ |
| 2026-07-26 | Подключена к кластеру |
| 2026-08-11 | Заменён SSH-ключ на ed25519 |

---

**Автор:** Артур (MartinMinart)  
**Обновлено:** 2026-08-11
