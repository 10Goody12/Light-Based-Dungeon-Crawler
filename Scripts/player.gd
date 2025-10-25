extends CharacterBody2D
class_name Player

@export var player_max_health : float = 100.0
var player_health : float
@onready var health_bar = get_tree().get_first_node_in_group("Healthbar")
var player_hit : bool = false
var was_pushed : bool = false
var time_since_last_hit : float = 0.0
@export var damage_cooldown : float = 0.0

###### MAYBE MOVE THESE VARIABLES LATER CUZ THIS MIGHT GET BLOATED LMAO

var money : int

######################

@export var player_speed : float = 100

var last_incoming_enemy : Enemy

signal was_injured
signal money_collected(coin_type)

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
	
	time_since_last_hit += delta
	if time_since_last_hit >= damage_cooldown:
		player_hit = false
	
	if was_pushed:
		var pushback_vec = position - last_incoming_enemy.position
		position.lerp(position + pushback_vec * 10, 10)
		#print("Played pushed back")
		was_pushed = false
	
	#print(velocity)

func _on_player_hitbox_area_entered(area: Area2D) -> void:
	#print("Player collided with enemy")
	if area.get_parent() is Enemy:	
		if not player_hit:
			player_hit = true
			last_incoming_enemy = area.get_parent()
			var damage_dealt = last_incoming_enemy.get_damage()
			player_health -= damage_dealt
			#print("Whatever the frick")
			emit_signal("was_injured", damage_dealt)
			Sound.play("res://SFX/PlayerNoises/player_hit.wav", 20)
			time_since_last_hit = 0.0
			was_pushed = true
	
	elif area.get_parent() is Coin:
		if area.get_parent().is_being_picked_up != true and area.get_parent().is_physically_in_game:
			var coin_type = area.get_parent().pickup(self)
			
			if coin_type == 0:
				money += 1
			if coin_type == 1:
				money += 100
			if coin_type == 2:
				money += 1000
			
			#print("The player now has ", money, " units worth of value in copper coins.")
			emit_signal("money_collected", coin_type)
