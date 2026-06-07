extends Area2D

# Variabel ini akan muncul di Inspector. 
# Anda tinggal mengklik ikon folder untuk memilih scene map tujuan (misal: jalanan_kota.tscn)
@export_file("*.tscn") var target_scene: String
@export var minimum_day_to_exit: int = 2
@export var locked_timeline: String = "pintu_terkunci"

func _ready() -> void:
	# Dengarkan ketika ada objek fisik yang menyentuh area pintu ini
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Ambil data hari dari StoryManager
		var sm = get_node_or_null("/root/StoryManager")
		var day = sm.current_day if sm else 1
		var event_done = sm.is_daily_event_done if sm else true
		
		# Kunci pintu jika hari < minimum_day_to_exit 
		# ATAU hari == minimum_day_to_exit tapi event belum selesai
		if day < minimum_day_to_exit or (day == minimum_day_to_exit and not event_done):
			if locked_timeline != "" and not Dialogic.current_timeline:
				Dialogic.start(locked_timeline)
			return
		
		# Jika lolos syarat, pindah scene
		if target_scene != "":
			get_tree().change_scene_to_file(target_scene)
