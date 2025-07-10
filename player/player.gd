class_name Player
extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -200.0

func _enter_tree():
	set_multiplayer_authority(int(str(name)))

func _ready():
	if !is_multiplayer_authority():
		$AnimatedSprite2D.modulate = Color.RED
		$Camera2D.enabled = false
	else:
		$Camera2D.enabled = true
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
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Animation control
	if not is_on_floor():
		$AnimatedSprite2D.play("jump")
	elif abs(velocity.x) > 2:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")
