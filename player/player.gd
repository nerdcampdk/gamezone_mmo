class_name Player
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _enter_tree():
	set_multiplayer_authority(int(str(name)))

func _ready():
	if !is_multiplayer_authority():
		$AnimatedSprite.modulate = Color.RED
		$Camera.current = false
	else:
		$Camera.current = true
		$NameLabel.text = Shared.player_name

func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Jump or double jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		if not has_meta("doublejump_used"):
			velocity.y = JUMP_VELOCITY
			set_meta("doublejump_used", true)
	
	if is_on_floor() and has_meta("doublejump_used"):
		remove_meta("doublejump_used")
	
	# Horizontal movement
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		$AnimatedSprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Animation control
	if not is_on_floor():
		$AnimatedSprite.play("jump")
	elif abs(velocity.x) > 2:
		$AnimatedSprite.play("run")
	else:
		$AnimatedSprite.play("idle")
