extends Control

func _ready() -> void:
	# Memastikan musik atau dialog sebelumnya benar-benar berhenti
	# (Berguna jika pemain kembali ke Main Menu dari tengah permainan)
	Dialogic.end_timeline()

# Fungsi ini akan dipanggil ketika tombol 'Mulai' diklik
func _on_tombol_mulai_pressed() -> void:
	# Pindah ke scene Prolog sebagai awal mula game
	get_tree().change_scene_to_file("res://scenes/maps/prolog.tscn")

# Fungsi ini akan dipanggil ketika tombol 'Keluar' diklik
func _on_tombol_keluar_pressed() -> void:
	# Menutup/mematikan game
	get_tree().quit()
