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
var damage_flicker_counter = 0.0

@onready var player = get_tree().get_first_node_in_group("Player")
#@onready var blood = $BloodParticles
@onready var body = $AnimatedSprite2D

var was_damaged : bool = false
var desired_direction_normalized

func get_desired_direction():
	#var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	var noise : Vector2 = Vector2(randf_range(-random_amplitude, random_amplitude), randf_range(-random_amplitude, random_amplitude))
	var desired_dir = player.position - position + (slide_factor * velocity) + noise
	desired_direction_normalized = desired_dir.normalized()
	#print(desired_direction_normalized)
	
	velocity = velocity.lerp(desired_dir.normalized() * enemy_speed if desired_dir != Vector2.ZERO else Vector2.ZERO, 0.1)

func check_health():
	if health <= 0:
		body.visible = false
		queue_free()

func inflict_damage(in_damage):
	if was_damaged == false:
		health -= in_damage
		was_damaged = true
		
		var blood_scene: PackedScene = load("res://Scenes/CursorCombat/blood_particles.tscn")
		var blood_particles = blood_scene.instantiate()
		blood_particles.position = self.position
		get_tree().root.add_child(blood_particles)
		
		#print("test 1")
		var damage_counter_scene: PackedScene = load("res://Scenes/CursorCombat/damage_counter.tscn")
		var damage_counter = damage_counter_scene.instantiate()
		damage_counter.initialize(in_damage, 10, 0.01, 1.5, 12, 1.0, Color.RED, self.global_position)
		get_tree().root.add_child(damage_counter)
		
		Sound.play_random_hit()

func get_damage():
	var out_damage = randf_range(min_damage, max_damage)
	print("Enemy dealt ", out_damage, " points of damage!")
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

func _ready() -> void:
	push_warning("Damage flickering augmented with halved alpha for damaged enemies. It was thought that doing this would A) let the player know which mobs had been attacked more clearly, and B) it was theorized to be useful when fighting many many mobs, potentially making it easier to know when you've missed a mob, or 'missed a spot.' Reconsider in future.")


func _process(delta: float) -> void:
	if was_damaged:
		damage_flicker_counter += delta
		modulate = Color.RED
		modulate.a = 0.5

		if damage_flicker_counter >= damage_cooldown:
			was_damaged = false
			damage_flicker_counter = 0
	else:
		modulate = modulate.lerp(Color.WHITE, delta * 5.0)
		modulate.a += 1 / damage_cooldown
	
	check_health()
	#adjust_flicker()
	

func _physics_process(delta):
	get_desired_direction()
	
	if has_proximity_aggro:
		can_move = false
		if (position - player.position).length() <= (aggro_range * 16):
			can_move = true
			has_proximity_aggro = false
			
	if can_move:
		move_and_slide()
	
	play_correct_animation()
