extends CharacterBody2D


enum States { AIR = 1, FLOOR, LADDER, WALL }

const SPEED = 300.0
const RUN_SPEED = 600.0
const JUMP_VELOCITY = -640.0

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as int
var state := States.AIR
var fireball_scene = preload("res://fireball.tscn") as PackedScene

@onready var tree := get_tree()
@onready var animated_sprite := $AnimatedSprite as AnimatedSprite2D
@onready var timer := $Timer as Timer
@onready var jump_sfx := $JumpSfx as AudioStreamPlayer


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	
	match state:
		States.AIR:
			if is_on_floor():
				state = States.FLOOR
				continue
			
			animated_sprite.play("jump")
			if direction:
				animated_sprite.flip_h = direction < 0
				var decel = 0.1 if abs(velocity.x) < SPEED else 0.03
				velocity.x = lerp(velocity.x, direction * SPEED, decel)
			else:
				velocity.x = lerp(velocity.x, 0, 0.2)
			
			# Add the gravity.
			velocity.y += gravity * delta
			move_and_slide()
			_fire()
			
		States.FLOOR:
			if not is_on_floor():
				state = States.AIR
				continue
			
			if direction:
				animated_sprite.flip_h = direction < 0
				animated_sprite.play("walk")
				if Input.is_action_pressed("run"):
					animated_sprite.speed_scale = 1.8
					velocity.x = lerp(velocity.x, direction * RUN_SPEED, 0.1)
				else:
					animated_sprite.speed_scale = 1
					velocity.x = lerp(velocity.x, direction * SPEED, 0.1)
			else:
				animated_sprite.play("idle")
				velocity.x = lerp(velocity.x, 0, 0.2)
			
			# Handle Jump.
			if Input.is_action_just_pressed("jump"):
				state = States.AIR
				velocity.y = JUMP_VELOCITY
				jump_sfx.play()
			
			move_and_slide()
			_fire()
			
		States.LADDER:
			pass
			
		States.WALL:
			pass


func bounce() -> void:
	velocity.y = JUMP_VELOCITY * 0.7


func ouch(enemy_posx: float) -> void:
	modulate = Color(1, 0.3, 0.3, 0.3)
	velocity.y = JUMP_VELOCITY * 0.5
	
	if position.x < enemy_posx:
		velocity.x = -1400
	elif position.x > enemy_posx:
		velocity.x = 1400
	
	Input.action_release("move_left")
	Input.action_release("move_right")
	timer.start()
	await timer.timeout
	tree.change_scene("res://game_over.tscn")


func _fire() -> void:
	if Input.is_action_just_pressed("fire"):
		var fireball := fireball_scene.instantiate()
		var direction := -1 if animated_sprite.flip_h else 1
		fireball.direction = direction
		fireball.position = position + Vector2(40 * direction, -20)
		get_parent().add_child(fireball)
