extends Node

@onready var hit_sound_names : Array[String] = []

func _ready():
	# Load the list of .wav files when the autoload is ready
	load_hit_sounds("res://SFX/Combat/")

func load_hit_sounds(folder_path):
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".wav"):
				hit_sound_names.append(folder_path + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Failed to open directory: ", folder_path)

func play(file_path):
	var player = AudioStreamPlayer.new()
	player.stream = load(file_path)
	player.finished.connect(func(): player.queue_free())
	add_child(player)
	player.play()

func play_random_hit():
	if hit_sound_names.size() > 0:
		var random_file = hit_sound_names.pick_random()
		play(random_file)
	else:
		print("No hit sounds found to play!")
