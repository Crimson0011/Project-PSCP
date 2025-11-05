extends Node

var level = 1
var score = 0
var answer = ""

func _get_high_score():
	var save = FileAccess.open("user://save.dat", FileAccess.READ)
	if save:
		return int(save.get_line())
	return 0
	
