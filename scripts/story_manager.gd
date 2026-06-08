extends Node

# Script Global (Autoload) untuk manajemen alur cerita dan state game

var current_day: int = 0
var can_sleep: bool = false
var can_leave_room: bool = false

signal day_changed(new_day: int)

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
	print(">> STORY MANAGER MENERIMA SINYAL: ", argument)
	if argument == "ganti_hari":
		ganti_hari()
	elif argument == "event_selesai":
		print(">> Misi hari ini tamat! MC sekarang diizinkan tidur.")
		can_sleep = true
		Dialogic.VAR.set("event_harian_selesai", true)
	elif argument == "boleh_keluar":
		print(">> MC sekarang diizinkan keluar kamar.")
		can_leave_room = true

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
	can_sleep = false
	can_leave_room = false
	
	# Sinkronkan dengan variabel Dialogic
	Dialogic.VAR.set("hari_ke", current_day)
	Dialogic.VAR.set("event_harian_selesai", false)
	
	# Beritahu seluruh game bahwa hari telah berganti
	day_changed.emit(current_day)
	
	# Pindahkan Player kembali ke kasur (titik awal) agar saat layar terang dia sudah di posisi semula
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.global_position = Vector2(24, 35)
	
	print("Sekarang adalah Hari ke-", current_day)
