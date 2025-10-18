extends CPUParticles2D
class_name Blood

func _ready() -> void:
	emitting = true

func _on_finished() -> void:
	#print("Blood finished!")
	queue_free()
