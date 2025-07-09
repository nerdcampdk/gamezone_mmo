class_name Player
extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -200.0

func _enter_tree():
	set_multiplayer_authority(int(str(name)))

func _ready():
	if !is_multiplayer_authority():
		$Sprite2D.modulate = Color.RED

func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		if not has_meta("doublejump_used"):
			velocity.y = JUMP_VELOCITY
			set_meta("doublejump_used", true)
	
	if is_on_floor() and has_meta("doublejump_used"):
		remove_meta("doublejump_used")
	
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
