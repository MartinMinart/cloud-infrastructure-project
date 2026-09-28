# Аналитическая платформа на Cloud.ru — единая хронология проекта

**Автор:** Артур Минин (MartinMinart)
**Период работы:** июль — сентябрь 2026 (проект живёт с 12.07.2026)
**Дата составления:** 28.09.2026
**Цель проекта:** портфолио для позиций Data Analyst / Analytics Engineer / Data Engineer
**Статус:** функциональность заморожена 21.09.2026; инфраструктура демонтирована 28.09.2026 по корневому README
**Платформа:** Cloud.ru Evolution (бывш. СберКлауд), зона ru.AZ-2, VPC Default, SSH-ключ ed25519

> Документ объединяет шесть отчётов и сводит повторяющиеся записи; проверки качества данных собраны в разделе 10.

## Легенда пометок

- `[ФАКТ]` — зафиксировано в переписке, скриншотах, логах или файлах.
- `[ВЫВОД]` — реконструкция логики по последовательности работ.
- `[ГИПОТЕЗА]` — предположение, не подтверждено.
- `[РАСХОЖДЕНИЕ]` — неразрешённое расхождение источников; указано в разделе 10.

> Безопасность: IP-адреса оставлены по решению пользователя. Пароли, kubeadm-токены и хеши в публичном документе должны быть представлены плейсхолдерами (`<PASS>`, `<TOKEN>`, `<CA_HASH>`).

---

# 1. Резюме проекта

Развёрнута аналитическая платформа на 4 ВМ Cloud.ru в двух треках:

1. **BI-стек** на `devops-main` — Docker Compose с набором аналитических сервисов и доказанным ETL-пайплайном PostgreSQL → Airflow → ClickHouse → BI (Grafana/Metabase), плюс dbt-проект.
2. **Kubernetes-кластер** на 3 ВМ (`k8s-master` + 2 worker) — kubeadm v1.29.15, CNI Flannel, Helm, мониторинг `kube-prometheus-stack` (Prometheus + Grafana + Alertmanager).

Проверенные данные по SQL-дампу и зафиксированным отчётам запросов:

| Что | Значение |
|---|---|
| PostgreSQL `analytics_db_new` | 15 таблиц, `sales` = 10 000 записей (2024-01-01 … 2026-08-24) |
| Выручка по `sales` | Все статусы: **11 333 254,25 ₽**; только `completed`: **10 601 006,25 ₽** (сверено с SQL-дампом) |
| ClickHouse `default.sales_daily` | 30 000 строк, 11 колонок по README/отчёту; CSV sample содержит 100 строк |
| ClickHouse сервер | 26.7.3.19 |
| Airflow | DAG `etl_to_clickhouse`, 4 задачи, 3 успешных запуска |
| dbt | проект + staging-модель `stg_sales.sql`, контейнер `Exited (0)` |
| Kubernetes | 3 ноды Ready v1.29.15, Helm `kube-prometheus-stack-88.5.4` |
| Клиенты с завершёнными заказами | **5 914** (сверено с SQL-дампом) |
| Grafana | панель/отчёт: 10 000 заказов; денежная метрика зависит от фильтра статуса |
| Redis | PONG, ключи `cache:daily_revenue=238600` и др. |
| MinIO | бакет `analytics-backups` |

Известные проблемы — главная: **30 ГБ диск** на devops-main (достигала 98–100%). См. раздел 5.


## История проекта (одним текстом)

> Задача — создать аналитическую инфраструктуру на Cloud.ru → развернуть 4 финальные ВМ → собрать Kubernetes 1+2 (kubeadm, Flannel, Helm, мониторинг kube-prometheus-stack) → развернуть Docker Compose analytics stack → загрузить 10 000 продаж → оркестрировать ETL через Airflow → подготовить отдельный dbt-проект со staging-моделью → создать OLAP-слой ClickHouse (`sales_daily`, 30 000 строк по отчёту) → подключить Grafana → проверить Redis/MinIO/Node-RED → восстановить PostgreSQL из recovery, очистить Docker/containerd и починить Airflow → сохранить документацию и демонтировать ВМ. Выручку указывать с фильтром статуса.

## Ключевые цифры

10 000 заказов · 11 333 254,25 ₽ по всем статусам / 10 601 006,25 ₽ по `completed` · 1 133,31 ₽ средний чек `completed` · 5 914 клиентов с завершёнными заказами · 8 баз PostgreSQL (6 без шаблонов) · 15+7 таблиц · 30 000 строк в ClickHouse `sales_daily` (по отчёту) · 16 сервисов Compose (9 работали в последнем срезе) · 3 ноды K8s · 1 Helm-релиз · 9 ГБ освобождено при чистке диска · 5 идентификаторов ВМ создано, 4 финальные ВМ демонтированы.

## Что показано (навыки)

1. Инфраструктура: развернуть 10+ сервисов, диагностировать и починить диск 100% (Docker + containerd).
2. Data Engineering: PostgreSQL → dbt → ClickHouse, ETL через Airflow (DAG, retry, XCom).
3. BI: Grafana (панели), Metabase (подключение; дашборд доснять).
4. Platform: K8s кластер (kubeadm, Flannel, Helm, kube-prometheus-stack).
5. Инциденты: recovery PostgreSQL, чистка containerd, фикс DAG, экспорт перед сносом.
6. Автоматизация: PowerShell-скрипты (структура, конвертация BMP→PNG).

## Перед публикацией на GitHub

- [ ] Санитизация: все пароли → плейсхолдеры; kubeadm token/hash → `<TOKEN>`/`<CA_HASH>`; IP-адреса оставлены по решению пользователя; не публиковать private kubeconfig и секретные манифесты.
- [ ] Согласовать технички с Compose: 16 объявленных сервисов и 9 сервисов в последнем запуске.
- [ ] `.gitignore`, `git init`, первый коммит, push на GitHub.
- [x] Демонтаж четырёх финальных ВМ отражён в корневом README; факт удаления бэкапа и групп безопасности требует отдельного подтверждения.

---

# 2. Хронология создания

## 2.1. Ранние эксперименты (июнь — начало июля 2026)

Проекту предшествовали два контекста:

**Локальный pet-проект (кредитный риск МСБ).** Архитектура PostgreSQL + Airflow + dbt + Metabase + Grafana на локальной машине, рабочий портфель 1005 кредитов на 5.09 млрд ₽ (из отчёта). Это не переносилось в облако как данные, но дало стартовую архитектурную рамку.

**Первые шаги в облаках (Yandex Cloud → Cloud.ru).** Пробные ВМ через веб-консоль: `test-01` (Intel Cascade Lake, до 4 vCPU, 20–100 ГБ HDD; по факту Ubuntu 20.04/24.04, пользователь `ivan` через cloud-init). Пробовался Terraform (провайдер `yandex-cloud/yandex` v0.140.1): `terraform init/plan/apply/destroy`, cloud-init-шаблон. Это было предпроектное тестирование — итоговый стек создавался вручную в консоли Cloud.ru.

**Полезные уроки раннего этапа:**
- Одна подсеть = один CIDR (`v4_cidr_blocks = ["192.168.10.0/24"]`), для нескольких подсетей — отдельные `resource yandex_vpc_subnet`.
- `terraform providers lock -platform=linux_amd64` при warning про lock file.
- После санкций HashiCorp Terraform из РФ ставится через локальные зеркала/провайдер Yandex.
- `terraform destroy` удаляет всё без отката — нужен бэкап `terraform.tfstate`.
- SSH по ключу вместо пароля; при первом подключении — подтверждение fingerprint.
- GUI на Linux сервере не нужен: сервисы открываются через веб-интерфейсы по портам или SSH-туннели (`ssh -L 3000:localhost:3000 ivan@<IP>`).
- VS Code Remote-SSH ставится только на локальный Windows, на ВМ ничего не ставится.
- Security Group: порт 22 не держать открытым для `0.0.0.0/0`, разрешать SSH только со своего IP (bots ломают за минуты).

## 2.2. Сводная таблица ключевых дат

