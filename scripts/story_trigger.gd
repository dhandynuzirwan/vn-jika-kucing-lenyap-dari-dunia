extends Area2D

@export var timeline_name: String = ""
@export var timeline_per_hari: Array[String] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	var sm = get_node_or_null("/root/StoryManager")
	if sm:
		sm.day_changed.connect(_on_day_changed)

func _on_day_changed(new_day: int) -> void:
	set_deferred("monitoring", true)

func _on_body_entered(body: Node2D) -> void:
	# Jika yang menginjak adalah Player, dan dialog sedang tidak berjalan
	if body.is_in_group("Player"):
		var target_timeline = timeline_name
		
		# Jika ada timeline_per_hari yang di set, gunakan itu berdasarkan hari
		if timeline_per_hari.size() > 0:
			var current_day = StoryManager.current_day
			if current_day < timeline_per_hari.size():
				target_timeline = timeline_per_hari[current_day]
				
		if target_timeline != "" and not Dialogic.current_timeline:
			Dialogic.start(target_timeline)
			
			# Nonaktifkan sementara sensor ini agar tidak memicu berulang kali di hari yang sama
			set_deferred("monitoring", false)
