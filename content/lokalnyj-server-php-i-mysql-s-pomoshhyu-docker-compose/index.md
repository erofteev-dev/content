---
title: "Локальный сервер PHP и MySQL с помощью Docker Compose"
description: "Как быстро развернуть сервер с помощью Docker."
author: "erofteev"
date: 2024-09-01
tags: ['backend']
keywords: "Docker, PHP, Apache, Nginx, MySQL, phpMyAdmin, контейнеры, сервер, конфигурация, образ, Volume, конфигурация Nginx, WordPress, разработка, тестирование, локальный сервер"
---

Сегодня мы развернем сервер с помощью Docker, который будет включать PHP, Apache, Nginx, MySQL и phpMyAdmin. Если вы не знакомы с Docker, я рекомендую вам ознакомиться с ним — это действительно просто и быстро!

Давайте перейдем к делу. Для запуска нашего сервера мы будем использовать файл `docker-compose.yml`, в котором мы опишем контейнеры для каждого из компонентов.

### Пример `docker-compose.yml`

```yaml
version: '3.9'

services:
  apache:
    image: php:latest-apache
    container_name: apache
    volumes:
      - ./web:/var/www/html
    ports:
      - "8080:80"
    depends_on:
      - mysql

  nginx:
    image: nginx:latest
    container_name: nginx
    ports:
      - "8081:80"
    volumes:
      - ./web:/var/www/html:ro
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - apache

  mysql:
    image: mysql:latest
    container_name: mysql
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: mydatabase
      MYSQL_USER: myuser
      MYSQL_PASSWORD: mypassword
    volumes:
      - db_data:/var/lib/mysql

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: phpmyadmin
    environment:
      PMA_HOST: mysql
      MYSQL_ROOT_PASSWORD: rootpassword
    ports:
      - "8082:80"
    depends_on:
      - mysql

volumes:
  db_data:
```

### Как это работает:

1. **Apache `apache`**:
   - Мы используем образ PHP с Apache `php:latest-apache`.
   - Порт 80 внутри контейнера пробрасывается на порт 8080 вашего хоста, так что вы сможете зайти на сервер по адресу `http://localhost:8080`.
   - Каталог `./web` на вашем компьютере монтируется в `/var/www/html` контейнера. Это значит, что файлы вашего сайта (например, WordPress) можно просто скопировать в эту папку на хосте.
   - Apache будет обрабатывать PHP-файлы.

2. **Nginx `nginx`**:
   - Используем образ Nginx.
   - Порт 80 контейнера пробрасывается на порт 8081 вашего хоста, доступен по адресу `http://localhost:8081`.
   - Nginx будет проксировать запросы к Apache. Конфигурация Nginx хранится в файле `./nginx/nginx.conf`, который вы создадите.

3. **MySQL `mysql`**:
   - Используем образ MySQL последней версии.
   - Устанавливаем переменные окружения для настройки базы данных (`MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`).
   - Данные базы данных сохраняются в Docker volume `db_data`, чтобы не потеряться при перезапуске контейнеров.

4. **phpMyAdmin `phpmyadmin`**:
   - Это веб-интерфейс для управления базой данных.
   - Доступен по адресу `http://localhost:8082`.
   - Подключается к MySQL-контейнеру и использует те же креденшелы.

### Файл конфигурации Nginx `nginx/nginx.conf`

Создайте файл `nginx.conf` в папке `nginx`, которая находится рядом с `docker-compose.yml`. Вот пример конфигурации:

```nginx
server {
    listen 80;

    server_name localhost;

    root /var/www/html;

    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass apache:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

### Как развернуть и запустить:

1. **Запустите Docker Compose**:
   ```bash
   docker-compose up -d
   ```

   Все сервисы будут запущены в фоновом режиме.

2. **Копируйте файлы**:
   - Перенесите файлы вашего сайта, включая WordPress, в папку `./web` на вашем компьютере. Эти файлы будут автоматически доступны на сервере.

3. **Получите доступ к сервисам**:
   - Apache (с PHP): `http://localhost:8080`
   - Nginx: `http://localhost:8081`
   - phpMyAdmin: `http://localhost:8082`

### Дополнительные настройки:

- **Креденшелы для MySQL**: Если нужно, замените `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD` в `docker-compose.yml` на свои значения.
- **Конфигурация Nginx**: Настраивайте `nginx.conf` в зависимости от ваших требований.

Теперь у вас есть локально развернутый сервер, который соответствует типичному окружению хостинга. Вы можете использовать его для разработки и тестирования перед развертыванием на реальном сервере. Удачи!