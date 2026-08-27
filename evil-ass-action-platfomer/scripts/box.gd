extends CharacterBody2D

class_name box

@export var custom_sprite: Sprite2D
@export var can_push: bool = false

var knockback = Vector2.ZERO
var knockback_timer = 0.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_on_floor() and knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
			velocity.x = 0
			velocity.y = 0
		
	move_and_slide()


func _on_box_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		if !can_push:
			queue_free()
		else:
			var knockback_dir = (global_position - area.global_position).normalized()
			apply_knockback(knockback_dir, 120.0, 0.12)


func apply_knockback(direction: Vector2, force: float, knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration
