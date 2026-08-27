extends CharacterBody2D

class_name SkeletonEnemy

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var melee_hit_box: CollisionShape2D = $MeleeArea/CollisionShape2D
@onready var melee_hurt_box: CollisionShape2D = $MeleeHurtbox/CollisionShape2D

signal dropEXP(exp: int)
@export var exp_reward: int = 10   # กำหนด EXP
@onready var healthbar = $EnemyBar

var speed: int
var speed_max: int = 100
var speed_min: int = 60
var dir: Vector2
var is_skeleton_chase: bool
var player: CharacterBody2D
var health: int = 0
@export var health_max: int = 30
var health_min: int = 0
var dead = false
var taking_damage = false
var is_roaming: bool
var knockback = Vector2.ZERO
var knockback_timer = 0.0
var is_attack = false
var melee_vector: Vector2


func _ready() -> void:
	Global.batBody = self
	is_skeleton_chase = true
	speed = randi_range(speed_min, speed_max)
	health = health_max
	randomize()
	print(speed)
	melee_vector = melee_hit_box.position
	
	add_to_group("enemies")
	healthbar.init_health(health_max)

func move(delta):
	if !dead and !is_attack:
		is_roaming = true
		if is_skeleton_chase and !Global.playerDead and Global.playerCanMove:
			player = Global.playerBody
			var dir_to_player = position.direction_to(player.position) * speed
			velocity.x = dir_to_player.x
			dir.x = abs(velocity.x) / velocity.x
		else:
			velocity += dir * speed * delta
	elif is_attack or dead:
		velocity.x = 0
	move_and_slide()

func _physics_process(delta: float) -> void:
	if !is_attack:
		melee_hurt_box.disabled = true
	if !is_on_floor():
		velocity += get_gravity() * delta
		velocity.x = 0
	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
	else:
		move(delta)
	move_and_slide()
	animation()
	if !Global.playerDead and Global.playerCanMove:
		is_skeleton_chase = true
	elif Global.playerDead or !Global.playerCanMove:
		is_skeleton_chase = false

func _on_timer_timeout() -> void:
	$Timer.wait_time = choose([0.5, 0.8])
	if !is_skeleton_chase:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()

func animation():
	if !dead and !taking_damage:
		if (velocity.x > 1 or velocity.x < -1) and is_attack == false and is_on_floor():
			animated_sprite_2d.animation = "walk"
		elif is_attack:
			animated_sprite_2d.animation = "attack"
		else:
			animated_sprite_2d.animation = "idle"
		if dir.x == 1:
			animated_sprite_2d.flip_h = false
			melee_hit_box.position = Vector2(melee_vector.x, melee_vector.y)
			melee_hurt_box.position = Vector2(melee_vector.x, melee_vector.y)
		elif dir.x == -1:
			animated_sprite_2d.flip_h = true
			melee_hit_box.position = Vector2(melee_vector.x * -1, melee_vector.y)
			melee_hurt_box.position = Vector2(melee_vector.x * -1, melee_vector.y)
	elif !dead and taking_damage:
		animated_sprite_2d.animation = "hurt"
	elif dead and is_roaming:
		is_roaming = false
		animated_sprite_2d.animation = "die"

func _on_skeleton_hitbox_area_entered(area: Area2D) -> void:
		if area.is_in_group("Sword"):
			var damage = Global.playerSwordDamage
			var knockback_dir = (global_position - area.global_position).normalized()
			apply_knockback(knockback_dir, 500.0, 0.12)
			take_damage(damage)

func take_damage(damage: int):
	if damage != 0:
		health -= damage
		taking_damage = true
		is_attack = false
		if health <= health_min:
			health = health_min
			dead = true
		print(str(self), health)
	#Added Level ทุกตัว
	if dead:
		dropEXP.emit(exp_reward)
	healthbar.health = health
	
func apply_knockback(direction: Vector2, force: float, knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration

func _on_melee_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") and !taking_damage:
		is_attack = true
		await get_tree().create_timer(0.7).timeout
		melee_hurt_box.disabled = false


func _on_animated_sprite_2d_animation_looped() -> void:
	if animated_sprite_2d.animation == "attack":
		melee_hurt_box.disabled = true
		is_attack = false
	if animated_sprite_2d.animation == "die":
		queue_free()
	if animated_sprite_2d.animation == "hurt":
		taking_damage = false
