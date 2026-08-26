extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar

var HP = 0 : set = _set_health

func _set_health(new_health):
	var perv_HP = HP
	HP = min(max_value, new_health)
	value = HP
	
	if HP <= 0:
		queue_free()
		
	if HP < perv_HP:
		timer.start()
	else:
		damage_bar.value = HP

func init_health(_health):
	HP = _health
	max_value = HP
	value = HP
	damage_bar.max_value = HP
	damage_bar.value = HP

func _on_timer_timeout() -> void:
	damage_bar.value = HP
