extends Sprite2D

class_name Bosses_bullet01

@onready var hurtbox: Area2D = $Hurtbox

var speed: float = 350.0
var damage: int = 10

const Is_Player = false

func _ready() -> void:
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _physics_process(delta: float) -> void:
	global_position += Vector2(1,0).rotated(rotation) * speed * delta

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Bullet Pass") or area.is_in_group("Sword"):
		return
	queue_free()
