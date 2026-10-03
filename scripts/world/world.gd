extends Node3D

const BLOCK_SCENE = preload("res://scenes/blocks/Block.tscn")
const PLAYER_SCENE = preload("res://scenes/player/Player.tscn")

const WORLD_SIZE := 60
const MAX_HEIGHT := 8
const SEED := 12345

@onready var blocks_container: Node3D = $Blocks

var noise := FastNoiseLite.new()


func _ready() -> void:
	_setup_noise()
	_generate_world()
	_spawn_player()


func _setup_noise() -> void:
	noise.seed = SEED
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.05


func _generate_world() -> void:
	for x in range(WORLD_SIZE):
		for z in range(WORLD_SIZE):
			var height := _get_height(x, z)

			for y in range(height):
				var block_type := "dirt"

				if y == height - 1:
					block_type = "grass"

				_create_block(
					Vector3(x, y, z),
					block_type
				)


func _get_height(x: int, z: int) -> int:
	var noise_value := noise.get_noise_2d(x, z)

	var height := int(
		(noise_value + 1.0) * 0.5 * MAX_HEIGHT
	)

	return max(height, 1)


func _create_block(position: Vector3, block_type: String) -> void:
	var block = BLOCK_SCENE.instantiate()

	block.position = position
	blocks_container.add_child(block)

	block.set_block_type(block_type)


func _spawn_player() -> void:
	print("================================")
	print("SPAWN PLAYER")
	print("================================")

	var player = PLAYER_SCENE.instantiate()

	player.position = Vector3(30, 15, 30)

	add_child(player)

	print("PLAYER POSITION: ", player.position)
	print("PLAYER CREATED: ", player)