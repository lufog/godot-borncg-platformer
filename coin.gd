extends Area2D


signal coin_collected

@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var collect_sfx := $CollectSfx as AudioStreamPlayer


func _on_body_entered(_body: Node2D) -> void:
	coin_collected.emit()
	set_deferred("monitoring", false)
	animation_player.play("bounce")
	collect_sfx.play()
	await animation_player.animation_finished
	queue_free()
