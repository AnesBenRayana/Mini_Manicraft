extends Node3D

const BLOCK_SCENE = preload("res://scenes/blocks/Block.tscn")
const PLAYER_SCENE = preload("res://scenes/player/Player.tscn")

const WORLD_SIZE := 100
const MAX_HEIGHT := 8
const SEED := 12345

# =========================
# TREES
# =========================

const TREE_COUNT := 35
const TREE_TRUNK_HEIGHT := 4

@onready var blocks_container: Node3D = $Blocks

var noise := FastNoiseLite.new()
var random := RandomNumberGenerator.new()


func _ready() -> void:
	_setup_noise()
	_generate_world()
	_generate_trees()
	_spawn_player()


# =========================
# TERRAIN
# =========================

func _setup_noise() -> void:
	noise.seed = SEED
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.05

	random.seed = SEED


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


# =========================
# BLOCK CREATION
# =========================

func _create_block(position: Vector3, block_type: String) -> void:

	var block = BLOCK_SCENE.instantiate()

	block.position = position

	blocks_container.add_child(block)

	block.set_block_type(block_type)


# =========================
# TREES
# =========================

func _generate_trees() -> void:

	for i in range(TREE_COUNT):

		var x := random.randi_range(3, WORLD_SIZE - 4)
		var z := random.randi_range(3, WORLD_SIZE - 4)

		var ground_height := _get_height(x, z)

		_create_tree(
			x,
			ground_height,
			z
		)


func _create_tree(x: int, ground_height: int, z: int) -> void:

	# =========================
	# TRUNK
	# =========================

	for y in range(TREE_TRUNK_HEIGHT):

		_create_block(
			Vector3(
				x,
				ground_height + y,
				z
			),
			"wood"
		)


	# =========================
	# LEAVES
	# =========================

	var leaves_center_y := ground_height + TREE_TRUNK_HEIGHT - 1

	for x_offset in range(-2, 3):

		for z_offset in range(-2, 3):

			for y_offset in range(-1, 2):

				# Skip some corners to make the tree less cubic
				if abs(x_offset) == 2 and abs(z_offset) == 2:
					continue

				# Don't put leaves inside the trunk
				if x_offset == 0 and z_offset == 0 and y_offset < 0:
					continue

				_create_block(
					Vector3(
						x + x_offset,
						leaves_center_y + y_offset,
						z + z_offset
					),
					"leaves"
				)


# =========================
# PLAYER
# =========================

func _spawn_player() -> void:

	var player = PLAYER_SCENE.instantiate()

	player.position = Vector3(30, 15, 30)

	add_child(player)