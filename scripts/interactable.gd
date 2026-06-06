extends Area2D
class_name Interactable

# Tentukan nama timeline Dialogic yang ingin dipicu melalui Inspector Godot
@export var timeline_name: String = ""

var is_player_in_range: bool = false

func _ready() -> void:
	# Hubungkan sinyal tabrakan Area2D
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_player_in_range = false

func _unhandled_input(event: InputEvent) -> void:
	# Cek apakah player di dalam area jangkauan dan menekan tombol Space/Enter (ui_accept)
	# Pastikan juga tidak ada dialog yang sedang aktif berjalan
	if is_player_in_range and event.is_action_pressed("ui_accept"):
		if timeline_name != "" and not Dialogic.current_timeline:
			Dialogic.start(timeline_name)
