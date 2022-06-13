extends Node2D


@onready var tree := get_tree()


func _on_fall_zone_body_entered(_body: Node2D) -> void:
	if Global.lives >= 1:
		tree.reload_current_scene()
	Global.lose_life()
