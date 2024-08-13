#!/bin/bash

# Определение цветов
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Переход на главную ветку и обновление
git checkout main
if [ $? -ne 0 ]; then
    echo -e "${RED}Ошибка: не удалось переключиться на ветку main${NC}"
    exit 1
fi

git pull
if [ $? -ne 0 ]; then
    echo -e "${RED}Ошибка: не удалось обновить ветку main${NC}"
    exit 1
fi

# Подтверждение отправки изменений
read -p "Вы действительно хотите отправить изменения в ветку main? (y/n): " CONFIRM
if [[ $CONFIRM != [yY] ]]; then
    echo "Операция отменена"
    exit 0
fi

# Добавление изменений
git add content/*
if [ $? -ne 0 ]; then
    echo -e "${RED}Ошибка: не удалось добавить файлы для коммита${NC}"
    exit 1
fi

# Коммит изменений с датой
COMMIT_MESSAGE="Добавлен новый материал-$(date +'%Y%m%d')"
git commit -m "$COMMIT_MESSAGE"
if [ $? -ne 0 ]; then
    echo -e "${RED}Ошибка: не удалось выполнить коммит${NC}"
    exit 1
fi

# Пуш изменений в удалённый репозиторий
git push origin main
if [ $? -ne 0 ]; then
    echo -e "${RED}Ошибка: не удалось выполнить пуш в ветку main${NC}"
    exit 1
fi

echo -e "${GREEN}Материал успешно добавлен!${NC}"
