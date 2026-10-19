extends Node2D

var server_url: String = "https://xn--80aqtedp.xn--p1ai"
var game_id: String = ""
var player_id = NewScript.player_name
var coordinates = NewScript.coordinates

func _ready() -> void:
	$Label2.text = "Пока ничего не произошло\n"
	create_game()
	print(NewScript.coordinates)

func create_game() -> void:
	var data: Dictionary = {"playerId": player_id, "coor": coordinates}
	send_request("/create-game", data)

# Присоединение к существующей игре
func join_game(existing_game_id: String) -> void:
	var data: Dictionary = {"gameId": existing_game_id, "playerId": player_id}
	send_request("/join-game", data)

# Отправка HTTP-запроса
func send_request(endpoint: String, data: Dictionary) -> void:
	var url: String = server_url + endpoint
	var json_data: String = JSON.stringify(data)
	var headers: Array = ["Content-Type: application/json"]
	var response: HTTPRequest = HTTPRequest.new()
	add_child(response)  # Добавляем HTTPRequest в сцену

	# Подключаем сигнал request_completed
	response.connect("request_completed", Callable(self, "_on_request_completed"))

	# Выполняем запрос
	var error: int = response.request(url, headers, HTTPClient.METHOD_POST, json_data)
	if error != OK:
		$Label2.text += "Ошибка запроса: " + str(error) + "\n"
		response.queue_free()

# Обработка завершения запроса
func _on_request_completed(result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	
	if response_code == 200:
		var response_body: String = body.get_string_from_utf8()
		var json = JSON.new()  # Создаем экземпляр JSON
		var parse_result: int = json.parse(response_body)
		if parse_result == OK:
			var data: Dictionary = json.get_data()
			$Label2.text += "Ответ сервера: " + str(data) + "\n"
			if data.has("gameId"):
				game_id = data["gameId"]
				NewScript.verification_code = game_id
				$Label2.text += "Игра создана. ID игры: " + game_id + "\n"
				make_request()
		else:
			$Label2.text += "Ошибка парсинга JSON: " + str(json.get_error_message()) + "\n"
	else:
		$Label2.text += "Ошибка HTTP: " + str(response_code) + "\n"
	
func make_request():
	var url: String = server_url + "/long-polling"
	var data = {"gameId": game_id, "message": game_id + player_id + "жду игру", "playerId": player_id}  # Исправлено playerId
	var json_data: String = JSON.stringify(data)
	var headers: Array = ["Content-Type: application/json"]
	var response: HTTPRequest = HTTPRequest.new()
	add_child(response)

	# Подключаем сигнал request_completed
	response.connect("request_completed", Callable(self, "_on_request_completed1"))

	# Отправляем POST-запрос
	var error: int = response.request(url, headers, HTTPClient.METHOD_POST, json_data)
	if error != OK:
		print("Ошибка запроса: ", error)
		response.queue_free()

func _on_request_completed1(result, response_code, headers, body):
	if response_code == 200:
		var response_body: String = body.get_string_from_utf8()
		var json = JSON.new()  # Создаем объект JSON
		var parse_result: int = json.parse(response_body)
		if parse_result == OK:
			var data: Dictionary = json.get_data()
			if data.has("message") and data.has("opponent"):
				print(data)
				print("Получено сообщение: ", data["message"])
				NewScript.id_of_opponent = data["opponent"]
				
				get_tree().change_scene_to_file("res://game_player1.tscn")
		else:
			print("Ошибка парсинга JSON:", json.get_error_message())
	else:
		print("Ошибка HTTP:", response_code)
