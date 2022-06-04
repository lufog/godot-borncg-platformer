extends CanvasLayer


var coins := 0

@onready var tree := get_tree()
@onready var coins_ui := $Panel/Coins as Label


func _ready() -> void:
	_update_coins(coins)


func _on_coin_collected() -> void:
	coins += 1
	_update_coins(coins)
	
	if coins == 3:
		tree.change_scene("res://you_win.tscn")


func _update_coins(value) -> void:
	coins_ui.text = str(value)
