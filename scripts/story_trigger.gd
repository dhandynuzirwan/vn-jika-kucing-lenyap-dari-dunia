extends Area2D

@export var timeline_name: String = ""
@export var timeline_per_hari: Array[String] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	var sm = get_node_or_null("/root/StoryManager")
	if sm:
		sm.day_changed.connect(_on_day_changed)
		
	# Khusus untuk TriggerBangun, kita masukkan ke grup dan paksa jalankan dialog di Hari 0
	if name == "TriggerBangun":
		add_to_group("WakingTrigger")
		if StoryManager.current_day == 0:
			call_deferred("force_trigger")

func _on_day_changed(new_day: int) -> void:
	set_deferred("monitoring", true)
	
	# Paksa jalankan dialog secara eksplisit tanpa mengandalkan physics engine
	if name == "TriggerBangun":
		force_trigger()

func force_trigger() -> void:
	var target_timeline = timeline_name
	
	if timeline_per_hari.size() > 0:
		var current_day = StoryManager.current_day
		if current_day < timeline_per_hari.size():
			target_timeline = timeline_per_hari[current_day]
			
	if target_timeline != "":
		# Jika dialog sebelumnya masih berjalan (misalnya hari0_malam_aloha baru saja memancarkan sinyal ganti_hari),
		# Kita harus tunggu dialog tersebut benar-benar selesai/menutup, baru kita mulai dialog pagi.
		if Dialogic.current_timeline != null:
			await Dialogic.timeline_ended
			
		Dialogic.start(target_timeline)
		set_deferred("monitoring", false)

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
