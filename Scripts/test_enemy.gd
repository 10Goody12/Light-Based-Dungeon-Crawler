extends CharacterBody2D

class_name Enemy

@export_category("Movement")
@export var can_move : bool = true
@export_range(1, 200, 0.1) var enemy_speed : float = 20
@export_range(0, 1, 0.025) var slide_factor : float = 0.15
@export_range(-25, 25, 0.1) var random_amplitude : float = 5.0

@export_category("Biology")
@export_range(1, 250, 1) var starting_health : float = 10.0
@onready var health : float = starting_health

@export_category("Damage Behaviour")
@export_range(1, 15, 1.0) var damage_cooldown = 5.0
var damage_flicker_counter = 0.0

@onready var player = get_tree().get_first_node_in_group("Player")
#@onready var blood = $BloodParticles
@onready var body = $AnimatedSprite2D

var was_damaged : bool = false

func get_desired_direction():
	#var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	var noise : Vector2 = Vector2(randf_range(-random_amplitude, random_amplitude), randf_range(-random_amplitude, random_amplitude))
	var desired_dir = player.position - position + (slide_factor * velocity) + noise
	
	velocity = velocity.lerp(desired_dir.normalized() * enemy_speed if desired_dir != Vector2.ZERO else Vector2.ZERO, 0.1)

func check_health():
	if health <= 0:
		body.visible = false
		queue_free()


func inflict_damage(in_damage):
	if was_damaged == false:
		health -= in_damage
		was_damaged = true
		
		var blood_scene: PackedScene = load("res://Scenes/blood_particles.tscn")
		var blood_particles = blood_scene.instantiate()
		blood_particles.position = self.position
		get_tree().root.add_child(blood_particles)
		
		#print("Blood particles position: ", blood_particles.global_position, "\nEnemy position: ", self.global_position, "\n")
		
		Sound.play_random_hit()

func adjust_flicker():
	if was_damaged:
		modulate = Color.DARK_RED
	else:
		modulate = modulate.lerp(Color.WHITE, 1 / damage_cooldown)

####

func _process(delta: float) -> void:
	if damage_flicker_counter == damage_cooldown:
		was_damaged = false
	
	if was_damaged:
		damage_flicker_counter += 1
	else:
		damage_flicker_counter = 0
	
	check_health()
	adjust_flicker()
	

func _physics_process(delta):
	#if is_frozen:
		#return
	
	get_desired_direction()
	
	if can_move:
		move_and_slide()
