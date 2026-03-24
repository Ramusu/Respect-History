extends Node2D

@export_category("TileMap Layers")
@export var path_layer: TileMapLayer
@export var wall_layer: TileMapLayer

var overlay_layer: TileMapLayer 

@export_category("Environment Settings")
@export var background_color: Color = Color("1a1a1a")

@export_category("Generation Settings")
@export var level_seed: String = ""
@export var wall_offset: int = 4

@export_category("Wall Tile Configuration")
@export var wall_source_id: int = 0
@export var wall_tiles: Array[WallTileConfig]

@export_category("Platform Overlay Settings")
@export var overlay_source_id: int = 3
@export var overlay_atlas_coords: Vector2i = Vector2i(0, 0)

func _ready() -> void:
	RenderingServer.set_default_clear_color(background_color)
	
	if level_seed.is_empty():
		randomize()
		level_seed = str(randi())
	
	seed(level_seed.hash())
	print("Level Generation Seed: ", level_seed)
	
	setup_overlay_layer()
	generate_walls()
	generate_platform_overlays()

func setup_overlay_layer() -> void:
	overlay_layer = TileMapLayer.new()
	overlay_layer.name = "OverlayTileMapLayer"
	overlay_layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	if wall_layer:
		overlay_layer.tile_set = wall_layer.tile_set
		overlay_layer.z_index = wall_layer.z_index + 1
	
	add_child(overlay_layer)

func generate_walls() -> void:
	if not path_layer or not wall_layer:
		return

	if wall_tiles.is_empty():
		return

	var path_cells: Array[Vector2i] = path_layer.get_used_cells()
	var path_set: Dictionary = {}
	for cell in path_cells:
		path_set[cell] = true
	
	var target_wall_cells: Dictionary = {}
	
	for cell in path_cells:
		for x in range(-wall_offset, wall_offset + 1):
			for y in range(-wall_offset, wall_offset + 1):
				var neighbor_pos: Vector2i = cell + Vector2i(x, y)
				if not path_set.has(neighbor_pos):
					target_wall_cells[neighbor_pos] = true
	
	var placed_walls: Dictionary = {}
	
	for wall_cell in target_wall_cells.keys():
		var chosen_tile: Vector2i = get_valid_random_wall_tile(wall_cell, path_set, placed_walls)
		wall_layer.set_cell(wall_cell, wall_source_id, chosen_tile)
		placed_walls[wall_cell] = chosen_tile

func get_valid_random_wall_tile(cell: Vector2i, path_set: Dictionary, placed_walls: Dictionary) -> Vector2i:
	var is_near_path: bool = false
	var neighbor_tiles: Array[Vector2i] = []
	
	for x in range(-1, 2):
		for y in range(-1, 2):
			if x == 0 and y == 0:
				continue
			
			var neighbor_pos: Vector2i = cell + Vector2i(x, y)
			
			if path_set.has(neighbor_pos):
				is_near_path = true
			
			if placed_walls.has(neighbor_pos):
				neighbor_tiles.append(placed_walls[neighbor_pos])

	var valid_tiles: Array[WallTileConfig] = []
	var local_total_weight: float = 0.0
	
	for tile in wall_tiles:
		if not tile: 
			continue 
		
		if tile.prevent_path_adjacency and is_near_path:
			continue
		
		if tile.prevent_clustering and neighbor_tiles.has(tile.atlas_coords):
			continue
		
		valid_tiles.append(tile)
		local_total_weight += tile.weight
	
	if valid_tiles.is_empty():
		return wall_tiles[0].atlas_coords if wall_tiles[0] else Vector2i.ZERO 
	
	var random_value: float = randf() * local_total_weight
	var current_weight: float = 0.0
	
	for tile in valid_tiles:
		current_weight += tile.weight
		if random_value <= current_weight:
			return tile.atlas_coords
	
	return valid_tiles[0].atlas_coords

func generate_platform_overlays() -> void:
	if not wall_layer or not overlay_layer or not path_layer:
		return
		
	var used_cells: Array[Vector2i] = wall_layer.get_used_cells()
	
	for cell in used_cells:
		var current_tile_data: TileData = wall_layer.get_cell_tile_data(cell)
		if not current_tile_data:
			continue
		
		var is_wall: bool = current_tile_data.get_collision_polygons_count(0) > 0
		
		if is_wall:
			var cell_above_pos: Vector2i = Vector2i(cell.x, cell.y - 1)
			var is_walkable_path: bool = path_layer.get_cell_source_id(cell_above_pos) != -1
			
			if is_walkable_path:
				overlay_layer.set_cell(cell, overlay_source_id, overlay_atlas_coords)