| Дата | Событие | Источник |
|---|---|---|
| 12.07.2026 | Созданы ВМ `devops-main`, `devops-k8s-master`, `devops-k8s-worker-1` | [README], биллинг |
| 12.07–31.07 | Настройка, тесты, эксперименты; расход гранта за июль **1 263,57 ₽** | биллинг |
| 12–26.07 | Развёртывание Docker Compose стека на devops-main (по README 14 сервисов) | [README] |
| 26.07.2026 | Инициализирован кластер K8s: containerd, `kubeadm init`, Flannel, Helm; подключён worker-1; тестовый nginx; установлен мониторинг Prometheus+Grafana. Helm-релиз повторно установлен 25.08 (revision 1, 22:28). | [README k8s-master], [скрин helm list] |
| 07.08.2026 | Создан бэкап `devops-main-backup` (14,5 ГБ); удалена ВМ `devops-main` (проблемы с SSH: RSA-ключ не работал из Windows); создан SSH-ключ `ssh-pk-ac8122` (ed25519) | биллинг, [README] |
| 11.08.2026 | Созданы `devops-main-new` (2vCPU/8ГБ/30ГБ) и `devops-k8s-worker-2`; заново развёрнут Docker-стек; все SSH-ключи переведены на ed25519 | биллинг, [README] |
| 25.08.2026 | Чистка кластера, Helm-релиз `monitoring` переустановлен (revision 1, updated 22:28); создан `database/` со схемами и бэкапом `analytics_db_backup_20260825.sql`; бэкапы compose; каталог `metabase/` | даты файлов |
| 25.08–26.08 | Массовые перезагрузки: Reboot ×8 по всем ВМ (отладка); 26.08 — все выключены на ночь; 27.08 — включены | биллинг |
| 26.08.2026 | Добавлен dbt (`docker-compose.yml.dbt-backup` 14:26, итоговый compose 14:45, `dbt/` 14:34); `.env` 13:12; DAG `etl_to_clickhouse` — 3 успешных запуска (09:53 и 11:23 UTC) | даты файлов, [скрин Airflow] |
| 27.08.2026 | Файл `medical_analytics_interview.sql` (25 КБ); последний логин на k8s-нодах | даты файлов |
| 08.09.2026 | Диск devops-main 94,8%; перезапуск Docker; `docker compose up -d` (подтянулся dbt-образ); на ПК создана папка `analytics-platform-cloudru/screenshots`; сняты скрины K8s (nodes, pods, svc, helm) | [скрин], [лог] |
| 21.09.2026 | Финальная сессия: диск 100%, глубокая чистка (9 ГБ), восстановление PostgreSQL из recovery, починка Airflow, скриншоты, планы экспорта/сноса. Решение: проект заморожен, функциональность больше не добавляем | переписка 21.09 |
| 23.09 / 28.09 | 28.09 снимок Kubernetes показывает ноды `Ready` в 12:26 UTC; корневой README сообщает о последующем демонтаже инфраструктуры в этот день. | `manifests/nodes.yaml`, корневой README |

## 2.3. Детальная хронология по этапам

### Этап 0. Постановка задачи (август 2026)
[ФАКТ] Исходная идея — не просто «поднять PostgreSQL», а полноценная учебная аналитическая инфраструктура на Cloud.ru с двумя треками: BI-стек на основной ВМ и Kubernetes-кластер с мониторингом. Цель — портфолио, демонстрация полного цикла: инфраструктура → данные → ETL → BI.

### Этап 1. Создание ВМ и базовой настройки (12.07.2026)
[ФАКТ] Созданы первые ВМ вручную в веб-консоли Cloud.ru (Elastic Cloud Server):
- `devops-main` — 2 vCPU / 4 ГБ / 30+50 ГБ (BI-стек)
- `devops-k8s-master` — 2 vCPU / 4 ГБ / 30 ГБ (control-plane)
- `devops-k8s-worker-1` — 1 vCPU / 2 ГБ / 30 ГБ (worker)

Ubuntu 22.04.5 LTS, kernel 5.15.0-190. SSH-доступ сначала настраивался через `id_rsa` и SSH-конфиг на ПК (`C:\Users\MI\.ssh\config`), VS Code Remote-SSH; позже все ВМ переведены на единый ключ ed25519 (из отчёта). `[ФАКТ]`.

### Этап 2. Docker Compose стек на devops-main (12–26.07.2026)
[ФАКТ] Развёрнут стек аналитических сервисов (по README — 14). Полный состав и порты — раздел 3.3. Стартовые вопросы: установка Docker, где писать команды (терминал VS Code vs PowerShell), как открыть порты в Cloud.ru.

Порядок работ (из отчёта):
1. Установка Docker (`curl -fsSL https://get.docker.com | sudo sh`; `sudo usermod -aG docker user1`).
2. Подготовка ВМ к K8s: disable swap, модули `overlay`/`br_netfilter`, sysctl (`net.bridge.bridge-nf-call-iptables` и др.).
3. containerd: `containerd config default`, `SystemdCgroup = true`.
4. Параллельно на master — Kubernetes (этап 3).

### Этап 3. Kubernetes (26.07.2026)
[ФАКТ] Ключевые шаги на всех трёх нодах / на master:
1. Отключение SWAP (`sudo swapoff -a`, комментарий строки swap в `/etc/fstab`).
2. Модули ядра `overlay`, `br_netfilter`; sysctl `net.ipv4.ip_forward=1`.
3. containerd с `SystemdCgroup=true`.
4. Установка `kubelet kubeadm kubectl` v1.29 (репозиторий `pkgs.k8s.io`, `--allow-change-held-packages`), `apt-mark hold`.
5. `sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.0.0.6 --kubernetes-version=v1.29.0`
6. Настройка kubectl (`/etc/kubernetes/admin.conf` → `~/.kube/config`).
7. CNI Flannel: `kubectl apply -f .../kube-flannel.yml` → master `Ready`.
8. Подключение worker-ов: `sudo kubeadm join 10.0.0.6:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<CA_HASH>` → worker-1 `Ready`; worker-2 подключили позднее.
9. Тестовый деплой: `kubectl create deployment nginx --image=nginx`, `kubectl expose deployment nginx --port=80 --type=NodePort` → проверка `http://82.202.158.28:32616` («Welcome to nginx!»).
10. Helm 3 (`get-helm-3` скрипт).
11. Мониторинг: `helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace`. Пароль Grafana — из секрета `app.kubernetes.io/component=admin-secret`, доступ через `kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80`.

Снимок кластера от 21.09 показывает 3 ноды `Ready` v1.29.15. В `namespaces.yaml` зафиксированы `default`, `kube-flannel`, `kube-node-lease`, `kube-public`, `kube-system`, `kubernetes-dashboard`, `monitoring` и `test-app`. Релиз Helm `monitoring` повторно установлен 25.08 (revision 1); точное первоначальное состояние отражено в истории выше.

### Этап 4. Проблемы и восстановление (07–11.08.2026)
[ФАКТ] Что случилось:
1. **Worker-2 перестала подключаться** — SSH timeout.
2. **devops-main сломался** — пришлось пересоздать ВМ (SSH-ключ RSA не работал из Windows).
3. **Диск на devops-main заполнился** — 95–96%.

Решения:
- Создана новая ВМ `devops-main-new` (213.171.26.123, 2vCPU/8ГБ) вместо старой `devops-main` (85.208.86.103).
- Создан новый SSH-ключ `id_ed25519` (безопаснее RSA).
- Worker-2 пересоздана — актуальный публичный IP `176.108.248.13` (README, WinSCP guide); старый IP относится к прежней ВМ.
- Все SSH-ключи заменены на ed25519.
- На 07.08 остался «мёртвый» ресурс: бэкап `devops-main-backup` (14,5 ГБ) — подлежит удалению.

### Этап 5. Работа с данными (25–27.08.2026)
[ФАКТ] Созданы схемы и данные:
- `database/schemas/` — скрипты 01–07 (create_tables, load_categories/suppliers/products/branches/employees/customers).
- `scripts/` — набор SQL (`retail_schema.sql`, `create_sales_final.sql`, `load_orders*.sql`, `load_supplies.sql`, `fix_categories.sql`, `insert_data.sql` и др.).
- БД `analytics_db_new`: 15 таблиц, `sales` = 10 000 записей (2024-01-01…2026-08-24).
- БД `medical_analytics`: 7 таблиц, ~5000 записей (данные медицины для тренировки SQL и собеседования; файл `medical_analytics_interview.sql` 27.08).
- Настроено подключение в DBeaver; отработаны JOIN, CTE, оконные функции, `EXPLAIN ANALYZE`.

