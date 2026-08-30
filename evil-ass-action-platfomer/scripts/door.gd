extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.On_stage_level == 2 and Global.Button_push:
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.On_stage_level == 3 and Global.Batkillcount >= 2:
		queue_free()
