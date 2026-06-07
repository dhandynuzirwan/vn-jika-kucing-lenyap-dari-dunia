extends Area2D

# Variabel ini akan muncul di Inspector. 
# Anda tinggal mengklik ikon folder untuk memilih scene map tujuan (misal: jalanan_kota.tscn)
@export_file("*.tscn") var target_scene: String

func _ready() -> void:
	# Dengarkan ketika ada objek fisik yang menyentuh area pintu ini
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Pastikan yang menyentuh pintu adalah Player (bukan NPC atau Kucing)
	# dan pastikan scene tujuannya sudah diisi di Inspector
	if body.is_in_group("Player") and target_scene != "":
		
		# Pindah ke scene map yang baru
		get_tree().change_scene_to_file(target_scene)
