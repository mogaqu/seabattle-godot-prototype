# мы решили не использовать, можно использовать для ознакомления
"""
extends Node

# Настройки клиента
var client_port = 4242  # Локальный порт клиента
var server_ip = "XXX.XXX.XXX.XXX"  # Внешний IP сервера
var server_port = 4242  # Порт сервера
var udp_client : PacketPeerUDP

func _ready():
	udp_client = PacketPeerUDP.new()
	
	# Открываем UDP сокет для работы на клиентском порту
	var result = udp_client.open(client_port)
	
	if result == OK:
		print("Клиент P2P подключен на порту:", client_port)
		
		# Подключаемся к серверу по IP и порту
		udp_client.connect_to_host(server_ip, server_port)
		send_initial_message()  # Отправляем первое сообщение серверу
	else:
		print("Не удалось запустить клиента на порту:", result)
	
	set_process(true)

func send_initial_message():
	var message = "Hello from Client"
	udp_client.put_packet(message.to_utf8())
	print("Отправлено сообщение серверу:", message)

# Используем _delta для избежания предупреждения о неиспользованной переменной
func _process(_delta):
	if udp_client.get_available_packet_count() > 0:
		var packet = udp_client.get_packet()
		var message = packet.get_string_from_utf8()
		print("Получено сообщение: ", message)

func _exit_tree():
	udp_client.close()
	print("Клиент завершил работу.")
"""
