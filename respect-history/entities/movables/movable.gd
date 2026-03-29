extends Node2D

@onready var wall_down: RayCast2D = $RaycastWalls/WallDown
@onready var wall_left: RayCast2D = $RaycastWalls/WallLeft
@onready var wall_right: RayCast2D = $RaycastWalls/WallRight

@onready var wall_down_left: RayCast2D = $RaycastWalls/WallDownLeft
@onready var wall_down_right: RayCast2D = $RaycastWalls/WallDownRight

@onready var entity_down: RayCast2D = $RaycastEntities/EntityDown
@onready var entity_left: RayCast2D = $RaycastEntities/EntityLeft
@onready var entity_right: RayCast2D = $RaycastEntities/EntityRight

@onready var entity_down_left: RayCast2D = $RaycastEntities/EntityDownLeft
@onready var entity_down_right: RayCast2D = $RaycastEntities/EntityDownRight
@onready var destroyable_down: RayCast2D = $RaycastEntities/DestroyableDown

@onready var player_down: RayCast2D = $RaycastPlayerKill/PlayerDown
@onready var player_left: RayCast2D = $RaycastPlayerKill/PlayerLeft
@onready var player_right: RayCast2D = $RaycastPlayerKill/PlayerRight

@export var fall_delay: float = 0.1
@export var slide_delay: float = 0.5 
var current_fall_time: float = 0.0
var current_slide_time: float = 0.0 

var falling: bool = false
var player_crushed: bool = false

@export var push_tiles_per_second: float = 2.0
var is_pushed: bool = false
var target_position: Vector2

var pending_slide_dir: int = 0

@export_group("Visuals")
@export var sprite: Node2D 
@export var shake_amplitude: float = 2.0
@export var shake_speed: float = 50.0
@export var slide_drift: float = 8.0 
var base_sprite_pos: Vector2

var push_speed: float:
	get:
		return Global.TILE_SIZE * push_tiles_per_second

func _ready() -> void:
	target_position = global_position
	if sprite:
		base_sprite_pos = sprite.position

func _physics_process(delta: float) -> void:
	if is_pushed:
		move_to_target(delta)
		return 
	
	wall_down.force_raycast_update()
	entity_down.force_raycast_update()
	destroyable_down.force_raycast_update()
	player_down.force_raycast_update()
	
	var solid_ground_below: bool = wall_down.is_colliding() or entity_down.is_colliding() or destroyable_down.is_colliding()
	var player_below: bool = player_down.is_colliding()
	
	if solid_ground_below:
		falling = false
		current_fall_time = 0.0 
		
		if entity_down.is_colliding() and not destroyable_down.is_colliding():
			wall_left.force_raycast_update()
			entity_left.force_raycast_update()
			wall_down_left.force_raycast_update()
			entity_down_left.force_raycast_update()
			player_left.force_raycast_update()
			
			wall_right.force_raycast_update()
			entity_right.force_raycast_update()
			wall_down_right.force_raycast_update()
			entity_down_right.force_raycast_update()
			player_right.force_raycast_update()
			
			var can_slide_left: bool = not (wall_left.is_colliding() or entity_left.is_colliding() or player_left.is_colliding() or wall_down_left.is_colliding() or entity_down_left.is_colliding())
			var can_slide_right: bool = not (wall_right.is_colliding() or entity_right.is_colliding() or player_right.is_colliding() or wall_down_right.is_colliding() or entity_down_right.is_colliding())
			
			var desired_slide_dir: int = 0
			if can_slide_left:
				desired_slide_dir = -1
			elif can_slide_right:
				desired_slide_dir = 1
				
			if desired_slide_dir != 0:
				if pending_slide_dir == desired_slide_dir:
					current_slide_time += delta
					if current_slide_time >= slide_delay:
						start_slide(desired_slide_dir) 
						current_slide_time = 0.0
						pending_slide_dir = 0
				else:
					pending_slide_dir = desired_slide_dir
					current_slide_time = 0.0
			else:
				pending_slide_dir = 0
				current_slide_time = 0.0
		else:
			pending_slide_dir = 0
			current_slide_time = 0.0
			
	elif not falling:
		pending_slide_dir = 0
		current_slide_time = 0.0 
		
		var target_delay: float = fall_delay * 5 if player_below else fall_delay
		
		current_fall_time += delta
		
		if current_fall_time >= target_delay:
			falling = true
			current_fall_time = 0.0
	
	if sprite:
		if pending_slide_dir != 0 and current_slide_time > 0.0:
			var t: float = current_slide_time / slide_delay 
			var shake_offset: float = sin(current_slide_time * shake_speed) * shake_amplitude * t
			var drift_offset: float = pending_slide_dir * slide_drift * t
			
			sprite.position.x = base_sprite_pos.x + drift_offset + shake_offset
		else:
			sprite.position.x = base_sprite_pos.x 

	if falling:
		fall()
		check_player_crush(player_down)

func fall() -> void:
	global_position.y += 2

func check_player_crush(ray: RayCast2D) -> void:
	if player_crushed:
		return
	
	ray.force_raycast_update()
	if ray.is_colliding():
		var body: Area2D = ray.get_collider()
		if body:
			var player: Node2D = body.get_parent()
			if player and player.is_in_group("player"):
				player.die()
				player_crushed = true

func move_to_target(delta: float) -> void:
	global_position = global_position.move_toward(target_position, push_speed * delta)
	
	if global_position.distance_to(target_position) < 1:
		global_position = target_position
		is_pushed = false

func push(dir: int) -> bool:
	if falling or is_pushed:
		return false
		
	var is_blocked: bool = false
	
	if dir > 0:
		wall_right.force_raycast_update()
		entity_right.force_raycast_update()
		is_blocked = wall_right.is_colliding() or entity_right.is_colliding()
	elif dir < 0:
		wall_left.force_raycast_update()
		entity_left.force_raycast_update()
		is_blocked = wall_left.is_colliding() or entity_left.is_colliding()
		
	if not is_blocked:
		target_position = global_position + Vector2(dir * Global.TILE_SIZE, 0)
		is_pushed = true 
		return true
		
	return false

func start_slide(dir: int) -> void:
	global_position.x += dir * Global.TILE_SIZE
	
	if sprite:
		sprite.position.x = base_sprite_pos.x
	
	falling = true
	current_fall_time = 0.0
