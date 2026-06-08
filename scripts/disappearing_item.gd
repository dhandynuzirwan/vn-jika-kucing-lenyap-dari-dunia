extends Node2D

@export var disappear_on_day: int = 1

func _ready() -> void:
	var sm = get_node_or_null("/root/StoryManager")
	if sm:
		sm.day_changed.connect(_on_day_changed)
		_on_day_changed(sm.current_day)

func _on_day_changed(new_day: int) -> void:
	# Jika hari sudah mencapai atau melewati hari hilangnya benda ini,
	# maka hapus benda ini dari map.
	if new_day >= disappear_on_day:
		hide()
		queue_free()
