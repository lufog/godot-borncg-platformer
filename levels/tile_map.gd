extends TileMap


func _on_button_pushed() -> void:
	set_layer_enabled(2, false)
	set_layer_enabled(3, true)
