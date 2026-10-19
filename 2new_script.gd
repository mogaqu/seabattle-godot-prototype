extends Node2D

var server_url: String = "https://xn--80aqtedp.xn--p1ai"
var game_id: String = ""
var player_id = NewScript.player_name
var coordinates = NewScript.coordinates
var existing_game_id = ""
func _ready() -> void:
	$Label2.text = "Пока ничего не произошло\n"
func _on_button_pressed():
	existing_game_id = $LineEdit.text
	if existing_game_id.length() != 9:
		print("неправильно")
		return
	join_game(existing_game_id)
	NewScript.id_of_opponent = existing_game_id


func create_game() -> void:
	var data: Dictionary = {"playerId": player_id, "coor": coordinates}
	send_request("/create-game", data)

# Присоединение к существующей игре
func join_game(existing_game_id: String) -> void:
	var data: Dictionary = {"gameId": existing_game_id, "playerId": player_id, "coor": coordinates}
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
		var json: JSON = JSON.new()
		var parse_result: int = json.parse(response_body)
		if parse_result == OK:
			var data: Dictionary = json.get_data()
			$Label2.text += "Ответ сервера: " + str(data) + "\n"
			if data.has("opponent"):
				NewScript.id_of_opponent = data["opponent"]
			if data.has("gameId"):
				game_id = data["gameId"]
				NewScript.verification_code = game_id
				$Label2.text += "Игра создана. ID игры: " + game_id + "\n"
				if "Игра создана. ID игры: " + game_id + "\n" in $Label2.text:
						var url = str(server_url + "/")
						var json_data: String = JSON.stringify("я всё")
						var response: HTTPRequest = HTTPRequest.new()
						add_child(response)  # Добавляем HTTPRequest в сцену
						get_tree().change_scene_to_file("res://game_player1.tscn")
						response.connect("request_completed", Callable(self, "_on_request_completed"))
	# Выполняем запрос
						var error: int = response.request(url, headers, HTTPClient.METHOD_POST, json_data)
						if error != OK:
							$Label2.text += "Ошибка запроса: " + str(error) + "\n"
							response.queue_free()
		else:
			$Label2.text += "Ошибка парсинга JSON: " + str(json.get_error_message()) + "\n"
	else:
		$Label2.text += "Ошибка HTTP: " + str(response_code) + "\n"
