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
		
		var trigger_bangku = get_node_or_null("TriggerBangkuHari3")
		if trigger_bangku:
			trigger_bangku.monitoring = false
			if not trigger_bangku.body_entered.is_connected(_on_trigger_bangku_body_entered):
				trigger_bangku.body_entered.connect(_on_trigger_bangku_body_entered)
		
		Dialogic.start("hari3_taman_bagian1")

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
	elif argument == "aktifkan_bangku":
		var trigger_bangku = get_node_or_null("TriggerBangkuHari3")
		if trigger_bangku:
			trigger_bangku.set_deferred("monitoring", true)
	elif argument == "ganti_hari_langsung":
		var sm = get_node_or_null("/root/StoryManager")
		if sm:
			if sm.has_method("pulang_malam"):
			sm.pulang_malam("res://scenes/maps/kamar_mc.tscn")
		else:
			sm.ganti_hari("res://scenes/maps/kamar_mc.tscn")


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
		var trigger_bangku = get_node_or_null("TriggerBangkuHari3")
		if trigger_bangku:
			trigger_bangku.set_deferred("monitoring", false)
			
		if player and player.has_method("lock_movement"):
			player.lock_movement()
			
		if player and player.has_method("play_custom_animation"):
			player.play_custom_animation("sit_down")
			
		if kubis:
			var anim = kubis.get_node_or_null("AnimatedSprite2D")
			if anim:
				anim.play("walk_left")
			
			var tween = create_tween()
			tween.tween_property(kubis, "global_position", player.global_position + Vector2(10, 0), 1.5)
			await tween.finished
			
			if anim:
				anim.play("melingkar_down")
				
		if not Dialogic.current_timeline:
			Dialogic.start("hari3_taman_bagian2")
