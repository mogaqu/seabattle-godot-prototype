extends Node

var server_url = "https://xn--80aqtedp.xn--p1ai"
var game_id = NewScript.verification_code
var player_id = NewScript.player_name
var victim = NewScript.id_of_opponent
var kletka = NewScript.kletka  # Последняя выбранная клетка
@onready var http = $HTTPRequest
@onready var status_label = $StatusLable
@onready var turn_arrow = $TurnArrow
@onready var own_control = $Control  # Левое поле (собственное)
@onready var opponent_control = $"1"  # Правое поле (оппонента)

var miss_texture = load("res://мимо.png")  # Синий круг для "мимо"
var hit_texture = load("res://подбит.png")  # Красный крест для "попал"
var default_texture = null  # Пустая текстура (null) для сброса

# Храним текущие координаты игрока
var player_coors = []
# Храним историю атак противника
var opponent_attacks = []
# Храним предыдущее состояние координат для определения попаданий
var previous_coors = []
# Флаг, указывающий, мой ли сейчас ход
var is_my_turn = false
# Флаг завершения игры
var game_over = false
# Победитель игры
var winner = ""
# Флаг дополнительного хода
var extra_turn = false
# Последнее время получения попадания от противника
var last_hit_time = 0

func _ready():
	http.connect("request_completed", Callable(self, "_on_request_completed"))
	print("[DEBUG] Game ID: " + game_id + ", Player ID: " + player_id + ", Opponent ID: " + victim)
	
	# Блокируем все кнопки действий при запуске, до получения своего хода
	disable_all_buttons()
	
	# Устанавливаем обработчики для кнопок на поле противника
	setup_opponent_buttons()
	
	# Устанавливаем обработчики для кнопок действий
	for button in get_tree().get_nodes_in_group("action_buttons"):
		button.connect("pressed", Callable(self, "_on_button_pressed").bind(button))
		button.disabled = true  # Блокируем все кнопки вначале
		
	start_polling()

func _process(delta):
	# Мигание при получении попадания
	if Time.get_ticks_msec() - last_hit_time < 1000:
		var flash_intensity = abs(sin(Time.get_ticks_msec() * 0.01))
		for attack in opponent_attacks:
			if attack.hit and Time.get_ticks_msec() - attack.time < 1000:
				var button = find_button_by_name_own(attack.coord)
				if button and button is Button:
					button.modulate = Color(1, 0.3, 0.3, 1.0 + flash_intensity * 0.5)
	else:
		# Возвращаем нормальный цвет
		for child in own_control.get_children():
			if child is Button:
				child.modulate = Color(1, 1, 1, 1)

# Настраиваем кнопки на поле противника
func setup_opponent_buttons():
	if opponent_control:
		for button in opponent_control.get_children():
			if button is Button:
				# Убеждаемся, что каждая кнопка имеет правильное состояние
				button.disabled = true  # По умолчанию все кнопки заблокированы
				if not button.is_connected("pressed", Callable(self, "_on_opponent_field_button_pressed")):
					button.connect("pressed", Callable(self, "_on_opponent_field_button_pressed").bind(button))

# Блокируем все кнопки
func disable_all_buttons():
	# Блокируем кнопки действий
	for button in get_tree().get_nodes_in_group("action_buttons"):
		button.disabled = true

	# Блокируем кнопки на поле противника
	if opponent_control:
		for button in opponent_control.get_children():
			if button is Button:
				button.disabled = true
	
	is_my_turn = false
	extra_turn = false
	if turn_arrow:
		turn_arrow.rotation_degrees = 180  # Повернуть к противнику

# Разблокируем кнопки для хода
func enable_buttons_for_turn(is_extra_turn = false):
	# Если игра уже завершена, не разблокируем кнопки
	if game_over:
		return
		
	# Разблокируем кнопки действий
	for button in get_tree().get_nodes_in_group("action_buttons"):
		button.disabled = false
		
	# Разблокируем кнопки на поле противника
	if opponent_control:
		for button in opponent_control.get_children():
			if button is Button:
				button.disabled = false
	
	is_my_turn = true
	extra_turn = is_extra_turn
	if turn_arrow:
		turn_arrow.rotation_degrees = 0  # Повернуть к себе
		
		# Можно добавить эффект для дополнительного хода
		if is_extra_turn:
			# Варианты для визуального выделения дополнительного хода
			turn_arrow.modulate = Color(1, 0.5, 0, 1)  # Оранжевый цвет для дополнительного хода
		else:
			turn_arrow.modulate = Color(1, 1, 1, 1)  # Обычный цвет для стандартного хода

