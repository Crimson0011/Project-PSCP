extends Control

func _ready():
	$Container/CurrentScore.text = "Current Score : %d" % globals.score
	$Container/HighScore.text = "Highest Score : %d" % globals._get_high_score()
	$Container/CorrectAnswer.text = "Correct Answer : %s" % globals.answer

func _on_Return_pressed():
	globals.level = 1
	globals.score = 0
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_return_button_button_down() -> void:
	$"../AudioStreamPlayer2D2".play()
	await $"../AudioStreamPlayer2D2".finished
	_on_Return_pressed()
