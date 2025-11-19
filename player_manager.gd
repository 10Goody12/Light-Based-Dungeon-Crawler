extends Node

func is_player_frozen(in_player):
	return in_player.is_frozen

func freeze_player(in_player):
	var last_state = in_player.is_frozen
	in_player.is_frozen = true
	return last_state

func unfreeze_player(in_player):
	var last_state = in_player.is_frozen
	in_player.is_frozen = false
	return last_state

func is_player_lightsword_enabled(in_player):
	return in_player.get_player_lightsword_enabled()

func disable_lightsword(in_player):
	var last_state = in_player.get_player_lightsword_enabled()
	in_player.disable_lightsword()
	return last_state

func enable_lightsword(in_player):
	var last_state = in_player.get_player_lightsword_enabled()
	in_player.enable_lightsword()
	return last_state
