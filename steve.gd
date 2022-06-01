extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -640.0

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var coins := 0

@onready var tree := get_tree()
@onready var animated_sprite := $AnimatedSprite as AnimatedSprite2D


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
	
	if coins == 3:
		tree.change_scene("res://level_1.tscn")


func add_coin() -> void:
	coins += 1
