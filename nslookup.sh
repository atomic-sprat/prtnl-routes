#!/bin/bash

# Проверяем, существует ли файл hosts.txt
if [ ! -f "hosts.txt" ]; then
  echo "Файл hosts.txt не найден!"
  exit 1
fi

# Очищаем файл routes.txt, если он существует
> routes.txt

# Читаем файл hosts.txt построчно
while IFS= read -r host; do
  # Выполняем nslookup для текущего хоста и получаем только IP-адреса
  ips=$(nslookup "$host" | awk '/^Address: / { print $2 }')

  # Для каждого найденного IP-адреса проверяем, что это IPv4
  for ip in $ips; do
    if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "$ip/32" >> routes.txt
    fi
  done
done < hosts.txt

echo "Маршруты сохранены в routes.txt"
