extends StaticBody3D


var block_type: String = "dirt"


@onready var mesh: MeshInstance3D = $Mesh


var block_shader = preload("res://assets/shaders/block.gdshader")


func set_block_type(type: String) -> void:

	block_type = type

	_update_appearance()


func _update_appearance() -> void:

	var material := ShaderMaterial.new()

	material.shader = block_shader


	# =========================
	# BLOCK TYPE
	# =========================

	match block_type:

		"grass":
			material.set_shader_parameter("block_type", 0)

		"dirt":
			material.set_shader_parameter("block_type", 1)

		"wood":
			material.set_shader_parameter("block_type", 2)

		"leaves":
			material.set_shader_parameter("block_type", 3)


	mesh.material_override = material