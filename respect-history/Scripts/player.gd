extends CharacterBody2D

@export var animated_sprite_2d: AnimatedSprite2D

var speed = 100 # movement speed
var last_direction := Vector2(1,0) # direction a player faces when standing still

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO
	var x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	if x != 0:
		direction = Vector2(x, 0)
	elif y != 0:
		direction = Vector2(0, y)
		
	velocity = direction*speed
	move_and_slide()

	if direction.length(): # check if player is moving
		last_direction = direction
		animation_move(direction)
	else:
		animation_idle(last_direction)

func play_animation(name: String):
	if animated_sprite_2d.animation != name:
		animated_sprite_2d.play(name)

func animation_move(direction):
	if direction.y > 0:
		play_animation("walk_down")
	elif direction.y < 0:
		play_animation("walk_up")
	elif direction.x > 0:
		play_animation("walk_right")
	elif direction.x < 0:
		play_animation("walk_left")

func animation_idle(direction):
	if direction.y > 0:
		play_animation("idle_down")
	elif direction.y < 0:
		play_animation("idle_up")
	elif direction.x > 0:
		play_animation("idle_right")
	elif direction.x < 0:
		play_animation("idle_left")
