extends StaticBody3D

var block_type: String = "dirt"


func set_block_type(type: String) -> void:
	block_type = type
	_update_appearance()


func _update_appearance() -> void:
	var mesh := $Mesh as MeshInstance3D
	var material := StandardMaterial3D.new()

	if block_type == "grass":
		material.albedo_color = Color(0.25, 0.65, 0.20, 1)

	elif block_type == "dirt":
		material.albedo_color = Color(0.45, 0.30, 0.15, 1)

	elif block_type == "wood":
		material.albedo_color = Color(0.35, 0.18, 0.07, 1)

	elif block_type == "leaves":
		material.albedo_color = Color(0.05, 0.30, 0.04, 1)
	

	mesh.material_override = material