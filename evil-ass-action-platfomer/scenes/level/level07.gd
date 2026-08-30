extends Node2D

@onready var scene_transition_animation = $SceneTransitionAnimation/AnimationPlayer
@onready var dialogue_area_2d: Area2D = $DialogueArea2D
@onready var dialogue_area_2d_2: Area2D = $DialogueArea2D2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene_transition_animation.get_parent().get_node("ColorRect").color.a = 255
	scene_transition_animation.play("fade_out")
	if Global.Fairy_IsAround == true and Global.Path02_Cutscene == false:
		dialogue_area_2d.set_deferred("monitoring", true)
	elif Global.Fairy_IsAround == false and Global.Path02_Cutscene == false:
		dialogue_area_2d_2.set_deferred("monitoring", true)
	if Global.On_stage_level == 5:
		Global.playerBody.position = Vector2(74, 585)
		Global.fairyBody.position = Vector2(74, 585)
	if Global.On_stage_level == 8:
		Global.playerBody.position = Vector2(-160, 284)
		Global.fairyBody.position = Vector2(-160, 284)
	if Global.On_stage_level == 9:
		Global.playerBody.position = Vector2(1187, 173)
		Global.fairyBody.position = Vector2(1187, 173)
		await get_tree().create_timer(0.5).timeout
		Global.Turn_left = false
	if Global.Fairy_IsAround == false and Global.Path02_Cutscene == false:
		Global.fairyBody.position = Vector2(542, 766)
	Global.On_stage_level = 7
	Global.Respawn_pos = Vector2(1021, 129)
	Global.playerBody.healthbar.init_health(Global.playerMaxHP)
	Global.playerBody.healthbar.HP = Global.playerHP


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for i in enemies:
		if not i.dropEXP.is_connected(experience_gained):
			i.dropEXP.connect(experience_gained)
	if Global.level < Global.MAX_LEVEL:
		if Global.experience >= Global.LEVEL_THRESHOLDS[Global.level - 1]:
			level_up(Global.experience)
	Global.experience_updated.emit(Global.experience, Global.level)

#Added Level เพิ่มทุกLevel
func experience_gained(exp_gain: int) -> void:
	if Global.level >= Global.MAX_LEVEL:
		return
	var new_experience: int = Global.experience + exp_gain
	Global.experience = new_experience

 
#Added Level เพิ่มทุกLevel
func level_up(new_experience: int) -> void:
	print("yay, I got more powerful")
	new_experience -= Global.LEVEL_THRESHOLDS[Global.level - 1]
	Global.level += 1
	Global.experience = new_experience
	 
	Global.playerSwordDamage += Global.DAMAGE_PER_LEVEL
	Global.playerMaxHP += Global.MAXHP_PER_LEVEL
	Global.playerBody.health_max = Global.playerMaxHP
	Global.playerBody.health = Global.playerBody.health_max
	Global.playerBody.healthbar.init_health(Global.playerBody.health_max)
	Global.playerBody.healthbar.HP = Global.playerBody.health
	Global.playerHP = Global.playerBody.health
	print(Global.level)
	print(Global.experience)


func _on_next_area_body_entered(body: Node2D) -> void:
	if body is Player:
		scene_transition_animation.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/level/level06.tscn")


func _on_next_area_2_body_entered(body: Node2D) -> void:
	if body is Player:
		scene_transition_animation.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/level/level05.tscn")


func _on_next_area_3_body_entered(body: Node2D) -> void:
	if body is Player:
		scene_transition_animation.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		Global.Turn_left = true
		get_tree().change_scene_to_file("res://scenes/level/level08.tscn")


func _on_next_area_4_body_entered(body: Node2D) -> void:
	if body is Player:
		scene_transition_animation.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/level/level09.tscn")
	

func _on_next_area_5_body_entered(body: Node2D) -> void:
	if body is Player and Global.Key_collect == true:
		scene_transition_animation.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/level/level11.tscn")