### Этап 6. Подготовка к собеседованию (27–28.08.2026)
[ФАКТ] Кандидатское направление: аналитик данных (ГБУЗ ПКБ №1 им. Н.А. Алексеева, от 150 000 ₽). Подготовка: самопрезентация 45 сек, разбор вероятных вопросов, SQL-тренажёр с 10 задачами, сравнение PostgreSQL vs ClickHouse. Это внешний контекст проекта; инженерно это выражено появлением датасета `medical_analytics`.

### Этап 7. Эксплуатация и борьба с диском (08.09–23.09.2026)
- 08.09: диск 94,8%, перезапуск Docker, повторный `docker compose up -d` (допуль образов), скриншоты K8s.
- 21.09: диск 100% (188 МБ свободно), PostgreSQL в recovery — детальный сценарий ниже.
- 23.09: ВКЛ/ВЫКЛ; 28.09: снимок нод `Ready` в 12:26 UTC, затем демонтаж ВМ по корневому README.

### Этап 8. Финальная сессия 21 сентября 2026 (пошагово)
[ФАКТ] Решение пользователя: «проект уже достаточно хороший, больше функциональность не добавляем» — перевод в режим «замораживаем → документируем → сохраняем → закрываем инфраструктуру».

1. **Обнаружение** → диск на devops-main 98–100%.
2. **K8s-проверка параллельно** → кластер стабилен, 3 ноды Ready.
3. **Чистка Docker** → `docker compose stop superset redash nifi mongodb qdrant kafka`; `docker container prune -f` (878,5 МБ); `docker image prune -a -f` (7,862 ГБ); `docker builder prune -a -f`; truncate json-логов контейнеров; `journalctl --vacuum-size=50M`; `apt clean && apt autoremove --purge -y`; чистка `~/.cache`. Итог: 98,9% → ~65–73%.
4. **Ошибка:** сразу после чистки `docker compose up -d` (без списка сервисов) перетянул 7 образов (redash, kafka, nifi, superset, mongo, dbt-postgres, qdrant) → диск снова 100%. `docker compose ps` = 16 контейнеров.
5. **Повторная чистка + минимальный запуск:** `docker compose stop`; `docker rmi ...` (молча не сработало из-за порядка и `2>/dev/null`); `docker volume rm analytics-stack_superset_home ...`; `docker rm -f` тяжёлых контейнеров; `docker compose up -d postgres clickhouse redis metabase minio airflow airflow-scheduler grafana node-red` → 9 контейнеров Up, но диск остался ~98% (образы на месте).
6. **Чистка containerd (ключевой шаг):** `sudo ctr -n moby images prune --all` → `/var/lib/containerd` с 18 ГБ до 9 ГБ; `df -h` → диск разгружен.
7. **PostgreSQL в recovery mode:** из-за «No space left on device» при checkpoint (PANIC на `pg_logical/replorigin_checkpoint.tmp`, `postmaster.pid`, «database system is in recovery mode»). После освобождения места сам прошёл recovery («database system is ready to accept connections»). Все 8 БД на месте.
8. **Проверка БД:** 6 пользовательских + `template0/template1`; 15 + 7 таблиц; `sales` = 10000; выручка 11 333 254,25 ₽.
9. **Починка Airflow:**
   - `ModuleNotFoundError: No module named 'clickhouse_connect'` → 3 неудачные попытки (`pip` не в PATH, `--user` запрещён, pip от root заблокирован) → успех: `docker exec -u 0 -it airflow python -m pip install clickhouse-connect`.
   - DAG не появлялся в UI → `docker restart airflow airflow-scheduler`, `airflow dags list`.
   - Соединение `postgres_default` вело не туда → `airflow connections delete postgres_default` + `airflow connections add` (host `analytics-postgres`, schema `analytics_db_new`, port 5432). DAG `etl_to_clickhouse` запущен успешно.
  - 21.09 около 19:50 UTC ручной запуск DAG упал на `load_to_clickhouse`; причина не расследована.
10. **Grafana:** в отчёте зафиксирована панель Stat с 10 000 заказов и выручкой 11 333 254 ₽. Отдельный старый скрин показывает 13 заказов / 12 638 ₽ при узком временном окне.
11. **Скриншоты всех сервисов** (Grafana, Redis, MinIO, Node-RED, Airflow, K8s nodes/pods/svc/helm).
12. **Бэкапы БД:** `~/backups/all_databases.sql` (51 МБ), `analytics_db_new.sql` (5,7 МБ), `medical_analytics.sql` (713 КБ), schema-only. В MinIO — только `test_backup.sql` (60 байт).
13. **Стоп ВМ** до следующего дня; план экспорта и сноса — раздел 9.

### Этап 9. План завершения (после 21.09)
Порядок (сформулирован пользователем): стабилизировать → сохранить → проверить README → финальный архив → удалить Cloud.ru VM. Детали: экспорт дампов/конфигов/манифестов через `scp`, санитизация паролей, `git init`/push, удаление 4 ВМ с «Удалить связанные ресурсы», удаление групп безопасности `SSH-access_ru.AZ-1`, `AZ-3`, `sg-ffd1ca`, проверка биллинга на следующий день.

## 2.4. Периоды включения ВМ

**График ВКЛ/ВЫКЛ (по биллингу):**

| Дата | Операция | Комментарий |
|---|---|---|
| 12.07–31.07 | ВКЛ периодически | Настройка, тесты, эксперименты |
| 07.08 | — | Удалена `devops-main` (08.08 был её бэкап) |
| 25–26.08 | Reboot ×8 | Массовые перезагрузки (отладка) |
| 26.08 | ВЫКЛ ×4 | На ночь |
| 27.08 | ВКЛ ×4 | Снова |
| 08.09 | ВКЛ → ВЫКЛ | Перерыв |
| 21.09 | ВКЛ → консоль k8s-master → ВЫКЛ | Финальная сессия |
| 23.09 | ВКЛ → ВЫКЛ | — |
| 28.09 | Снимок кластера `Ready` в 12:26 UTC; README фиксирует последующий демонтаж ВМ в этот день | Точное время демонтажа в репозитории не указано |

## 2.5. Общий порядок этапов проекта (склейка)

1. Провижининг ВМ (Cloud.ru Evolution, зона ru.AZ-2, VPC Default, SSH-ключ ed25519).
2. Kubernetes: подготовка нод → kubeadm init → Flannel → Helm → kube-prometheus-stack (+ Kubernetes Dashboard, тестовый nginx).
3. Docker Compose стек на devops-main: PostgreSQL, ClickHouse, Redis, MinIO, Metabase, Grafana, Node-RED, Airflow (+ Superset, Redash, NiFi, Kafka, MongoDB, Qdrant — эксперименты).
4. Данные: `retail_schema.sql`, загрузчики, БД `analytics_db_new` (15 таблиц, 10 000 продаж) + `medical_analytics`.
5. ETL: DAG `etl_to_clickhouse` (Postgres → ClickHouse `sales_daily`).
6. dbt: staging-модель `stg_sales.sql` (marts пуст).
7. BI/проверки: Metabase, Grafana (панель на Postgres), Redis (кэш-ключи), MinIO (бакет), Node-RED (flow inject → debug).
8. Борьба с диском (08.09 и 21.09).
9. Скриншоты, экспорт и документация; ВМ демонтированы 28.09 по корневому README.

---

# 3. Инфраструктура

## 3.1. Виртуальные машины

| ВМ | Публичный IP | Внутр. IP | Ресурсы | Роль | Создана | Статус |
|---|---|---|---|---|---|---|
| devops-main | 85.208.86.103 | 10.0.0.5 | Требует уточнения: параметры старой ВМ не указаны в техничке | BI-стек | 12.07 | Удалена 07.08 |
| devops-main-new | 213.171.26.123 | 10.0.0.5 | 2 vCPU / 8 ГБ / 30 ГБ SSD | BI-стек | 11.08 | Демонтирована 28.09 (по README) |
| devops-k8s-master | 85.208.87.114 | 10.0.0.6 | 2 vCPU / 4 ГБ / 30 ГБ SSD | control-plane | 12.07 | Демонтирована 28.09 (по README) |
| devops-k8s-worker-1 | 82.202.158.28 | 10.0.0.7 | 1 vCPU / 2 ГБ / 30 ГБ SSD | worker | 12.07 | Демонтирована 28.09 (по README) |
| devops-k8s-worker-2 | 176.108.248.13 | 10.0.0.9 | 2 vCPU / 8 ГБ / 30 ГБ SSD | worker | 11.08 (пересоздана) | Демонтирована 28.09 (по README) |

