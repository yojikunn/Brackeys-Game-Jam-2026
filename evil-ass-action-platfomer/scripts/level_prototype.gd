extends Node2D

@onready var scene_transition_animation = $ScenceTransitionAnimation/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.playerBody.healthbar.init_health(Global.playerBody.health_max)
	var enemies = get_tree().get_nodes_in_group("enemies")
	for i in enemies:
		if not i.dropEXP.is_connected(experience_gained):
			i.dropEXP.connect(experience_gained)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_next_area_body_entered(body: Node2D) -> void:
	if body is Player:
		scene_transition_animation.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/level2_prototype.tscn")


#Added Level เพิ่มทุกLevel
func experience_gained(exp_gain: int) -> void:
	if Global.level >= Global.MAX_LEVEL:
		return
	var new_experience: int = Global.experience + exp_gain
	if new_experience >= Global.LEVEL_THRESHOLDS[Global.level - 1]:
		level_up(new_experience)
	else:
		Global.experience = new_experience
	Global.experience_updated.emit(Global.experience, Global.level)
 
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