# Создаем и показываем плашку окончания игры
func show_game_over_screen(is_winner: bool):
	# Создаем панель для плашки
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.size = Vector2(500, 300)
	panel.position = Vector2(-250, -150)  # Смещение относительно центра
	
	# Контейнер для элементов
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 20)
	panel.add_child(vbox)
	
	# Заголовок
	var title = Label.new()
	title.text = "Игра окончена!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	vbox.add_child(title)
	
	# Сообщение о результате
	var result = Label.new()
	result.text = "Вы победили!" if is_winner else "Вы проиграли!"
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result.add_theme_font_size_override("font_size", 24)
	vbox.add_child(result)
	
	# Пустое пространство
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(spacer)
	
	# Кнопка возврата в меню
	var button = Button.new()
	button.text = "Вернуться в меню"
	button.custom_minimum_size = Vector2(200, 60)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.connect("pressed", Callable(self, "_on_return_to_menu_pressed"))
	vbox.add_child(button)
	
	# Добавляем плашку на сцену
	add_child(panel)
	
	# Анимация появления
	panel.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.5)

# Возврат в меню
func _on_return_to_menu_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")

# Обработка завершения игры
func handle_game_over(winner_id):
	if game_over:  # Игра уже завершена, не дублируем действия
		return
		
	game_over = true
	winner = winner_id
	
	# Блокируем все кнопки
	disable_all_buttons()
	
	# Обновляем UI для показа победителя
	if status_label:
		var winner_text = "Вы победили!" if winner_id == player_id else "Ваш противник победил!"
		status_label.text = "Игра окончена! " + winner_text
	
	if turn_arrow:
		turn_arrow.visible = false
	
	# Можно добавить какие-то визуальные эффекты или звуки для завершения игры
	print("[GAME OVER] Игра завершена. Победитель: " + winner_id)
	
	# Показываем плашку окончания игры
	show_game_over_screen(winner_id == player_id)

func start_polling():
	# Если игра уже завершена, не делаем опрос
	if game_over:
		return
		
	var url = server_url + "/long-polling-game"
	var body = JSON.stringify({ "gameId": game_id, "playerId": player_id })
	var headers = ["Content-Type: application/json"]
	http.request(url, headers, HTTPClient.METHOD_POST, body)
	print("[DEBUG] Начат опрос сервера: " + url)

func send_action(action: String, kletka: String = ""):
	# Проверка, наш ли сейчас ход и не завершена ли игра
	if !is_my_turn or game_over:
		print("[ERROR] Попытка сделать ход не в свою очередь или после завершения игры!")
		if status_label and !game_over:
			status_label.text = "Сейчас не ваш ход!"
		return false
	
	var url = server_url + "/post-action"
	var body = JSON.stringify({
		"gameId": game_id,
		"playerId": player_id,
		"action": action,
		"kletka": kletka,
		"victim": victim
	})
	var headers = ["Content-Type: application/json"]
	http.request(url, headers, HTTPClient.METHOD_POST, body)
	print("[DEBUG] Отправлено действие: " + action + " по клетке: " + kletka)
	
	# Блокируем кнопки после отправки действия, чтобы избежать двойных кликов
	disable_all_buttons()
	
	return true

