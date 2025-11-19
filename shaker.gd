extends Node2D
class_name Shaker

enum Axes { X_AXIS, Y_AXIS }

var is_shaking : bool = false

var amplitude
var damping
var speed
var frequency
var cutoff
var is_sound_synced
var axis

var x = 0.0

var parent_to_shake
var original_pos

func setup_shake(in_amplitude, in_damping, in_frequency, in_speed, in_cutoff, in_is_sound_synced : bool, in_axis = Axes):
	amplitude = in_amplitude
	damping = in_damping
	frequency = in_frequency
	
	cutoff = in_cutoff
	speed = in_speed
	is_sound_synced = in_is_sound_synced
	
	axis = in_axis
	
	parent_to_shake = get_parent()
	original_pos = parent_to_shake.position
	
	is_shaking = true
	print("Shaking ", parent_to_shake.name, ".")

func damped_func(in_x):
	var a = amplitude
	var b = damping
	var c = frequency
	var d = - PI / 2
	
	var output = a * exp( - b * in_x ) * cos( c * in_x + d )
	
	if in_x >= cutoff:
		output = 0
		pass
	
	return output

func _process(delta: float) -> void:
	if is_shaking:
		
		x += delta * speed
		#print(x)
	
		if axis == Axes.X_AXIS:
			parent_to_shake.position.x = original_pos.x + damped_func(x)
		elif axis == Axes.Y_AXIS:
			parent_to_shake.position.y = original_pos.y + damped_func(x)
		
		if damped_func(x) == 0:
			is_shaking = false
			print(parent_to_shake.name, " is done shaking.")
			queue_free()