Итого: **создано 5 идентификаторов ВМ**; исходная `devops-main` удалена 07.08, после пересоздания в финальном окружении работали 4 ВМ. Снимок `nodes.yaml` показывает ноды `Ready` 28.09 в 12:26 UTC, а корневой README сообщает о последующем демонтаже в тот же день. Точное время демонтажа в репозитории не указано.

## 3.2. Версии и ключевые компоненты

| Компонент | Версия | Источник |
|---|---|---|
| ОС | Ubuntu 22.04.5 LTS (kernel 5.15.0-190) | лог |
| Docker | 29.6.2 на Kubernetes-нодах; версия на `devops-main-new` в проверяемых источниках не указана | worker README, `docs/k8s-master-tech.md` |
| containerd | CRI runtime, `SystemdCgroup=true` | лог |
| Kubernetes | v1.29.15 (init заявлен `--kubernetes-version=v1.29.0`) | скрин |
| CNI | Flannel (`10.244.0.0/16`) | конфиг |
| Helm | v3.21.3 | `docs/k8s-master-tech.md`, `docs/k8s-cluster-setup.md` |
| kube-prometheus-stack | 88.5.4 (app v0.93.1) | helm list |
| PostgreSQL | `postgres:15-alpine` | compose |
| ClickHouse | 26.7.3.19 | запрос |
| Airflow | 2.10.0, LocalExecutor | compose |
| Metabase/Grafana/etc. | `latest` | compose |

## 3.3. Docker Compose — сервисы и порты (devops-main)

В `configs/docker-compose.yml` объявлено **16 сервисов**. Последний зафиксированный запуск после чистки 21.09 включал 9 работающих сервисов; это исторический срез, а не текущий статус ВМ.

| Сервис (service) | container_name | Порт | Назначение | Статус |
|---|---|---|---|---|
| postgres | analytics-postgres | 5432 | Реляционное хранилище | Работал в последнем срезе 21.09 |
| clickhouse | analytics-clickhouse | 8123, 9005→9000 | Колоночная OLAP | Работал в последнем срезе 21.09 |
| redis | analytics-redis | 6379 | Кэш | Работал в последнем срезе 21.09 |
| metabase | analytics-metabase | 3000 | BI | Контейнер работал; сохранённый дашборд не подтверждён |
| minio | analytics-minio | 9001, 9105 | S3-хранилище | Работал в последнем срезе 21.09 |
| airflow | airflow | 8080 | Оркестрация ETL | Работал в последнем срезе 21.09 |
| airflow-scheduler | airflow-scheduler | — | Scheduler | Работал в последнем срезе 21.09 |
| grafana | grafana | 3001 | Мониторинг/BI | Работал в последнем срезе 21.09 |
| node-red | node-red | 1880 | Визуальные потоки | Работал в последнем срезе 21.09 |
| dbt | analytics-dbt | — | Трансформации | `Exited (0)`; запускается по требованию |
| superset | analytics-superset | 8088 | BI-визуализация | Остановлен; не входил в набор из 9 запущенных после чистки |
| redash | redash | 5000 | SQL-запросы | Остановлен после Internal Server Error |
| kafka | analytics-kafka | 9092 | Потоковые данные | Остановлен; pub/sub не проверен |
| nifi | nifi | 8443 | Потоковая обработка | Удалён из активного набора после проблем с HTTPS |
| mongodb | mongodb | 27017 | NoSQL | Удалён из активного набора после `Restarting (139)` |
| qdrant | analytics-qdrant | 6333 | Векторная БД (RAG) | Остановлен; API key не настроен |

Правило доступа: для внешнего доступа открывалось в ЛК Cloud.ru (Security Group): 3000, 3001, 5000, 5050, 5678, 6333, 8080, 8088, 8123, 8443, 9001, 9002, 9092, 1880 (источник `0.0.0.0/0`).

Redis настроен без volume, поэтому ключи не сохраняются при пересоздании контейнера.

## 3.4. Kubernetes — содержимое кластера

- На снимке `manifests/nodes.yaml` от 28.09.2026 12:26 UTC все три ноды (`devops-k8s-master`, `devops-k8s-worker-1`, `devops-k8s-worker-2`) имели статус `Ready`, версия kubelet v1.29.15.
- Namespaces по `manifests/namespaces.yaml`: `default`, `kube-flannel`, `kube-node-lease`, `kube-public`, `kube-system`, `kubernetes-dashboard`, `monitoring`, `test-app`.
- `monitoring`: Prometheus, Alertmanager, Grafana (3/3), kube-state-metrics, 3× node-exporter, operator.
- Тестовые deployment/NodePort упоминаются в отчётах; указанные manifests фиксируют namespaces, но не подтверждают наличие этих workloads в финальном снимке.
- Helm: релиз `monitoring` (kube-prometheus-stack-88.5.4, deployed, revision 1, updated 2026-08-25 22:28).
- Заметны рестарты подов 4–12 за «82 минуты» (ноды перезагружались).
- `kubectl delete namespace minio` выполнялся (namespace minio создавали/удаляли).
- kubeconfig: на ВМ `~/.kube/config`; локально экспортирован `private-kubeconfig.yaml`.

## 3.5. Как устанавливался стек (пошагово, по отчётам)

Подготовка всех нод:
```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay && sudo modprobe br_netfilter
sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system
```

Docker:
```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io
```

containerd:
```bash
sudo systemctl stop containerd
sudo sh -c 'containerd config default > /etc/containerd/config.toml'
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl start containerd && sudo systemctl status containerd
```

Kubernetes:
```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm kubectl --allow-change-held-packages
sudo apt-mark hold kubelet kubeadm kubectl
```

Master:
```bash
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address=10.0.0.6 \
  --kubernetes-version=v1.29.0
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

Workers:
```bash
sudo kubeadm join 10.0.0.6:6443 --token <TOKEN> \
  --discovery-token-ca-cert-hash sha256:<CA_HASH>
```

Helm + monitoring:
```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh && ./get_helm.sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80
kubectl get secret --namespace monitoring -l app.kubernetes.io/component=admin-secret \
  -o jsonpath="{.items[0].data.admin-password}" | base64 --decode ; echo
