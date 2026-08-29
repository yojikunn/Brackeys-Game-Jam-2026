extends ProgressBar
@onready var timer = $Timer
@onready var damage_bar = $DamageBar
var start_x: float = 62.0
var HP = 0 : set = _set_health
var max_hp: int = 100
const BASE_MAX_HP: float = 100.0
const BASE_BAR_WIDTH: float = 200.0

func _ready() -> void:
	Global.experience_updated.connect(_on_level_changed)

func _on_level_changed(_exp: int, _lv: int) -> void:
	var new_max: int = int(Global.playerMaxHP)
	if new_max == max_hp:
		return
	max_hp = new_max
	_resize_bar()
	HP = min(HP, max_hp)

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
	_resize_bar()

func _on_timer_timeout() -> void:
	damage_bar.value = value


func _resize_bar() -> void:
	var bar_width = (float(max_hp) / BASE_MAX_HP) * BASE_BAR_WIDTH
	custom_minimum_size.x = bar_width
	size.x = bar_width
	position.x = start_x
	damage_bar.custom_minimum_size.x = bar_width
	damage_bar.size.x = bar_width
	damage_bar.position.x = 0
