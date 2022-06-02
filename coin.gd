extends Area2D


signal coin_collected

@onready var animation_player := $AnimationPlayer as AnimationPlayer


func _on_body_entered(body: Node2D) -> void:
	coin_collected.emit()
	set_deferred("monitoring", false)
	animation_player.play("bounce")
	await animation_player.animation_finished
	queue_free()
