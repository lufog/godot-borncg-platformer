extends StaticBody2D


var above_ladder := false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _physics_process(_delta: float) -> void:
	if above_ladder and Input.is_action_pressed("down"):
		collision_shape.rotation = deg2rad(180)
	elif not above_ladder:
		collision_shape.rotation = deg2rad(0)


func _on_above_checker_body_entered(_body: Node2D) -> void:
	above_ladder = true


func _on_above_checker_body_exited(_body: Node2D) -> void:
	above_ladder = false
