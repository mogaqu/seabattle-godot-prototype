extends Node

var avatar = 0
var player_name = ""
var verification_code = ""
var kletka = ""
var action = ""
var who_to_move = ""
var id_of_opponent = "" #для второго игрока, если будет не первый, то не используется
var kletki = [["А1", "А2", "А3", "А4", "А5", "А6", "А7", "А8", "А9", "А10",
 "Б1", "Б2", "Б3", "Б4", "Б5", "Б6", "Б7", "Б8", "Б9", "Б10",
 "В1", "В2", "В3", "В4", "В5", "В6", "В7", "В8", "В9", "В10",
 "Г1", "Г2", "Г3", "Г4", "Г5", "Г6", "Г7", "Г8", "Г9", "Г10",
 "Д1", "Д2", "Д3", "Д4", "Д5", "Д6", "Д7", "Д8", "Д9", "Д10",
 "Е1", "Е2", "Е3", "Е4", "Е5", "Е6", "Е7", "Е8", "Е9", "Е10",
 "Ж1", "Ж2", "Ж3", "Ж4", "Ж5", "Ж6", "Ж7", "Ж8", "Ж9", "Ж10",
 "З1", "З2", "З3", "З4", "З5", "З6", "З7", "З8", "З9", "З10",
 "И1", "И2", "И3", "И4", "И5", "И6", "И7", "И8", "И9", "И10",
 "К1", "К2", "К3", "К4", "К5", "К6", "К7", "К8", "К9", "К10"]]
# для выбирания координат 
var coordinates = []
var value_count1 = ProjectSettings.get("custom/value_count1")
var value_count2 = ProjectSettings.get("custom/value_count2")
var value_count3 = 0
var value_count4 = 0
var nujno = ProjectSettings.get("custom/nujno_test")
var first_kletka = ProjectSettings.get("custom/first_kletka")
var sigma3 = ProjectSettings.get("custom/sigma3")


func reset_all_values_count():
	# Сброс значений в ProjectSettings
	ProjectSettings.set("custom/value_count1", 0)
	ProjectSettings.set("custom/value_count2", 0)
	ProjectSettings.set("custom/value_count3", 0)
	ProjectSettings.set("custom/value_count4", 0)
	ProjectSettings.save()

	# Сброс глобальных переменных
	value_count1 = 0
	value_count2 = 0
	value_count3 = 0
	value_count4 = 0

func save_value_count1():
	ProjectSettings.set("custom/value_count1", value_count1)
	ProjectSettings.save()

func load_value_count1():
	if ProjectSettings.has_setting("custom/value_count1"):
		value_count1 = ProjectSettings.get("custom/value_count1")


func save_value_count2():
	ProjectSettings.set("custom/value_count2", value_count2)
	ProjectSettings.save()

func load_value_count2():
	if ProjectSettings.has_setting("custom/value_count2"):
		value_count2 = ProjectSettings.get("custom/value_count2")  # Исправлено

func save_nujno_test():
	ProjectSettings.set("custom/nujno_test", nujno)
	ProjectSettings.save()

func load_nujno_test():
	if ProjectSettings.has_setting("custom/nujno_test"):
		nujno = ProjectSettings.get("custom/nujno_test")

func save_first_kletka():
	ProjectSettings.set("custom/first_kletka", first_kletka)
	ProjectSettings.save()

func load_first_kletka():
	if ProjectSettings.has_setting("custom/first_kletka"):
		first_kletka = ProjectSettings.get("custom/first_kletka")

func save_value_count3():
	ProjectSettings.set("custom/value_count3", value_count3)
	ProjectSettings.save()

func load_value_count3():
	if ProjectSettings.has_setting("custom/value_count3"):
		value_count3 = ProjectSettings.get("custom/value_count3")  # Исправлено
func load_sigma3():
	if ProjectSettings.has_setting("custom/sigma3"):
		value_count3 = ProjectSettings.get("custom/sigma3")  # Исправлено
func save_sigma3():
	ProjectSettings.set("custom/sigma3", sigma3)
	ProjectSettings.save()
