extends Sprite2D
class_name Potion

enum PotionType { 
	AMBIGUOUS, ## No information is printed on the bottle itself. Useful for wild card potions, or for potions with nuanced, conditional, or miscellaneous effects.
	BUFFING, ## Potions that increase something. Usually used for good things. Numbers might actually be decreased with this potion, but the general effect is beneficial.
	NERFING, ## Potions that decrease something. Even if the number itself is increasing behind the scenes, if the effect is generally negative, this is the correct type.
	MODIFIER, ## A potion that is applied multiplicatively to a stat or effect. It modifies something, or adds a new effect. More information can be provided with colouring.
	SPAWNER, ## A potion that can be used to spawn a creature, or perhaps creatures. Useful for players who might want to farm or grind, or perhaps need some quick coin.
	SHIELDING ## A potion that increases the player's defenses. This one is differentiated from the rest for ease of quick readability mid-combat.
	}

@export var potion_type_visual : PotionType ## What type of potion this potion will appear as in the game world. Useful for quickly letting the player know what this potion does.
@export var potion_colour : Color ## Changes the liquid inside the potion to this colour.
@export_subgroup("Healing")
@export var heal_amount : int = 0 ## How much this potion will heal, if it heals at all.

var is_being_picked_up = false
var picker_upper : Player

func pickup(in_player : Player):
	#Sound.play("res://SFX/edited_coin_sound.wav", 20, 0.3)
	Sound.play("res://SFX/PlayerNoises/player_heal.ogg", 20)
	push_warning("Potion class is acting like the potions are used immediately on-pickup. Fix this later!")
	is_being_picked_up = true
	picker_upper = in_player
	return heal_amount
