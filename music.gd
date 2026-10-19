# Music.gd
extends Node

var audio_player = AudioStreamPlayer.new()
var is_looping = true  # Флаг для управления зацикливанием

func _ready():
	add_child(audio_player)
	# Подключаем сигнал finished для ручного зацикливания
	audio_player.connect("finished", _on_music_finished)

func play_music(stream):
	if stream is AudioStream:
		audio_player.stream = stream
		# Проверяем, поддерживает ли стрим зацикливание
		if "loop" in stream:
			stream.loop = is_looping  # Устанавливаем зацикливание в соответствии с флагом
		audio_player.play()

func stop_music():
	audio_player.stop()
	audio_player.disconnect("finished", _on_music_finished)  # Отключаем сигнал при остановке

func set_loop(enabled: bool):
	is_looping = enabled  # Устанавливаем флаг зацикливания
	if audio_player.stream and "loop" in audio_player.stream:
		audio_player.stream.loop = enabled  # Устанавливаем зацикливание для стрима, если поддерживается
	# Обновляем подключение сигнала в зависимости от состояния
	if enabled:
		if not audio_player.is_connected("finished", _on_music_finished):
			audio_player.connect("finished", _on_music_finished)
	else:
		if audio_player.is_connected("finished", _on_music_finished):
			audio_player.disconnect("finished", _on_music_finished)
		# Если музыка играет и зацикливание выключено, останавливаем её после текущего проигрывания
		if audio_player.playing:
			await audio_player.finished  # Ждём окончания текущего трека
			if not is_looping:
				audio_player.stop()

func _on_music_finished():
	if is_looping and audio_player.stream:
		audio_player.play()  # Ручное зацикливание, если флаг включён
