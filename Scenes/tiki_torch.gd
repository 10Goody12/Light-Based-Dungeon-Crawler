extends Node2D
class_name TikiTorch

@export var flame_colour : Color
@export_range(0, 100.0, 5.0) var light_intensity : float

@onready var flame = $Flame
@onready var shadow = $Shadow
@onready var flame_light = $Flamelight

@onready var shadow_default_a = $Shadow.self_modulate.a
@onready var flame_origin_pos

@export_range(0, 5, 0.1) var flicker_time : float
@export_range(0, 24, 0.5) var flicker_amplitude : float = 2.0
@export_range(0, 10, 0.1) var flicker_speed : float = 1.0
var time_since_last_flicker : float = 0.0

func _ready() -> void:
	flame.self_modulate = flame_colour
	flame_light.color = flame_colour
	flame.play("on")
	flame_origin_pos = Vector2.ZERO

func _physics_process(delta: float) -> void:
	time_since_last_flicker += delta
	var target_pos = Vector2.ZERO
	
	if time_since_last_flicker >= flicker_time:
		time_since_last_flicker = 0.0
		target_pos =  + Vector2(randf_range(-flicker_amplitude, flicker_amplitude), randf_range(-flicker_amplitude, flicker_amplitude))
	
	flame_light.position = position.lerp(target_pos, delta)
