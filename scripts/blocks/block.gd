extends StaticBody3D


var block_type: String = "dirt"
var is_player_placed: bool = false


@onready var mesh: MeshInstance3D = $Mesh


var block_shader = preload("res://assets/shaders/block.gdshader")


func set_block_type(type: String) -> void:

	block_type = type

	if type == "placed":
		is_player_placed = true

	_update_appearance()


func _update_appearance() -> void:

	var material := ShaderMaterial.new()

	material.shader = block_shader


	match block_type:

		"grass":
			material.set_shader_parameter("block_type", 0)

		"dirt":
			material.set_shader_parameter("block_type", 1)

		"wood":
			material.set_shader_parameter("block_type", 2)

		"leaves":
			material.set_shader_parameter("block_type", 3)

		"placed":
			material.set_shader_parameter("block_type", 4)


	mesh.material_override = material