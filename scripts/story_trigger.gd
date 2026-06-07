extends Area2D

@export var timeline_name: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Jika yang menginjak adalah Player, dan dialog sedang tidak berjalan
	if body.is_in_group("Player") and timeline_name != "":
		if not Dialogic.current_timeline:
			Dialogic.start(timeline_name)
			
			# Menghapus sensor ini dari game agar dialog tidak terulang lagi saat diinjak
			queue_free()
