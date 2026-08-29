extends ProgressBar
@onready var timer = $Timer
@onready var damage_bar = $DamageBar
var health:int = 0 : set = _set_health
 
func _set_health(new_health):
	var prev_health = health
	health = clamp(new_health, 0, max_value)
	value = health
	
	if health <= 0:
		queue_free()
		
	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health
 
func init_health(_health):
	max_value = _health
	damage_bar.max_value = _health
	health = _health
	value = _health
	damage_bar.value = _health
 
func _on_timer_timeout() -> void:
	damage_bar.value = health
 
