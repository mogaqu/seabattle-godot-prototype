extends Label
var wegotit = false



func _on_timer_timeout():
	if wegotit == true:
		return
	if NewScript.verification_code != "":
		$".".text = NewScript.verification_code
		wegotit = true
