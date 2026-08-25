extends Area2D

const DialogueSystemPreload = preload("res://Dialogue/Dialogue_Code/dialogue_system.tscn")

@export var activate_instant: bool
@export var activate_when_interact: bool
@export var only_activate_once: bool
@export var override_dialogue_position: bool
@export var override_position: Vector2
@export var dialogue: Array[DE]

var dialogue_top_pos: Vector2 = Vector2(160, 48)
var dialogue_bottom_pos: Vector2 = Vector2(160, 192)

var player_body_in: bool = false
var has_activated_already: bool = false
var desired_dialogue_pos: Vector2

var player_node: CharacterBody2D = null

func _ready() -> void:
	for i in get_tree().get_nodes_in_group("player"):
		if i is CharacterBody2D:
			player_node = i

func _process(_delta: float) -> void:
	if !player_node:
		for i in get_tree().get_nodes_in_group("player"):
			if i is CharacterBody2D:
				player_node = i
		return
	
	if !activate_instant and player_body_in:
		if only_activate_once and has_activated_already:
			set_process(false)
			return
	
		if Input.is_action_just_pressed("dialogue"):
			_activate_dialogue()
			player_body_in = false

func _activate_dialogue() -> void:
	player_node.can_move = false
	has_activated_already = true
	
	var new_dialogue = DialogueSystemPreload.instantiate()
	if override_dialogue_position:
		desired_dialogue_pos = override_position
	else:
		var camera: Camera2D = get_viewport().get_camera_2d()
		if camera and player_node.global_position.y > camera.get_screen_center_position().y:
			desired_dialogue_pos = dialogue_top_pos
		else:
			desired_dialogue_pos = dialogue_bottom_pos
	new_dialogue.offset = desired_dialogue_pos
	new_dialogue.dialogue = dialogue
	get_parent().add_child(new_dialogue)

##Added/Fixed
func _on_body_entered(body: Node2D) -> void:
	if only_activate_once and has_activated_already:
		return
	if body.is_in_group("player"):
		player_body_in = true
		print("is_in")
		if activate_instant:
			_activate_dialogue()
		if activate_when_interact and Input.is_action_just_pressed("dialogue"):
			_activate_dialogue()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("is_out")
		player_body_in = false
