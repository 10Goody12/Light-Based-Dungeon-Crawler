extends CharacterBody2D
class_name Player

@export var player_max_health : float = 100.0
var player_health : float

@onready var health_bar = get_tree().get_first_node_in_group("Healthbar")
@onready var animation = $AnimationPlayer
@onready var body = $Body

@onready var cursor = get_tree().get_first_node_in_group("LightSword")

var player_hit : bool = false
var was_pushed : bool = false
var is_frozen : bool = false
var is_dead : bool = false
var is_player_lightsword_enabled : bool = true

var time_since_last_hit : float = 0.0
@export var damage_cooldown : float = 1.0

var time_since_death : float = 0.0
@export var respawn_cooldown : float = 5.0


###### MAYBE MOVE THESE VARIABLES LATER CUZ THIS MIGHT GET BLOATED LMAO

var last_checkpoint_coord : Vector2
var money : int

######################

@export var player_speed : float = 100

var last_incoming_enemy : Enemy

signal was_injured
signal money_collected(coin_type)
signal was_healed(heal_amount)

signal player_died(last_position)

func get_player_lightsword_enabled():
	return is_player_lightsword_enabled

func disable_lightsword():
	cursor.disable()

func enable_lightsword():
	cursor.enable()

func _ready() -> void:
	player_health = player_max_health
	#was_injured.connect(health_bar.subtract_health.bind())
	animation.play("idle")

func get_input():
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.lerp(input_dir.normalized() * player_speed if input_dir != Vector2.ZERO else Vector2.ZERO, 0.1)

func adjust_flicker(delta):
	if player_hit:
		modulate = Color.RED
		#modulate.a = 0.5
	else:
		modulate = modulate.lerp(Color.WHITE, delta)
		#modulate.a += 1 / damage_cooldown

func check_health():
	player_health = clamp(player_health, 0, player_max_health)
	
	if player_health <= 0:
		emit_signal("player_died", global_position)
		return false
	else:
		return true

func respawn_player(starting_health, spawn_pos : Vector2 = Vector2(0.0, 0.0)):
	print("Player respawned at ", spawn_pos, " with ", starting_health, " health points!")
	global_position = spawn_pos
	visible = true
	player_health = clampf(starting_health, 0, player_max_health)
	is_dead = false
	emit_signal("was_healed", starting_health)
	print("Player unfrozen after death.")
	PlayerManager.unfreeze_player(self)
	
	await get_tree().process_frame
	print("Player's Lightsword enabled after death.")
	PlayerManager.enable_lightsword(self)

func _on_player_died(last_position: Variant) -> void:
	print("Player died! Their last position was ", last_position)
	visible = false
	is_dead = true
	
	#var coin_scene = load("res://Scenes/Drops/coin.tscn")
	#var new_coin = coin_scene.instantiate()
	#new_coin.position = position
	#new_coin.name = "Coin"
	
	#get_tree().get_root().call_deferred("add_child", new_coin)
	
	PlayerManager.freeze_player(self)
	PlayerManager.disable_lightsword(self)
	Sound.play_death_sound(0, 30.0, 0.5) # Splat sound

func _physics_process(delta):
	#if is_frozen:
		#return
	
	get_input()
	
	if not is_frozen:
		move_and_slide()
	
	if not is_dead:
		check_health()
	
	adjust_flicker(delta * 10)
		
	###########
	
	if is_dead:
		time_since_death += delta
	
	if is_dead and time_since_death >= respawn_cooldown:
		respawn_player(100.0, last_checkpoint_coord)
	
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
	if not is_dead:
		if area.get_parent() is Enemy:	
			if not player_hit:
				player_hit = true
				
				last_incoming_enemy = area.get_parent()
				var damage_dealt = last_incoming_enemy.get_damage()
				player_health -= damage_dealt
				emit_signal("was_injured", damage_dealt)
				
				var new_shaker = ShakeManager.create(body)
				if new_shaker:
					new_shaker.setup_shake(2, 2, 25, 2, 1, false, 0)
				
				var blood_scene: PackedScene = load("res://Scenes/CursorCombat/blood_particles.tscn")
				var blood_particles = blood_scene.instantiate()
				blood_particles.position = position
				get_tree().root.add_child(blood_particles)
				blood_particles.name = "AttackParticles"
				blood_particles.modulate = Color.CYAN
				blood_particles.self_modulate = Color.CYAN
				
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
		
		elif area.get_parent() is Potion:
			var potion_heal_amount = area.get_parent().pickup(self)
			player_health += potion_heal_amount
			
			emit_signal("was_healed", potion_heal_amount)
