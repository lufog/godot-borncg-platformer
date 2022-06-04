extends Button


@onready var tree := get_tree()


func _on_pressed() -> void:
	tree.change_scene("res://level_1.tscn")
