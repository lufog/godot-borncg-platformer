extends Node2D


@onready var tree := get_tree()


func _on_fall_zone_body_entered(_body: Node2D) -> void:
	tree.change_scene("res://level_1.tscn")
