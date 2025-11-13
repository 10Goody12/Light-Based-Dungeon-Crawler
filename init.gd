extends Node

func _ready() -> void:
	push_warning("IN test_enemy.gd => Damage flickering augmented with halved alpha for damaged enemies. It was thought that doing this would A) let the player know which mobs had been attacked more clearly, and B) it was theorized to be useful when fighting many many mobs, potentially making it easier to know when you've missed a mob, or 'missed a spot.' Reconsider in future.")
