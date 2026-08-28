extends Node2D

@onready var scene_transition_animation = $SceneTransitionAnimation/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene_transition_animation.get_parent().get_node("ColorRect").color.a = 255
	scene_transition_animation.play("fade_out")
	if Global.On_stage_level == 2:
		await get_tree().create_timer(0.5).timeout
		Global.Turn_left = false
	Global.On_stage_level = 5
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
		get_tree().change_scene_to_file("res://scenes/level/level02.tscn")
