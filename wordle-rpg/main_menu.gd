extends Control

func _ready() -> void:
	pass # Replace with function body.

func _on_start_button_button_down() -> void:
	$"../VBoxContainer/AudioStreamPlayer2D3".play()
	await $"../VBoxContainer/AudioStreamPlayer2D3".finished
	get_tree().change_scene_to_file("res://gameplay.tscn")

func _on_quit_button_button_down() -> void:
	get_tree().quit()

func _on_start_button_mouse_entered():
	$"../AudioStreamPlayer2D".play()
	
func _on_quit_button_mouse_entered():
	$"../AudioStreamPlayer2D".play()
