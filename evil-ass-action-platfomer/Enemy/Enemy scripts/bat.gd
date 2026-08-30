extends CharacterBody2D
class_name BatEnemy

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var bat_hurtbox: Area2D = $BatHurtbox

#Added Level ทุกตัว
signal dropEXP(exp: int)
@export var exp_reward: int = 10   # กำหนด EXP
@onready var healthbar = $EnemyBar

var speed: int
var speed_max: int = 100
var speed_min: int = 60
var dir: Vector2
var is_bat_chase: bool
var player: CharacterBody2D
var health: int = 0
@export var health_max: int = 30
var health_min: int = 0
var dead = false
var taking_damage = false
var is_roaming: bool
var knockback = Vector2.ZERO
var knockback_timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.batBody = self
	is_bat_chase = true
	speed = randi_range(speed_min, speed_max)
	health = health_max
	randomize()
	print(speed)
	
	add_to_group("enemies")
	healthbar.init_health(health_max)

func move(delta):
	if !dead:
		is_roaming = true
		if !taking_damage and is_bat_chase and !Global.playerDead and Global.playerCanMove:
			player = Global.playerBody
			velocity = position.direction_to(player.position) * speed
			dir.x = abs(velocity.x) / velocity.x
		else:
			velocity += dir * speed * delta
	elif dead:
		velocity.x = 0
	move_and_slide()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
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
		is_bat_chase = true
	elif Global.playerDead or !Global.playerCanMove:
		is_bat_chase = false

func _on_timer_timeout() -> void:
	$Timer.wait_time = choose([0.5, 0.8])
	if !is_bat_chase:
		dir = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])
		

func choose(array):
	array.shuffle()
	return array.front()

func animation():
	if !dead and !taking_damage:
		if dir.x == 1:
			sprite_2d.flip_h = true
		elif dir.x == -1:
			sprite_2d.flip_h = false
	elif !dead and taking_damage:
		await get_tree().create_timer(1.0).timeout
		taking_damage = false
	elif dead and is_roaming:
		is_roaming = false
		queue_free()
		
		
func _on_bat_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		var damage = Global.playerSwordDamage
		var knockback_dir = (global_position - area.global_position).normalized()
		apply_knockback(knockback_dir, 120.0, 0.001)
		take_damage(damage)

func take_damage(damage: int):
	health -= damage
	taking_damage = true
	if health <= health_min:
		health = health_min
		dead = true
	print(str(self), health)
	#Added Level ทุกตัว
	if dead:
		dropEXP.emit(exp_reward)
		Global.Batkillcount +=1
	healthbar.health = health

func apply_knockback(direction: Vector2, force: float, knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration
