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
	if Global.On_stage_level == 2 or Global.On_stage_level == 3 or Global.On_stage_level == 4 or Global.On_stage_level == 10:
		limit_left = 10
		limit_bottom = 710
		limit_top = -46
		limit_right = 1050
	if Global.On_stage_level == 5:
		limit_left = -1536
		limit_bottom = 710
		limit_top = -339
		limit_right = 1106
	if Global.On_stage_level == 6:
		limit_left = 10
		limit_bottom = 710
		limit_top = -720
		limit_right = 1050
	if Global.On_stage_level == 7 or Global.On_stage_level == 8:
		limit_left = -234
		limit_bottom = 710
		limit_top = -150
		limit_right = 1277
	if Global.On_stage_level == 9:
		limit_left = -154
		limit_bottom = 838
		limit_top = -76
		limit_right = 2145
