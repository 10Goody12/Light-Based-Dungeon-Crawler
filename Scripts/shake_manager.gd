extends Node

func create(in_node):
	var node_children = in_node.get_children()
	var should_proceed = true
	
	for node in node_children:
		if node is Shaker:
			print("There was a prior shaker. Not creating one.")
			should_proceed = false
			return null
	
	if should_proceed:
		print("A shaker was made for a node called ", in_node.name)
		var shaker_scene: PackedScene = load("res://Scenes/shaker.tscn")
		var new_shaker = shaker_scene.instantiate()
		in_node.add_child(new_shaker)
		
		return new_shaker
