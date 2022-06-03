extends CharacterBody2D


@export var direction := -1
@export var detects_cliffs := true

var speed = 100.0
var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as int

@onready var animated_sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var collision := $CollisionShape2D as CollisionShape2D
@onready var floor_checker := $FloorChecker as RayCast2D
@onready var squash_area := $SquashArea as Area2D
@onready var hit_area := $HitArea as Area2D
@onready var timer := $Timer as Timer


func _ready() -> void:
	floor_checker.enabled = detects_cliffs
	_rotate_character()
	if detects_cliffs:
		modulate = Color(1.2, 0.5, 1)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_wall() or detects_cliffs and not floor_checker.is_colliding() and is_on_floor():
		direction = -direction
		_rotate_character()

	if direction:
		velocity.x = direction * speed

	move_and_slide()


func _on_squash_area_body_entered(body: Node2D) -> void:
	animated_sprite.play("squashed")
	speed = 0
	set_collision_layer_value(5, false)
	set_collision_mask_value(1, false)
	squash_area.set_collision_layer_value(5, false)
	squash_area.set_collision_mask_value(1, false)
	hit_area.set_collision_layer_value(5, false)
	hit_area.set_collision_mask_value(1, false)
	timer.start()
	body.bounce()
	await timer.timeout
	queue_free()


func _on_hit_area_body_entered(body: Node2D) -> void:
	body.ouch(position.x)


func _rotate_character() -> void:
	var shape := collision.shape as RectangleShape2D
	floor_checker.position.x = shape.size.x / 2 * direction
	animated_sprite.flip_h = direction > 0
