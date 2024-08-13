#!/bin/bash

# Определение цветов
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Переменные
TITLE=""
DESCRIPTION=""
FOLDER=""
AUTHOR=""
TAGS=""
AVAILABLE_TAGS=("frontend" "backend" "linux") # ("тег1" "тег2")

# Функция для транслитерации кириллицы в латиницу и замены пробелов на дефисы
translit() {
  echo "$1" | LC_ALL=POSIX iconv -c -f utf-8 -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:] _-' | sed 's/ /-/g'
}

# Функция для выбора тегов
select_tags() {
  local selected_tags=()
  declare -A tag_set
  local num_tags=${#AVAILABLE_TAGS[@]}
  local choice

  while true; do
    clear
    echo "Список тегов:"
    for i in "${!AVAILABLE_TAGS[@]}"; do
      echo "$((i + 1)). ${AVAILABLE_TAGS[i]}"
    done
    echo -e "$((num_tags + 1)). ${YELLOW}Свой вариант${NC}"

    # Отображение выбранных тегов
    echo
    if [ ${#selected_tags[@]} -gt 0 ]; then
      local formatted_tags=""
      for tag in "${selected_tags[@]}"; do
        formatted_tags+="$tag, "
      done
      formatted_tags=${formatted_tags%, }  # Удаляем последнюю запятую и пробел
      echo "Выбранные теги: $formatted_tags"
    else
      echo "Выбранные теги: нет"
    fi

    echo
    echo "Введите номер тега для выбора (или введите '0' для завершения):"
    read -r choice

    if [[ "$choice" == "0" ]]; then
      break
    elif [[ "$choice" =~ ^[0-9]+$ && "$choice" -gt 0 && "$choice" -le "$num_tags" ]]; then
      tag="${AVAILABLE_TAGS[$((choice - 1))]}"
      if [[ " ${selected_tags[@]} " =~ " ${tag} " ]]; then
        selected_tags=($(printf "%s\n" "${selected_tags[@]}" | grep -vxF "$tag"))
        unset "tag_set[$tag]"
      else
        selected_tags+=("$tag")
        tag_set["$tag"]=1
      fi
    elif [[ "$choice" == "$((num_tags + 1))" ]]; then
      echo "Введите свой вариант тега (можно использовать пробелы):"
      read -r custom_tag
      if [[ -n "$custom_tag" && -z "${tag_set[$custom_tag]}" ]]; then
        selected_tags+=("$custom_tag")
        tag_set["$custom_tag"]=1
      else
        echo -e "${RED}Тег уже выбран или пустой. Пожалуйста, попробуйте снова.${NC}"
        sleep 1
      fi
    else
      echo -e "${RED}Неверный выбор. Пожалуйста, попробуйте снова.${NC}"
      sleep 1
    fi
  done

  # Формирование строки тегов для записи
  if [ ${#selected_tags[@]} -eq 0 ]; then
    echo "Вы не выбрали ни одного тега."
    TAGS=""
  else
    TAGS=$(printf "'%s', " "${selected_tags[@]}")
    TAGS=${TAGS%, }
  fi
}

# Проверка заголовка
while [[ -z "$TITLE" ]]; do
  read -r -p "Введите заголовок статьи: " TITLE
  if [[ -z "$TITLE" ]]; then
    echo -e "${RED}Заголовок не может быть пустым.${NC}"
  fi
done

read -r -p "Введите краткое описание статьи (можно будет дополнить позже): " DESCRIPTION
read -r -p "Введите имя автора или никнейм: " AUTHOR

# Транслитерация заголовка и его очистка
FOLDER=$(translit "$TITLE")

# Проверка существования папки
while [ -d "content/$FOLDER" ]; do
  echo -e "${RED}К сожалению, папка $FOLDER уже существует...${NC}"
  read -r -p "Введите другое название статьи: " TITLE
  FOLDER=$(translit "$TITLE")
done

# Выбор тегов
select_tags

# Создание структуры папок и файла
mkdir -p "content/$FOLDER"
mkdir -p "content/$FOLDER/images"
touch "content/$FOLDER/index.md"

# Заполнение файла заголовком
cat <<EOF > "content/$FOLDER/index.md"
---
title: "$TITLE"
description: "$DESCRIPTION"
author: "$AUTHOR"
date: $(date +'%Y-%m-%d')
tags: [$TAGS]
---

EOF

echo -e "${GREEN}Новый шаблон создан и находится в папке: content/$FOLDER${NC}"