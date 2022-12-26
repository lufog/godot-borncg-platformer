extends StaticBody2D


signal button_pushed

var on_button := false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var collision_top: CollisionShape2D = $CollisionTop
@onready var top_checker: Area2D = $TopChecker
@onready var sound_player: AudioStreamPlayer = $SoundPlayer


func _physics_process(_delta: float) -> void:
	if on_button and Input.is_action_pressed("down"):
		animated_sprite.play("down")
		sound_player.play()
		top_checker.monitoring = false
		collision_top.position.y = -19
		(collision_top.shape as CapsuleShape2D).height = 24
		button_pushed.emit()


func _on_top_checker_body_entered() -> void:
	on_button = true


func _on_top_checker_body_exited() -> void:
	on_button = false