func _on_request_completed(result, response_code, headers, body):
	var response = JSON.parse_string(body.get_string_from_utf8())
	print("[DEBUG] Ответ сервера (код " + str(response_code) + "): ", response)

	if response_code != 200:
		if status_label:
			status_label.text = "Ошибка HTTP: " + str(response_code)
		return

	if response.has("error"):
		if status_label:
			status_label.text = "Ошибка: " + response["error"]
		else:
			print("[ERROR] " + response["error"])
		return
	
	# Проверяем, есть ли информация о завершении игры
	if response.has("gameOver") and response.gameOver == true:
		var winner_id = response.winner if response.has("winner") else ""
		handle_game_over(winner_id)
		return
		
	if response.has("move") and response["move"] == "your":
		if status_label:
			status_label.text = "Твой ход! Последний ход: " + str(response.get("previous_move", ""))
		
		# Сохраняем предыдущее состояние координат
		previous_coors = player_coors.duplicate()
		
		# Обновляем свои координаты из ответа
		if response.has("coor") and response["coor"].has(player_id):
			player_coors = response["coor"][player_id]
			print("[DEBUG] Получены обновленные координаты: ", player_coors)
			
			# Проверяем, изменились ли координаты (попал ли противник)
			check_for_hits(previous_coors, player_coors)
			
			update_own_field(player_coors)
		elif response.has("own_coors"):
			player_coors = response["own_coors"]
			print("[DEBUG] Получены собственные координаты: ", player_coors)
			update_own_field(player_coors)
			
		update_opponent_field()  # Сбрасываем иконки оппонента перед новым ходом
		
		# Разблокируем кнопки для нашего хода (обычный ход)
		enable_buttons_for_turn(false)
	else:
		if status_label:
			status_label.text = "Ожидаем оппонента... Последний ход: " + str(response.get("previous_move", ""))
		
		# Убеждаемся, что кнопки заблокированы, когда не наш ход
		disable_all_buttons()
			
		# Проверяем, есть ли информация о последнем ходе противника
		if response.has("previous_move"):
			parse_previous_move(response["previous_move"])
		
		# Проверяем, есть ли информация о последней атаке
		if response.has("attackResult") and response["attackResult"]:
			process_attack_result(response["attackResult"])
			
		start_polling()

	if response.has("status"):
		if status_label:
			var status_text = response["status"]
			
			# Проверяем на дополнительный ход
			var is_extra_turn = response.has("extraTurn") and response.extraTurn == true
			if is_extra_turn and response["status"] == "попал":
				status_text += " — вы получаете дополнительный ход!"
				
			status_label.text = "Результат: " + status_text
		
		# Обработка vertikalim
		if response["action"] == "vertikalim" and response.has("mirrored_coors"):
			player_coors = response["mirrored_coors"]
			NewScript.coordinates = player_coors  # Сохраняем для отладки
			update_own_field(player_coors)
		
		# Обновляем icon для "bombim" на поле оппонента
		if response["action"] == "bombim" and kletka:
			var target_button = find_button_by_name_opponent(kletka)
			if target_button and target_button is Button:
				if response["status"] == "попал":
					target_button.icon = hit_texture
					print("[SUCCESS] Попал по " + kletka + " — установлена текстура " + hit_texture.resource_path)
					
					# Проверяем, получили ли мы дополнительный ход
					if response.has("extraTurn") and response.extraTurn == true:
						print("[BONUS] Вы получили дополнительный ход за попадание!")
						# Разблокируем кнопки для дополнительного хода
						enable_buttons_for_turn(true)
				elif response["status"] == "мимо":
					target_button.icon = miss_texture
					print("[INFO] Промах по " + kletka + " — установлена текстура " + miss_texture.resource_path)

		# Проверяем победу после удара
		if response.has("winner"):
			handle_game_over(response["winner"])
		elif !game_over:
			# Если нет дополнительного хода, начинаем опрос
			if !response.has("extraTurn") or response.extraTurn == false:
				start_polling()

# Обработка результата атаки из ответа сервера
func process_attack_result(attackResult):
	if attackResult == null:
		return
		
	print("[DEBUG] Обработка результата атаки: ", attackResult)
	
	if attackResult.target == player_id:
		# Противник атаковал нас
		print("[ALERT] Противник атаковал нашу клетку: " + attackResult.coordinate)
		
		# Находим соответствующую кнопку на нашем поле
		var target_button = find_button_by_name_own(attackResult.coordinate)
		if target_button and target_button is Button:
			if attackResult.result == "hit":
				target_button.icon = hit_texture
				last_hit_time = Time.get_ticks_msec()
				print("[DEBUG] Отмечено попадание на собственном поле: " + attackResult.coordinate)
				
				# Добавляем в список атак противника с временной меткой
				opponent_attacks.append({
					"coord": attackResult.coordinate, 
					"hit": true, 
					"time": Time.get_ticks_msec()
				})
				
				# Визуальное выделение попадания
				target_button.modulate = Color(1, 0, 0, 1.5)  # Яркий красный цвет
				
				# Если противник получил дополнительный ход, сообщаем об этом
				if attackResult.has("extraTurn") and attackResult.extraTurn == true:
					print("[WARN] Противник попал и получает дополнительный ход!")
					if status_label:
						status_label.text = "Противник попал по вашему кораблю и получает дополнительный ход!"
			elif attackResult.result == "miss":
				print("[DEBUG] Противник промахнулся по клетке: " + attackResult.coordinate)
				
				# Можно визуально показать промах противника
				var miss_indicator = Sprite2D.new()
				miss_indicator.texture = miss_texture
				miss_indicator.scale = Vector2(0.5, 0.5)
				miss_indicator.position = target_button.position + Vector2(target_button.size.x/2, target_button.size.y/2)
				own_control.add_child(miss_indicator)
				
				# Удаляем индикатор промаха через 2 секунды
				var t = Timer.new()
				t.wait_time = 2.0
				t.one_shot = true
				t.connect("timeout", Callable(self, "_on_miss_indicator_timeout").bind(miss_indicator))
				add_child(t)
				t.start()

