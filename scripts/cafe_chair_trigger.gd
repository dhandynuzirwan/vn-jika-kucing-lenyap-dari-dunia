extends Area2D

@export var timeline_to_play: String = "hari1_siang_cafe"

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# Sembunyikan dan nonaktifkan jika event sudah pernah dilakukan
	if StoryManager.cafe_event_done:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not StoryManager.cafe_event_done:
		# Mencegah trigger terpanggil berkali-kali
		set_deferred("monitoring", false)
		
		# Mengunci pergerakan pemain
		if body.has_method("lock_movement"):
			body.lock_movement()
			
		# Menge-snap (menarik) pemain agar pas berada di tengah kursi
		body.global_position = global_position
		
		# Mainkan animasi duduk menghadap kanan
		if body.has_method("play_custom_animation"):
			body.play_custom_animation("sit_right")
		elif body.has_node("AnimatedSprite2D"):
			body.get_node("AnimatedSprite2D").play("sit_right")
			
		# Cari NPC Mantan dan posisi kursi Mantan
		var mantan = get_node_or_null("../NPC_Mantan")
		var marker_mantan = get_node_or_null("../MarkerKursiMantan")
		
		if mantan and marker_mantan:
			# Matikan AI Follower sementara agar tidak konflik dengan Tween jalan
			if "is_following_player" in mantan:
				mantan.is_following_player = false
				mantan.is_moving = false
				
			# NPC berjalan otomatis menuju kursinya (dengan opsi titik belok agar tidak nabrak meja)
			if mantan.has_method("walk_to_target"):
				var marker_jalan = get_node_or_null("../MarkerJalanMantan")
				if marker_jalan:
					await mantan.walk_to_target(marker_jalan.global_position, 1.0)
				await mantan.walk_to_target(marker_mantan.global_position, 1.5)
			else:
				mantan.global_position = marker_mantan.global_position
				
			# Setelah sampai, mainkan animasi NPC duduk menghadap kiri
			if mantan.has_node("AnimatedSprite2D"):
				mantan.get_node("AnimatedSprite2D").play("sit_left")
				
		# Jeda sejenak agar lebih dramatis
		await get_tree().create_timer(0.5).timeout
		
		# Mulai Dialog
		if not Dialogic.current_timeline:
			Dialogic.start(timeline_to_play)
			Dialogic.timeline_ended.connect(_on_dialog_ended)

func _on_dialog_ended() -> void:
	# Dialog selesai
	Dialogic.timeline_ended.disconnect(_on_dialog_ended)
	
	# Tandai bahwa cutscene cafe hari ini sudah selesai
	StoryManager.cafe_event_done = true
	
	# Kembalikan kontrol pemain
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("unlock_movement"):
		player.unlock_movement()
		if player.has_method("play_idle_animation"):
			player.play_idle_animation()
			
	# Kembalikan NPC ke idle dan aktifkan kembali AI Follower
	var mantan = get_node_or_null("../NPC_Mantan")
	if mantan:
		if mantan.has_node("AnimatedSprite2D"):
			mantan.get_node("AnimatedSprite2D").play("idle_down")
		if "is_following_player" in mantan:
			mantan.is_following_player = true
	
	# Hapus area trigger agar tidak menumpuk
	queue_free()
