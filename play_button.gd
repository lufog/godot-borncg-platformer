extends Button


@onready var tree := get_tree()


func _on_pressed() -> void:
	Global.lives = Global.max_lives
	tree.change_scene_to_file("res://level_1.tscn")
