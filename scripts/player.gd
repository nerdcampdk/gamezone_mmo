extends CharacterBody2D
@onready var basic_tile_map: TileMapLayer = $"../TileMaps/BasicTileMap"

const SPEED = 110.0
const JUMP_VELOCITY = 200.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle dying falling of the map.
	if position.y > basic_tile_map.get_used_rect().end.y + 100:
		print("you died")  # Or handle respawning, etc.

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -JUMP_VELOCITY
	
	# Handle doublejump/airjump.
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		if not has_meta("doublejump_used"):
			velocity.y = -JUMP_VELOCITY
			set_meta("doublejump_used", true)
			
	# Reset doublejump when touching the floor.
	if is_on_floor() and has_meta("doublejump_used"):
		remove_meta("doublejump_used")
		
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
