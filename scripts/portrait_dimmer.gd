extends Node

# Warna saat bicara (normal)
var color_active = Color(1.0, 1.0, 1.0, 1.0)
# Warna saat diam (hitam-putih / gelap)
var color_dim = Color(0.3, 0.3, 0.3, 1.0)

func _ready():
	# Memastikan script ini hanya jalan jika ada Dialogic
	if Engine.has_singleton("Dialogic"):
		# Dialogic.Text.about_to_show_text dipanggil setiap kali teks baru muncul
		Dialogic.Text.about_to_show_text.connect(_on_text_show)
		# Jika dialog selesai atau ditutup, kembalikan warna semua
		Dialogic.timeline_ended.connect(_reset_all)

func _on_text_show(info: Dictionary):
	# Dapatkan karakter yang sedang bicara saat ini
	var speaker = info.get("character")
	
	# Ambil semua karakter yang sedang muncul di layar
	var joined_chars = Dialogic.Portraits.get_joined_characters()
	
	for char_obj in joined_chars:
		# Ambil node portrait-nya
		var char_node = Dialogic.Portraits.get_character_node(char_obj)
		
		if is_instance_valid(char_node):
			# Jika ini adalah karakter yang sedang bicara, warnanya normal
			if speaker != null and char_obj == speaker:
				_tween_color(char_node, color_active)
			# Jika ini karakter lain (sedang mendengarkan), gelapkan
			else:
				_tween_color(char_node, color_dim)

func _reset_all():
	# Jika percakapan selesai, normalkan warna semua portrait yang mungkin tersisa
	var joined_chars = Dialogic.Portraits.get_joined_characters()
	for char_obj in joined_chars:
		var char_node = Dialogic.Portraits.get_character_node(char_obj)
		if is_instance_valid(char_node):
			char_node.modulate = color_active

func _tween_color(node: Node, target_color: Color):
	var tween = create_tween()
	# Ganti warna dengan halus selama 0.2 detik
	tween.tween_property(node, "modulate", target_color, 0.2).set_trans(Tween.TRANS_SINE)
