extends CharacterBody2D
class_name BatEnemy

@onready var sprite_2d: Sprite2D = $Sprite2D

var speed: int
var speed_max: int = 100
var speed_min: int = 60
var dir: Vector2
var is_bat_chase: bool
var player: CharacterBody2D
var health = 30
var health_max = 30
var health_min = 0
var dead = false
var taking_damage = false
var is_roaming: bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_bat_chase = true
	speed = randi_range(speed_min, speed_max)
	randomize()
	print(speed)

func move(delta):
	player = Global.playerBody
	if !dead:
		is_roaming = true
		if !taking_damage and is_bat_chase and !Global.playerDead:
			player = Global.playerBody
			velocity = position.direction_to(player.position) * speed
			dir.x = abs(velocity.x) / velocity.x
		elif taking_damage:
			var knockback_dir = position.direction_to(player.position) * -10
			velocity = knockback_dir * 10
		else:
			velocity += dir * speed * delta
	elif dead:
		velocity.x = 0
	move_and_slide()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move(delta)
	animation()
	
	if !Global.playerDead:
		is_bat_chase = true
	elif Global.playerDead:
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
		take_damage(damage)

func take_damage(damage):
	health -= damage
	taking_damage = true
	if health <= health_min:
		health = health_min
		dead = true
	print(str(self), health)
