extends Node2D
@onready var dialogue_area_2d_2: Area2D = $DialogueArea2D2
@onready var dialogue_area_2d_3: Area2D = $DialogueArea2D3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func choose_yes():
	dialogue_area_2d_2.set_deferred("monitoring", true)
func choose_no():
	dialogue_area_2d_3.set_deferred("monitoring", true)