```

---

# 4. Данные и проверенные результаты

## 4.1. PostgreSQL

- Сервис: `postgres`, контейнер `analytics-postgres`, образ `postgres:15-alpine`, схема БД пользователя `analytics`.
- В перечне 6 БД без шаблонов: `airflow_db`, `analytics_db`, `analytics_db_new`, `medical_analytics`, `metabase_db`, `postgres` (последняя — стандартная служебная БД PostgreSQL); плюс `template0` и `template1`, всего 8.
- `analytics_db_new` — 15 таблиц: branches, categories, customers, employees, inventory, products, products_new, promotions, sale_details, sales, sections, suppliers, supplies, supply_details, work_schedule.
- `sales` — **10 000 записей**, диапазон **2024-01-01 … 2026-08-24**.
- Выручка всех заказов `SUM(total_amount)` = **11 333 254,25 ₽**; только `status = 'completed'` = **10 601 006,25 ₽**.
- В дампе 9 354 завершённых заказа; средний чек для них **1 133,31 ₽**. Уникальных клиентов с завершёнными заказами — **5 914** (6 152 клиента по всем статусам).
- `medical_analytics` — 7 таблиц: appointments, branches, departments, doctors, patients, payments, services (≈5000 записей).
- SQL-практика на датасете: JOIN, CTE, оконные функции, экспорт `\COPY ... CSV`.

## 4.2. ClickHouse

- Сервер 26.7.3.19; базы: `INFORMATION_SCHEMA`, `default`, `information_schema`, `medical_analytics_ch`, `system`.
- Таблица `default.sales_daily` (MergeTree, `ORDER BY (sale_date, category_id, branch_id)`), 11 колонок:
  `sale_date, category_id, category_name, branch_id, branch_name, city, total_orders, total_revenue, avg_order_value, unique_customers, created_at`.
- **30 000 строк** — значение из BI README и отчёта запроса после трёх успешных запусков.
- Сохранённый CSV — sample из 100 строк с датами `2024-12-30`–`2025-01-01`; первые три строки повторяют одни измерения и показатели с разным `created_at`. Sample не подтверждает максимальную дату полной таблицы.
- В отчёте запроса по полной таблице указаны min `2024-12-30`, max `2026-08-24`; воспроизвести эти границы по имеющемуся sample нельзя.
- Повтор первых трёх строк и отношение 30 000 / 10 000 указывают на возможное повторное добавление результата DAG. Полную степень дублирования нужно проверить запросом `SELECT count(), uniqExact(sale_date, category_id, branch_id) FROM default.sales_daily`.
- `medical_analytics_ch` — база есть, данных нет (в ClickHouse медицина не загружена: не хватило места на диске).

## 4.3. Airflow

- Версия 2.10.0, LocalExecutor, metadata БД — PostgreSQL.
- DAG `etl_to_clickhouse.py`: 4 задачи `create_clickhouse_tables → extract_aggregated_data → load_to_clickhouse → check_clickhouse_data`, все PythonOperator, `Schedule: None` (ручной запуск).
- 3 успешных запуска 26.08 (7–8 сек). 21.09 ~19:50 UTC — запуск упал на `load_to_clickhouse` [совпадает с диском 100%; не расследовано].

## 4.4. dbt

- Структура: `dbt/dbt_project.yml`, `dbt/models/staging/stg_sales.sql`; `marts` пуст.
- Контейнер `analytics-dbt` последний запуск `Exited (0)`.
- [ВЫВОД] dbt не интегрирован в Airflow (в DAG нет dbt-задач) и marts не реализованы — корректная формулировка: «настроен dbt-проект со staging-моделью».

## 4.5. BI-слой

- **Grafana** (3001): datasource PostgreSQL подключён; панель Stat с правильным SQL:
  ```sql
  SELECT COUNT(*) AS orders, SUM(total_amount) AS revenue FROM sales;
  ```
  → **10000 orders / 11 333 254 revenue**. Важно: для Stat-panel SQL без `GROUP BY`; панель с `GROUP BY day` + узкое окно давали ложные «13 заказов / 12 638».
- **Metabase** (3000): запуск и подключение к PostgreSQL описаны, но в репозитории нет подтверждённого Metabase-дашборда или его скриншота; отчёт фиксирует проблему с `core_user` и Setup Wizard. Это главный пробел BI-демонстрации. Не путать с панелями Grafana.
- **Superset** (8088): «не использовался» (не открывался).
- **Redash** (5000): Internal Server Error.

## 4.6. Инфраструктурные сервисы

- **Redis** (6379): `PING` → PONG. В отчётах записаны временные тестовые ключи; после пересоздания контейнера `KEYS *` возвращал пустой список, так как у сервиса нет volume. Статус `production-ready` был тестовым значением, не оценкой проекта.
- **MinIO** (9001/9105): бакет `analytics-backups`, файл `test_backup.sql` (60 байт). [ВЫВОД] реальный дамп не залит.
- **Node-RED** (1880): flow `Inject → Debug` с JSON-результатом.

---

# 5. Проблемы и их решения (единая таблица)

Группа «диск / Docker»:

| # | Проблема | Симптом | Причина | Решение / статус |
|---|---|---|---|---|
| 1 | Диск 98.9–100% на devops-main (30 ГБ) | Postgres падал, «No space left on device»; `df: 188M available` | 15 образов ≈16,85 ГБ (7,74 ГБ reclaimable) + containerd-слои ~9 ГБ + volumes 2,7 ГБ на 30 ГБ | `docker image prune -a -f` (7,9 ГБ) + `ctr -n moby images prune --all` (9 ГБ) + чистка логов (0,9 ГБ); 100% → 65–73% |
| 2 | `docker compose up -d` перекачал удалённые образы | Сразу после чистки диск снова 100% | Compose без списка сервисов поднимает всё и тянет образы (redash, kafka, nifi, superset, mongo, qdrant, dbt) | Поднимать только нужные: `docker compose up -d postgres clickhouse redis metabase minio airflow airflow-scheduler grafana node-red`; либо `profiles:` |
| 3 | `docker rmi` не удалил образы | Образы всё ещё в `docker images` | `rmi` до удаления контейнеров; ошибки скрыты `2>/dev/null` | Порядок: `docker rm -f` → `docker rmi` → `docker volume rm`; ошибки не прятать. На последний лог образы так и не удалены |
| 4 | containerd дублирует хранилище Docker | `/var/lib/containerd` 18 ГБ | Docker 2.0 хранит образы в containerd (namespace `moby`) | Главная команда: `sudo ctr -n moby images prune --all` (18→9 ГБ) |
| 5 | 30 ГБ мало для стека | Регулярные 95–100% | Слишком много тяжёлых образов на маленьком диске | Базовая грабля проекта; требовать ≥100 ГБ либо уменьшать стек |

Группа «PostgreSQL»:

| # | Проблема | Симптом | Причина | Решение / статус |
|---|---|---|---|---|
| 6 | PostgreSQL в recovery mode | `PANIC: could not write to file "pg_logical/replorigin_checkpoint.tmp": No space left on device`; `FATAL: the database system is in recovery mode`; `rejecting connections` | WAL-checkpoint не записался при полном диске | Освободить место → PG сам прошёл recovery, все 8 БД на месте. Урок: бэкап `pg_dumpall` был сделан заранее |
| 7 | Образ `postgres:15-alpine` пропал | Postgres не стартовал | `docker image prune -a` удаляет образы остановленных сервисов | `docker pull postgres:15-alpine` |
| 8 | Шум в логах каждые 10 сек | `FATAL: database "analytics" does not exist` | healthcheck `pg_isready -U analytics` без `-d` | Безвредно; лечится `-d postgres` в healthcheck |
| 9 | `n_live_tup = 0` у таблиц при 10 000 строк | Кажется, что таблицы пусты | Статистика сброшена после crash-recovery | Считать через `SELECT COUNT(*)`, при желании `ANALYZE` |

Группа «Airflow»:

| # | Проблема | Симптом | Причина | Решение / статус |
|---|---|---|---|---|
| 10 | `could not translate host name "postgres"` | Ошибка старта | Postgres остановлен/упал | Перезапуск Airflow → Up |
| 11 | `ModuleNotFoundError: No module named 'clickhouse_connect'` | DAG import error | библиотека не в контейнере | 3 неудачные попытки → успех: `docker exec -u 0 -it airflow python -m pip install clickhouse-connect` |
| 12 | DAG не появлялся в UI | — | Кэш webserver | `docker restart airflow airflow-scheduler`; `airflow dags list` |
| 13 | Connection вёл не туда | Ошибки доступа к PG | Старое значение host `postgres` | `airflow connections delete postgres_default` + `add` (host `analytics-postgres`) |
| 14 | Ручной запуск DAG 21.09 упал | Красный граф, `check_clickhouse_data` upstream_failed | [ГИПОТЕЗА] диск 100% в 23:00 | Не расследовано; смотреть логи задачи |

Группа «BI / сервисы»:

| # | Проблема | Симптом | Причина | Решение / статус |
|---|---|---|---|---|
| 15 | Metabase не зайти | `core_user` пустая, ERR_EMPTY_RESPONSE | Ошибка инициализации после сброса | Перезапуск, проверка PG; в одном из отчётов указано, что настройку решили отложить; дашборд не подтверждён |
| 16 | Grafana пароль не подходит | Не входил | Пароль из секрета/значения рассинхронизированы | В отчёте указана попытка сброса CLI; фактический пароль здесь не приводится |
| 17 | Grafana «13 заказов / 12 638» | Панель мало данных | SQL с `GROUP BY` + узкий диапазон (6 ч) | Правильный Stat-SQL без GROUP BY + Last 5 years |
| 18 | redis-cli ошибки на `#` | `ERR unknown command '#'`, `Invalid argument(s)` | Многострочная вставка с комментариями | Выполнять построчно |
| 19 | Redis-ключи пропали | `KEYS *` пуст | У сервиса нет `volumes:` | Переснять; добавить volume для персистентности |
| 20 | NiFi → SSL Error | HTTPS required | Требует настройки TLS | Отложено; NiFi исключён из финала |
| 21 | MongoDB → Restarting (139) | crash-loop | Мелкая ошибка конфигурации | Удалён из стека |
| 22 | Redash → Internal Server Error | 500 | Не настроен | Отложено |
| 23 | Qdrant API key не сработал | — | — | Отложено |
| 24 | Kafka pub/sub не тестирован | — | Не хватило времени | Отложено |
| 25 | Контейнеры crash-loop: `analytics-dbt` (Restarting 0), `nifi` | Restarting | dbt запускается командой без аргументов | dbt → `Exited (0)`; nifi удалён |
| 26 | Порты не доступны извне | Сервисы есть, браузер не открывает | Security Group не разрешает | В ЛК добавить правила на порты; ждать 1–2 мин |

