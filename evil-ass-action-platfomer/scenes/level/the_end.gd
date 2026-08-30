extends Node2D

@onready var ending_tex_00t: Sprite2D = $EndingTex00t
@onready var ending_tex_01t: Sprite2D = $EndingTex01t
@onready var ending_tex_02t: Sprite2D = $EndingTex02t
@onready var ending_tex_03t: Sprite2D = $EndingTex03t


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.Ending == 0:
		ending_tex_00t.visible = true
	if Global.Ending == 1:
		ending_tex_01t.visible = true
	if Global.Ending == 2:
		ending_tex_02t.visible = true
	if Global.Ending == 3:
		ending_tex_03t.visible = true
