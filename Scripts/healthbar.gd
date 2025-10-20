extends Control

@onready var player = get_tree().get_first_node_in_group("Player")


func _ready() -> void:
	player.was_injured.connect(subtract_health.bind())

func subtract_health(in_damage):
	$NinePatchRect/TextureProgressBar.value -= in_damage
	#print("Health subtracted")
	$NinePatchRect/TextureProgressBar/Control/HealthDropParticles.emitting = true
	
	var damage_counter_scene: PackedScene = load("res://Scenes/CursorCombat/damage_counter.tscn")
	var damage_counter = damage_counter_scene.instantiate()
	var damage_counter_pos = self.global_position + Vector2(140, -180)
	damage_counter.initialize(float(in_damage), 10, 0.01, 1.5, 52, 1.0, Color.RED, damage_counter_pos)
	$NinePatchRect/TextureProgressBar/Control.add_child(damage_counter)