Группа «Kubernetes / SSH / прочее»:

| # | Проблема | Симптом | Причина | Решение / статус |
|---|---|---|---|---|
| 27 | Worker-2 не подключается к кластеру | Не в списке нод | Сеть/SG; потом — пересоздание ВМ | Открыть порт 22 в SG, перезагрузить; на раннем этапе работали с master и worker-1; позднее worker-2 пересоздана и подключена (3 Ready) |
| 28 | SSH-ключ не работал на devops-main | `Identity file ... not accessible`, `Connection reset by <IP> port 22` | Ключ был на ПК, использовался Windows-путь внутри Linux; RSA не подходил | Новый ключ `id_ed25519`, добавлен в `authorized_keys` на все ВМ, обновлён конфиг `IdentityFile C:/Users/MI/.ssh/id_ed25519` |
| 29 | Пароли в открытом виде | Пароли или base64-значения в черновых конфигурациях | Часть значений хранилась вне `.env` | Заменить найденные значения плейсхолдерами и сменить раскрывавшиеся пароли до публикации |
| 30 | README vs реальность | Состав сервисов и статусы расходились с последним снимком | Документация обновлялась в разные даты | Указывать конфигурацию Compose отдельно от числа реально запущенных сервисов |

---

# 6. Архитектурные решения и обоснование

> Важно: часть формулировок «почему X» не зафиксирована пользователем — помечено [ВЫВОД]. Перед собеседованием стоит вписать собственные мотивы.

| Решение | Обоснование | Альтернативы (рассмотрены) |
|---|---|---|
| PostgreSQL | OLTP + staging; транзакции, JOIN, оконные функции/CTE; совместим с Airflow, Metabase, dbt из коробки; лёгкий образ 15-alpine (~110 МБ); один инстанс — данные и метаданные (airflow_db, metabase_db) | MySQL (слабее для аналитики), Oracle (дорого) |
| ClickHouse | Колоночный OLAP; агрегации на больших объёмах (субсекундные); MergeTree сжатие ~10x и партиционирование; демонстрация разделения OLTP/OLAP | Greenplum (сложнее), Vertica (дорого) |
| Airflow | Стандарт оркестрации ETL/ELT; Python-DAG, визуальный граф, мониторинг; в DAG — retry logic (2 попытки, 5 мин), XCom между тасками | Prefect (менее зрелый), Luigi (устаревший) |
| dbt | SQL-трансформации с версионированием, тестами (unique, not_null), распределённой документацией/lineage, `ref()` | Spark SQL (избыточен для объёмов), Stored Procedures (нет версионирования) |
| Docker Compose для BI-стека | 16 сервисов объявлено в конфигурации; 9 были запущены после чистки 21.09. Compose проще K8s для stateful-BI без масштабирования | Kubernetes для BI (избыточен, оверхед) |
| Kubernetes 1 master + 2 worker | Минимальная HA-топология: control plane + рабочие ноды; демонстрация kubeadm, CNI, Helm, распределения подов, мониторинга | 1+1 (нет отказоустойчивости), 3+3 (дорого для pet-проекта) |
| kube-prometheus-stack через Helm | Готовый мониторинг Prometheus+Grafana+Alertmanager одной командой | Datadog (дорого), New Relic (облачный) |
| Разделение на 2 кейса (BI-стек / K8s) | Разные компетенции (Data/Analytics Eng vs DevOps/Platform Eng); хаб-документация со ссылками на подпроекты | Один монолит-описание (хуже читается, сложно подать два навыка) |

**Схема аналитического ядра:**

```text
                ┌───────────────┐
                │   PostgreSQL  │  (sales, 15 таблиц; medical_analytics, 7 таблиц)
                └───────┬───────┘
                        │
                  Airflow ETL ── DAG etl_to_clickhouse (4 таска)
                        │
                       dbt ── staging/stg_sales.sql (заготовка)
                        │
                        ▼
                ┌───────────────┐
                │   ClickHouse  │  default.sales_daily (30 000 строк)
                └───────┬───────┘
              ┌─────────┼───────────┐
              ▼         ▼           ▼
           Grafana   Metabase    Superset
       (панель есть)  (нет дашборда)   (не использован)
```

**Инфраструктурное окружение:** Redis (кэш), MinIO (S3), Kafka, Qdrant, MongoDB, NiFi, Node-RED — демонстрационная/учебная роль, в DWH-пайплайн не включены (честное позиционирование, см. раздел 8).

---

# 7. «Грабли» и уроки (топ для портфолио)

1. **Один том datacenter** — 30 ГБ на Если-стек = системная недооценка размера диска. Docker-образы — главный потребитель.
2. **`container_name` ≠ compose service name.** `docker compose up -d analytics-postgres` → `no such service`. В Compose — имя сервиса, в `docker exec` — имя контейнера.
3. **Полный `docker compose up -d` возвращает тяжёлые сервисы.** После чистки освободили место → запустили весь Compose → образы скачались → диск забит. Лечение: запуск только нужного списка сервисов или `profiles:`.
4. **Порядок удаления:** `docker rm -f` → `docker rmi` → `docker volume rm`. Ошибки не прятать (`2>/dev/null` скрыл проблему).
5. **containerd** хранит дубликаты образов: чистить `sudo ctr -n moby images prune --all`.
6. **Не удалять volumes** вместе с контейнерами до backup — особенно PostgreSQL, ClickHouse, Metabase, Grafana, MinIO.
7. **Многострочные команды через SSH легко испортить вставкой**: лишние `#`, пустые строки, склейка команд (`metabase#`, `--servicesecho`). Выполнять блоками и проверять результат.
8. **PowerShell `mkdir dir1 dir2 dir3`** обрабатывает только первый аргумент — создавать по одной или `mkdir X, Y, Z`.
9. **Grafana Stat-панель** с `GROUP BY` в SQL и узким диапазоном даёт ложную агрегацию — для «одного числа» нужен SQL без GROUP BY.
10. **Redis без volume = данные исчезают** при пересоздании контейнера.
11. **`pg_isready` без `-d`** в healthcheck шумит в логи, а `n_live_tup=0` после crash-recovery misleading — считать только `COUNT(*)`.
12. **Резервная копия до инцидента** (`pg_dumpall`) — единственное, что позволило не переживать за данные при recovery.
13. **Пароли из чатов/README нельзя исключить из риска**: после сноса — всё равно сменить засвеченные (ВМ удаляются).

---

# 8. Слабые места проекта (честное позиционирование)

- **dbt не встроен в оркестрацию:** в DAG 4 PythonOperator и ни одной dbt-задачи; marts пуст. Нельзя писать «dbt-модели в пайплайне» — точнее «настроен dbt-проект со staging-моделью».
- **Выручка зависит от фильтра:** SQL-дамп подтверждает 11 333 254,25 ₽ по всем статусам и 10 601 006,25 ₽ только по `completed`; 5 914 — уникальные клиенты с завершёнными заказами, 6 152 — со всеми статусами. В отчётах необходимо указывать фильтр.
- **Повторы в ClickHouse:** sample содержит три одинаковых агрегата с разным `created_at`; проверь идемпотентность по полной таблице до публикации результата.
- **Grafana-скрин «13 заказов / 12 638»** не использовать как доказательство — окно 6 ч. Показатель — 10 000 / 11 333 254.
- **Redis `platform:status "production-ready"`** в портфолио не показывать — проект учебный.
- **Metabase:** сохранённый дашборд в репозитории не подтверждён; не утверждать, что дашборд собран. Grafana-панели — отдельный инструмент.
- **Датасет `medical_analytics`** описан в корневом README как синтетический набор PostgreSQL; наличие данных в ClickHouse этим не подтверждается.
- В `namespaces.yaml` есть `kubernetes-dashboard`, но состав namespaces не подтверждает наличие рабочего Dashboard-приложения или nginx-workload в финальном снимке.

