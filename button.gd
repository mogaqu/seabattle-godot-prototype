extends Node2D

var vibrano = "igra"
var array = ["igra", "pravila", "settings"]
var slovarik = {"igra": 0, "pravila": 1, "settings": 2}

@onready var igra = $Button
@onready var pravila = $Button2
@onready var settings = $Button3

var scale_duration = 0.3  # Increased animation duration slightly
var current_tween = null  # Track the active tween
var hover_offset = Vector2(30, 0)  # Offset for selected button
var original_positions = []  # Store the original positions of buttons

func _ready():
	print("Ready called")
	Musicpanel.panel()
	Music.play_music(preload("res://Sounds/track1.mp3"))
	
	# Store original button positions
	original_positions = [$Button.position, $Button2.position, $Button3.position]
	
	update_button_sizes()  # Set initial button states

func enter():
	if vibrano == "igra":
		get_tree().change_scene_to_file("res://game_1.tscn")
	elif vibrano == "pravila":
		get_tree().change_scene_to_file("res://pravila.tscn")
	elif vibrano == "settings":
		Musicpanel.show_settings()

func update_button_sizes():
	# Stop any existing tween to prevent overlap
	if current_tween:
		current_tween.kill()
	current_tween = create_tween()
	
	if current_tween:
		var selected_scale = Vector2(1.3, 1.3)  # Increased scale for selected button
		var normal_scale = Vector2(0.9, 0.9)    # Slightly smaller scale for unselected buttons
		var selected_alpha = 1.0                # Fully opaque
		var normal_alpha = 0.5                  # 50% transparent
		var selected_rotation = 0.05            # Slight rotation for selected button
		var normal_rotation = 0.0               # No rotation for unselected buttons
		
		var buttons = [igra, pravila, settings]
		var selected_button = buttons[slovarik[vibrano]]
		
		# Animate all buttons in parallel with enhanced effects
		for i in range(buttons.size()):
			var button = buttons[i]
			var is_selected = button == selected_button
			
			# Target values based on selection state
			var target_scale = selected_scale if is_selected else normal_scale
			var target_alpha = selected_alpha if is_selected else normal_alpha
			var target_rotation = selected_rotation if is_selected else normal_rotation
			
			# Get original position and set target position
			var original_position = original_positions[i]
			var target_position = Vector2(original_position.x, original_position.y)
			
			if is_selected:
				target_position.x += hover_offset.x
			
			# Color effect - make selected button slightly yellow tinted
			var target_color = Color(1.0, 1.0, 0.8, target_alpha) if is_selected else Color(1, 1, 1, target_alpha)
			
			# Scale animation with bounce for selected button
			var trans_type = Tween.TRANS_ELASTIC if is_selected else Tween.TRANS_QUAD
			var ease_type = Tween.EASE_OUT
			
			current_tween.parallel().tween_property(
				button, "scale", target_scale, scale_duration
			).set_trans(trans_type).set_ease(ease_type)
			
			# Position animation - always tween to absolute position
			current_tween.parallel().tween_property(
				button, "position", target_position, scale_duration
			).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			
			# Rotation animation
			current_tween.parallel().tween_property(
				button, "rotation", target_rotation, scale_duration
			).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			
			# Color/opacity animation
			current_tween.parallel().tween_property(
				button, "modulate", target_color, scale_duration
			).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	else:
		print("Ошибка: Главный Tween не создан!")

func _input(event):
	if event.is_action_pressed("s"):  # Down (mapped to "W")
		if vibrano != "settings":
			vibrano = array[slovarik[vibrano] + 1]
			update_button_sizes()
		print("Переключение вниз (W)")
	elif event.is_action_pressed("w or up"):  # Up (mapped to "S")
		if vibrano != "igra":
			vibrano = array[slovarik[vibrano] - 1]
			update_button_sizes()
		print("Переключение вверх (S)")
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("Enter"):  # Enter key
		enter()

func _on_settings_button_pressed():
	Musicpanel.show_settings()

func _on_button_pressed():
	get_tree().change_scene_to_file("res://game_1.tscn")

func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://pravila.tscn")
