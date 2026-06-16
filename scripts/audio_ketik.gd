extends Node

var sounds_array: Array[AudioStream] = []

func _ready():
	# Muat beberapa suara ketikan default dari Dialogic
	sounds_array.append(preload("res://addons/dialogic/Example Assets/sound-effects/typing1.wav"))
	sounds_array.append(preload("res://addons/dialogic/Example Assets/sound-effects/typing2.wav"))
	sounds_array.append(preload("res://addons/dialogic/Example Assets/sound-effects/typing4.wav"))
	
	# Pantau setiap node baru yang muncul di game
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node):
	# Jika node adalah mesin suara ketikan dialogic dan masih kosong, isi dengan suara default!
	if node.name == "DialogicNode_TypeSounds":
		if "sounds" in node and node.sounds.is_empty():
			node.sounds = sounds_array
			node.play_every_character = 1
