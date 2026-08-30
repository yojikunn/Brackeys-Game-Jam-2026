extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


const speed = 300.0
var player: CharacterBody2D
var dir: Vector2
var FollowPlayer = true
@export var FollowingRange: float = 100

func _ready() -> void:
	Global.fairyBody = self
	if !Global.Fairy_IsAround:
		animated_sprite_2d.visible = false
		FollowPlayer = false
func _physics_process(delta: float) -> void:
	if !Global.Fairy_IsAround:
		if Global.On_stage_level == 3:
			animated_sprite_2d.visible = true
			FollowPlayer = true
		elif Global.On_stage_level == 8 or Global.On_stage_level == 7:
			animated_sprite_2d.visible = true
			FollowPlayer = true
	player = Global.playerBody
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player > FollowingRange and FollowPlayer:
		velocity = position.direction_to(player.position) * speed
		dir.x = abs(velocity.x) / velocity.x
	elif distance_to_player <= FollowingRange and FollowPlayer:
		velocity.x = 0
		velocity.y = 0
	if dir.x == 1:
		animated_sprite_2d.flip_h = true
	elif dir.x == -1:
		animated_sprite_2d.flip_h = false
	move_and_slide()

func turn_left():
	animated_sprite_2d.flip_h = false
func turn_right():
	animated_sprite_2d.flip_h = true
func move_cutscene():
	if Global.On_stage_level == 2:
		FollowPlayer = false
		velocity = position.direction_to(Vector2(1220, 405)) * speed
		dir.x = abs(velocity.x) / velocity.x
	if Global.On_stage_level == 7:
		FollowPlayer = true
		velocity = position.direction_to(Vector2(559, 370)) * speed
		dir.x = abs(velocity.x) / velocity.x
func end_cutscene():
	if Global.On_stage_level == 1:
		Global.First_Cutscene = true
	if Global.On_stage_level == 2:
		Global.Path01_Cutscene = true
		Global.Fairy_IsAround = false
	if Global.On_stage_level == 3:
		Global.Bat_Cutscene = true
		Global.Fairy_IsAround = true
	if Global.On_stage_level == 7:
		Global.Path02_Cutscene = true
		Global.Fairy_IsAround = true
	if Global.On_stage_level == 11:
		if Global.Ending == 1:
			get_tree().change_scene_to_file("res://scenes/level/the_end.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/level/level10.tscn")
