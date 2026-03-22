extends CharacterBody2D

signal moving(dir: Vector2, is_moving: bool)

@onready var ray_cast_up: RayCast2D = $RayCastUp
@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight

@export var tiles_per_second: int = 4
const tile_size: int = 32

var move_speed: float:
	get:
		return tile_size * tiles_per_second

var target_position: Vector2
var is_moving: bool = false
var current_direction: Vector2 = Vector2.ZERO

var last_emitted_dir: Vector2 = Vector2.ZERO
var last_emitted_moving: bool = false

func _ready():
	target_position = global_position

func _physics_process(delta: float) -> void:
	handle_input()
	move_to_target(delta)

func handle_input():
	if is_moving:
		return
	
	var direction: Vector2 = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		direction = Vector2.UP
	elif Input.is_action_pressed("move_down"):
		direction = Vector2.DOWN
	elif Input.is_action_pressed("move_left"):
		direction = Vector2.LEFT
	elif Input.is_action_pressed("move_right"):
		direction = Vector2.RIGHT
	
	move(direction)

func move(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		update_moving_signal(current_direction, false)
		return
	
	current_direction = direction
	
	if is_moving:
		return

	var can_move: bool = false
	match direction:
		Vector2.UP:
			can_move = not ray_cast_up.is_colliding()
		Vector2.DOWN:
			can_move = not ray_cast_down.is_colliding()
		Vector2.LEFT:
			can_move = not ray_cast_left.is_colliding()
		Vector2.RIGHT:
			can_move = not ray_cast_right.is_colliding()
	
	if can_move:
		target_position = global_position + direction * tile_size
		is_moving = true
		update_moving_signal(current_direction, true)
	else:
		update_moving_signal(current_direction, false)

func move_to_target(delta: float) -> void:
	if not is_moving:
		return
	
	global_position = global_position.move_toward(target_position, move_speed * delta)
	
	if global_position.distance_to(target_position) < 1:
		global_position = target_position
		is_moving = false
		handle_input()

func update_moving_signal(dir: Vector2, state: bool) -> void:
	if dir != last_emitted_dir or state != last_emitted_moving:
		moving.emit(dir, state)
		last_emitted_dir = dir
		last_emitted_moving = state
