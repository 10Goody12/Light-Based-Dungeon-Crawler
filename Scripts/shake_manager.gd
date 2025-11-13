extends Node

func create(in_node):
	print("A shaker was made for a node called ", in_node.name)
	var shaker_scene: PackedScene = load("res://Scenes/shaker.tscn")
	var new_shaker = shaker_scene.instantiate()
	in_node.add_child(new_shaker)
	
	return new_shaker
