extends Sprite2D

var origin_pos: Vector2 = Vector2(0.5, -0.5)
var last_target_pos: Vector2
var tween: Tween

@onready var player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	last_target_pos = origin_pos
	position = origin_pos

func get_cursor_direction() -> Array:
	var offset_vec: Vector2 = -player.position + get_global_mouse_position()
	var is_in_deadzone: bool = offset_vec.length() <= 8
	return [offset_vec.normalized(), is_in_deadzone]

func _process(delta: float) -> void:
	var cursor_info = get_cursor_direction()
	var dir: Vector2 = cursor_info[0]
	var is_in_deadzone: bool = cursor_info[1]

	var target_pos: Vector2
	
	if is_in_deadzone:
		target_pos = origin_pos
	else:
		target_pos = origin_pos + (dir * 0.5)

	# Only start a tween if the target actually changed
	if target_pos != last_target_pos:
		last_target_pos = target_pos

		# Kill any previous tween so they don't conflict
		if tween and tween.is_running():
			tween.kill()

		tween = create_tween()
		tween.tween_property(self, "position", target_pos, 0.08) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_OUT)
