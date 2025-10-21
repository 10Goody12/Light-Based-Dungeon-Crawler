extends RichTextLabel

@onready var player = get_tree().get_first_node_in_group("Player")

func _on_money_collected(coin_type):
	text = str(player.money)

func _ready() -> void:
	player.money_collected.connect(_on_money_collected.bind())
