extends CharacterBody2D

class_name Player

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $jump_sound
@onready var melee_hit_box: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var sword_sound: AudioStreamPlayer2D = $sword_sound
@onready var camera_2d: Camera2D = $Camera2D
@onready var player_hitbox: Area2D = $PlayerHitbox

#Added
@onready var healthbar = $CanvasLayer/HPBar

const SPEED = 300.0
const JUMP_VELOCITY = -1450.0
const JUMP_DECELERATION = 1500.0
const FALL_VELOCITY = 500.0
var is_attack: bool
var is_jump: bool
var is_fall: bool
var health = 100
var health_max = 100
var health_min = 0
var can_take_damage: bool
var taking_damage: bool
var zoom_in = 8
var knockback = Vector2.ZERO
var knockback_timer = 0.0
var can_move = true

func _ready() -> void:
	Global.playerBody = self
	Global.playerDead = false
	can_take_damage = true
	is_attack = false
	is_jump = false
	is_fall = false
	taking_damage = false
	#Added
	healthbar.init_health(health_max)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Global.playerDead:
		if (zoom_in >= 0):
			camera_2d.offset.y += 12
			camera_2d.zoom.x += 0.1 
			camera_2d.zoom.y += 0.1
			zoom_in -= 1
			await get_tree().create_timer(1).timeout
			print(zoom_in)
	if can_take_damage:
		modulate.a = 1
	if is_attack:
		melee_hit_box.disabled = false
	else:
		melee_hit_box.disabled = true
	if knockback_timer > 0.0 and taking_damage:
		velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
	else:
		move(delta)
	Global.playerCanMove = can_move
	animation()

func move(delta):
	# ADDED
	if !Global.playerDead and can_move and !taking_damage:
		# Add the gravity.
		if not is_on_floor() and Input.is_action_just_pressed("jump"):
			is_jump = true
		elif is_on_floor():
			is_fall = false
			
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor() and can_move:
			velocity.y = JUMP_VELOCITY
			is_jump = true
			jump_sound.play()
		
		if is_jump == true:
			velocity.y = move_toward(velocity.y, 0, JUMP_DECELERATION * delta)
			
			if Input.is_action_just_released("jump") or velocity.y >= 0:
				velocity.y = 0
				is_jump = false
				is_fall = true
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
		if direction and can_move:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if Input.is_action_just_pressed("attack") and can_move:
			if is_attack == false:
				sword_sound.play()
			is_attack = true
		
		if direction == 1.0:
			animated_sprite_2d.flip_h = false
			melee_hit_box.position = Vector2(50, 1)
		elif direction == -1.0:
			animated_sprite_2d.flip_h = true
			melee_hit_box.position = Vector2(-50, 1)
	#ADDED
	elif !can_move:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func animation():
	if !Global.playerDead and !taking_damage:
		if (velocity.x > 1 or velocity.x < -1) and is_attack == false and is_on_floor():
			animated_sprite_2d.animation = "run"
		else:
			if is_attack == false and is_fall == false and Global.playerDead == false:
				animated_sprite_2d.animation = "idle"
		if not is_on_floor():
			if is_attack == false and is_jump == true:
				animated_sprite_2d.animation = "jump"
			if is_attack == false and is_fall == true:
				animated_sprite_2d.animation = "fall"
		if is_attack == true:
			if is_on_floor() and animated_sprite_2d.animation != "air_attack":
				animated_sprite_2d.animation = "attack"
			elif not is_on_floor() and animated_sprite_2d.animation != "attack":
				animated_sprite_2d.animation = "air_attack"

func _on_animated_sprite_2d_animation_looped() -> void:
	if animated_sprite_2d.animation == "attack":
		melee_hit_box.disabled = true
		is_attack = false
	if animated_sprite_2d.animation == "air_attack":
		is_attack = false
	if animated_sprite_2d.animation == "dead":
		self.queue_free()
	if animated_sprite_2d.animation == "hurt":
		taking_damage = false

func _on_player_hitbox_area_entered(area: Area2D) -> void:
	var damage: int
	if area.is_in_group("Bat"):
		damage = Global.batDamage
	elif area.is_in_group("Bullet"):
		damage = area.get_parent().damage
	if can_take_damage and can_move:
		take_damage(damage, area)

func take_damage(damage, area: Area2D):
	if damage != 0:
		taking_damage = true
		is_attack = false
		re_collistion(2.0)
		if health > health_min:
			health -= damage
			print(health)
			animated_sprite_2d.animation = "hurt"
			velocity.x = 0
		if health <= health_min:
			health = health_min
			Global.playerDead = true
			animated_sprite_2d.animation = "dead"
			velocity.x = 0
		if is_instance_valid(area):
			if health > health_min:
				var knockback_dir = (global_position - area.global_position).normalized()
				apply_knockback(knockback_dir, 500.0, 0.12)
		take_damage_cooldown(2.0)
		
		#Added
		healthbar.HP = health 

func take_damage_cooldown(wait_time):
	if !Global.playerDead:
		modulate.a = 0.5
	can_take_damage = false
	await get_tree().create_timer(wait_time).timeout
	can_take_damage = true

func re_collistion(wait_time: float):
	player_hitbox.set_deferred("monitoring", false)
	await get_tree().create_timer(wait_time).timeout
	player_hitbox.set_deferred("monitoring", true)

func apply_knockback(direction: Vector2, force: float, knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration
