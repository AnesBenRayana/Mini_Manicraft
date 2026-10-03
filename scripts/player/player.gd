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
# FLY MODE
# =========================

var fly_mode := false


func _ready() -> void:
	camera = $Camera3D

	# Capture the mouse when the game starts
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:

	# Mouse movement
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)

		camera_pitch -= event.relative.y * MOUSE_SENSITIVITY
		camera_pitch = clamp(
			camera_pitch,
			deg_to_rad(-89.0),
			deg_to_rad(89.0)
		)

		camera.rotation.x = camera_pitch

	# Keyboard
	if event is InputEventKey:
		if event.pressed and not event.echo:

			# Escape releases the mouse
			if event.keycode == KEY_ESCAPE:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

			# F activates/deactivates Fly Mode
			if event.keycode == KEY_F:
				fly_mode = not fly_mode

				if fly_mode:
					print("FLY MODE: ON")
				else:
					print("FLY MODE: OFF")


func _physics_process(delta: float) -> void:

	# =========================
	# FLY MODE
	# =========================

	if fly_mode:
		_process_fly_mode()
		return


	# =========================
	# NORMAL GRAVITY
	# =========================

	if not is_on_floor():
		velocity.y -= GRAVITY * delta


	# =========================
	# JUMP
	# =========================

	if Input.is_physical_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = JUMP_VELOCITY


	# =========================
	# MOVEMENT
	# =========================

	var input_vector := Vector2.ZERO

	if Input.is_physical_key_pressed(KEY_A):
		input_vector.x -= 1.0

	if Input.is_physical_key_pressed(KEY_D):
		input_vector.x += 1.0

	if Input.is_physical_key_pressed(KEY_W):
		input_vector.y -= 1.0

	if Input.is_physical_key_pressed(KEY_S):
		input_vector.y += 1.0


	# =========================
	# DIRECTION
	# =========================

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


	# =========================
	# WALK / RUN
	# =========================

	var current_speed := WALK_SPEED

	if Input.is_physical_key_pressed(KEY_SHIFT):
		current_speed = RUN_SPEED

	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed


	# Stop horizontal movement
	if input_vector.length() == 0.0:
		velocity.x = move_toward(velocity.x, 0.0, WALK_SPEED)
		velocity.z = move_toward(velocity.z, 0.0, WALK_SPEED)


	# =========================
	# MOVE
	# =========================

	move_and_slide()


# =========================================================
# FLY MODE MOVEMENT
# =========================================================

func _process_fly_mode() -> void:

	var direction := Vector3.ZERO

	# Forward / backward
	if Input.is_physical_key_pressed(KEY_W):
		direction -= transform.basis.z

	if Input.is_physical_key_pressed(KEY_S):
		direction += transform.basis.z

	# Left / right
	if Input.is_physical_key_pressed(KEY_A):
		direction -= transform.basis.x

	if Input.is_physical_key_pressed(KEY_D):
		direction += transform.basis.x

	# Up
	if Input.is_physical_key_pressed(KEY_SPACE):
		direction += Vector3.UP

	# Down
	if Input.is_physical_key_pressed(KEY_CTRL):
		direction -= Vector3.UP

	if direction.length() > 0.0:
		direction = direction.normalized()

	var current_speed := FLY_SPEED

	# Shift = faster flying
	if Input.is_physical_key_pressed(KEY_SHIFT):
		current_speed = FLY_SPEED * 2.0

	velocity = direction * current_speed

	move_and_slide()