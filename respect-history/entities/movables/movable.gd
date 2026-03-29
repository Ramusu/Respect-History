extends Node2D

@onready var wall_down: RayCast2D = $RaycastWalls/WallDown
@onready var entity_down: RayCast2D = $RaycastEntities/EntityDown
@onready var player_down: RayCast2D = $RaycastPlayerKill/PlayerDown

var fall_delay: float = 0.2
var current_fall_time: float= 0.0

var falling: bool = false
var player_crushed: bool = false

func _physics_process(delta: float) -> void:
	wall_down.force_raycast_update()
	entity_down.force_raycast_update()
	player_down.force_raycast_update()
	
	var solid_ground_below: bool = wall_down.is_colliding() or entity_down.is_colliding()
	var player_below: bool = player_down.is_colliding()
	
	if solid_ground_below:
		falling = false
		current_fall_time = 0.0
	elif not falling:
		var target_delay: float = fall_delay * 2.5 if player_below else fall_delay
		
		current_fall_time += delta
		
		if current_fall_time >= target_delay:
			falling = true
			current_fall_time = 0.0

	if falling:
		fall()
		check_player_crush()


func fall() -> void:
	global_position.y += 2


func check_player_crush() -> void:
	if player_crushed:
		return
	
	if player_down.is_colliding():
		var body: Area2D = player_down.get_collider()
		if body:
			var player: Node2D = body.get_parent()
			if player and player.is_in_group("player"):
				player.die()
				player_crushed = true
