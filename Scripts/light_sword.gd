extends Node2D

@export_range(0, 2500, 0.1) var damage = 1
@onready var light_sword = get_tree().get_first_node_in_group("LightSword")

func _process(delta: float) -> void:
	position = get_global_mouse_position()
	light_sword.position = position

func _on_collision_hitbox_body_entered(target: Node2D) -> void:
	#print("Collision detected between the cursor and: ", str(body))
	
	if target is Enemy:
		target.inflict_damage(damage)