# Удаление индикатора промаха
func _on_miss_indicator_timeout(indicator):
	if indicator:
		indicator.queue_free()

# Анализирует строку с последним ходом противника
func parse_previous_move(move_text: String):
	if move_text == null or move_text.length() == 0:
		return
		
	print("[DEBUG] Анализ хода: " + move_text)
	
	# Если это сообщение о победе, обрабатываем его
	if move_text.contains("победил") and !game_over:
		print("[GAME INFO] Получено сообщение о завершении игры: " + move_text)
		
		# Определяем победителя из сообщения
		var winner_from_message = ""
		if move_text.begins_with(player_id):
			winner_from_message = player_id
		elif move_text.begins_with(victim):
			winner_from_message = victim
		
		if winner_from_message:
			handle_game_over(winner_from_message)
			return
	
	# Проверяем на попадание по нашим координатам
	if move_text.contains(victim) and move_text.contains("попал по"):
		var parts = move_text.split("попал по")
		if parts.size() > 1:
			var target_coord = parts[1].strip_edges()
			
			# Если указан дополнительный ход, обрабатываем это
			if target_coord.contains(" и получает дополнительный ход"):
				target_coord = target_coord.replace(" и получает дополнительный ход!", "")
			
			print("[ALERT] Противник попал по нашей клетке: " + target_coord)
			
			# Отмечаем попадание на своем поле
			var target_button = find_button_by_name_own(target_coord)
			if target_button:
				target_button.icon = hit_texture
				last_hit_time = Time.get_ticks_msec()
				print("[DEBUG] Отмечено попадание на собственном поле: " + target_coord)
				
				# Добавляем в список атак противника с временной меткой
				opponent_attacks.append({
					"coord": target_coord, 
					"hit": true, 
					"time": Time.get_ticks_msec()
				})
				
				# Визуальное выделение попадания
				target_button.modulate = Color(1, 0, 0, 1.5)  # Яркий красный цвет

# Проверяет, что изменилось в координатах (нашли попадания противника)
func check_for_hits(old_coords: Array, new_coords: Array):
	if old_coords.size() == 0:
		return  # Нет старых координат для сравнения
		
	print("[DEBUG] Проверка попаданий. Старые координаты: ", old_coords)
	print("[DEBUG] Новые координаты: ", new_coords)
	
	var hit_coords = []
	
	# Находим координаты, которые были в старом наборе, но отсутствуют в новом
	for coord in old_coords:
		if not new_coords.has(coord):
			hit_coords.append(coord)
			print("[ALERT] Обнаружено попадание по клетке: " + coord)
	
	# Визуализируем попадания на своем поле
	for hit_coord in hit_coords:
		var target_button = find_button_by_name_own(hit_coord)
		if target_button:
			# Показываем анимацию или эффект попадания
			target_button.icon = hit_texture
			last_hit_time = Time.get_ticks_msec()
			print("[DEBUG] Визуализировано попадание на собственном поле: " + hit_coord)
			
			# Добавляем в список атак противника с временной меткой
			opponent_attacks.append({
				"coord": hit_coord, 
				"hit": true, 
				"time": Time.get_ticks_msec()
			})
			
			# Визуальное выделение попадания
			target_button.modulate = Color(1, 0, 0, 1.5)  # Яркий красный цвет

