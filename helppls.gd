extends Button

func _on_pressed() -> void:
	if NewScript.who_to_move == "me":
		NewScript.kletka = self.name
		NewScript.action = "bombim"
