class_name Hud extends CanvasLayer


var coins := 0
var has_key := false:
	get:
		return has_key
	set(value):
		has_key = value
		key.texture = load("res://assets/HUD/key_yellow.png" if has_key else "res://assets/HUD/key_yellow_empty.png")

@onready var tree := get_tree()
@onready var coins_ui: Label = $Panel/Coins
@onready var key: TextureRect = $Panel/Key
@onready var hearts_empty: TextureRect = $Panel/HeartsEmpty
@onready var hearts_full: TextureRect = $Panel/HeartsFull


func _ready() -> void:
	Global.hud = self
	_update_coins(coins)
	update_hearts()


func _on_coin_collected() -> void:
	coins += 1
	_update_coins(coins)
	
	if coins == 3:
		tree.change_scene_to_file("res://screens/you_win.tscn")


func update_hearts() -> void:
	hearts_empty.size.x = Global.max_lives * 53
	hearts_full.size.x = Global.lives * 53


func _update_coins(value) -> void:
	coins_ui.text = str(value)
