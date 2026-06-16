extends Node2D

@onready var tsutaya = $NPC_Tsutaya
@onready var player = $Player

func _ready() -> void:
	if Dialogic.has_signal("signal_event"):
		Dialogic.signal_event.connect(_on_dialogic_signal)
		
	# Pastikan pintu keluar terkunci di awal
	var pintu = get_node_or_null("PintuKeluar")
	if pintu:
		pintu.requires_leave_permission = true

func _on_dialogic_signal(argument: String) -> void:
	if argument == "tsutaya_cari_dvd":
		_tsutaya_cari_dvd()
	elif argument == "tsutaya_kembali":
		_tsutaya_kembali()

func _tsutaya_cari_dvd() -> void:
	if not tsutaya: return
	
	# Pause dialogic text briefly if needed, but Dialogic will wait if we don't advance it manually, 
	# actually Dialogic advances automatically if there's no [wait]. The user script has narration next, so it will play alongside the movement.
	
	var tween = create_tween()
	var start_pos = tsutaya.global_position
	
	# Jalan ke kiri
	tween.tween_property(tsutaya, "global_position:x", start_pos.x - 40, 1.0)
	# Jalan ke kanan
	tween.tween_property(tsutaya, "global_position:x", start_pos.x + 40, 2.0)
	
	# We let it play while narrator speaks.

func _tsutaya_kembali() -> void:
	if not tsutaya: return
	
	# Jeda dialogic: The user put [signal arg="tsutaya_kembali"] BEFORE tsutaya speaks. 
	# We want to pause the timeline until Tsutaya comes back.
	# Dialogic 2 can be paused:
	Dialogic.paused = true
	
	var tween = create_tween()
	# Kembali ke dekat player (kiri/kanan)
	tween.tween_property(tsutaya, "global_position", player.global_position + Vector2(20, -10), 1.5)
	await tween.finished
	
	Dialogic.paused = false
