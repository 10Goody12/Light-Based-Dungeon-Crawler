extends Sprite2D

@export var rotation_speed : float
@export var scale_factor : float

func _process(delta: float) -> void:
	rotation += rotation_speed * delta
