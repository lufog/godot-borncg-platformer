extends Node


var max_lives := 3
var lives := max_lives
var hud

@onready var tree := get_tree()


func lose_life() -> void:
	lives -= 1
	hud.update_hearts()
	if lives <= 0:
		lives = max_lives
		hud.update_hearts()
		tree.change_scene_to_file("res://screens/game_over.tscn")
