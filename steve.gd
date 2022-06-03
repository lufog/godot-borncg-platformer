extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -640.0

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as int

@onready var tree := get_tree()
@onready var animated_sprite := $AnimatedSprite as AnimatedSprite2D
@onready var timer := $Timer as Timer


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction:
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("walk")
		velocity.x = direction * SPEED
	else:
		animated_sprite.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if not is_on_floor():
		# Add the gravity.
		animated_sprite.play("jump")
		velocity.y += gravity * delta
	else:
		# Handle Jump.
		if Input.is_action_just_pressed("jump"):
			animated_sprite.flip_h = direction < 0
			velocity.y = JUMP_VELOCITY
		
	move_and_slide()


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
	tree.change_scene("res://level_1.tscn")
