extends CharacterBody2D


const SPEED = 400.0
const BOUNCE = -300.0

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: float = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var sfx: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	velocity.x = direction * SPEED


func _physics_process(delta: float) -> void:
	sprite.rotation += deg_to_rad(25) * direction
	
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = BOUNCE
	
	if is_on_wall():
		queue_free()
	
	move_and_slide()


func _on_screen_exited() -> void:
	queue_free()


func _on_timer_timeout() -> void:
	sfx.play()
