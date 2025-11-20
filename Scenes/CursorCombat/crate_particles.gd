extends Node2D
class_name CrateParticles

@onready var plank_1 = $Planks
@onready var plank_2 = $Planks2
@onready var chips = $Woodchips

var children

func set_for_all(in_attribute : String, value):
	for child in children:
		if child.get(in_attribute) != null:
			child.set(in_attribute, value)
		else:
			#print("Child does NOT have an attribute named: ", in_attribute)
			pass

func _ready() -> void:
	children = get_children()
	
	#print(children)
	set_for_all("emitting", true)

#func _process(delta: float) -> void:
	#set_for_all("emitting", true)

func _on_finished() -> void:
	#print("Blood finished!")
	queue_free()
	#pass
