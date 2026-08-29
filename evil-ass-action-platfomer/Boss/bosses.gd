extends CharacterBody2D
class_name Bosses

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var Skill02: AnimatedSprite2D = $Skill02

signal dropEXP(exp: int)
@export var exp_reward: int = 20
@onready var healthbar = $CanvasLayer/EnemyBar

var player: CharacterBody2D
var health: int = 500
@export var health_max: int = 500
var health_min: int = 0
var dead = false
var taking_damage = false

@export var first_skill_delay: float = 2.0

func _ready() -> void:
	Global.batBody = self
	apply_level_scaling()
	health = health_max
	add_to_group("enemies")
	healthbar.init_health(health_max)
	$SkillTimer.wait_time = first_skill_delay
	$SkillTimer.start()
	$Skill02.sprite_frames.set_animation_loop("Charge", false)
	

func _physics_process(delta: float) -> void:
	animation()
	
func animation():
	if !dead and taking_damage:
		await get_tree().create_timer(1.0).timeout
		taking_damage = false
	elif dead:
		queue_free()
		
func _on_bat_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		var damage = Global.playerSwordDamage
		take_damage(damage)

func take_damage(damage: int):
	health -= damage
	taking_damage = true
	if health <= health_min:
		health = health_min
		dead = true
	print(str(self), health)
	if dead:
		dropEXP.emit(exp_reward)
	healthbar.health = health


var current_skill: int = 0
const SKILL_COUNT: int = 5
const SKILL_ORDER: Array[int] = [1, 5, 2, 5, 3, 4, 5]
var skill_index: int = 0

@export var skill_cooldown: Dictionary = {
	1: 4.0,
	2: 3.5,
	3: 1.0,
	4: 6.0,
	5: 1,
}

func _on_skill_timer_timeout() -> void:
	NextSkill()

func UseBossesSkill(skillnum: int) -> void:
	match skillnum:
		1: skill1()
		2: skill2()
		3: skill3()
		4: skill4()
		5: skill5()

func NextSkill():
	var skillnum: int = SKILL_ORDER[skill_index]
	skill_index = (skill_index + 1) % SKILL_ORDER.size()
	UseBossesSkill(skillnum)
	$SkillTimer.wait_time = skill_cooldown[skillnum]
	$SkillTimer.start()

#Skill01
const boss_bullet = preload("res://Boss/bosses_bullet01.tscn")
@export var row_y: Array[float] = [383, 200, 64]
@export var spawn_x: float = 1000.0
@export var bullets_per_wave: int = 4
@export var bullet_gap: float = 40.0
@export var wave_count: int = 4
@export var wave_delay: float = 1.0
@export var vertical_per_column: int = 2
@export var vertical_gap: float = 40.0
var last_row: int = -1

#Upgrade Skill 1
@export var vertical_x: Array[float] = [225, 850]
var Skill01_Upgrade: bool = false

func skill1():
	print("skill1")
	if boss_bullet == null or row_y.is_empty():
		return
	for w in wave_count:
		_fire_row(_pickrow())
		if Skill01_Upgrade:
			_fire_vertical()
		if w < wave_count - 1:
			await get_tree().create_timer(wave_delay).timeout
			if dead:
				return

func _fire_vertical() -> void:
	for x in vertical_x:
		for i in vertical_per_column:
			var b = boss_bullet.instantiate()
			get_parent().add_child(b)
			b.global_position = Vector2(x, 500.0 + i * vertical_gap)
			b.rotation = -PI / 2

func _pickrow() ->  int:
	var r: int = randi_range(0, row_y.size() - 1)
	if row_y.size() > 1:
		while r == last_row:
			r = randi() % row_y.size()
	last_row = r
	return r

func _fire_row(row:int) -> void:
	for i in bullets_per_wave:
		var b = boss_bullet.instantiate()
		get_parent().add_child(b)
		b.global_position = Vector2(spawn_x + i * bullet_gap, row_y[row])
		b.rotation = PI

#Skill2
const homing_bullet = preload("res://Boss/bosses_bullet_02.tscn")
@export var homing_count: int = 2
@export var homing_delay: float = 1
@export var homing_offset: float = 40.0
func skill2():
	print("skill2")
	$Skill02.visible = true
	$Skill02.play("Charge")

func _on_skill_02_animation_finished() -> void:
	for i in homing_count:
		var b = homing_bullet.instantiate()
		b.global_position = global_position + Vector2(0, -homing_offset * 0.5 + i * homing_offset)
		get_parent().add_child(b)
		if i < homing_count - 1:
			await get_tree().create_timer(homing_delay).timeout
			if dead:
				return
	$Skill02.visible = false

@export var skill3_duration: float = 3.0
@export var skill3_interval: float = 0.1
@export var skill3_row: int = 0
var Skill03_Upgrade = false

func skill3():
	print("skill3")
	if Skill03_Upgrade:
		var elapsed: float = 0.0
		while elapsed < skill3_duration:
			if dead:
				return
			_fire_row(skill3_row)
			await get_tree().create_timer(skill3_interval).timeout
			elapsed += skill3_interval

#Skill04
@export var dash_distance: float = 800.0
@export var dash_time: float = 1.5
@export var dash_homing_count: int = 3
@export var homing_spacing: float = 0.3
const homing_dash = preload("res://Boss/bosses_bullet_03.tscn")
func skill4():
	print("skill4")
	global_position = Vector2(900, 90)
	
	var dir: float = -1.0
	if is_instance_valid(Global.playerBody):
		dir = signf(Global.playerBody.global_position.x - global_position.x)
		if dir == 0.0:
			dir = -1.0
	var tw = create_tween()
	tw.tween_property(self, "global_position", global_position + Vector2(dir * dash_distance, 0), dash_time)
		
	for i in dash_homing_count:
		await get_tree().create_timer(homing_spacing).timeout
		if dead:
			return
		var b = homing_dash.instantiate()
		get_parent().add_child(b)
		b.global_position = global_position
	await tw.finished
	global_position = teleport_points[1]


@export var teleport_points: Array[Vector2] = [
	Vector2(150,350),
	Vector2(500,350),
	Vector2(750,350),
	Vector2(225,200),
	Vector2(830,200),
]
func skill5():
	print("skill5 -> ", global_position)
	if teleport_points.is_empty():
		return
	global_position = teleport_points.pick_random()

func apply_level_scaling() -> void:
	var lv: int = Global.level
	if lv >= 2:
		health_max = 700

	if lv >= 3:
		skill_cooldown = {1: 3.5, 2: 2.5, 3: 2, 4: 4, 5: 1}

	if lv >= 4:
		bullets_per_wave = 4
		dash_homing_count = 3
		homing_count = 3

	if lv >= 5:
		Skill01_Upgrade = true
		homing_count = 4
		Skill03_Upgrade = true
		dash_homing_count = 5
