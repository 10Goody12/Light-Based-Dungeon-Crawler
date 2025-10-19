extends Node2D

@export_range(0, 2500, 0.1) var damage : float = 1.0
@onready var light_sword = get_tree().get_first_node_in_group("LightSword")

var last_pos = Vector2(0,0)
var particle_direction
var cursor_speed

@onready var particles

signal per_process(in_pos, cursor_speed)

#func _ready() -> void:
	#particles = $CPUParticles2D

func _process(delta: float) -> void:
	#await get_tree().process_frame
	
	particle_direction = get_global_mouse_position() - last_pos
	
	cursor_speed = (get_global_mouse_position() - last_pos).length() / max(delta, 0.0001)
	
	emit_signal("per_process", particle_direction, cursor_speed)
	#print(particle_direction)
	
	position = get_global_mouse_position()
	last_pos = position

func _on_collision_hitbox_body_entered(target: Node2D) -> void:
	#print("Collision detected between the cursor and: ", str(body))
	
	if target is Enemy:
		target.inflict_damage(damage)
