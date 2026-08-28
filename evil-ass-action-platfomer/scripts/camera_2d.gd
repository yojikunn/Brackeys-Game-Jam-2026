extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.On_stage_level == 1:
		limit_left = 0
		limit_bottom = 710
		limit_top = 0
		limit_right = 1290
	if Global.On_stage_level == 2 or Global.On_stage_level == 3 or Global.On_stage_level == 4:
		limit_left = 10
		limit_bottom = 710
		limit_top = -46
		limit_right = 1050
	if Global.On_stage_level == 5:
		limit_left = -1536
		limit_bottom = 710
		limit_top = -339
		limit_right = 1106
