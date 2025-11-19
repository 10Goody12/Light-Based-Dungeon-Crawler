extends Area2D
class_name Checkpoint

func _on_checkpoint_entered(area: Area2D) -> void:
	var obj = area.get_parent()
	if obj is Player:
		print("Player detected in checkpoint area!")
		obj.last_checkpoint_coord = global_position
