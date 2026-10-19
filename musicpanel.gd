# Musicpanel.gd
extends Node

var settings_panel = null
var is_dragging = false
var drag_start_position = Vector2()

func panel():
	print("Panel function called")
	if settings_panel and is_instance_valid(settings_panel):
		print("Panel already exists, showing it")
		settings_panel.show()
		return
	
	print("Creating new panel")
	# Создаем панель
	settings_panel = Panel.new()
	settings_panel.size = Vector2(400, 300)  # Устанавливаем размер сразу после создания
	settings_panel.position = Vector2(100, 100)  # Фиксированная начальная позиция в видимой области
	settings_panel.z_index = 20  # Высокий z_index для отображения поверх всех элементов

	# Пытаемся найти Control в сцене под Node2D
	var control_node = get_tree().root.get_node_or_null("Node2D/Control")
	if control_node:
		control_node.add_child(settings_panel)  # Добавляем панель в Control
		print("Panel added to Control under Node2D")
	else:
		get_tree().root.add_child(settings_panel)  # Если Control нет, добавляем в корень
		print("Panel added to root")

	# Добавляем стиль с цветным фоном
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.8)  # Полупрозрачный серый фон
	settings_panel.add_theme_stylebox_override("panel", style)
	print("Panel style applied with color: ", style.bg_color)
	
	# Контейнер для элементов
	var vbox = VBoxContainer.new()
	vbox.size = settings_panel.size  # Устанавливаем размер контейнера равным размеру панели
	settings_panel.add_child(vbox)
	print("VBox container added to panel with size: ", vbox.size)
	
	# Выбор музыкального трека
	var music_label = Label.new()
	music_label.text = "Выбор музыки"
	vbox.add_child(music_label)
	print("Music label added to vbox with text: ", music_label.text)
	
	var music_options = OptionButton.new()
	music_options.add_item("Трек 1", 0)
	music_options.add_item("Трек 2", 1)
	music_options.add_item("Трек 3", 2)
	music_options.connect("item_selected", _on_music_selected)
	vbox.add_child(music_options)
	print("Music options added to vbox with items: ", music_options.get_item_count())
	
	# Опция зацикливания музыки
	var loop_label = Label.new()
	loop_label.text = "Зациклить музыку"
	vbox.add_child(loop_label)
	print("Loop label added to vbox with text: ", loop_label.text)
	
	var loop_toggle = CheckButton.new()
	loop_toggle.button_pressed = true  # По умолчанию зацикливание включено
	loop_toggle.connect("toggled", _on_loop_toggled)
	vbox.add_child(loop_toggle)
	print("Loop toggle added to vbox with state: ", loop_toggle.button_pressed)
	
	# Тестовый текст для проверки видимости (можно убрать, если не нужен)
	var test_label = Label.new()
	test_label.text = "Тестовая панель"
	test_label.add_theme_color_override("font_color", Color.RED)  # Красный текст для заметности
	vbox.add_child(test_label)
	print("Test label added to vbox with text: ", test_label.text, " and color: ", test_label.get_theme_color("font_color"))

	# Громкость
	var volume_label = Label.new()
	volume_label.text = "Громкость"
	vbox.add_child(volume_label)
	print("Volume label added to vbox with text: ", volume_label.text)
	
	var volume_slider = HSlider.new()
	volume_slider.min_value = -80
	volume_slider.max_value = 0
	volume_slider.value = AudioServer.get_bus_volume_db(0)
	volume_slider.connect("value_changed", _on_volume_changed)
	vbox.add_child(volume_slider)
	print("Volume slider added to vbox with value: ", volume_slider.value)
	
	# Полноэкранный режим
	var fullscreen_label = Label.new()
	fullscreen_label.text = "Полноэкранный режим"
	vbox.add_child(fullscreen_label)
	print("Fullscreen label added to vbox with text: ", fullscreen_label.text)
	
	var fullscreen_toggle = CheckButton.new()
	fullscreen_toggle.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen_toggle.connect("toggled", _on_fullscreen_toggled)
	
	# Настраиваем выравнивание текста в CheckButton
	var label_settings = LabelSettings.new()
	
	vbox.add_child(fullscreen_toggle)
	print("Fullscreen toggle added to vbox with state: ", fullscreen_toggle.button_pressed)
	
	# Кнопка закрытия
	var close_button = Button.new()
	close_button.text = "Закрыть"
	close_button.connect("pressed", _on_close_button_pressed)
	vbox.add_child(close_button)
	print("Close button added to vbox with text: ", close_button.text)

	# Подключаем сигнал для перетаскивания панели
	settings_panel.connect("gui_input", _on_panel_gui_input)
	
	# Скрываем панель по умолчанию
	settings_panel.hide()
	print("Panel created and hidden")

func show_settings():
	print("Show settings called")
	if settings_panel:
		settings_panel.show()
		print("Panel shown at position: ", settings_panel.position, " with size: ", settings_panel.size, " and z_index: ", settings_panel.z_index)

func _on_panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_position = event.position  # Сохраняем начальную позицию мыши относительно панели
			else:
				is_dragging = false  # Завершаем перетаскивание
	elif event is InputEventMouseMotion and is_dragging:
		# Перемещаем панель на разницу между текущей позицией мыши и начальной
		var new_position = settings_panel.position + (event.position - drag_start_position)
		settings_panel.position = new_position
		print("Panel dragged to: ", new_position)

func _on_volume_changed(value):
	print("Volume changed to: ", value)
	AudioServer.set_bus_volume_db(0, value)

func _on_fullscreen_toggled(button_pressed):
	print("Fullscreen toggled to: ", button_pressed)
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_close_button_pressed():
	print("Close button pressed")
	if settings_panel:
		settings_panel.hide()
		print("Panel hidden")

func _on_music_selected(index):
	print("Music selection changed to index: ", index)
	var music_paths = [
		preload("res://Sounds/track1.mp3"),  # Замени на реальный путь к первому треку
		preload("res://Sounds/track2.mp3"),  # Замени на реальный путь ко второму треку
		preload("res://Sounds/track3.mp3")   # Замени на реальный путь к третьему треку
	]
	if index >= 0 and index < music_paths.size():
		Music.play_music(music_paths[index])
		Music.set_loop(true)  # Включаем зацикливание по умолчанию при выборе трека
	else:
		print("Invalid music track selected")

func _on_loop_toggled(button_pressed):
	print("Loop toggled to: ", button_pressed)
	Music.set_loop(button_pressed)  # Устанавливаем зацикливание для текущего трека
	if Music.audio_player.playing and not button_pressed:
		# Если музыка играет, но зацикливание выключено, ждём окончания трека и останавливаем
		await Music.audio_player.finished
		if not Music.is_looping:  # Проверяем флаг is_looping
			Music.audio_player.stop()
