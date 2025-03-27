#!/bin/bash

# Проверяем, существует ли файл hosts.txt
if [ ! -f "hosts.txt" ]; then
  echo "Файл hosts.txt не найден!"
  exit 1
fi

# Очищаем файл ip.txt, если он существует
> ip.txt

# Читаем файл hosts.txt построчно
while IFS= read -r host; do
  # Выполняем nslookup для текущего хоста и получаем только IP-адреса
  ips=$(nslookup "$host" | awk '/^Address: / { print $2 }')

  # Для каждого найденного IP-адреса проверяем, что это IPv4, и записываем в ip.txt
  for ip in $ips; do
    # Проверяем, что это IPv4-адрес (он должен состоять из 4 чисел, разделенных точками)
    if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "$ip/32" >> ip.txt
    fi
  done
done < hosts.txt

echo "IPv4-адреса сохранены в ip.txt"
