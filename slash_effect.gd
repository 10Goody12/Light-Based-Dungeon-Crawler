extends CPUParticles2D
class_name Slash

enum DamageType { PHYSICAL, LIGHT, MAGIC, ICE, FIRE, POISON, MENTAL }
@export var damage_type : DamageType

func _ready() -> void:
	emitting = true

func set_damage_type(in_damage_type):
	damage_type = in_damage_type

func _on_finished():
	queue_free()
