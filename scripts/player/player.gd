extends CharacterBody3D


# =========================
# MOVEMENT
# =========================

const WALK_SPEED := 5.0
const RUN_SPEED := 8.0
const FLY_SPEED := 10.0
const JUMP_VELOCITY := 6.0
const GRAVITY := 15.0


# =========================
# CAMERA
# =========================

const MOUSE_SENSITIVITY := 0.004

var camera: Camera3D
var camera_pitch := 0.0


# =========================
# BLOCK DETECTION
# =========================

var block_raycast: RayCast3D


# =========================
# BLOCK BREAKING
# =========================

var breaking_block = null
var breaking_progress := 0.0
var blocks_count := 0

const BREAK_TIME := 0.5


# =========================
# BLOCK COUNTER
# =========================

var block_counter_label: Label
var block_icon: ColorRect


# =========================
# HAND ANIMATION
# =========================

var hand: MeshInstance3D
var hand_animating := false


# =========================
# FLY MODE
# =========================

var fly_mode := false


# =========================
# BUILDING
# =========================

const BLOCK_SCENE = preload("res://scenes/blocks/Block.tscn")


func _ready() -> void:

	camera = $Camera3D
	block_raycast = $Camera3D/BlockRayCast
	hand = $Camera3D/Hand


	# =========================
	# BLOCK COUNTER
	# =========================

	if has_node("BlockCounterLayer/BlockCounterPanel/Multiplier"):

		block_counter_label = $BlockCounterLayer/BlockCounterPanel/Multiplier
		block_icon = $BlockCounterLayer/BlockCounterPanel/BlockIcon

		block_counter_label.text = "× 0"

		print("BLOCK COUNTER: OK")

	else:

		print("ERREUR: COMPTEUR INTROUVABLE")


	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# =========================================================
# INPUT
# =========================================================

func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseMotion:

		rotate_y(
			-event.relative.x * MOUSE_SENSITIVITY
		)

		camera_pitch -= (
			event.relative.y * MOUSE_SENSITIVITY
		)

		camera_pitch = clamp(
			camera_pitch,
			deg_to_rad(-89.0),
			deg_to_rad(89.0)
		)

		camera.rotation.x = camera_pitch


	if event is InputEventMouseButton:

		# =========================
		# CLIC GAUCHE = CASSER
		# =========================

		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:

				_start_breaking()

			else:

				_stop_breaking()


		# =========================
		# CLIC DROIT = CONSTRUIRE
		# =========================

		if event.button_index == MOUSE_BUTTON_RIGHT:

			if event.pressed:

				_place_block()


	if event is InputEventKey:

		if event.pressed and not event.echo:

			if event.keycode == KEY_ESCAPE:

				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


			if event.keycode == KEY_F:

				fly_mode = not fly_mode

				if fly_mode:

					print("FLY MODE: ON")

				else:

					print("FLY MODE: OFF")


func _physics_process(delta: float) -> void:

	_check_block_target()

	_process_block_breaking(delta)


	if fly_mode:

		_process_fly_mode()

		return


	if not is_on_floor():

		velocity.y -= GRAVITY * delta


	if Input.is_physical_key_pressed(KEY_SPACE):

		if is_on_floor():

			velocity.y = JUMP_VELOCITY


	var input_vector := Vector2.ZERO


	if Input.is_physical_key_pressed(KEY_A):

		input_vector.x -= 1.0


	if Input.is_physical_key_pressed(KEY_D):

		input_vector.x += 1.0


	if Input.is_physical_key_pressed(KEY_W):

		input_vector.y -= 1.0


	if Input.is_physical_key_pressed(KEY_S):

		input_vector.y += 1.0


	var direction := Vector3(
		input_vector.x,
		0.0,
		input_vector.y
	)


	if direction.length() > 0.0:

		direction = direction.normalized()

		direction = transform.basis * direction

		direction.y = 0.0

		direction = direction.normalized()


	var current_speed := WALK_SPEED


	if Input.is_physical_key_pressed(KEY_SHIFT):

		current_speed = RUN_SPEED


	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed


	if input_vector.length() == 0.0:

		velocity.x = move_toward(
			velocity.x,
			0.0,
			WALK_SPEED
		)

		velocity.z = move_toward(
			velocity.z,
			0.0,
			WALK_SPEED
		)


	move_and_slide()


# =========================================================
# BLOCK DETECTION
# =========================================================

func _check_block_target() -> void:

	if not block_raycast.is_colliding():

		return


	var target = block_raycast.get_collider()


	if target is StaticBody3D:

		pass


# =========================================================
# BREAKING
# =========================================================

func _start_breaking() -> void:

	if not block_raycast.is_colliding():

		return


	var target = block_raycast.get_collider()


	if target is StaticBody3D:

		breaking_block = target

		breaking_progress = 0.0


func _stop_breaking() -> void:

	if breaking_block != null:

		print("STOP BREAKING")


	breaking_block = null

	breaking_progress = 0.0


