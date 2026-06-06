extends Node

# Script Global (Autoload) untuk manajemen alur cerita dan state game

# Variabel cerita global
var current_day: int = 1
var is_cats_disappeared: bool = false

func _ready() -> void:
	# Tunggu satu frame agar seluruh sistem (termasuk Dialogic) terinisialisasi sepenuhnya
	await get_tree().process_frame
	
	# Hubungkan sinyal Dialogic secara dinamis
	# Dialogic 2 memancarkan sinyal saat timeline dimulai dan diakhiri
	if Dialogic.has_signal("timeline_started"):
		Dialogic.timeline_started.connect(_on_dialogue_started)
	if Dialogic.has_signal("timeline_ended"):
		Dialogic.timeline_ended.connect(_on_dialogue_ended)

func _on_dialogue_started() -> void:
	# Cari player di dalam grup "Player" lalu kunci gerakannya
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("lock_movement"):
		player.lock_movement()

func _on_dialogue_ended() -> void:
	# Buka kunci gerakan player setelah dialog selesai
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("unlock_movement"):
		player.unlock_movement()
