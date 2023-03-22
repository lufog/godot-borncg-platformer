class_name Door extends Area2D


@export var target_door: Door
@export var hud: Hud

var is_over_door := false
var player: Player
var is_locked := true
var teleport_state := 0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var teleport_timer: Timer = $TeleportTimer
@onready var unlock_sound: AudioStreamPlayer = $UnlockSound
@onready var locked_sound: AudioStreamPlayer = $LockedSound
@onready var teleport_sound: AudioStreamPlayer = $TeleportSound


func _physics_process(_delta: float) -> void:
	if is_over_door:
		if Input.is_action_just_pressed("up") and is_locked:
			locked_sound.play()
		elif Input.is_action_just_pressed("up") and not is_locked:
			animated_sprite.play("opened")
			player.state = Player.States.FROZEN
			player.set_collision_layer_value(1, false)
			teleport_timer.start()


func _on_body_entered(body: Node2D) -> void:
	is_over_door = true
	player = body as Player


func _on_body_exited(_body: Node2D) -> void:
	is_over_door = false
	#player = null


func _on_near_door_body_entered(_body: Node2D) -> void:
	if hud.has_key and is_locked:
		animated_sprite.play("closed")
		target_door.animated_sprite.play("closed")
		unlock_sound.play()
		is_locked = false
		target_door.is_locked = false


func _on_teleport_timer_timeout() -> void:
	match teleport_state:
		0:
			teleport_sound.play()
			player.hide()
		1:
			animated_sprite.play("closed")
			target_door.animated_sprite.play("opened")
			player.global_position = target_door.global_position
			var player_camera := player.get_node("Camera") as Camera2D
			player_camera.reset_smoothing()
		2:
			player.show()
			player.state = Player.States.FLOOR
		3:
			target_door.animated_sprite.play("closed")
			set_collision_layer_value(1, true)
			teleport_timer.stop()
	
	teleport_state = wrapi(teleport_state + 1, 0, 4)
	
