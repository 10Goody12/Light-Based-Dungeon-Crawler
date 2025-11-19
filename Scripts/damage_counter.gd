extends Node2D
class_name DamageCounter

var damage_dealt
var counter_text : String
var counter_text_prefix : String = "[center]"
var counter_text_suffix : String = "[/center]"

@export var float_height : float = 50.0
@export var float_speed : float = 10.0
@export var float_linger : float = 1000.0
@export var font_size : float = 12.0
@export var font_size_decay : float = 2.0
@export var label_colour : Color = Color.WHITE
@export var use_rainbow_shader : bool = false


var start_position : Vector2
var float_counter : float = 0.0

@onready var label = $Container/DamageLabel
@onready var container = $Container
var camera

#func update_screen_position():
	#var camera = get_viewport().get_camera_2d()
	#if camera:
		#var screen_pos = camera.unproject_position(start_position)
		#container.position = screen_pos

func initialize(in_damage_dealt, in_float_height, in_float_speed, in_float_linger, in_font_size, in_font_size_decay, in_colour, in_position, in_use_rainbow_shader : bool = false):
	damage_dealt = snappedf(in_damage_dealt, 0.01)
	float_height = in_float_height
	float_speed = in_float_speed
	float_linger = in_float_linger
	font_size = in_font_size
	font_size_decay = in_font_size_decay
	label_colour = in_colour
	#container.global_position = in_position
	start_position = in_position
	use_rainbow_shader = in_use_rainbow_shader

func _ready() -> void:
	camera = get_tree().get_first_node_in_group("Camera")
	container.global_position = start_position
	
	if float(damage_dealt) == int(damage_dealt):
		var damage_dealt_as_int = int(damage_dealt)
		damage_dealt = damage_dealt_as_int
		#print("Damage dealt: ", damage_dealt, "\nDamage as int: ", int(damage_dealt))
	
	counter_text = str(damage_dealt)
	label.text = counter_text_prefix + counter_text + counter_text_suffix
	label.add_theme_font_size_override("normal_font_size", font_size)
	label.add_theme_color_override("default_color", label_colour)
	float_counter = 0.0
	#print("Damage Counter spawned: ", str(self))
	
	var shader := Shader.new()
	var mat := ShaderMaterial.new()
	
	if use_rainbow_shader:
		shader.code = preload("res://Resources/Shaders/rgb_cycle.gdshader").code
		mat.shader = shader
		label.material = mat
	#else:
		#mat.shader = null
		#label.material = null

func _process(delta: float) -> void:
	float_counter += delta
	#start_position = start_position + camera.position
	
	if float_counter >= float_linger / float_speed:
		queue_free()
		pass
	else:
		container.position = container.position.lerp(start_position + Vector2(0, - float_height), delta * float_speed)
		modulate.a -= delta
		#label.add_theme_font_size_override("normal_font_size", font_size - (font_size_decay * float_counter))
		label.scale = label.scale.lerp(Vector2(0,0), font_size_decay * delta)
		#label.position.x += float(font_size_decay * delta)
		label.position.x = lerp(label.position.x, 5.0, delta / font_size_decay)
