extends Node

# Script Global (Autoload) untuk manajemen alur cerita dan state game

var current_day: int = 1

func _ready() -> void:
	# Tunggu satu frame agar seluruh sistem terinisialisasi
	await get_tree().process_frame
	
	if Dialogic.has_signal("timeline_started"):
		Dialogic.timeline_started.connect(_on_dialogue_started)
	if Dialogic.has_signal("timeline_ended"):
		Dialogic.timeline_ended.connect(_on_dialogue_ended)
	if Dialogic.has_signal("signal_event"):
		Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument: String) -> void:
	if argument == "ganti_hari":
		ganti_hari()

func _on_dialogue_started() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("lock_movement"):
		player.lock_movement()

func _on_dialogue_ended() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("unlock_movement"):
		player.unlock_movement()

# Fungsi untuk memanggil pergantian hari dari kasur/interaksi tidur
func ganti_hari() -> void:
	current_day += 1
	# Sinkronkan dengan variabel Dialogic (jika Anda membuat variabel 'hari_ke' di Dialogic)
	Dialogic.VAR.set("hari_ke", current_day)
	
	# Memuat scene transisi hitam/layar loading (opsional)
	# get_tree().change_scene_to_file("res://scenes/ui/layar_transisi.tscn")
	
	print("Sekarang adalah Hari ke-", current_day)

