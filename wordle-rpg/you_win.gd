extends Control

func _ready():
	$ScoreContainer/CurrentScore.text = "Current Score : %d" % globals.score
	$ScoreContainer/HighScore.text = "Highest Score : %d" % globals._get_high_score()

func _on_Next_pressed():
		globals.level += 1
		get_tree().change_scene_to_file("res://gameplay.tscn")

func _on_Return_pressed():
	globals.level = 1
	globals.score = 0
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_next_button_button_down() -> void:
	_on_Next_pressed()

func _on_return_button_button_down() -> void:
	_on_Return_pressed()
