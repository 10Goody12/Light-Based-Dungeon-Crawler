extends Node2D
class_name CrateWood

@onready var sprite = $CrateSprite

@export var health = 5.0

var was_damaged = false
var time_since_last_damage = 0.0
@export var damage_cooldown = 0.5

@export_category("Loot")
@export var drops_coins : bool = true

func break_crate():
	sprite.visible = false
	var new_coin
	
	if drops_coins:
		var coin_scene = load("res://Scenes/Drops/coin.tscn")
		new_coin = coin_scene.instantiate()
		new_coin.position = position
		new_coin.name = "Coin"
	
	var crate_particles_scene = load("res://Scenes/CursorCombat/crate_particles.tscn")
	var crate_particles = crate_particles_scene.instantiate()
	crate_particles.position = position
	crate_particles.name = "CrateParticles"
	
	if drops_coins:
		get_tree().get_root().call_deferred("add_child", new_coin)
	
	get_tree().get_root().call_deferred("add_child", crate_particles)
	
	Sound.play_random_hit(0.3)
	Sound.play_death_sound(1, 20, 0.25) # Crate sound
	queue_free()

func check_health():
	if health <= 0:
		break_crate()
		return false
	else:
		return true

func inflict_damage(in_damage, was_crit, damage_type, pushback_scale):
	if was_damaged == false:
		health -= in_damage
		was_damaged = true
		
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


func _physics_process(delta: float) -> void:
	time_since_last_damage += delta
	
	if time_since_last_damage >= damage_cooldown:
		was_damaged = false


func _on_hitbox_area_entered(area: Area2D) -> void:
	var obj = area.get_parent()
	#print(obj.get_class())
	
	if obj is LightSword:
		var shaker = ShakeManager.create(sprite)
		
		
		if shaker:
			shaker.setup_shake(5, 2, 25, 2, 1, false, 0)
