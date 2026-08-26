extends Label

func _ready() -> void:
	Global.experience_updated.connect(_on_experience_updated)
	_on_experience_updated(Global.experience, Global.level)
 
func _on_experience_updated(current_exp: int, level: int) -> void:
	if level >= Global.MAX_LEVEL:
		text = "EXP: MAX"
	else:
		var threshold = Global.LEVEL_THRESHOLDS[level - 1]
		text = "Level: %d" % level
		text = "EXP: %d/%d" % [current_exp, threshold]
