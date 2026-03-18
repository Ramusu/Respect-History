extends Area2D

@export var speed = 500

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if collision_mask == 1:
		position.y = speed * delta