func find_button_by_name_opponent(name: String) -> Node:
	if opponent_control:
		for button in opponent_control.get_children():
			if button.name == name and button is Button:
				return button
	return null

func find_button_by_name_own(name: String) -> Node:
	if own_control:
		for button in own_control.get_children():
			if button.name == name and (button is Button or button is Node2D or button is Control):
				return button
	print("[WARNING] Не найдена кнопка на собственном поле: " + name)
	return null

func update_own_field(coordinates: Array):
	if not own_control:
		print("[ERROR] OwnControl узел не найден")
		return
	
	print("[DEBUG] Обновление собственного поля с координатами:", coordinates)
	
	# Сбрасываем все иконки и видимость на своём поле (оставляем только корабли)
	for child in own_control.get_children():
		if child is Button or child is Node2D or child is Control:
			child.visible = false
			if child is Button:
				child.icon = null  # Убедимся, что иконки сброшены (только корабли)
	
	# Показываем только свои координаты (корабли)
	for coord in coordinates:
		if typeof(coord) == TYPE_STRING and coord.length() >= 2:
			var letter = coord[0].to_upper()
			var number = coord.substr(1).to_int()
			var node_name = letter + str(number)  # Например, "К10"
			
			var target_node = own_control.get_node_or_null(node_name)
			if target_node and (target_node is Button or target_node is Node2D or target_node is Control):
				target_node.visible = true
				print("[DEBUG] Показан узел (собственное поле):", node_name)
			else:
				print("[WARNING] Узел не найден для координаты:", node_name)
		else:
			print("[WARNING] Некорректная координата (собственное поле):", coord)
	
	# Восстанавливаем отметки о попаданиях противника
	for attack in opponent_attacks:
		if attack.hit:
			var target_button = find_button_by_name_own(attack.coord)
			if target_button and target_button is Button:
				target_button.icon = hit_texture
				print("[DEBUG] Восстановлена отметка попадания на: " + attack.coord)
				
				# Если попадание было недавно, подсвечиваем его
				if attack.has("time") and Time.get_ticks_msec() - attack.time < 2000:
					target_button.modulate = Color(1, 0, 0, 1.5)  # Яркий красный цвет
			
func update_opponent_field():
	if not opponent_control:
		print("[WARNING] OpponentControl не найден")
		return
	
	# Сбрасываем все иконки на поле оппонента (устанавливаем пустую текстуру)
	for child in opponent_control.get_children():
		if child is Button:
			child.icon = default_texture  # Устанавливаем null (пустую текстуру)
			# Убеждаемся, что кнопки активны только когда наш ход и игра не завершена
			child.disabled = !is_my_turn or game_over

# Обработчик для кнопок на поле противника
func _on_opponent_field_button_pressed(button):
	if !is_my_turn or game_over:
		print("[ERROR] Попытка сделать ход не в свою очередь или после завершения игры! Блокируем кнопку.")
		button.disabled = true
		return
		
	kletka = button.name
	if send_action("bombim", kletka):
		print("[ACTION] Bombim на клетку: " + kletka)

func _on_button_pressed(button):
	# Старый обработчик для кнопок - оставляем на случай, если он используется для кнопок действий
	if button.name in opponent_control.get_children().map(func(node): return node.name):
		_on_opponent_field_button_pressed(button)
	else:
		print("[DEBUG] Нажата кнопка действия: " + button.name)

func _on_vertikalim_pressed():
	if !is_my_turn or game_over:
		print("[ERROR] Попытка вертикализироваться не в свою очередь или после завершения игры!")
		return
		
	kletka = ""
	if send_action("vertikalim", kletka):
		print("[ACTION] Vertikalim pressed")

# Для отладки - вывести текущее состояние игры
func debug_game_state():
	print("====== СОСТОЯНИЕ ИГРЫ ======")
	print("Игра: " + game_id)
	print("Игрок: " + player_id)
	print("Противник: " + victim)
	print("Мои координаты: ", player_coors)
	print("Атаки противника: ", opponent_attacks)
	print("Мой ход: ", is_my_turn)
	print("Дополнительный ход: ", extra_turn)
	print("Игра завершена: ", game_over)
	if game_over:
		print("Победитель: ", winner)
	print("==============================")