---

# 9. Что не доделано и отложено

Ниже приведён срез задач на 21.09.2026. ВМ демонтированы 28.09; пункты, требовавшие доступа к ним, после демонтажа невыполнимы без сохранённых экспортов.

## По проекту (приоритетное)
- [ ] Стабилизация диска devops-main: образы superset/kafka/nifi/mongo/qdrant/redash всё ещё на диске (7,74 ГБ reclaimable).
- [ ] Выяснить причину падения `load_to_clickhouse` 21.09; получить чистый успешный прогон DAG для скриншота.
- [ ] Проверить идемпотентность ClickHouse (30 000 = 3×10 000).
- [ ] Пересчитать метрики SQL-запросом (выручка/чек/клиенты/филиалы/товары).
- [ ] dbt: marts (`fct_sales`, `dim_products`, `dim_customers`, `dim_branches`, `dim_time`), интеграция в Airflow, `dbt docs generate`.
- [ ] Metabase: хотя бы один дашборд (главный BI-пробел).
- [ ] Grafana: панель на весь период (сейчас не «13»).
- [ ] MinIO: реальный дамп вместо `test_backup.sql` (60 байт).
- [ ] Redis: переснять ключи без ошибок; добавить volume.
- [ ] Скриншоты `docker compose ps` и `df -h` после стабилизации; скрины 3 k8s-нод и Grafana monitoring.
- [ ] README k8s: убрать дубли блоков, добавить подтверждённые сведения о Dashboard/nginx и убрать секреты; README BI: согласовать статусы с последним снимком.
- [ ] Санитизация паролей/IP, `.gitignore`, `git init` + push в GitHub.
- [x] Снос четырёх финальных ВМ завершён 28.09 по корневому README; удаление бэкапа, групп безопасности и итоговая проверка биллинга перечисленными источниками не подтверждены.

## Экспорт (план)
`pg_dump`/`pg_dumpall`, схема и sample ClickHouse, архивы volume'ов, `kubectl get ... -o yaml`, `helm get values`/`manifest`, `scp -r`. Не делать экспорт volume на полном диске (tar не запишет).

## Отложено на потом
- Ingress Controller (Nginx) + cert-manager (HTTPS).
- CI/CD (GitLab CI / GitHub Actions).
- Centralized logging (ELK).
- Автобэкапы БД (cron `pg_dump`, clickhouse-backup), snapshot ВМ.
- Airbyte (ELT), Streamlit-дашборды, JupyterHub, DBeaver-дока.
- Kafka pub/sub (producer→consumer), Qdrant vector search, NiFi data flow, MongoDB документы.
- Мониторинг K8s: Grafana-дашборды, Prometheus rules, Alertmanager-уведомления в Telegram/Email.

## Пробелы в хронологии
Эти данные предлагалось получить с ВМ до демонтажа. Репозиторий не подтверждает, что история shell и события были экспортированы; восполнить их можно только из сохранённых логов или бэкапов.
```bash
# на каждой ВМ
history | less        # или: cat ~/.bash_history
# на k8s-master
helm history monitoring -n monitoring
kubectl get events -A --sort-by=.lastTimestamp | tail -50
# на devops-main
ls -la --time-style=long-iso ~/analytics-stack ~/analytics-stack/scripts ~/analytics-stack/database
cat ~/analytics-stack/airflow/dags/etl_to_clickhouse.py
```
ВМ демонтированы, поэтому `.bash_history` за июль–август недоступна, если файлы не попали в экспорт.

---

# 10. Качество данных проекта

## 10.1. Характеристики качества

| Характеристика | Что проверено | Статус |
|---|---|---|
| **Точность** (accuracy) | В SQL-дампе `sales.total_amount` совпадает с суммой `sale_details.total_price` для 10 000 продаж; расхождений больше 0,01 ₽ нет. Выручка по всем статусам — 11 333 254,25 ₽. | ✅ Проверено по дампу |
| **Полнота** (completeness) | 10 000 строк в `sales`; 15 таблиц в `analytics_db_new`; 7 таблиц в `medical_analytics`. | ✅ Подтверждено дампом/README |
| **Согласованность** (consistency) | Отчёт сообщает 30 000 строк в `sales_daily` после трёх запусков. В CSV sample из 100 строк 66 повторных строк по ключу `(sale_date, category_id, branch_id)`. | ⚠️ Повторы подтверждены только в sample; полнотабличная идемпотентность не проверена |
| **Своевременность** (timeliness) | Максимальная `sale_date` в дампе `sales` — 2026-08-24. | ⚠️ Это дата последней записи в снимке, не подтверждение актуальности на 28.09 |
| **Валидность** (validity) | Статусы в дампе: `completed` — 9 354, `processing` — 631, `cancelled` — 15. Статуса `returned` в этом снимке нет. | ✅ Статусы посчитаны по дампу |
| **Целостность** (integrity) | Внешние ключи `sale_details.sale_id → sales.sale_id` и `sale_details.product_id → products.product_id`; orphan-строк по обеим ссылкам в дампе нет. | ✅ Проверено по схеме и дампу |
| **Уникальность** (uniqueness) | `sales.sale_id` — первичный ключ; 10 000 строк и 10 000 уникальных ID. | ✅ Проверено по дампу |

## 10.2. Что обнаружено

### Проблемы

1. **Повторы в ClickHouse sample.** В 100 строках CSV sample только 34 уникальных ключа `(sale_date, category_id, branch_id)`, 66 строк повторяют ключи. Это свидетельствует о повторных записях в sample, но не доказывает, что вся таблица содержит ровно три копии каждого агрегата. Перед выводом о полной идемпотентности проверь таблицу `default.sales_daily`. Возможные решения после проверки — очистка/перезагрузка либо движок с дедупликацией.
2. **MinIO содержит только `test_backup.sql` размером 60 байт** по зафиксированному снимку. Наличие реального дампа не подтверждено.
3. **Redis без volume.** В Compose у `redis` нет подключённого volume; данные не сохраняются при пересоздании контейнера.

### Замечания

4. **`analytics_db_new` и `analytics_db`.** В `.env.example` задано `POSTGRES_DB=analytics_db`, а сохранённая рабочая БД называется `analytics_db_new`. Использовать согласованное имя при новом развертывании.
5. **Медицинские данные.** `medical_analytics` присутствует в PostgreSQL; по прежнему отчёту `medical_analytics_ch` в ClickHouse была пустой. Не заявлять загрузку медицинских данных в ClickHouse без нового подтверждения.

## 10.3. Методы проверки

### PostgreSQL (сравнение суммы продаж и позиций)

```sql
SELECT COUNT(*) AS mismatches
FROM (
    SELECT s.sale_id,
           s.total_amount,
           COALESCE(SUM(sd.total_price), 0) AS details_sum
    FROM sales s
    LEFT JOIN sale_details sd ON sd.sale_id = s.sale_id
    GROUP BY s.sale_id, s.total_amount
) checks
WHERE ABS(total_amount - details_sum) > 0.01;
-- Ожидается: 0
```

### PostgreSQL (уникальность, ссылки и статусы)

```sql
SELECT COUNT(*) AS total, COUNT(DISTINCT sale_id) AS unique_ids FROM sales;
-- Ожидается: 10000 / 10000

SELECT COUNT(*) AS orphan_sales
FROM sale_details sd LEFT JOIN sales s ON s.sale_id = sd.sale_id
WHERE s.sale_id IS NULL;

SELECT COUNT(*) AS orphan_products
FROM sale_details sd LEFT JOIN products p ON p.product_id = sd.product_id
WHERE p.product_id IS NULL;
-- Ожидается: 0 для каждой проверки

SELECT status, COUNT(*) FROM sales GROUP BY status ORDER BY status;
-- В сохранённом снимке: cancelled 15, completed 9354, processing 631

SELECT status, COUNT(*) AS orders,
       ROUND(SUM(total_amount)::numeric, 2) AS revenue
FROM sales GROUP BY status ORDER BY status;
-- completed: 9354 / 10601006.25; все статусы вместе: 10000 / 11333254.25
```

