extends Resource
class_name WallTileConfig

@export var label: String
@export var atlas_coords: Vector2i = Vector2i.ZERO
@export var weight: float = 1.0
@export var prevent_clustering: bool = false
@export var prevent_path_adjacency: bool = false
