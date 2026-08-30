extends Area2D

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.Button_push == true:
		sprite_2d.animation = "press"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		Global.Button_push = true
		sprite_2d.animation = "press"
