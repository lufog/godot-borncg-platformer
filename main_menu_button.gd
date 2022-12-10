extends Button


@onready var tree := get_tree()


func _on_pressed() -> void:
	tree.change_scene_to_file("res://title_menu.tscn")
