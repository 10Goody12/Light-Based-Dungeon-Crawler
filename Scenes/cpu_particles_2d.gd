extends CPUParticles2D

@onready var shader_mat = material as ShaderMaterial

func on_mouse_moved(angle, speed):
	rotation = -atan2(angle[0], angle[1])
	
	shader_mat.set_shader_parameter("cursor_speed", speed)

func _on_light_sword_per_process(in_pos: Variant, cursor_speed: Variant) -> void:
	on_mouse_moved(in_pos, cursor_speed)
