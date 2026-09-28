# 🐳 DEVOPS-MAIN — BI-СТЕК (Docker Compose)

**Роль:** Основной BI-стек для аналитической платформы  
**IP:** 213.171.26.123  
**ОС:** Ubuntu 22.04.5 LTS  
**Ресурсы:** 2 vCPU, 8 ГБ RAM, 30 ГБ SSD  
**SSH-ключ:** ed25519 ✅

---

## 📋 СТАТУС

```bash
cd ~/analytics-stack
docker compose ps
```

**Результат (14 сервисов):**
```
NAME                   STATUS    PORTS
airflow                Up         8080
analytics-clickhouse   Up         8123
analytics-kafka        Up         9092
analytics-metabase     Up         3000
analytics-minio        Up         9001
analytics-postgres     Healthy    5432
analytics-qdrant       Up         6333
analytics-redis        Up         6379
analytics-superset     Healthy    8088
grafana                Up         3001
mongodb                Up         27017
nifi                   Up         8443
node-red               Up         1880
redash                 Up         5000
```

---

## 🛠️ СЕРВИСЫ

### Базы данных
| Сервис | Порт | Назначение |
|--------|------|------------|
| **PostgreSQL** | 5432 | Основное реляционное хранилище |
| **ClickHouse** | 8123 | Колоночная БД для аналитики |
| **MongoDB** | 27017 | NoSQL документное хранилище |
| **Qdrant** | 6333 | Векторная БД для AI/RAG |

### ETL и Оркестрация
| Сервис | Порт | Назначение |
|--------|------|------------|
| **Apache Airflow** | 8080 | Оркестрация ETL-пайплайнов |
| **Apache NiFi** | 8443 | Потоковая обработка данных |
| **Apache Kafka** | 9092 | Брокер сообщений |

### BI и Визуализация
| Сервис | Порт | Назначение |
|--------|------|------------|
| **Metabase** | 3000 | BI-дашборды для бизнес-пользователей |
| **Apache Superset** | 8088 | BI для продвинутой аналитики |
| **Grafana** | 3001 | Мониторинг и метрики |
| **Redash** | 5000 | SQL-запросы и визуализация |

### Автоматизация и Хранилище
| Сервис | Порт | Назначение |
|--------|------|------------|
| **Node-RED** | 1880 | Визуальная разработка потоков |
| **MinIO** | 9001 | S3-совместимое объектное хранилище |

---

## 🌐 ДОСТУП К СЕРВИСАМ

| Сервис | URL | Логин | Пароль |
|--------|-----|-------|--------|
| **Metabase** | http://213.171.26.123:3000 | — | создать при входе |
| **Superset** | http://213.171.26.123:8088 | admin | (см. `.env`) |
| **Airflow** | http://213.171.26.123:8080 | admin | (см. `.env`)  |
| **Grafana** | http://213.171.26.123:3001 | admin | (см. `.env`)  |
| **Redash** | http://213.171.26.123:5000 | — | создать при входе |
| **MinIO Console** | http://213.171.26.123:9001 | minioadmin | (см. `.env`) |
| **Node-RED** | http://213.171.26.123:1880 | — | без пароля |
| **NiFi** | https://213.171.26.123:8443 | admin | (см. `.env`)  |
| **ClickHouse** | http://213.171.26.123:8123 | clickhouse | (см. `.env`) |
| **Qdrant** | http://213.171.26.123:6333/dashboard | — | (см. `.env`) |

---

## 📁 СТРУКТУРА ПРОЕКТА

```
~/
├── analytics-stack/              # Основной Docker Compose стек
│   ├── docker-compose.yml        # Конфигурация всех сервисов
│   ├── .env                      # Переменные окружения (НЕ в Git!)
│   ├── .env.example              # Шаблон переменных (в Git)
│   ├── airflow/
│   │   ├── dags/                 # DAG-файлы Airflow
│   │   ├── logs/                 # Логи Airflow
│   │   └── plugins/              # Плагины Airflow
│   └── ...
├── docs/                         # Документация
│   ├── commands.txt              # Полезные команды
│   └── step-by-step.md           # Пошаговая инструкция
├── README.md                     # Этот файл
└── Analytics Platform on Cloud.ru.md  # Описание проекта
```

---

## 🔧 УПРАВЛЕНИЕ

### Основные команды

```bash
cd ~/analytics-stack

# Статус всех контейнеров
docker compose ps

# Запустить все
docker compose up -d

# Остановить все
docker compose down

# Перезапустить конкретный сервис
docker compose restart metabase

# Логи всех контейнеров
docker compose logs -f

# Логи конкретного контейнера
docker compose logs analytics-postgres --tail=50
```

### Обновление сервисов

```bash
# Скачать новые образы
docker compose pull

# Пересоздать контейнеры
docker compose up -d --force-recreate
```

---

## 🔑 ПОДКЛЮЧЕНИЕ

### Из PowerShell

```powershell
ssh -i C:\Users\MI\.ssh\id_ed25519 user1@213.171.26.123
```

### Из VS Code

```
F1 → Remote-SSH: Connect to Host... → devops-main
```

---

## 📝 ПЕРЕМЕННЫЕ ОКРУЖЕНИЯ

Все чувствительные данные хранятся в файле `.env`:

```bash
cat ~/analytics-stack/.env
```

Для нового развертывания используйте шаблон:

```bash
cp ~/analytics-stack/.env.example ~/analytics-stack/.env
# Затем отредактируйте пароли
```

---

## 📅 ИСТОРИЯ

| Дата | Событие |
|------|---------|
| 2026-07-12 | Создана первая ВМ devops-main |
| 2026-08-11 | Пересоздана devops-main-new (213.171.26.123) |
| 2026-08-11 | Развёрнут Docker стек из 14 сервисов |
| 2026-08-11 | Настроен единый ed25519 SSH-ключ |

---

## 🔗 СВЯЗАННЫЕ ВМ

| ВМ | IP | Роль |
|----|----|----|
| **k8s-master** | 85.208.87.114 | Kubernetes Control Plane |
| **k8s-worker-1** | 82.202.158.28 | Kubernetes Worker |
| **k8s-worker-2** | 176.108.248.13 | Kubernetes Worker |

---

**Автор:** Артур (MartinMinart)  
**Обновлено:** 2026-08-11