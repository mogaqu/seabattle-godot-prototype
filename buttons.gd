#самый мощный скрипт для задания координат(короче, для логики выбирания кораблей)
extends Button
var coordinate = NewScript.coordinates
var is_button_3_pressed = false
var is_button_4_pressed = false
var button_name = str(self.name)
var linija = null # true - это горизонталь, false - вертикаль
var first_kletka = ""
var first_cifra = null
var is_button_5_pressed = false
var sigma = ProjectSettings.get_setting("custom/sigma3", [])
var slovar = {
"А": 1, "Б": 2, "В": 3, "Г": 4, "Д": 5, "Е": 6, "Ж": 7, "З": 8, "И": 9, "К": 10
}
var bukovki = ["А", "Б", "В", "Г", "Д", "Е", "Ж", "З", "И", "К"]
var touched = false

func _ready():
	NewScript.reset_all_values_count()
	ProjectSettings.set_setting("custom/sigma3", [])
	NewScript.load_value_count3()
	if NewScript.value_count3 != 0:
		ProjectSettings.set_setting("custom/value_count3", 0)
	if NewScript.value_count1 != 0:
		ProjectSettings.set_setting("custom/value_count1", 0)
	
	if NewScript.value_count2 != 0:
		ProjectSettings.set_setting("custom/value_count2", 0)
	ProjectSettings.save()
	is_button_3_pressed = false
	is_button_4_pressed = false
	is_button_5_pressed = false
func _on_button_4_pressed():
	is_button_4_pressed = true
	var touched = true
func _on_button_3_pressed():
	is_button_3_pressed = true
	var touched = true 
func _on_button_5_pressed():
	is_button_5_pressed = true
	var touched = true
func _block_me():
	var bukva_index = slovar[str(self.name)[0]]
				
	for i in range(3):
		var block_bukovka_index = bukva_index - 2 + i
		if block_bukovka_index < 0 or block_bukovka_index >= bukovki.size():
			continue
		var block_bukovka = bukovki[block_bukovka_index]
					
		for y in range(3):
			var block_ciferka = int(str(self.name).substr(1, button_name.length() - 1)) - 1 + y
			var kletka = block_bukovka + str(block_ciferka)
			var ban_kletka = get_parent().get_node(kletka)
			if ban_kletka:
				ban_kletka.disabled = true
func _block_first_kletka():
	NewScript.load_first_kletka()
	print(first_kletka)
	var bukva_index = slovar[NewScript.first_kletka[0]]
				
	for i in range(3):
		var block_bukovka_index = bukva_index - 2 + i
		if block_bukovka_index < 0 or block_bukovka_index >= bukovki.size():
			continue
		var block_bukovka = bukovki[block_bukovka_index]
					
		for y in range(3):
			var block_ciferka = int(NewScript.first_kletka.substr(1, button_name.length() - 1)) - 1 + y
			var kletka = block_bukovka + str(block_ciferka)
			var ban_kletka = get_parent().get_node(kletka)
			if ban_kletka:
				ban_kletka.disabled = true

