extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $jump_sound


const SPEED = 300.0
const JUMP_VELOCITY = -1150.0
var is_attack = false

func _physics_process(delta: float) -> void:
	
	if (velocity.x > 1 or velocity.x < -1) and is_attack == false :
		animated_sprite_2d.animation = "run"
	else:
		if is_attack == false:
			animated_sprite_2d.animation = "idle"
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if is_attack == false:
			if velocity.y < -1:
				animated_sprite_2d.animation = "jump"
			elif velocity.y > 1:
				if animated_sprite_2d.animation != "fall":
					animated_sprite_2d.animation = "fall"
	
	if is_attack == true:
		if is_on_floor() and animated_sprite_2d.animation != "air_attack":
			animated_sprite_2d.animation = "attack"
		elif not is_on_floor() and animated_sprite_2d.animation != "attack":
			animated_sprite_2d.animation = "air_attack"
	
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()
	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if Input.is_action_just_pressed("attack"):
		is_attack = true
	move_and_slide()
	
	if direction == 1.0:
		animated_sprite_2d.flip_h = false
	elif direction == -1.0:
		animated_sprite_2d.flip_h = true

func _on_animated_sprite_2d_animation_looped() -> void:
	if animated_sprite_2d.animation == "attack":
		is_attack = false
	if animated_sprite_2d.animation == "air_attack":
		is_attack = false
