extends Node

# Script Global (Autoload) untuk manajemen alur cerita dan state game

var current_day: int = 1
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
	elif argument == "teleport_ke_taman":
		print(">> Pindah otomatis ke Taman!")
		var player = get_tree().get_first_node_in_group("Player")
		if player and player.has_method("unlock_movement"):
			player.unlock_movement()
		get_tree().change_scene_to_file("res://scenes/maps/taman.tscn")
	elif argument == "mantan_datang":
		# Cari NPC Mantan dan buat dia lari ke arah player
		var mantan = get_tree().get_root().find_child("NPC_Mantan", true, false)
		var player = get_tree().get_first_node_in_group("Player")
		if mantan and player:
			mantan.show()
			# Munculkan mantan agak jauh di atas pemain
			mantan.global_position = player.global_position + Vector2(0, -60)
			
			# Jalan ke arah pemain
			await mantan.walk_to_target(player.global_position + Vector2(0, -20), 1.5)
			
			# Mulai percakapan lanjutannya
			Dialogic.start("hari1_mantan_datang")
	elif argument == "mantan_ikut":
		var mantan = get_tree().get_root().find_child("NPC_Mantan", true, false)
		if mantan:
			mantan.is_following_player = true
			print(">> Mantan sekarang mengikuti Player!")

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
		# Posisi tepat di atas bantal/kasur (digeser sedikit ke kiri sesuai request)
		player.global_position = Vector2(7, 29)
		if player.has_method("play_waking_up_animation"):
			player.play_waking_up_animation()
	
	print("Sekarang adalah Hari ke-", current_day)
