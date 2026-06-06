extends CharacterBody2D
class_name Player

@export var speed: float = 150.0

# Mendapatkan referensi ke node AnimatedSprite2D yang ada di dalam Player
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Flag untuk mengunci pergerakan pemain (misal saat dialog aktif)
var is_movement_locked: bool = false

# Menyimpan arah hadap terakhir untuk menentukan animasi diam (default menghadap bawah/depan)
var last_facing_direction: String = "down"

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
	animated_sprite.play("idle_" + last_facing_direction)

# Fungsi untuk dipanggil dari luar (misal oleh StoryManager saat dialog mulai)
func lock_movement() -> void:
	is_movement_locked = true
	play_idle_animation()

func unlock_movement() -> void:
	is_movement_locked = false
