import pymongo
import json
from pymongo import MongoClient
from bson import ObjectId

# Настройки для подключения к MongoDB
mongo_client = pymongo.MongoClient("mongodb://localhost:27017/")  # Подключение к MongoDB
db = mongo_client['pritunl']  # Выбор базы данных
servers_collection = db['servers']  # Коллекция с серверами
# Открытие файла и чтение всех server_id
with open('pritunl-servers-id-mongo.txt', 'r') as file:
    server_ids = file.readlines()

# Убираем возможные пустые строки и символы новой строки
server_ids = [server_id.strip() for server_id in server_ids if server_id.strip()]

# Пример маршрута в формате строки
def create_route(network):
    return {
        "network": network,
        "comment": None,
        "metric": None,
        "nat": True,
        "nat_interface": None,
        "nat_netmap": None,
        "advertise": False,
        "vpc_region": None,
        "vpc_id": None,
        "net_gateway": False,
        "server_link": False
    }

# Чтение списка маршрутов из файла
with open('routes.txt', 'r') as file:
    routes = [create_route(line.strip()) for line in file.readlines()]

# Добавление маршрутов для каждого server_id
for server_id_str in server_ids:
    try:
        server_id = ObjectId(server_id_str)
        for route in routes:
            result = servers_collection.update_one(
                {"_id": server_id},  # Убедитесь, что ID сервера правильный
                {"$push": {"routes": route}}  # Добавление маршрута в поле "routes"
            )
            
            if result.modified_count > 0:
                print(f"Маршрут {route['network']} успешно добавлен для server_id {server_id_str}.")
            else:
                print(f"Ошибка при добавлении маршрута {route['network']} для server_id {server_id_str}.")
    except Exception as e:
        print(f"Ошибка при обработке server_id {server_id_str}: {e}")
