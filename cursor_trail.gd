extends Line2D

class_name CursorTrail

@export var max_line_points : int
var time_left : float
var max_lifetime

#func set_time_left(in_time):
	#time_left = in_time
	#max_lifetime = in_time

func set_max_line_points(in_num):
	max_line_points = in_num

func _process(delta: float) -> void:
	#var alpha_per_second = 255 / max_lifetime
	#if time_left <= 0:
		#queue_free()
	
	#time_left -= delta
	#default_color.a -= alpha_per_second * delta
	
	if points.size() >= max_line_points:
		var points_removed : int = 0
		while points.size() > max_line_points:
			remove_point(0)
			#points_removed += 1
		#print("Removing oldest point(s) in cursor trail")
		#print("Removed the oldest ", points_removed, " points from the cursor_trail")
