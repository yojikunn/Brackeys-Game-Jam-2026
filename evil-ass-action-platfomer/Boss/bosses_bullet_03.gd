extends Sprite2D
class_name Bosses_bullet03

@onready var hurtbox: Area2D = $Hurtbox

@export var lifetime: float = 10
@export var speed: float = 150.0
@export var turn_speed: float = 2.5
var damage: int = 10

var target: Node2D
var age: float = 0.0
const Is_Player = false

func _ready() -> void:
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	target = Global.playerBody

func _physics_process(delta: float) -> void:
	age += delta
	if age >= lifetime:
		queue_free()
		return
	if is_instance_valid(target):
		var want: float = (target.global_position - global_position).angle()
		rotation = rotate_toward(rotation, want, turn_speed * delta)

	global_position += Vector2(1, 0).rotated(rotation) * speed * delta

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Bullet Pass"):
		return
	if area.is_in_group("Sword"):
		queue_free()