func _process_block_breaking(delta: float) -> void:

	if breaking_block == null:

		return


	if not block_raycast.is_colliding():

		_stop_breaking()

		return


	var current_target = block_raycast.get_collider()


	if current_target != breaking_block:

		_stop_breaking()

		return


	breaking_progress += delta / BREAK_TIME


	_animate_hand_break()


	print(
		"BREAKING: ",
		int(breaking_progress * 100.0),
		"%"
	)


	if breaking_progress >= 1.0:

		print("BLOCK BROKEN!")


		var broken_position: Vector3 = breaking_block.global_position


		_create_block_debris(broken_position)


		breaking_block.queue_free()


		# =========================
		# GIVE ONE BLOCK
		# =========================

		blocks_count += 1


		print(
			"BLOCKS AVAILABLE = ",
			blocks_count
		)


		if block_counter_label != null:

			block_counter_label.text = "× " + str(blocks_count)


		breaking_block = null

		breaking_progress = 0.0


# =========================================================
# BUILDING
# =========================================================

func _place_block() -> void:

	# =========================
	# CHECK AVAILABLE BLOCKS
	# =========================

	if blocks_count <= 0:

		print("NO BLOCKS AVAILABLE")

		return


	# =========================
	# CHECK TARGET
	# =========================

	if not block_raycast.is_colliding():

		print("NO BLOCK TARGET")

		return


	var target = block_raycast.get_collider()


	if not target is StaticBody3D:

		return


	# =========================
	# GET BLOCK FACE
	# =========================

	var normal := block_raycast.get_collision_normal()

	var target_position: Vector3 = target.global_position

	var new_position := target_position + normal


	# =========================
	# GRID ALIGNMENT
	# =========================

	new_position.x = round(new_position.x)
	new_position.y = round(new_position.y)
	new_position.z = round(new_position.z)


	# =========================
	# DON'T PLACE INSIDE PLAYER
	# =========================

	var distance := new_position.distance_to(global_position)


	if distance < 1.0:

		print("BLOCK TOO CLOSE TO PLAYER")

		return


	# =========================
	# CREATE BLOCK
	# =========================

	var new_block = BLOCK_SCENE.instantiate()


	get_tree().current_scene.add_child(new_block)


	new_block.global_position = new_position


	# =========================
	# PLAYER PLACED BLOCK
	# =========================

	if new_block.has_method("set_block_type"):

		new_block.set_block_type("placed")


	# =========================
	# REMOVE ONE AVAILABLE BLOCK
	# =========================

	blocks_count -= 1


	if block_counter_label != null:

		block_counter_label.text = "× " + str(blocks_count)


	print(
		"BLOCK PLACED | BLOCKS LEFT = ",
		blocks_count
	)


# =========================================================
# HAND ANIMATION
# =========================================================

func _animate_hand_break() -> void:

	if hand == null:

		return


	if hand_animating:

		return


	hand_animating = true


	var start_position := hand.position


	var tween := create_tween()


	tween.tween_property(
		hand,
		"position",
		start_position + Vector3(0.0, 0.05, 0.18),
		0.10
	)


	tween.tween_property(
		hand,
		"position",
		start_position,
		0.10
	)


	tween.tween_callback(
		func():
			hand_animating = false
	)


# =========================================================
# DEBRIS
# =========================================================

func _create_block_debris(block_position: Vector3) -> void:

	for i in range(6):

		var debris := MeshInstance3D.new()

		var mesh := BoxMesh.new()

		mesh.size = Vector3(
			0.15,
			0.15,
			0.15
		)

		debris.mesh = mesh


		debris.position = block_position + Vector3(
			randf_range(-0.35, 0.35),
			randf_range(-0.35, 0.35),
			randf_range(-0.35, 0.35)
		)


		var material := StandardMaterial3D.new()

		material.albedo_color = Color(
			0.45,
			0.30,
			0.18
		)

		debris.material_override = material


		get_tree().current_scene.add_child(debris)


		var direction := Vector3(
			randf_range(-1.0, 1.0),
			randf_range(0.5, 1.5),
			randf_range(-1.0, 1.0)
		).normalized()


		var tween := create_tween()


		tween.parallel().tween_property(
			debris,
			"position",
			debris.position + direction * 1.5,
			0.4
		)


		tween.tween_callback(
			debris.queue_free
		)


# =========================================================
# FLY MODE
# =========================================================

func _process_fly_mode() -> void:

	var direction := Vector3.ZERO


	if Input.is_physical_key_pressed(KEY_W):

		direction -= transform.basis.z


	if Input.is_physical_key_pressed(KEY_S):

		direction += transform.basis.z


	if Input.is_physical_key_pressed(KEY_A):

		direction -= transform.basis.x


	if Input.is_physical_key_pressed(KEY_D):

		direction += transform.basis.x


	if Input.is_physical_key_pressed(KEY_SPACE):

		direction += Vector3.UP


	if Input.is_physical_key_pressed(KEY_CTRL):

		direction -= Vector3.UP


	if direction.length() > 0.0:

		direction = direction.normalized()


	var current_speed := FLY_SPEED


	if Input.is_physical_key_pressed(KEY_SHIFT):

		current_speed = FLY_SPEED * 2.0


	velocity = direction * current_speed


	move_and_slide()