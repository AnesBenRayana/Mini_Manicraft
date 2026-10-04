extends Control


func _ready() -> void:
	var background_texture = load("res://assets/textures/menu/menu_backround.png")

	var background := TextureRect.new()
	background.texture = background_texture
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(background)
	move_child(background, 0)

	var start_button := Button.new()

	start_button.text = "START"
	start_button.position = Vector2(550, 350)
	start_button.size = Vector2(200, 70)

	start_button.add_theme_font_size_override("font_size", 28)

	start_button.pressed.connect(_on_start_pressed)

	add_child(start_button)


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world/World.tscn")