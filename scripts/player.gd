extends CharacterBody2D
class_name Player

@export var speed: float = 150.0

# Mendapatkan referensi ke node AnimatedSprite2D yang ada di dalam Player
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Flag untuk mengunci pergerakan pemain (misal saat dialog aktif)
var is_movement_locked: bool = false

# Menyimpan arah hadap terakhir untuk menentukan animasi diam (default menghadap bawah/depan)
var last_facing_direction: String = "down"

# Flag tambahan agar animasi bangun tidur tidak tertimpa
var is_waking_up: bool = false

func _ready() -> void:
	# Masukkan player ke dalam grup "Player" agar mudah dicari oleh script lain
	add_to_group("Player")

func _physics_process(_delta: float) -> void:
	# Jika gerakan dikunci (misal sedang berdialog)
	if is_movement_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		play_idle_animation()
		return

	# Mengambil input arah dari Project Settings -> Input Map (W-A-S-D atau Arah Panah)
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * speed
		update_walk_animation(direction)
	else:
		# Perlambatan pergerakan agar terasa halus saat tombol dilepas
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		play_idle_animation()

	move_and_slide()

# Fungsi untuk menentukan animasi berjalan berdasarkan input arah
func update_walk_animation(direction: Vector2) -> void:
	# Membandingkan kekuatan input horizontal vs vertikal (untuk gerakan diagonal)
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			animated_sprite.play("walk_right")
			last_facing_direction = "right"
		else:
			animated_sprite.play("walk_left")
			last_facing_direction = "left"
	else:
		if direction.y > 0:
			animated_sprite.play("walk_down")
			last_facing_direction = "down"
		else:
			animated_sprite.play("walk_up")
			last_facing_direction = "up"

# Fungsi untuk memainkan animasi diam berdasarkan arah hadap terakhir
func play_idle_animation() -> void:
	if not is_waking_up:
		animated_sprite.play("idle_" + last_facing_direction)

# Fungsi untuk dipanggil dari luar (misal oleh StoryManager saat dialog mulai)
func lock_movement() -> void:
	is_movement_locked = true
	play_idle_animation()

func unlock_movement() -> void:
	is_movement_locked = false

# Fungsi untuk memutar animasi bangun tidur saat berganti hari
func play_waking_up_animation() -> void:
	is_waking_up = true
	is_movement_locked = true
	
	# 1. Fase Tidur (Jika ada animasi "idle_tidur", mainkan sebentar)
	if animated_sprite.sprite_frames.has_animation("idle_tidur"):
		animated_sprite.play("idle_tidur")
		# Biarkan MC terlihat tertidur selama 0.5 detik untuk memberi waktu TriggerBangun memicu dialog
		await get_tree().create_timer(0.5).timeout
		
		# Jika dialog sudah terpicu (sedang berjalan), tunggu sampai dialog tersebut ditutup/selesai!
		while Dialogic.current_timeline != null:
			# Tunggu sejenak berulang kali sampai timeline habis
			await get_tree().create_timer(0.1).timeout
			
		# Tambahan jeda 0.5 detik setelah dialog selesai agar MC tidak langsung melompat instan
		await get_tree().create_timer(0.5).timeout
		
	# 2. Fase Loncat Bangun (Jika ada animasi "bangun_tidur")
	if animated_sprite.sprite_frames.has_animation("bangun_tidur"):
		animated_sprite.play("bangun_tidur")
		
		# Animasi pindah posisi (melompat) dari kasur ke lantai samping kasur
		# Posisi target: Vector2(24, 35)
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", Vector2(24, 35), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		# Tunggu sampai animasi melompat selesai
		await animated_sprite.animation_finished
		
	# Setelah selesai, kembalikan ke state normal
	is_waking_up = false
	last_facing_direction = "down"
	
	# Buka kunci pergerakan
	unlock_movement()
