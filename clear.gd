#скрипт дял сброса
extends Button

func _on_pressed():
	# Сбрасываем значения в ProjectSettings
	ProjectSettings.set("custom/value_count1", 0)
	ProjectSettings.set("custom/value_count2", 0)
	ProjectSettings.set("custom/nujno_test", [])
	ProjectSettings.set("custom/first_kletka", "")
	ProjectSettings.save()

	# Загружаем новые значения в переменные NewScript
	NewScript.load_value_count1()
	NewScript.load_value_count2()
	NewScript.load_nujno_test()
	NewScript.load_first_kletka()

	# Проверка обновленных значений
	print("value_count1:", NewScript.value_count1)
	print("value_count2:", NewScript.value_count2)
	print("nujno:", NewScript.nujno)
	print("first_kletka:", NewScript.first_kletka)

	# Перезапуск сцены
	get_tree().change_scene_to_file("res://game_1.tscn")
