#хороший был скрипт(для взаимодействия с сервером), можно смотреть
"""extends Node

var http_request : HTTPRequest

# Публичный URL, который дал ngrok
var url = "https://pro-gar-annually.ngrok-free.app"  # Добавляем маршрут /send-data

func _ready():

	http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Подключаем сигнал, который вызывается при завершении запроса
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	
	# Отправляем данные на сервер
	send_data_to_server()

func send_data_to_server():
	var code = NewScript.verification_code
	var sigma = false
	var data = {
		"ver_code": code,
		"player_name": NewScript.player_name,
		"coordinate": NewScript.coordinates,
		"avatar": NewScript.avatar
	}
	
	# Преобразуем данные в JSON
	var json_data = JSON.stringify(data)  # Преобразуем словарь в JSON строку
	
	# Заголовки для POST-запроса
	var headers = ["Content-Type: application/json"]
	
	# Отправляем POST-запрос
	var err = http_request.request(url, headers, HTTPClient.METHOD_POST, json_data) 
	
	if err != OK:
		print("Ошибка при отправке запроса: ", err)
	else:
		print("Запрос отправлен на сервер")

# Функция для обработки ответа от сервера
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json_parser = JSON.new()  # Создаём экземпляр класса JSON
		var response = json_parser.parse(body.get_string_from_utf8())
		
		if response.error == OK:
			var response_data = response.result
			print("Ответ сервера: ", response_data)
		else:
			print("Ошибка при парсинге JSON ответа: ", response.error_string)
	else:
		print("Ошибка: код ответа от сервера: ", response_code)
"""
