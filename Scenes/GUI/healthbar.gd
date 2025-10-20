extends Control

@onready var bar = get_tree().get_first_node_in_group("Healthbar")
@onready var player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	player.was_injured.connect(subtract_health.bind())

func subtract_health(in_damage):
	bar.value -= in_damage
	print("Health subtracted")
