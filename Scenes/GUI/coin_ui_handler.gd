extends Control

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var coin

func _on_money_collected(coin_type):
	coin.visible = true
	
	if coin_type == 0:
		coin.coin_type = coin.Coins.COPPER
		coin.update_coin()
	elif coin_type == 1:
		coin.coin_type = coin.Coins.SILVER
		coin.update_coin()
	elif coin_type == 2:
		coin.coin_type = coin.Coins.GOLD
		coin.update_coin()

func _ready() -> void:
	coin = $Coin
	player.money_collected.connect(_on_money_collected.bind())
