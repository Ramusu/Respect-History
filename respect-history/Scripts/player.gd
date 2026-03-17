extends CharacterBody2D

var speed = 100 # movement speed
var last_direction := Vector2(1,0) # direction a player faces when standing still

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction*speed
	move_and_slide()
	
	if direction.length(): # check if player is moving
		last_direction = direction
		animation_move(direction)
	else:
		animation_idle(last_direction)
func animation_move(direction):
	if direction.y > 0:
		$AnimatedSprite2D.play("walk_up")
	elif direction.y < 0:
		$AnimatedSprite2D.play("walk_down")
	elif direction.x > 0:
		$AnimatedSprite2D.play("walk_right")
	elif direction.x < 0:
		$AnimatedSprite2D.play("walk_left")
func animation_idle(direction):
	if direction.y > 0:
		$AnimatedSprite2D.play("idle_up")
	elif direction.y < 0:
		$AnimatedSprite2D.play("idle_down")
	elif direction.x > 0:
		$AnimatedSprite2D.play("idle_right")
	elif direction.x < 0:
		$AnimatedSprite2D.play("idle_left")
