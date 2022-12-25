extends CanvasLayer


var coins := 0

@onready var tree := get_tree()
@onready var coins_ui := $Panel/Coins as Label
@onready var hearts_empty := $Panel/HeartsEmpty as TextureRect
@onready var hearts_full := $Panel/HeartsFull as TextureRect


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
