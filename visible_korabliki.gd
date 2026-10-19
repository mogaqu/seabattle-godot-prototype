extends Node
var coor = NewScript.coordinates

func _ready():
	print("alo")
	for y in range(self.get_child_count()):
		for i in range(coor.size()):
			var nushnaya_coordinata = coor[i]
			var realniy_rebenok_object = self.get_child(y)
			if nushnaya_coordinata.contains(realniy_rebenok_object.name):
				realniy_rebenok_object.visible = true
				print("rabotaet")
			else:
				print("ne rabotaet")
