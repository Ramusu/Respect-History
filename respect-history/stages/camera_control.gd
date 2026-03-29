extends Camera2D

@export var target: Node2D
var locked: bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if not locked:
		global_position = target.global_position
	else:
		return

func on_target_intro_complete():
	locked = false
