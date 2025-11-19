extends CharacterBody2D

class_name Enemy

enum AggroState { PASSIVE, HOSTILE, PEACEFUL }

@export_category("Movement Behaviour")
@export var can_move : bool = true
@export_range(1, 200, 0.1) var enemy_speed : float = 20
@export_range(0, 1, 0.025) var slide_factor : float = 0.15
@export_range(-25, 25, 0.1) var random_amplitude : float = 5.0

@export_category("Player Response")
@export var has_proximity_aggro : bool = false ## Whether or not this creature needs to be prompted into aggression through proximity.
@export var aggro_range : float = INF ## The range for the proximity aggro. Measured in cells (16x).
@export var default_state: AggroState

@export_category("Biology")
@export_range(1, 250, 1) var starting_health : float = 10.0
@onready var health : float = starting_health

@export_category("Damage Behaviour")
@export var min_damage : float
@export var max_damage : float
@export_range(1, 15, 1.0) var damage_cooldown = 0.5
@export_range(0, 1000.0, 10.0) var pushback_power : float = 100.0
var damage_flicker_counter = 0.0

@export_category("On Death")
@export_range(0,1, 0.05) var drop_chance : float ## The chance of this monster dropping anything. 0 for no drops at all, and 1.0 for drops every time. This does not affect item drop chances, though.
@export_subgroup("Coins")
@export_range(0,1, 0.05) var coins_chance : float ## When a drop does happen, this is the chance that coins will be dropped.
@export var min_coins : int ## The lowest number of coins dropped.
@export var max_coins : int ## The maximum number of coins dropped.
@export_subgroup("Heals")
@export_range(0,1, 0.05) var heals_chance : float ## When a drop does happen, this is the chance that healing potions or items will be dropped.
@export var min_health_dropped : int ## The total minimum number of hitpoints that will be doled out with potions. The code should automatically figure out what the breakdown will be.
@export var max_health_dropped : int ## The total maximum number of hitpoints doled out.
@export var other_heals_dropped : Dictionary ## A dictionary of other items to be dropped. Their item id is the key, and their chance is the value.
@export_subgroup("Power-Ups")
@export var powerups_chance : float
@export var powerups_dropped : Dictionary
@export_subgroup("Weapons")
@export var weapon_chance : float
@export var weapon_drops : Dictionary
@export_subgroup("Quest Items")
@export var quest_item_drops : Dictionary
@export_subgroup("Guaranteed Drops")
@export var guaranteed_drops : Dictionary

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var cursor = get_tree().get_first_node_in_group("Cursor")

#@onready var blood = $BloodParticles
@onready var body = $AnimatedSprite2D

var was_damaged : bool = false
var is_stunned : bool = false
var desired_direction_normalized

signal death

func get_desired_direction(delta):
	#var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	var noise : Vector2 = Vector2(randf_range(-random_amplitude, random_amplitude), randf_range(-random_amplitude, random_amplitude))
	var desired_dir = player.position - position + (slide_factor * velocity) + noise
	desired_direction_normalized = desired_dir.normalized()
	#print(desired_direction_normalized)
	
	if not is_stunned:
		velocity = velocity.lerp(desired_dir.normalized() * enemy_speed if desired_dir != Vector2.ZERO else Vector2.ZERO, 0.1)
	else:
		velocity = velocity.lerp(Vector2.ZERO, delta)

func _on_death():
	body.visible = false
	var coin_scene = load("res://Scenes/Drops/coin.tscn")
	var new_coin = coin_scene.instantiate()
	new_coin.position = position
	new_coin.name = "Coin"
	
	get_tree().get_root().call_deferred("add_child", new_coin)
	
	Sound.play_random_hit(0.3)
	Sound.play_death_sound(0) # Splat sound

func check_health():
	if health <= 0:
		emit_signal("death")
		queue_free()
		return false
	else:
		return true

func inflict_damage(in_damage, was_crit, damage_type, pushback_scale):
	if was_damaged == false:
		health -= in_damage
		was_damaged = true
		
		var blood_scene: PackedScene = load("res://Scenes/CursorCombat/blood_particles.tscn")
		var blood_particles = blood_scene.instantiate()
		blood_particles.position = self.position
		get_tree().root.add_child(blood_particles)
		blood_particles.name = "AttackParticles"
		
		var slash_scene: PackedScene = load("res://Scenes/CursorCombat/slash_effect.tscn")
		var slash_effect = slash_scene.instantiate()
		slash_effect.position = self.position
		get_tree().root.add_child(slash_effect)
		slash_effect.set_damage_type(0)
		slash_effect.name = "SlashEffect_" + str(damage_type)
		
		#print("test 1")
		var damage_counter_scene: PackedScene = load("res://Scenes/CursorCombat/damage_counter.tscn")
		var damage_counter = damage_counter_scene.instantiate()
		damage_counter.name = "DamageCounter"
		
		damage_counter.initialize(in_damage, 10, 0.01, 1.5, 12, 1.0, Color.RED, self.global_position, was_crit)
		get_tree().root.add_child(damage_counter)
		
		if check_health():
			Sound.play_random_hit(0.3)
		
		var cursor_rel_pos_norm = (Vector2(get_global_mouse_position() - global_position)).normalized()
		velocity += -1 * cursor_rel_pos_norm * pushback_scale * pushback_power
		print("Enemy named: ", self.name, " was pushed with a force of ", cursor_rel_pos_norm * pushback_scale * pushback_power, " away from the Lightsword!")

func get_damage():
	var out_damage = randf_range(min_damage, max_damage)
	#print("Enemy dealt ", out_damage, " points of damage!")
	return out_damage

func adjust_flicker():
	if was_damaged:
		modulate = Color.RED
		modulate.a = 0.5
		print("test")
	else:
		modulate = modulate.lerp(Color.WHITE, 1 / damage_cooldown)
		modulate.a += 1 / damage_cooldown

func play_correct_animation():
	var tan_num = atan2(desired_direction_normalized[0], desired_direction_normalized[1])
		
	if tan_num >= -PI/4 and tan_num <= PI/4:
		#print("GOING DOWN")
		body.play("down")
	elif tan_num >= PI/4 and tan_num <= 3*PI/4:
		#print("GOING RIGHT")
		body.play("right")
	elif tan_num >= 3*PI/4 or tan_num <= -3*PI/4:
		#print("GOING UP")
		body.play("up")
	elif tan_num >= -3*PI/4 and tan_num <= -PI/4:
		#print("GOING LEFT")
		body.play("left")

####

func _process(delta: float) -> void:
	if was_damaged:
		is_stunned = true
		damage_flicker_counter += delta
		modulate = Color.RED
		modulate.a = 0.5

		if damage_flicker_counter >= damage_cooldown:
			was_damaged = false
			damage_flicker_counter = 0
	else:
		is_stunned = false
		modulate = modulate.lerp(Color.WHITE, delta * 5.0)
		modulate.a += 1 / damage_cooldown
	
	check_health()
	#adjust_flicker()
	

func _physics_process(_delta):
	get_desired_direction(_delta)
	
	if has_proximity_aggro:
		can_move = false
		if (position - player.position).length() <= (aggro_range * 16):
			can_move = true
			has_proximity_aggro = false
			
	if can_move:
		move_and_slide()
	
	play_correct_animation()
