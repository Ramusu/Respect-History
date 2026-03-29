extends AnimatedSprite2D

func _ready() -> void:
	get_parent().moving.connect(animate_movement)
	get_parent().dead.connect(animate_death)

func animate_movement(direction: Vector2, is_moving: bool) -> void:
	var dir_string: String = direction_to_string(direction)
	
	if dir_string == "":
		return
		
	var state_prefix: String
	if is_moving:
		state_prefix = "walk_"
	else:
		state_prefix = "idle_"
	
	var anim_name: String = state_prefix + dir_string
	play(anim_name)

func animate_death() -> void:
	play("dead")

func direction_to_string(dir: Vector2) -> String:
	match dir:
		Vector2.UP:
			return "up"
		Vector2.DOWN:
			return "down"
		Vector2.LEFT:
			return "left"
		Vector2.RIGHT:
			return "right"
	return ""
