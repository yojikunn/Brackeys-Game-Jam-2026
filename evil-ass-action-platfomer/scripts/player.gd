extends CharacterBody2D

class_name Player

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $jump_sound
@onready var melee_hit_box: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var sword_sound: AudioStreamPlayer2D = $sword_sound
@onready var camera_2d: Camera2D = $Camera2D
@onready var player_hitbox: Area2D = $PlayerHitbox
@onready var player: Player = $"."

#Added
@onready var healthbar = $CanvasLayer/HPBar


const SPEED = 300.0
const  DASH_SPEED = 15.0
const JUMP_VELOCITY = -1450.0
const JUMP_DECELERATION = 1500.0
const FALL_VELOCITY = 500.0
var is_attack: bool
var is_jump: bool
var is_fall: bool
var is_dash: bool
#อยู่ใน Global
var health: float = 100
var health_max: float = 100
var health_min: float = 0
var can_take_damage: bool
var taking_damage: bool
var zoom_in = 8
var knockback = Vector2.ZERO
var knockback_timer = 0.0
var can_move = true
var can_jump:bool = true
var can_dash:bool = false
var jump_count:int
var dash_count:int
var is_dash_cooldown: bool

func _ready() -> void:
	Global.playerBody = self
	Global.playerDead = false
	can_take_damage = true
	is_attack = false
	is_jump = false
	is_fall = false
	is_dash = false
	is_dash_cooldown = false
	dash_count = Global.playerMaxDash
	taking_damage = false
	#Added
	healthbar.init_health(health_max)
	health_max = Global.playerMaxHP
	health = min(Global.playerHP, health_max)
	jump_count = Global.playerMaxJump

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_dash:
		velocity.y = 0
	if is_on_floor():
		can_jump = true
		jump_count = Global.playerMaxJump
		if dash_count < Global.playerMaxDash and !is_dash_cooldown:
			dash_cooldown(2.0)
			is_dash_cooldown = true
	if jump_count <= 0:
		can_jump = false
	if dash_count <= 0:
		can_dash = false
	else:
		can_dash = true
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
		if not is_on_floor() and Input.is_action_just_pressed("jump") and !is_dash:
			is_jump = true
		elif is_on_floor():
			is_fall = false
			
		# Handle jump.
		if Input.is_action_just_pressed("jump") and jump_count != 0 and can_move and can_jump and !is_dash:
			velocity.y = JUMP_VELOCITY
			is_jump = true
			jump_sound.play()
		
		if is_jump == true and can_jump and !is_dash: 
			velocity.y = move_toward(velocity.y, 0, JUMP_DECELERATION * delta)
			
			if Input.is_action_just_released("jump") or velocity.y >= 0:
				jump_count -= 1
				velocity.y = 0
				is_jump = false
				is_fall = true
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
		if direction and can_dash and can_move and Input.is_action_just_pressed("dash") and !is_attack:
			dash(direction, 0.12)
			is_dash = true
			dash_count -= 1
			if dash_count <= 0:
				can_dash = false
			print(dash_count)
		elif direction and can_move and !is_dash:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if Input.is_action_just_pressed("attack") and can_move and !is_dash:
			if is_attack == false:
				sword_sound.play()
			is_attack = true
		
		if direction == 1.0 or Global.Turn_right:
			animated_sprite_2d.flip_h = false
			melee_hit_box.position = Vector2(50, 12)
		elif direction == -1.0 or Global.Turn_left:
			animated_sprite_2d.flip_h = true
			melee_hit_box.position = Vector2(-50, 12)
		
		if Input.is_action_just_pressed("heal") and can_move and !is_attack and !is_dash:
			healing(20.0)

	#ADDED
	elif !can_move:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func animation():
	if can_move:
		Global.Current_dialogue = 0
		print(Global.Current_dialogue)
	if !Global.playerDead and !taking_damage and can_move:
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
		if is_dash == true:
			animated_sprite_2d.animation = "dash"
	elif !can_move:
		if Global.On_stage_level == 1 and Global.Current_dialogue <= 2:
			animated_sprite_2d.animation = "sleep"
		elif Global.On_stage_level == 1 and Global.Current_dialogue > 2:
			animated_sprite_2d.animation = "idle"

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
		print("Gethitbybullet")
	elif area.is_in_group("Skeleton"):
		damage = Global.skeletonDamage
	elif area.is_in_group("GoldSkeleton"):
		damage = Global.goldskeletonDamage
	elif area.is_in_group("Spike"):
		damage = Global.spikeDamage
		player.set_position(Global.Respawn_pos)
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
			if health > health_min and !area.is_in_group("Spike"):
				var knockback_dir = (global_position - area.global_position).normalized()
				apply_knockback(knockback_dir, 500.0, 0.12)
		take_damage_cooldown(2.0)
		
		#Added
		healthbar.HP = health 
		
		#Added Level
		Global.playerHP = health

func healing(heal: float):
	if Global.playerHeal > 0 and health != Global.playerMaxHP:
		health = clampf(health + heal, 0.0, Global.playerMaxHP)
		print(health)
		Global.playerHeal -= 1
	else:
		print("Can't heal")
	#Added
	healthbar.HP = health 
	#Added Level
	Global.playerHP = health
	
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

func dash_cooldown(wait_time):
	await get_tree().create_timer(wait_time).timeout
	dash_count = Global.playerMaxDash
	print(dash_count)
	is_dash_cooldown = false
func dash(dir, time):
	print("dash")
	velocity.x = dir * SPEED * DASH_SPEED
	await get_tree().create_timer(time).timeout
	is_dash = false
