extends Node

func _ready():
	if Engine.has_singleton("Dialogic"):
		Dialogic.Text.about_to_show_text.connect(_on_text_show)

func _on_text_show(info: Dictionary):
	var speaker = info.get("character")
	var joined_chars = Dialogic.Portraits.get_joined_characters()
	
	for char_obj in joined_chars:
		var char_node = Dialogic.Portraits.get_character_node(char_obj)
		if is_instance_valid(char_node):
			# Jika ini adalah karakter yang sedang bicara, munculkan!
			if speaker != null and char_obj == speaker:
				char_node.show()
				_tween_alpha(char_node, 1.0)
			# Jika bukan, hilangkan!
			else:
				_tween_alpha(char_node, 0.0)

func _tween_alpha(node: Node, target_alpha: float):
	var tween = create_tween()
	# Transisi halus (fade in/fade out) selama 0.15 detik
	tween.tween_property(node, "modulate:a", target_alpha, 0.15).set_trans(Tween.TRANS_SINE)
	
	if target_alpha == 0.0:
		tween.tween_callback(node.hide)
