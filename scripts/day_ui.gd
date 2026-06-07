extends Label

func _ready() -> void:
	print("--- DAY UI SCRIPT BERJALAN! ---")
	text = "MEMUAT UI HARI..."
	
	# Paksa posisi, ukuran, dan warna langsung dari script agar pasti terlihat!
	position = Vector2(50, 50)
	add_theme_font_size_override("font_size", 72)
	add_theme_color_override("font_color", Color.YELLOW)
	
	await get_tree().process_frame
	
	# Cari otak dari game (StoryManager)
	var sm = get_node_or_null("/root/StoryManager")
	if sm:
		print("StoryManager ditemukan! Memuat Hari ke-", sm.current_day)
		_on_day_changed(sm.current_day)
		sm.day_changed.connect(_on_day_changed)
	else:
		print("ERROR: StoryManager TIDAK DITEMUKAN di Autoload!")
		text = "ERROR: STORY MANAGER HILANG"

# Fungsi ini dipanggil otomatis setiap ganti hari
func _on_day_changed(new_day: int) -> void:
	print("Mengubah UI menjadi Hari ke-", new_day)
	text = "HARI KE- " + str(new_day)
