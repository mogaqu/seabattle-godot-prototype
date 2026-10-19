extends LineEdit

var name1 = NewScript.player_name

# Called when the node enters the scene tree for the first time.
func _ready():
	print("dwa")

func _input(event):
	if Input.is_action_pressed("Enter") or get_node("../Button").is_pressed():
		if NewScript.value_count1 == 4 and NewScript.value_count2 == 6 and NewScript.value_count3 == 6:
			self.set_editable(false)
			NewScript.player_name = %LineEdit.text
			NewScript.avatar = %OptionButton.get_selected_id()
			var arr = NewScript.coordinates
			var seen = {}
			var unique_arr = []  
			for element in arr:
				if not seen.has(element):
					unique_arr.append(element)
					seen[element] = true

			print(unique_arr)
			NewScript.coordinates = unique_arr
			print(NewScript.avatar)
			get_tree().change_scene_to_file("res://choose.tscn")
