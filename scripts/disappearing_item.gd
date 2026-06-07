extends Node2D

@export var disappear_on_day: int = 3

func _ready() -> void:
	var sm = get_node_or_null("/root/StoryManager")
	# Jika hari sudah mencapai atau melewati hari hilangnya benda ini,
	# maka hapus benda ini dari map.
	if sm and sm.current_day >= disappear_on_day:
		queue_free()
