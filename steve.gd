extends CharacterBody2D


enum States { AIR = 1, FLOOR, LADDER, WALL }

const SPEED = 300.0
const RUN_SPEED = 600.0
const JUMP_VELOCITY = -640.0

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as int
var facing_direction := 1.0
var last_jump_direction := 0.0
var on_ladder := false
var hurt := 0
var state := States.AIR
var fireball_scene = preload("res://fireball.tscn") as PackedScene

@onready var animated_sprite := $AnimatedSprite as AnimatedSprite2D
@onready var timer := $Timer as Timer
@onready var jump_sfx := $JumpSfx as AudioStreamPlayer
@onready var wall_checker := $WallChecker as RayCast2D


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction:
		facing_direction = ceil(direction)
		animated_sprite.flip_h = direction < 0
	
	match state:
		States.AIR:
			if is_on_floor() and velocity.y == 0:
				state = States.FLOOR
				continue
			elif _is_near_wall():
				state = States.WALL
				continue
			elif _should_climb_ladder():
				state = States.LADDER
				continue
			
			animated_sprite.play("jump")
			if direction:
				var decel = 0.1 if abs(velocity.x) < SPEED else 0.03
				velocity.x = lerpf(velocity.x, direction * SPEED, decel)
			else:
				velocity.x = lerpf(velocity.x, 0.0, 0.2)
			
			# Add the gravity.
			velocity.y += gravity * delta
			move_and_slide()
			_fire()
		
		States.FLOOR:
			if not is_on_floor():
				state = States.AIR
				continue
			elif _should_climb_ladder():
				state = States.LADDER
				continue
			
			if direction:
				animated_sprite.play("walk")
				if Input.is_action_pressed("run"):
					animated_sprite.speed_scale = 1.8
					velocity.x = lerp(velocity.x, direction * RUN_SPEED, 0.1)
				else:
					animated_sprite.speed_scale = 1
					velocity.x = lerp(velocity.x, direction * SPEED, 0.1)
			else:
				animated_sprite.play("idle")
				velocity.x = lerpf(velocity.x, 0.0, 0.2)
			
			# Handle Jump.
			if Input.is_action_just_pressed("jump"):
				state = States.AIR
				velocity.y = JUMP_VELOCITY
				jump_sfx.play()
			
			move_and_slide()
			_fire()
		
		States.LADDER:
			if not on_ladder:
				state = States.AIR
				continue
			elif is_on_floor() and Input.is_action_pressed("down") and velocity.y == 0:
				state = States.FLOOR
				Input.action_release("down")
				continue
			elif Input.is_action_just_pressed("jump"):
				state = States.FLOOR
				Input.action_release("up")
				Input.action_release("down")
				velocity.y = JUMP_VELOCITY * 0.7
				state = States.AIR
				continue
			
			if Input.is_action_pressed("up") \
					or Input.is_action_pressed("down") \
					or Input.is_action_pressed("move_left") \
					or Input.is_action_pressed("move_right"):
				animated_sprite.play("climb")
			else:
				animated_sprite.stop()
			
			if Input.is_action_pressed("up"):
				velocity.y = -SPEED
			elif Input.is_action_pressed("down"):
				velocity.y = SPEED
			else:
				velocity.y = lerp(velocity.y, 0, 0.3)
			
			if Input.is_action_pressed("move_left"):
				velocity.x = -SPEED / 6
			elif Input.is_action_pressed("move_right"):
				velocity.x = SPEED / 6
			else:
				velocity.x = lerpf(velocity.x, 0.0, 0.3)
			
			move_and_slide()
		
		States.WALL:
			if is_on_floor():
				last_jump_direction = 0
				state = States.FLOOR
				continue
			elif not _is_near_wall():
				state = States.AIR
				continue
			
			animated_sprite.play("wall")
			if facing_direction != last_jump_direction \
					and Input.is_action_pressed("jump") \
					and ((Input.is_action_pressed("move_left") and facing_direction == 1) \
					or (Input.is_action_pressed("move_right") and facing_direction == -1)):
				
				last_jump_direction = facing_direction
				velocity.x = 450 * -facing_direction
				velocity.y = JUMP_VELOCITY * 0.7
				jump_sfx.play()
				state = States.AIR
			
			velocity.y += gravity * delta
			velocity.y = clamp(velocity.y, JUMP_VELOCITY, 200)
			move_and_slide()


func _on_ladder_checker_body_entered(_body: Node2D) -> void:
	on_ladder = true


func _on_ladder_checker_body_exited(_body: Node2D) -> void:
	on_ladder = false


func _on_hurt_timer_timeout() -> void:
	if hurt <= 0:
		timer.stop()
		modulate = Color(1, 1, 1, 1)
		set_collision_layer_value(1, true)
	else:
		modulate = Color(1, 1, 1, 0.9) if hurt % 2 == 0 else Color(1, 0.3, 0.3, 0.7)
	hurt -= 1
	


func bounce() -> void:
	velocity.y = JUMP_VELOCITY * 0.7


func ouch(enemy_posx: float) -> void:
	Global.lose_life()
	velocity.y = JUMP_VELOCITY * 0.5
	
	if position.x < enemy_posx:
		velocity.x = -1400
	elif position.x > enemy_posx:
		velocity.x = 1400
	
	Input.action_release("move_left")
	Input.action_release("move_right")
	
	modulate = Color(1, 0.3, 0.3, 0.3)
	set_collision_layer_value(1, false)
	timer.start()
	hurt = 20


func _fire() -> void:
	if Input.is_action_just_pressed("fire") and not _is_near_wall() and hurt <= 0:
		var fireball := fireball_scene.instantiate()
		fireball.direction = facing_direction
		fireball.position = position + Vector2(40 * facing_direction, -20)
		get_parent().add_child(fireball)


func _should_climb_ladder() -> bool:
	return on_ladder and (Input.is_action_pressed("up") \
			or Input.is_action_pressed("down"))


func _is_near_wall() -> bool:
	wall_checker.target_position.x = 30 * facing_direction
	return wall_checker.is_colliding()

