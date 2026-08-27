extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar
var HP = 0 : set = _set_health
var max_hp: int = 100

const BASE_MAX_HP: float = 100.0
const BASE_BAR_WIDTH: float = 200.0

func _set_health(new_health):
	var prev_HP = HP
	HP = clamp(new_health, 0, max_hp)
	value = (float(HP) / float(max_hp)) * 100.0 if max_hp > 0 else 0.0
	
	if HP <= 0:
		queue_free()
		
	if HP < prev_HP:
		timer.start()
	else:
		damage_bar.value = value

func init_health(_health):
	max_hp = _health
	HP = _health
	max_value = 100
	value = 100
	damage_bar.max_value = 100
	damage_bar.value = 100

	var bar_width = (float(Global.playerMaxHP) / BASE_MAX_HP) * BASE_BAR_WIDTH
	custom_minimum_size.x = bar_width
	damage_bar.custom_minimum_size.x = bar_width

func _on_timer_timeout() -> void:
	damage_bar.value = value
