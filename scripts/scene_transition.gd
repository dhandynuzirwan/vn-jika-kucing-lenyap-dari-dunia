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
		var can_leave = sm.can_leave_room if sm else true
		
		# Kunci pintu jika belum ada izin keluar
		if not can_leave:
			if locked_timeline != "" and not Dialogic.current_timeline:
				Dialogic.start(locked_timeline)
			return
		
		# Jika lolos syarat, pindah scene
		if target_scene != "":
			get_tree().change_scene_to_file(target_scene)
