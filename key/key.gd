extends Area2D



@export var hud: Hud

@onready var collect_sfx: AudioStreamPlayer = $CollectSfx


func _on_body_entered(_body: Node2D) -> void:
	collect_sfx.play()
	hud.has_key = true
	hide()
	set_deferred("monitoring", false)
	await collect_sfx.finished
	queue_free()
