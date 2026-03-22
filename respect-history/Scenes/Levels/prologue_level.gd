extends Node2D

@export var base_layer: TileMapLayer
var overlay_layer: TileMapLayer 

const OVERLAY_SOURCE_ID: int = 3
const OVERLAY_ATLAS_COORDS: Vector2i = Vector2i(0, 0)

func _ready() -> void:
	overlay_layer = TileMapLayer.new()
	overlay_layer.name = "OverlayTileMapLayer"
	overlay_layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	if base_layer:
		overlay_layer.tile_set = base_layer.tile_set
		overlay_layer.z_index = base_layer.z_index + 1
	
	add_child(overlay_layer)
	generate_platform_overlays()

func generate_platform_overlays() -> void:
	# Add a safety check just in case
	if not base_layer or not overlay_layer:
		return
		
	var used_cells: Array[Vector2i] = base_layer.get_used_cells()
	
	for cell in used_cells:
		var current_tile_data: TileData = base_layer.get_cell_tile_data(cell)
		if not current_tile_data:
			continue
		
		var is_wall: bool = current_tile_data.get_collision_polygons_count(0) > 0
		
		if is_wall:
			var cell_above_pos: Vector2i = Vector2i(cell.x, cell.y - 1)
			var tile_above_data: TileData = base_layer.get_cell_tile_data(cell_above_pos)
			
			if tile_above_data and tile_above_data.get_collision_polygons_count(0) == 0:
				overlay_layer.set_cell(cell, OVERLAY_SOURCE_ID, OVERLAY_ATLAS_COORDS)
