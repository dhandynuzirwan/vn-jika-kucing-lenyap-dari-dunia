extends Area2D
class_name Interactable

@export var timeline_name: String = ""
@export var timeline_per_hari: Array[String] = []
@export var titik_kumpul_per_hari: Array[NodePath] = []
@export var hapus_setelah_dialog: bool = false
@export var timeline_berikutnya: String = ""
@export var requires_daily_event: bool = false
@export var locked_timeline: String = ""

var is_player_in_range: bool = false

func _ready() -> void:
	# Hubungkan sinyal tabrakan Area2D
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Dengarkan sinyal dari Dialogic
	if Dialogic.has_signal("signal_event"):
		Dialogic.signal_event.connect(_on_dialogic_signal)
		
	# Dengarkan sinyal ganti hari dari StoryManager
	var sm = get_node_or_null("/root/StoryManager")
	if sm:
		sm.day_changed.connect(_on_day_changed)

func _on_day_changed(new_day: int) -> void:
	# Pindahkan posisi NPC menggunakan titik penanda (Marker2D) yang ada di map
	if not titik_kumpul_per_hari.is_empty():
		var index = new_day - 1
		if index >= 0 and index < titik_kumpul_per_hari.size():
			var jalur_node = titik_kumpul_per_hari[index]
			if not jalur_node.is_empty():
				var target = get_node_or_null(jalur_node)
				if target:
					global_position = target.global_position
	
	# Munculkan kembali NPC di hari baru
	show()
	var shape = get_node_or_null("CollisionShape2D")
	if shape: shape.set_deferred("disabled", false)

func _on_dialogic_signal(argument: String) -> void:
	if argument == "npc_hilang" and hapus_setelah_dialog:
		# Buat animasi memudar (Tween)
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 1.5) # Memudar selama 1.5 detik
		
		# Setelah animasi selesai
		tween.finished.connect(func():
			if timeline_berikutnya != "":
				Dialogic.start(timeline_berikutnya)
			
			# Jangan dihapus, tapi disembunyikan agar bisa muncul besok
			hide()
			var shape = get_node_or_null("CollisionShape2D")
			if shape: shape.set_deferred("disabled", true)
			
			# Reset transparansi untuk persiapan besok
			modulate.a = 1.0
		)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_player_in_range = false

func _unhandled_input(event: InputEvent) -> void:
	# Cek apakah player di dalam area jangkauan dan menekan tombol Space/Enter (ui_accept)
	# Pastikan juga tidak ada dialog yang sedang aktif berjalan
	if is_player_in_range and event.is_action_pressed("ui_accept"):
		if timeline_name != "" and not Dialogic.current_timeline:
			
			# --- FITUR NPC MENGHADAP PLAYER ---
			var player = get_tree().get_first_node_in_group("Player")
			var sprite = get_node_or_null("AnimatedSprite2D") # Sesuaikan nama node jika beda
			
			if player and sprite:
				var diff = player.global_position - global_position
				
				# Jika jarak horizontal lebih besar dari vertikal (berada di kiri/kanan)
				if abs(diff.x) > abs(diff.y):
					if diff.x > 0:
						sprite.play("idle_right")
					else:
						sprite.play("idle_left")
				# Jika jarak vertikal lebih besar (berada di atas/bawah)
				else:
					if diff.y > 0:
						sprite.play("idle_down")
					else:
						sprite.play("idle_up")
			# ----------------------------------
			
			# Tentukan timeline mana yang dimainkan berdasarkan hari
			var tl_to_play = timeline_name
			var sm = get_node_or_null("/root/StoryManager")
			if sm and not timeline_per_hari.is_empty():
				var index = sm.current_day - 1 # Hari 1 berarti index 0
				if index >= 0 and index < timeline_per_hari.size():
					if timeline_per_hari[index] != "":
						tl_to_play = timeline_per_hari[index]
			
			# --- PENGECEKAN SYARAT EVENT HARIAN ---
			if requires_daily_event:
				var sm_check = get_node_or_null("/root/StoryManager")
				if sm_check and not sm_check.is_daily_event_done:
					if locked_timeline != "":
						Dialogic.start(locked_timeline)
					return # Hentikan proses, jangan putar dialog utama
			# --------------------------------------
			
			if tl_to_play != "":
				Dialogic.start(tl_to_play)
