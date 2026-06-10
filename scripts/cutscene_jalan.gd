extends Node2D

@onready var parallax_bg = $ParallaxBackground
@onready var bioskop = $GedungBioskop
@onready var player = $Player
@onready var mantan = $NPC_Mantan
@onready var aloha = $NPC_Aloha

var is_walking = false
var is_arriving = false
var walk_speed = 30.0

func _ready() -> void:
	# Dengarkan sinyal dari Dialogic
	if Dialogic.has_signal("signal_event"):
		Dialogic.signal_event.connect(_on_dialogic_signal)
		
	# Setup awal
	aloha.hide()
	aloha.modulate.a = 0.0
	bioskop.position.x = 400.0 # Taruh bioskop di luar layar kanan (agar tidak kelihatan)
	
	# Posisikan karakter agak ke kiri (jarak lebih rapat)
	player.position.x = 80.0
	mantan.position.x = 100.0
	
	# Mulai cutscene
	start_walking()

func start_walking():
	is_walking = true
	if player.has_method("play_custom_animation"):
		player.play_custom_animation("walk_right")
		if player.has_node("AnimatedSprite2D"):
			player.get_node("AnimatedSprite2D").speed_scale = 0.5
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").play("walk_right")
		mantan.get_node("AnimatedSprite2D").speed_scale = 0.5
		
	# Matikan AI follower jika ada
	if "is_following_player" in mantan:
		mantan.is_following_player = false
		mantan.is_moving = false
		
	# Mulai dialog
	if not Dialogic.current_timeline:
		Dialogic.start("hari1_malam_jalan")

func _process(delta: float) -> void:
	if is_walking:
		# Geser parallax background ke kiri untuk memberi ilusi berjalan ke kanan
		parallax_bg.scroll_offset.x -= walk_speed * delta
		
		# Jika sudah waktunya sampai, gedung bioskop ikut bergeser secepat jalanan
		if is_arriving:
			bioskop.position.x -= walk_speed * delta
			# Jika gedung sudah masuk agak ke tengah layar, berhenti!
			if bioskop.position.x <= 260.0:
				is_walking = false
				is_arriving = false
				_karakter_jalan_ke_tengah()

func _on_dialogic_signal(argument: String) -> void:
	if argument == "sampai_bioskop":
		is_arriving = true
	elif argument == "mantan_pergi":
		_mantan_masuk_bioskop()
	elif argument == "aloha_muncul":
		_munculkan_aloha()
	elif argument == "mc_pingsan":
		_mc_pingsan()

func _karakter_jalan_ke_tengah():
	# Kembalikan kecepatan animasi normal
	if player.has_node("AnimatedSprite2D"):
		player.get_node("AnimatedSprite2D").speed_scale = 1.0
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").speed_scale = 1.0
		
	# Karakter berjalan secara fisik ke arah tengah bioskop
	var tween = create_tween()
	tween.set_parallel(true)
	# MC berhenti di sebelah kiri pintu (posisi bioskop dikurangi 30px)
	tween.tween_property(player, "position:x", bioskop.position.x - 30.0, 2.0)
	# Mantan berhenti tepat di depan pintu bioskop (posisi bioskop dikurangi 10px)
	tween.tween_property(mantan, "position:x", bioskop.position.x - 10.0, 2.0)
	tween.set_parallel(false)
	await tween.finished
	
	# Setelah sampai, karakter berhenti dan menghadap ke atas (ke arah gedung)
	if player.has_method("play_custom_animation"):
		player.play_custom_animation("idle_up")
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").play("idle_up")

func _mantan_masuk_bioskop():
	# Mantan berjalan ke atas (masuk pintu)
	if mantan.has_node("AnimatedSprite2D"):
		mantan.get_node("AnimatedSprite2D").play("walk_up")
		
	var tween = create_tween()
	tween.tween_property(mantan, "position:y", mantan.position.y - 40, 1.5)
	await tween.finished
	
	# Mantan menghilang setelah masuk
	mantan.hide()
	
func _munculkan_aloha():
	# Posisikan Aloha agak ke kiri dari MC agar tidak nempel (karena MC ada di 200.0)
	aloha.position.x = 150.0
	aloha.position.y = player.position.y
	
	# Aloha muncul (fade in)
	aloha.show()
	if aloha.has_node("AnimatedSprite2D"):
		aloha.get_node("AnimatedSprite2D").play("idle_right") # Aloha menghadap MC (karena dari kiri)
		
	var tween = create_tween()
	tween.tween_property(aloha, "modulate:a", 1.0, 1.0)
	
	# MC menghadap ke Aloha (ke arah kiri)
	if player.has_method("play_custom_animation"):
		player.play_custom_animation("idle_left")

func _mc_pingsan():
	# Matikan timeline agar tidak menggantung
	if Dialogic.current_timeline:
		Dialogic.end_timeline()
		
	# Animasi pingsan darurat: Rotasi 90 derajat
	var tween = create_tween()
	tween.tween_property(player, "rotation_degrees", 90.0, 0.5)
	tween.tween_property(player, "position:y", player.position.y + 10, 0.5)
	await tween.finished
	
	# Ganti ke hari ke-2
	var sm = get_node_or_null("/root/StoryManager")
	if sm:
		sm.current_day = 2
		sm.can_leave_room = false
		sm.cafe_event_done = false
		
	# Transisi ke kamar MC
	get_tree().change_scene_to_file("res://scenes/maps/kamar_mc.tscn")
