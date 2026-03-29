extends Node
signal movable_land

func land() -> void:
	movable_land.emit()