func _on_pressed():
	if not is_button_3_pressed and not is_button_4_pressed and not is_button_5_pressed:
		return
	if self.disabled:
		return
	if is_button_3_pressed == true and NewScript.value_count1 == 4:
		is_button_3_pressed = false
		$"../../Катер".disabled = true
		touched = false
	
	if is_button_5_pressed and NewScript.value_count3 !=6:
		var button_name = str(self.name)
		var bukva = button_name[0]
		var cifra = int(button_name.substr(1, button_name.length() - 1))
		if int(NewScript.value_count3) % 3 == 0:
			NewScript.first_kletka = button_name
			NewScript.save_first_kletka()
			NewScript.nujno = []
			if sigma == null:
				sigma = []
				ProjectSettings.set_setting("custom/sigma3", sigma)
				ProjectSettings.save()
			sigma.append(str(self.name))
			ProjectSettings.set_setting("custom/sigma3", sigma)
			ProjectSettings.save()
			for i in range(3): 
				var block_bukovka_index = slovar[bukva] - 2 + i
				if block_bukovka_index < 0 or block_bukovka_index >= bukovki.size():
					continue
				var block_bukovka = bukovki[block_bukovka_index]
				for y in range(3):
					var block_ciferka = cifra - 1 + y
					var kletka = block_bukovka + str(block_ciferka)
					if block_bukovka == bukva or block_ciferka == cifra:
						NewScript.nujno.append(kletka)
					else:
						var ban_kletka = get_parent().get_node(kletka)
						if ban_kletka:
							ban_kletka.disabled = true

			self.disabled = true
			self.icon = load("res://New Piskel (2).png")
			NewScript.value_count3 += 1
			NewScript.save_value_count3()
			NewScript.coordinates.append(button_name)
			return
			
	# Второй ход
		elif NewScript.value_count3 % 3 == 1:
			if sigma == null:
				sigma = []
				ProjectSettings.set_setting("custom/sigma3", sigma)
				ProjectSettings.save()
			sigma.append(str(self.name))
			
			ProjectSettings.set_setting("custom/sigma3", sigma)
			ProjectSettings.save()
			if button_name not in NewScript.nujno:
				return
			

			if bukva in NewScript.first_kletka:
				linija = "vert"  # Направление вертикаль
			elif str(cifra) in NewScript.first_kletka:
				linija = "horiz"  # Направление горизонталь
			else:
				NewScript.value_count3 -= 1
				return

			NewScript.nujno = []  # Очищаем список допустимых клеток
			_block_first_kletka()
			for i in range(3):  # Радиус 3x3
				var block_bukovka_index = slovar[bukva] - 2 + i  # Рассчитываем индекс буквы
				if block_bukovka_index < 0 or block_bukovka_index >= bukovki.size():
					continue
				var block_bukovka = bukovki[block_bukovka_index]
				for j in range(3):  # Рассчитываем индекс цифры
					var block_ciferka = cifra - 1 + j
					if block_ciferka < 1 or block_ciferka > 10:  # Убедимся, что цифра в границах поля
						continue
					var kletka = block_bukovka + str(block_ciferka)
					if linija == "vert" and block_bukovka == bukva:  # Проверяем горизонталь
						NewScript.nujno.append(kletka)
						NewScript.save_nujno_test()
						print("Список допустимых клеток:", NewScript.nujno)
					elif linija == "horiz" and block_ciferka == cifra:  # Проверяем вертикаль
						NewScript.nujno.append(kletka)
						NewScript.save_nujno_test()
						print("Список допустимых клеток:", NewScript.nujno)
					else:
						var ban_kletka = get_parent().get_node(kletka)
						if ban_kletka:
							ban_kletka.disabled = true
			self.disabled = true
			self.icon = load("res://New Piskel (2).png")
			NewScript.value_count3 += 1
			NewScript.save_value_count3()
			NewScript.coordinates.append(button_name)
			
			return

	# Третий ход
		elif NewScript.value_count3 % 3 == 2:
			print("Текущие допустимые клетки:", NewScript.nujno)
			print("Текущая кнопка:", button_name)
			if sigma == null:
				sigma = []
				ProjectSettings.set_setting("custom/sigma3", sigma)
				ProjectSettings.save()
			sigma.append(str(self.name))
			ProjectSettings.set_setting("custom/sigma3", sigma)
			ProjectSettings.save()
			if button_name not in NewScript.nujno:
				print("Клетка", button_name, "не в списке допустимых!")
				return
			if NewScript.value_count3 == 5:
				$"../../Линкор".disabled = true
			for i in range(3):  # Радиус 3x3
				var block_bukovka_index = slovar[bukva] - 2 + i
				if block_bukovka_index < 0 or block_bukovka_index >= bukovki.size():
					continue
				var block_bukovka = bukovki[block_bukovka_index]
				for y in range(3):
					var block_ciferka = cifra - 1 + y
					var kletka = block_bukovka + str(block_ciferka)
					var ban_kletka = get_parent().get_node(kletka)
					if ban_kletka:
						ban_kletka.disabled = true
			self.disabled = true
			_block_me()
			self.icon = load("res://New Piskel (2).png")
			NewScript.value_count3 += 1
			NewScript.save_value_count3()
			
			NewScript.coordinates.append(button_name)
			
			

	if is_button_4_pressed and NewScript.value_count2 != 6:
		
		if touched == true and NewScript.value_count2 == 0:
			return
		if true:
			if NewScript.value_count2 == 5:
				$"../../Эсминец".disabled = true
				touched = false
			NewScript.value_count2 += 1
			var button_name = str(self.name)
			
			var bukva = button_name[0]
			var cifra = int(button_name.substr(1, button_name.length() - 1))

			
			
			if NewScript.value_count2 % 2 == 0 and slovar.has(bukva):
				var bukva_index = slovar[bukva]
				if str(self.name) in NewScript.nujno:
					print("good")
				else:
					NewScript.value_count2 -=1
					touched = true
					return
				for i in range(3):
					var block_bukovka_index = slovar[bukva] - 2 + i
					if block_bukovka_index < 0 or block_bukovka_index >= bukovki.size():
						continue
					var block_bukovka = bukovki[block_bukovka_index]
						
					for y in range(3):
						var block_ciferka = cifra - 1 + y
						var kletka = block_bukovka + str(block_ciferka)
						var ban_kletka = get_parent().get_node(kletka)
						if ban_kletka:
							ban_kletka.disabled = true
					print("Имя кнопки: ", button_name)
					NewScript.coordinates.append(button_name)
					print(NewScript.coordinates)
					self.icon = load("res://New Piskel (2).png")
					NewScript.save_value_count2()
				for i in range(3):
					
					if NewScript.first_kletka == "" or NewScript.first_kletka.length() < 1:
						print("Ошибка: first_kletka пустая!") #чини всё ярик
						return

					var block_bukovka_index = slovar[NewScript.first_kletka[0]] - 2 + i
					if block_bukovka_index < 0 or block_bukovka_index >= bukovki.size():
						continue
					var block_bukovka = bukovki[block_bukovka_index]
						
					for y in range(3):
						if NewScript.first_kletka.length() == 3:
							first_cifra = 10
						else:
							first_cifra = int(NewScript.first_kletka[1])
						var block_ciferka = first_cifra - 1 + y
						var kletka = block_bukovka + str(block_ciferka)
							
						var ban_kletka = get_parent().get_node(kletka)
						if ban_kletka:
							ban_kletka.disabled = true
					print("Имя кнопки: ", button_name)
					self.icon = load("res://New Piskel (2).png")
					NewScript.save_value_count2()
			else:
				if is_button_3_pressed or is_button_5_pressed:
					is_button_3_pressed = false
					is_button_5_pressed = false
				var bukva_index = slovar[bukva]
				for i in range(3):
					var block_bukovka_index = bukva_index - 2 + i
					
					if block_bukovka_index < 0 or block_bukovka_index >= bukovki.size():
						continue
					var block_bukovka = bukovki[block_bukovka_index]
					
					for y in range(3):
						var block_ciferka = cifra - 1 + y
						var kletka = block_bukovka + str(block_ciferka)
						if block_bukovka == bukva or block_ciferka == cifra:
							NewScript.nujno.append(kletka)
							NewScript.save_nujno_test()
							continue
						else:
							var ban_kletka = get_parent().get_node(kletka)
							if ban_kletka:
								ban_kletka.disabled = true
				NewScript.first_kletka = str(self.name)
				print(NewScript.first_kletka)
				NewScript.save_first_kletka()
				print("Имя кнопки: ", button_name)
				print(coordinate)
				NewScript.coordinates.append(button_name)
				self.disabled = true
				NewScript.save_value_count2()
				self.icon = load("res://New Piskel (2).png")
	if is_button_3_pressed:

		if NewScript.value_count1 != 4:
			if touched == true and NewScript.value_count1 == 0:
				return
			if NewScript.value_count1 == 3:
				$"../../Катер".disabled = true
				touched = false
			NewScript.value_count1 += 1
			self.icon = load("res://New Piskel (2).png")

			var button_name = str(self.name)
			
			if button_name.length() < 2:
				return
			
			var bukva = button_name[0]
			var cifra = int(button_name.substr(1, button_name.length() - 1))
			
			if slovar.has(bukva):
				var bukva_index = slovar[bukva]
				
				for i in range(3):
					var block_bukovka_index = bukva_index - 2 + i
					if block_bukovka_index < 0 or block_bukovka_index >= bukovki.size():
						continue
					var block_bukovka = bukovki[block_bukovka_index]
					
					for y in range(3):
						var block_ciferka = cifra - 1 + y
						var kletka = block_bukovka + str(block_ciferka)
						var ban_kletka = get_parent().get_node(kletka)
						if ban_kletka:
							ban_kletka.disabled = true
				print("Имя кнопки: ", button_name)
				NewScript.coordinates.append(button_name)
				print(NewScript.coordinates)
				self.disabled = true
				NewScript.save_value_count1()
