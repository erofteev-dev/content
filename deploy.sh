#!/bin/bash

# Определение цветов
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Определите переменные
USER=""
BRANCH_NAME=""

# Ввод имени пользователя
read -r -p "Введите имя пользователя (или ник, который будет использоваться в названии ветки): " USER

# Генерация имени ветки
BRANCH_NAME="article-${USER}-$(date +'%Y%m%d%H%M')"

# Переключение на новую ветку
git checkout -b "$BRANCH_NAME"
if [ $? -ne 0 ]; then
    echo -e "${RED}Ошибка: не удалось создать и переключиться на новую ветку ${BRANCH_NAME}${NC}"
    exit 1
fi

# Добавление всех новых и изменённых файлов
git add content/*
if [ $? -ne 0 ]; then
    echo -e "${RED}Ошибка: не удалось добавить файлы для коммита${NC}"
    exit 1
fi

# Коммит изменений
git commit -m "Добавлен новый материал от $USER"
if [ $? -ne 0 ]; then
    echo -e "${RED}Ошибка: не удалось выполнить коммит${NC}"
    exit 1
fi

# Пуш изменений в удалённый репозиторий
git push origin "$BRANCH_NAME"
if [ $? -ne 0 ]; then
    echo -e "${RED}Ошибка: не удалось выполнить пуш в ветку ${BRANCH_NAME}${NC}"
    exit 1
fi

echo -e "${GREEN}Изменения успешно отправлены в ветку: ${BRANCH_NAME}${NC}"
