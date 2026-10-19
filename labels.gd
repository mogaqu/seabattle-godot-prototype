extends Node
var urname = NewScript.player_name
var opponent_name = NewScript.id_of_opponent
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var labels = self.get_children()
	print(labels[1], labels[0])
	labels[0].text = ("Оппонент: %s" % opponent_name).format(opponent_name)
	labels[1].text = ("Вы: %s" % urname).format(urname)
	labels[2].text = ("Игра против %s" % opponent_name).format(opponent_name)
