extends Node2D

class_name Coin

enum Coins { COPPER, SILVER, GOLD }

@export var pickup_speed : float = 15.0
@export var coin_type : Coins = Coins.COPPER
var is_being_picked_up : bool = false
var picker_upper : Player
var picker_pos : Vector2
var shadow
#var coin_sprite
@onready var coin_sprite = $AnimatedSprite2D

@export var is_physically_in_game : bool = true

func pickup(in_player : Player):
	Sound.play("res://SFX/edited_coin_sound.wav", 20, 0.3)
	is_being_picked_up = true
	picker_upper = in_player
	return coin_type

func update_coin():
	if coin_type == 0:
		coin_sprite.play("copper")
	elif coin_type == 1:
		coin_sprite.play("silver")
	elif coin_type == 2:
		coin_sprite.play("gold")

func _ready() -> void:
	#await get_tree().process_frame
	#coin_sprite = $AnimatedSprite2D
	shadow = $AnimatedSprite2D/Shadow
	
	if coin_type == 0:
		coin_sprite.play("copper")
	elif coin_type == 1:
		coin_sprite.play("silver")
	elif coin_type == 2:
		coin_sprite.play("gold")

func _process(delta: float) -> void:
	if picker_upper:
		picker_pos = picker_upper.position
		#print("Picker upper updated")
	
	if is_being_picked_up:
		position = position.lerp(picker_pos, pickup_speed * delta)
		#print("Picker pos is ", str(picker_pos), " and my pos is ", str(position))
		#print("Vector to move coin will be ", str(Vector2(picker_pos - position)))
		scale = scale.lerp(Vector2(0,0), pickup_speed * delta)
		
		if abs(position - picker_pos).length() <= 5.0:
			queue_free()
			#print("Coin removed!")
