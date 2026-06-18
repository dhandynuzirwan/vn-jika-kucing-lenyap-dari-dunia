extends Node2D

@onready var kubis = $NPC_Kubis
var player: Node2D

func _ready() -> void:
	if StoryManager.current_day == 3:
		if Dialogic.has_signal("signal_event"):
			Dialogic.signal_event.connect(_on_dialogic_signal)
		
		# Sembunyikan trigger taman default untuk mencegah tabrakan timeline
		var trigger_taman = get_node_or_null("TriggerTaman")
		if trigger_taman:
			trigger_taman.queue_free()
		
		player = get_tree().get_first_node_in_group("Player")
		if player and player.has_method("lock_movement"):
			# Awal masuk scene, langsung jalankan cutscene dan kunci pergerakan
			player.lock_movement()
		
		Dialogic.start("hari3_taman_bagian1")
		var trigger_bangku = get_node_or_null("TriggerBangkuHari3")
		if trigger_bangku and not trigger_bangku.body_entered.is_connected(_on_trigger_bangku_body_entered):
			trigger_bangku.body_entered.connect(_on_trigger_bangku_body_entered)

	else:
		# Jika bukan hari ke-3, hapus trigger bangku khusus
		var trigger_bangku = get_node_or_null("TriggerBangkuHari3")
		if trigger_bangku:
			trigger_bangku.queue_free()
			
		if kubis:
			kubis.queue_free()

func _on_dialogic_signal(argument: String) -> void:
	if argument == "kubis_jalan_ke_bunga":
		_jalan_ke_kanan_anim()
	elif argument == "kubis_jalan_ke_bukit":
		_jalan_ke_atas_anim()
	elif argument == "kubis_duduk":
		if kubis and kubis.has_node("AnimatedSprite2D"):
			kubis.get_node("AnimatedSprite2D").play("sit_down")
	elif argument == "izinkan_mc_jalan":
		if player and player.has_method("unlock_movement"):
			player.unlock_movement()
	elif argument == "mc_duduk":
		# Animasi player duduk
		if player and player.has_method("play_custom_animation"):
			player.play_custom_animation("sit_down")
	elif argument == "hari3_selesai":
		# Selesai event
		StoryManager._on_dialogic_signal("event_selesai")

func _jalan_ke_kanan_anim() -> void:
	if kubis:
		var anim = kubis.get_node_or_null("AnimatedSprite2D")
		if anim:
			anim.play("walk_right")
		
		var tween = create_tween()
		tween.tween_property(kubis, "position:x", kubis.position.x + 80, 2.0)
		await tween.finished
		
		if anim:
			anim.play("idle_right")

func _jalan_ke_atas_anim() -> void:
	if kubis:
		var anim = kubis.get_node_or_null("AnimatedSprite2D")
		if anim:
			anim.play("walk_up")
		
		var tween = create_tween()
		tween.tween_property(kubis, "position:y", kubis.position.y - 100, 3.0)
		await tween.finished
		
		if anim:
			anim.play("idle_up")

# Script dipanggil oleh Area2D bangku
func _on_trigger_bangku_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and StoryManager.current_day == 3:
		# Mulai bagian 2 dan nonaktifkan trigger ini
		if not Dialogic.current_timeline:
			Dialogic.start("hari3_taman_bagian2")
			var trigger = get_node_or_null("TriggerBangkuHari3")
			if trigger:
				trigger.set_deferred("monitoring", false)
