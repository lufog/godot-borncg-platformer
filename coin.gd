extends Area2D


@onready var animation_player := $AnimationPlayer as AnimationPlayer


func _on_body_entered(body: Node2D) -> void:
	animation_player.play("bounce")
	await animation_player.animation_finished
	body.add_coin()
	queue_free()
