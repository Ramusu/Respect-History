extends CharacterBody2D

@export var speed = 500

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity = Vector2(0,speed)
	move_and_slide()
