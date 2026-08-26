extends Label
 
func _ready() -> void:
	Global.experience_updated.connect(_on_experience_updated)
	_on_experience_updated(Global.experience, Global.level)
 
func _on_experience_updated(current_exp: int, level: int) -> void:
	text = "Lv.%d" % level
 
