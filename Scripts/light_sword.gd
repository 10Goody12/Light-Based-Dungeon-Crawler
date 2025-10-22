extends Node2D

@export_range(0, 2500, 0.1) var damage : float = 1.0
@onready var sparkles = get_tree().get_first_node_in_group("CursorSparkles")
@onready var star = get_tree().get_nodes_in_group("CursorStar")[0]
@onready var star_2 = get_tree().get_nodes_in_group("CursorStar")[1]
@onready var light = get_tree().get_first_node_in_group("CursorLight")
@onready var trail = get_tree().get_first_node_in_group("CursorTrail")

var last_pos = Vector2(0,0)

var data
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

func draw_trail(in_end : Vector2, in_width, is_rainbow : bool = false, is_sparkling : bool = false, max_points : int = TYPE_NIL):	
	trail.add_point(in_end)
	trail.width = in_width
	if max_points != TYPE_NIL:
		trail.set_max_line_points(max_points)
	if not is_rainbow:
		trail.gradient = null

func check_for_objects_slashed(last_pos):
	var segment = SegmentShape2D.new()
	segment.a = last_pos
	segment.b = get_global_mouse_position()

	var shape_query = PhysicsShapeQueryParameters2D.new()
	shape_query.set_shape(segment)
	shape_query.transform = Transform2D.IDENTITY
	shape_query.collision_mask = 0xFFFFFFFF

	var space_state = get_world_2d().direct_space_state
	var results = space_state.intersect_shape(shape_query)

	return results
	
	#for result in results:
		#var collider = result.collider
		#if collider.get_parent() is Enemy:
			#collider.get_parent().inflict_damage(output_damage)


func _process(delta: float) -> void:
	data = get_cursor_move_data(delta)
	position = get_global_mouse_position()
	
	#draw_line_from_to(last_pos, position, 100.0, 1.0)
	draw_trail(position, 5, true, true, 50)
	star.scale = (Vector2(data[0], data[0]) / 500) * star.scale_factor + Vector2(0.2, 0.2)
	star_2.scale = (Vector2(data[0], data[0]) / 500) * star_2.scale_factor
	light.energy = data[0] / 500
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(last_pos, get_global_mouse_position())
	var result = space_state.intersect_ray(query)
	
	var intersects = check_for_objects_slashed(last_pos)
	
	#if not intersects.is_empty():
		#print("Mouse too fast! Mouse was found to have intersected: ", intersects)
	
	for hitbox in intersects:
		var collider = hitbox.collider
		
		if collider is Enemy:
			#print(collider, " was caught between frames, and was an Enemy!")
			
			if not collider.was_damaged:
				_on_collision_hitbox_body_entered(collider)
				#print("Object by the name of ", collider.name, " was damaged between frames.")
			
		#if object is Enemy:
			#print(object, " was caught between frames, and was an Enemy.")
			#if not object.was_damaged:
				#_on_collision_hitbox_body_entered(object)
				#print("Object by the name of ", object.name, " was damaged between frames.")
		#else:
			##print(object, " was not an enemy. It was of type: ", str(object.get_class()))
			#pass
	
	if data[0] <= 1:
		sparkles.emitting = false
	else:
		sparkles.emitting = true
	
	last_pos = position

func _on_collision_hitbox_body_entered(target: Node2D) -> void:
	#print("Collision detected between the cursor and: ", str(body))
	var speed = data[0]
	if target is Enemy:
		var speed_multiplier = clampf((speed/750), 0.0, 1.5)
		var output_damage = (speed_multiplier * damage) + damage
		if speed_multiplier >= 1.5:
			target.inflict_damage(output_damage, true)
			#print("Critical hit!")
		else:
			target.inflict_damage(output_damage, false)
	
	elif target.collision_layer & (1 << 0):
		print("Target is on layer 1 (Wall)")
	
	elif target.physics_layer_0 & (1 << 0):
		print("Target is on layer 1 (Wall)")
