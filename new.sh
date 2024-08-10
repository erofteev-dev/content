#!/bin/bash

# Определите переменные
TITLE=""
FOLDER=""
USER=""
BRANCH_NAME=""

# Функция для транслитерации кириллицы в латиницу
translit() {
  echo "$1" | sed -e 's/а/a/g' -e 's/б/b/g' -e 's/в/v/g' -e 's/г/g/g' -e 's/д/d/g' \
                   -e 's/е/e/g' -e 's/ё/yo/g' -e 's/ж/zh/g' -e 's/з/z/g' -e 's/и/i/g' \
                   -e 's/й/y/g' -e 's/к/k/g' -e 's/л/l/g' -e 's/м/m/g' -e 's/н/n/g' \
                   -e 's/о/o/g' -e 's/п/p/g' -e 's/р/r/g' -e 's/с/s/g' -e 's/т/t/g' \
                   -e 's/у/u/g' -e 's/ф/f/g' -e 's/х/kh/g' -e 's/ц/ts/g' -e 's/ч/ch/g' \
                   -e 's/ш/sh/g' -e 's/щ/shch/g' -e 's/ъ//g' -e 's/ы/y/g' -e 's/ь//g' \
                   -e 's/э/e/g' -e 's/ю/yu/g' -e 's/я/ya/g' -e 's/А/A/g' -e 's/Б/B/g' \
                   -e 's/В/V/g' -e 's/Г/G/g' -e 's/Д/D/g' -e 's/Е/E/g' -e 's/Ё/YO/g' \
                   -e 's/Ж/ZH/g' -e 's/З/Z/g' -e 's/И/I/g' -e 's/Й/Y/g' -e 's/К/K/g' \
                   -e 's/Л/L/g' -e 's/М/M/g' -e 's/Н/N/g' -e 's/О/O/g' -e 's/П/P/g' \
                   -e 's/Р/R/g' -e 's/С/S/g' -e 's/Т/T/g' -e 's/У/U/g' -e 's/Ф/F/g' \
                   -e 's/Х/KH/g' -e 's/Ц/TS/g' -e 's/Ч/CH/g' -e 's/Ш/SH/g' -e 's/Щ/SHCH/g' \
                   -e 's/Ъ//g' -e 's/Ы/Y/g' -e 's/Ь//g' -e 's/Э/E/g' -e 's/Ю/YU/g' -e 's/Я/YA/g'
}

# Ввод заголовка и имени пользователя
read -r -p "Введите заголовок статьи: " TITLE
read -r -p "Введите имя пользователя (или ник, который будет использоваться в названии ветки): " USER

# Транслитерация заголовка в латиницу
FOLDER=$(translit "$TITLE" | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')

# Генерация имени ветки
#BRANCH_NAME="article-${USER}-$(date +'%Y%m%d%H%M%S')"

# Проверка существования папки
while [ -d "content/$FOLDER" ]; do
  echo "К сожалению, папка $FOLDER уже существует..."
  read -r -p "Введите другое название статьи: " TITLE
  FOLDER=$(translit "$TITLE" | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
done

# Создание структуры папок и файла
mkdir -p "content/$FOLDER"
touch "content/$FOLDER/index.md"

# Заполнение файла заголовком
cat <<EOF > "content/$FOLDER/index.md"
---
layout: base.njk
title: "$TITLE"
permalink: '{{ page.fileSlug | articleUrl }}'
---

EOF

## Для админа
# Переход на главную ветку, обновление и коммит
#git checkout main
#git pull

# Добавление и коммит изменений
#git add "content/$FOLDER/index.md"
#git commit -m "Добавлен новый материал: $TITLE"

# Пуш изменений в удалённый репозиторий
#git push origin main

echo "Новый материал создан и находится в папке: content/$FOLDER"


## Для пользователей
## Переключение на новую ветку, создание и коммит изменений
#git checkout -b "$BRANCH_NAME"
#git add "content/$FOLDER/index.md"
#git commit -m "Добавлен новый материал от $USER: $TITLE"

## Пуш изменений в удалённый репозиторий
#git push origin "$BRANCH_NAME"

#echo "Новый материал создан и находится в ветке: $BRANCH_NAME"