### ClickHouse (полная таблица; sample не заменяет эту проверку)

```sql
SELECT count() AS total_rows,
       uniqExact(sale_date, category_id, branch_id) AS unique_keys
FROM default.sales_daily;
-- Если total_rows > unique_keys, проверь повторы агрегатов.
```

### dbt-тесты (не реализованы)

```yaml
version: 2
models:
  - name: stg_sales
    columns:
      - name: sale_id
        tests:
          - unique
          - not_null
      - name: total_amount
        tests:
          - not_null
```

```bash
dbt test
```

## 10.4. План развития проверок

- [ ] Добавить dbt-тесты для `stg_sales` (`unique`, `not_null`).
- [ ] Настроить проверки качества данных в Airflow (Great Expectations или Soda).
- [ ] Настроить алерт при отсутствии строк в `sales_daily`.
- [ ] По полной таблице проверить повторы `sales_daily` и затем выбрать стратегию идемпотентности.
- [ ] Добавить volume для Redis.
- [ ] Загрузить реальный дамп в MinIO.

---

# 11. Cheatsheet (сводный)

## SSH / scp
```bash
# PowerShell (Windows)
ssh -i C:\Users\MI\.ssh\id_ed25519 user1@213.171.26.123   # devops-main-new
ssh -i C:\Users\MI\.ssh\id_ed25519 user1@85.208.87.114    # k8s-master
ssh -i C:\Users\MI\.ssh\id_ed25519 user1@82.202.158.28    # k8s-worker-1
ssh -i C:\Users\MI\.ssh\id_ed25519 user1@176.108.248.13   # k8s-worker-2
# копирование папки ВМ → ПК
scp -i "$HOME\.ssh\id_ed25519" -r user1@213.171.26.123:~/export/* C:\Users\MI\Desktop\cloud-infrastructure-project\bi-analytics-stack\
# туннели для веб-интерфейсов
ssh -L 3000:localhost:3000 -L 8088:localhost:8088 -L 5432:localhost:5432 user1@<IP>
```

## Docker / Compose
```bash
cd ~/analytics-stack
docker compose ps                     # статус
docker compose ps -a                  # включая остановленные
docker compose up -d postgres clickhouse redis metabase minio airflow airflow-scheduler grafana node-red   # только нужное!
docker compose stop <svc>...          # остановить (не down)
docker compose down                   # остановить + контейнеры (НЕ volumes)
docker compose logs --tail=50 <svc>   # логи
docker compose config --services      # список сервисов
docker compose rm -f <svc>            # удалить контейнер

docker system df                      # что ест место
docker images / docker volume ls / docker ps -a
docker rm -f <container>              # СНАЧАЛА контейнеры
docker rmi <image>                    # ПОТОМ образы
docker volume rm <volume>
docker container prune -f
docker image prune -a -f              # осторожно: удалит образы остановленных сервисов
docker builder prune -a -f
sudo systemctl status docker
```

## Диск / containerd
```bash
df -h / && df -i
docker system df
sudo du -sh /var/lib/docker /var/lib/containerd /var/lib/clickhouse /var/log /home
sudo ctr -n moby images list
sudo ctr -n moby snapshots list
sudo ctr -n moby images prune --all     # КЛЮЧЕВАЯ чистка containerd
sudo find /var/lib/docker/containers -name "*-json.log" -exec truncate -s 0 {} \;
sudo journalctl --vacuum-size=100M
sudo apt clean && sudo apt autoremove --purge -y
rm -rf ~/.cache/* ~/.npm/* ~/.cache/pip/*
```

## Kubernetes / kubeadm / Helm
```bash
kubectl get nodes; kubectl get nodes -o wide
kubectl get pods -A; kubectl get svc -A; kubectl get ns
kubectl get pods -n monitoring; kubectl get svc -n monitoring
kubectl describe node <name>; kubectl describe pod <pod> -n <ns>; kubectl logs -f <pod> -n <ns>
kubectl get events -A --sort-by='.lastTimestamp' | tail -50
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80
kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n monitoring 9090:9090
kubectl get secret --namespace monitoring -l app.kubernetes.io/component=admin-secret \
  -o jsonpath="{.items[0].data.admin-password}" | base64 --decode ; echo
kubectl create namespace test-app
kubectl create deployment nginx-test --image=nginx -n test-app
kubectl expose deployment nginx-test --port=80 --type=NodePort -n test-app

# master
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.0.0.6 --kubernetes-version=v1.29.0
mkdir -p $HOME/.kube && sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && sudo chown $(id -u):$(id -g) $HOME/.kube/config
# worker
sudo kubeadm join 10.0.0.6:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<CA_HASH>

# Helm
helm list -A
helm history monitoring -n monitoring
helm get values monitoring -n monitoring
helm get manifest monitoring -n monitoring
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
helm uninstall monitoring -n monitoring
```

## PostgreSQL
```bash
docker exec analytics-postgres pg_isready -U analytics -d postgres
docker exec analytics-postgres psql -U analytics -d postgres -c "\l"
docker exec analytics-postgres psql -U analytics -d analytics_db_new -c "\dt"
docker exec analytics-postgres psql -U analytics -d analytics_db_new -c "SELECT COUNT(*), MIN(sale_date), MAX(sale_date) FROM sales;"
docker exec analytics-postgres psql -U analytics -c "SELECT SUM(total_amount) FROM analytics_db_new.sales;"
docker exec analytics-postgres pg_dumpall -U analytics > ~/backups/all_databases.sql
docker exec analytics-postgres pg_dump -U analytics analytics_db_new > ~/backups/analytics_db_new.sql
docker exec analytics-postgres pg_dump -U analytics medical_analytics > ~/backups/medical_analytics.sql
docker exec analytics-postgres pg_dump -U analytics --schema-only analytics_db_new > schema.sql
docker exec -i analytics-postgres psql -U analytics < backup.sql
```

## ClickHouse
```bash
docker exec analytics-clickhouse clickhouse-client --user clickhouse --password <PW> --query "SELECT version()"
docker exec analytics-clickhouse clickhouse-client --user clickhouse --password <PW> --query "SHOW DATABASES"
docker exec analytics-clickhouse clickhouse-client --user clickhouse --password <PW> --query "SHOW TABLES FROM default"
docker exec analytics-clickhouse clickhouse-client --user clickhouse --password <PW> --query "DESCRIBE TABLE default.sales_daily"
docker exec analytics-clickhouse clickhouse-client --user clickhouse --password <PW> --query "SELECT count(), min(sale_date), max(sale_date) FROM default.sales_daily"
docker exec analytics-clickhouse clickhouse-client --user clickhouse --password <PW> --query "SELECT count(), uniqExact(sale_date, category_id, branch_id) FROM default.sales_daily"   # проверка дублей
```

## Redis / MinIO / Node-RED
```bash
docker exec -it analytics-redis redis-cli
# PING / SET / GET / KEYS * / DEL — команды построчно, без комментариев
# MinIO: консоль :9001, API :9105, бакет analytics-backups
# Node-RED: :1880, flow Inject → Debug
```

## Airflow
```bash
docker exec -it airflow airflow dags list
docker exec -it airflow airflow dags list-import-errors
docker exec -it airflow airflow users list
docker exec -it airflow airflow connections list
docker exec -it airflow airflow connections add 'postgres_default' \
    --conn-type 'postgres' --conn-host 'analytics-postgres' \
    --conn-login 'analytics' --conn-password '<PW>' --conn-schema 'analytics_db_new' --conn-port 5432
docker exec -it airflow airflow connections delete postgres_default
docker exec -u 0 -it airflow python -m pip install clickhouse-connect
docker restart airflow airflow-scheduler
```

## Grafana
Пароль получаем из Kubernetes Secret, как указано в `docs/k8s-master-tech.md`.
```bash
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80
```

## Локальный PowerShell
```powershell
mkdir X, Y, Z        # не mkdir X Y Z
Get-ChildItem -Recurse -File | Select-Object FullName
Select-String -Path "file.yml" -Pattern "password|secret"
# BMP → PNG
Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Image]::FromFile("in.bmp"); $bmp.Save("out.png", [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
```


