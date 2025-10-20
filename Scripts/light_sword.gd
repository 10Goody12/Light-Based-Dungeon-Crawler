extends Node2D

@export_range(0, 2500, 0.1) var damage : float = 1.0
@onready var sparkle = get_tree().get_first_node_in_group("LightSparkle")
@onready var sparkle2 = get_tree().get_nodes_in_group("LightSparkle")[1]
@onready var light = get_tree().get_first_node_in_group("CursorLight")
@onready var trail = get_tree().get_first_node_in_group("CursorTrail")
@onready var particles

var last_pos = Vector2(0,0)

var cursor_speed
var direction_angle
var velocity : Vector2

#func _ready() -> void:
	#trail = $CursorTrail

func get_cursor_move_data(delta: float):
	var cursor_diff_vec = get_global_mouse_position() - last_pos
	direction_angle = atan2(cursor_diff_vec.y, cursor_diff_vec.x)
	cursor_speed = cursor_diff_vec.length() / delta
	#print("Cursor speed: ", cursor_speed, "\nCursor direction: ", direction_angle)
	
	var cursor_data = [ cursor_speed, direction_angle ]
	return cursor_data

#func draw_line_from_to(in_start : Vector2, in_end : Vector2, in_lifetime, in_width):
	#var new_line = CursorTrail.new()
	#get_tree().root.add_child(new_line)
	#
	#new_line.add_point(in_start, 0)
	#new_line.add_point(in_end, 1)
	#
	#new_line.width = in_width
	#
	#new_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	#new_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	##new_line.set_time_left(in_lifetime)

func draw_trail(in_end : Vector2, in_width, is_rainbow : bool = false, max_points : int = TYPE_NIL):	
	trail.add_point(in_end)
	trail.width = in_width
	if max_points != TYPE_NIL:
		trail.set_max_line_points(max_points)
	if not is_rainbow:
		trail.gradient = null

func _process(delta: float) -> void:
	var data = get_cursor_move_data(delta)
	position = get_global_mouse_position()
	
	#draw_line_from_to(last_pos, position, 100.0, 1.0)
	draw_trail(position, 5, true, 50)
	sparkle.scale = (Vector2(data[0], data[0]) / 500) * sparkle.scale_factor
	sparkle2.scale = (Vector2(data[0], data[0]) / 500) * sparkle2.scale_factor
	light.energy = data[0] / 500

	last_pos = position

func _on_collision_hitbox_body_entered(target: Node2D) -> void:
	#print("Collision detected between the cursor and: ", str(body))
	
	if target is Enemy:
		target.inflict_damage(damage)
