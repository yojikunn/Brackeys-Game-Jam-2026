extends ProgressBar
@onready var timer = $Timer
@onready var exp_gain_bar = $EXPGainBar
 
var current_exp: int = 0 : set = _set_exp
 
func _ready() -> void:
	Global.experience_updated.connect(_on_experience_updated)
	_on_experience_updated(Global.experience, Global.level)
 
func _on_experience_updated(exp: int, level: int) -> void:
	if level >= Global.MAX_LEVEL:
		max_value = 1
		exp_gain_bar.max_value = 1
		current_exp = 1
	else:
		var threshold = Global.LEVEL_THRESHOLDS[level - 1]
		max_value = threshold
		exp_gain_bar.max_value = threshold
		current_exp = exp
 
func _set_exp(new_exp):
	var prev_exp = current_exp
	current_exp = clamp(new_exp, 0, max_value)
	value = current_exp
 
	if current_exp > prev_exp:
		timer.start()
	else:
		exp_gain_bar.value = current_exp
 
func _on_timer_timeout() -> void:
	exp_gain_bar.value = current_exp
 
