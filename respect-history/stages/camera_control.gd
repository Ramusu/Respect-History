extends Camera2D

@export var target: Node2D
var locked: bool = true

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if locked:
		return
	global_position = target.global_position

func on_target_intro_complete():
	locked = false
