# DevOps Infrastructure Homework

## Описание проекта

Учебный проект по развёртыванию DevOps-инфраструктуры на Ubuntu 24.04.

В проекте используются Ansible, Terraform, Docker, Docker Compose, Bash и Git.

Управление сервером осуществляется с локального компьютера macOS через SSH.

## Структура проекта

- `ansible/` — автоматическая настройка Ubuntu-сервера.
- `terraform/` — управление Docker-инфраструктурой через Terraform.
- `scripts/monitor.sh` — мониторинг systemd-сервиса и системных журналов.
- `compose/` — приложение Hello World и Nginx reverse proxy.
- `screenshots/` — скриншоты выполнения и проверок.

## 1. Ansible

Ansible запускается с macOS и подключается к удалённому Ubuntu-серверу через SSH.

Playbook `ansible/setup_host.yml`:

- Устанавливает необходимые системные пакеты.
- Добавляет официальный Docker APT-репозиторий.
- Устанавливает Docker Engine и Docker Compose Plugin.
- Запускает и включает сервис Docker.
- Создаёт пользователя `deployer`.
- Добавляет пользователя в группу Docker.
- Настраивает sudo для `deployer`.

Запуск:

```bash
cd ansible
ansible -i inventory.ini servers -m ping
ansible-playbook -i inventory.ini setup_host.yml --ask-become-pass
```

Повторный запуск используется для проверки идемпотентности.

## 2. Terraform

Terraform запускается на macOS и управляет Docker Engine на Ubuntu через SSH с помощью провайдера `kreuzwerker/docker`.

Создаваемые ресурсы:

| Ресурс | Значение |
|---|---|
| Контейнер | `terraform_nginx` |
| Docker-сеть | `terraform_net` |
| Docker volume | `nginx_data` |
| HTTP-порт | `127.0.0.1:8081` |

Команды:

```bash
cd terraform
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Проверка на Ubuntu:

```bash
curl -i http://127.0.0.1:8081
```

Ожидаемый HTTP-статус: `200 OK`.

## 3. Bash Monitoring

Скрипт `scripts/monitor.sh`:

- Проверяет состояние указанного systemd-сервиса.
- Выводит последние 10 записей журнала сервиса.
- Показывает системные ошибки за последний час.
- Возвращает код `0` при успешной проверке или ненулевой код при обнаружении проблемы.

Пример запуска на Ubuntu:

```bash
sudo /usr/local/bin/monitor.sh docker
```

Проверка обработки ошибки:

```bash
sudo /usr/local/bin/monitor.sh nonexistent-devops-service
echo $?
```

## 4. Docker Compose

Docker Compose запускает два контейнера:

- `compose_app` — HTTP-приложение со страницей Hello World.
- `compose_proxy` — Nginx reverse proxy, перенаправляющий запросы приложению.

Оба контейнера подключены к отдельной сети `compose_net`.

Публикуется только порт reverse proxy: `127.0.0.1:8080`.

Запуск на Ubuntu из каталога проекта:

```bash
docker compose up -d
docker compose ps
```

Проверка:

```bash
curl -i http://127.0.0.1:8080
```

Ожидаемый результат — `HTTP/1.1 200 OK` и страница `Hello World!`.

## 5. Изоляция проектов

Terraform и Docker Compose работают независимо:

| Проект | Сеть | Порт |
|---|---|---|
| Terraform Nginx | `terraform_net` | `8081` |
| Docker Compose | `compose_net` | `8080` |

Контейнеры Docker Compose не подключены к сети Terraform.

## 6. Проверки

Для подтверждения выполнения задания используются:

- Успешный запуск Ansible и повторный запуск без изменений.
- Успешный `terraform apply` и `terraform plan` без изменений.
- HTTP-ответ `200 OK` от Terraform Nginx.
- Успешный запуск Bash-мониторинга и проверка ошибки.
- Состояние контейнеров Docker Compose.
- HTTP-ответ `200 OK` и страница Hello World.
- Проверка отдельных Docker-сетей.

## 7. Используемые технологии

Ubuntu 24.04, macOS, SSH, Git, Ansible, Terraform, Docker Engine, Docker Compose, Nginx, Bash.
