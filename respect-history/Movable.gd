extends RayCast2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !is_colliding():
		position.y += 150 * delta
