extends Node2D
class_name ExpDrainer

@export var drain_total: int = 200
@export var drain_per_tick: int = 3
@export var drain_interval: float = 0.08

var draining: bool = false

func start_drain() -> void:
	if draining:
		return
	draining = true
	for i in drain_total:
		if Global.level <= 1 and Global.experience <= 0:
			break
		Global.drain_exp(drain_per_tick)
		await get_tree().create_timer(drain_interval).timeout
	draining = false
