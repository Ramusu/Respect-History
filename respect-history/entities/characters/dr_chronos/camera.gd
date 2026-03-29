extends Camera2D

@export var random_strength: float = 2
@export var shake_fade: float = 10

var rng = RandomNumberGenerator.new()

var shake_strength: float = 0.0


func _ready() -> void:
	Signals.movable_land.connect(apply_shake)

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
	
	offset = random_offset()

func apply_shake() -> void:
	shake_strength = random_strength

func movable_fall_shake() -> void:
	apply_shake()
	

func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
