# 🐳 DEVOPS-MAIN — BI-СТЕК (Docker Compose)

**Роль:** Основной BI-стек для аналитической платформы  
**IP:** 213.171.26.123  
**ОС:** Ubuntu 22.04.5 LTS  
**Ресурсы:** 2 vCPU, 8 ГБ RAM, 30 ГБ SSD  
**SSH-ключ:** ed25519 ✅

> ⚠️ ВМ **демонтирована 28.09.2026**. Документ описывает исторический срез на 21.09.2026.

---

## 📋 СТАТУС

```bash
cd ~/analytics-stack
docker compose ps
```

**В `docker-compose.yml` объявлено:** 16 сервисов.  
**Работало в последнем срезе 21.09:** 9 контейнеров.
```
NAME                    STATUS    PORTS
airflow                 Up        8080
airflow-scheduler       Up        —
analytics-clickhouse    Up        8123
analytics-metabase      Up        3000
analytics-minio         Up        9001
analytics-postgres      Healthy   5432
analytics-redis         Up        6379
grafana                 Up        3001
node-red                Up        1880
```

---

## 🛠️ СЕРВИСЫ

### Рабочие в последнем срезе (9 контейнеров)

| Compose service | `container_name` | Порт | Роль / состояние |
|---|---|---|---|
| `postgres` | `analytics-postgres` | 5432 | PostgreSQL, `Healthy` |
| `clickhouse` | `analytics-clickhouse` | 8123, 9005→9000 | OLAP, `Up` |
| `redis` | `analytics-redis` | 6379 | Кэш, `Up`; без volume |
| `metabase` | `analytics-metabase` | 3000 | `Up`; сохранённый дашборд не подтверждён |
| `minio` | `analytics-minio` | 9001, 9105 | S3-хранилище, `Up` |
| `airflow` | `airflow` | 8080 | Webserver, `Up` |
| `airflow-scheduler` | `airflow-scheduler` | — | Scheduler, `Up` |
| `grafana` | `grafana` | 3001 | Дашборды, `Up` |
| `node-red` | `node-red` | 1880 | Flow `Inject → Debug`, `Up` |

### Остальные объявленные в Compose (7)

| Compose service | `container_name` | Порт | Статус в историческом срезе |
|---|---|---|---|
| `dbt` | `analytics-dbt` | — | `Exited (0)`; запускается по требованию, не входит в 9 контейнеров `Up` |
| `superset` | `analytics-superset` | 8088 | Не работал в последнем срезе; не использовался |
| `redash` | `redash` | 5000 | Остановлен после `Internal Server Error` |
| `kafka` | `analytics-kafka` | 9092 | Остановлен; pub/sub не проверен |
| `nifi` | `nifi` | 8443 | Не использовался; отмечена проблема SSL |
| `mongodb` | `mongodb` | 27017 | Не работал стабильно (`Restarting 139`) |
| `qdrant` | `analytics-qdrant` | 6333, 6334 | Остановлен; API key не настроен |

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
| 2026-08-11 | Развёрнут Docker-стек; техничка фиксирует исторический список из 14 сервисов |
| 2026-08-11 | Настроен единый ed25519 SSH-ключ |
| 2026-08-26 | В Compose добавлен dbt; итоговая конфигурация объявляет 16 сервисов |
| 2026-09-21 | После чистки диска в последнем рабочем срезе запущено 9 контейнеров |
| 2026-09-28 | ВМ демонтирована; документ сохранён как историческая техничка |

---

## 🔗 СВЯЗАННЫЕ ВМ

| ВМ | IP | Роль |
|----|----|----|
| **k8s-master** | 85.208.87.114 | Kubernetes Control Plane |
| **k8s-worker-1** | 82.202.158.28 | Kubernetes Worker |
| **k8s-worker-2** | 176.108.248.13 | Kubernetes Worker |

---

**Автор:** Артур (MartinMinart)  
**Обновлено:** 2026-09-28