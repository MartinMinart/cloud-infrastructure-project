===========================================
KUBERNETES CLUSTER - ПОЛЕЗНЫЕ КОМАНДЫ
===========================================
Дата создания: 2026-07-26

--- ПОДКЛЮЧЕНИЯ ---
# Подключение к master
ssh -i C:\Users\MI\.ssh\id_rsa user1@85.208.87.114

# Подключение к worker-1
ssh -i C:\Users\MI\.ssh\id_rsa user1@82.202.158.28

# Подключение к worker-2
ssh -i C:\Users\MI\.ssh\id_rsa user1@176.108.248.13

--- КОМАНДА JOIN (для worker-ов) ---
kubeadm join <MASTER_IP>:6443 --token <TOKEN> \
        --discovery-token-ca-cert-hash sha256:<CA_CERT_HASH>
( к примеру: kubeadm join 10.0.0.6:6443 --token <TOKEN> \
        --discovery-token-ca-cert-hash sha256:b11df3dd0511ec52504718977075ed9c08540d84a3ec063c6534b38e___________)

--- ОСНОВНЫЕ КОМАНДЫ KUBECTL ---
kubectl get nodes                 # Список всех нод
kubectl get pods                  # Список подов
kubectl get pods -A               # Поды во всех namespace
kubectl get svc                   # Список сервисов
kubectl get deployments           # Список деплойментов
kubectl describe node <name>      # Информация о ноде
kubectl describe pod <name>       # Информация о поде
kubectl logs <pod-name>           # Логи пода
kubectl delete pod <name>         # Удалить под

--- ДИАГНОСТИКА ---
kubectl version --client          # Версия kubectl
kubeadm version                   # Версия kubeadm
docker --version                  # Версия Docker
uname -r                          # Версия ядра
sudo systemctl status containerd  # Статус containerd
sudo systemctl status kubelet     # Статус kubelet

--- УСТАНОВКА СЕТЕВОГО ПЛАГИНА ---
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

--- ПРОВЕРКА СТАТУСА ---
kubectl get nodes
kubectl get pods -n kube-system
