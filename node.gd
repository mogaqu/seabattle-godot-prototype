extends Node

func become_host():
	get_tree().change_scene_to_file("res://kodvvedite1.tscn")
#	%MultiplayerHUD.hide()
#	MultiplayerManager.become_host()

func join_as_player_2():
	get_tree().change_scene_to_file("res://kodvvedite2.tscn")
#	print("ur player2")
#	%MultiplayerHUD.hide()
#	MultiplayerManager.join_as_player_2()
