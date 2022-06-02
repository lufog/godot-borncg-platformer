extends CharacterBody2D


const SPEED = 100.0
enum Direction { LEFT, RIGHT }

@export var start_direction: Direction
@export var detects_cliffs := true

var direction := 0
var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as int

@onready var animated_sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var collision := $CollisionShape2D as CollisionShape2D
@onready var floor_checker := $FloorChecker as RayCast2D


func _ready() -> void:
	floor_checker.enabled = detects_cliffs
	direction = -1 if (start_direction == Direction.LEFT) else 1
	_rotate_character()
	


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_wall() or detects_cliffs and not floor_checker.is_colliding() and is_on_floor():
		direction = -direction
		_rotate_character()

	if direction:
		velocity.x = direction * SPEED

	move_and_slide()


func _rotate_character() -> void:
	var shape := collision.shape as RectangleShape2D
	floor_checker.position.x = shape.size.x / 2 * direction
	animated_sprite.flip_h = direction > 0
