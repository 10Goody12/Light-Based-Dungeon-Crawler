extends CharacterBody2D
class_name Player

@export var player_max_health : float = 100.0
var player_health : float
@onready var health_bar = get_tree().get_first_node_in_group("Healthbar")

@export var player_speed : float = 100

signal was_injured

func _ready() -> void:
	player_health = player_max_health
	#was_injured.connect(health_bar.subtract_health.bind())

func get_input():
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.lerp(input_dir.normalized() * player_speed if input_dir != Vector2.ZERO else Vector2.ZERO, 0.1)

func _physics_process(delta):
	#if is_frozen:
		#return
	
	get_input()
	move_and_slide()

func _on_player_hitbox_area_entered(area: Area2D) -> void:
	#print("Player collided with enemy")
	var damage_dealt = area.get_parent().get_damage()
	player_health -= damage_dealt
	print("Whatever the fuck")
	emit_signal("was_injured", damage_dealt)
