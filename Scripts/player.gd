extends CharacterBody2D
class_name Player

@export var player_speed : float = 100

func get_input():
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.lerp(input_dir.normalized() * player_speed if input_dir != Vector2.ZERO else Vector2.ZERO, 0.1)

func _physics_process(delta):
	#if is_frozen:
		#return
	
	get_input()
	move_and_slide()
