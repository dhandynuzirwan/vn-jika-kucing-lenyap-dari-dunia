extends CharacterBody2D
class_name Player

@export var speed: float = 150.0

# Flag untuk mengunci pergerakan pemain (misal saat dialog aktif)
var is_movement_locked: bool = false

func _ready() -> void:
	# Masukkan player ke dalam grup "Player" agar mudah dicari oleh script lain
	add_to_group("Player")

func _physics_process(_delta: float) -> void:
	if is_movement_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Mengambil input arah dari Project Settings -> Input Map
	# ui_left, ui_right, ui_up, ui_down sudah terpetakan otomatis ke tombol arah/W-A-S-D bawaan Godot
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * speed
	else:
		# Perlambatan pergerakan agar terasa halus saat tombol dilepas
		velocity = velocity.move_toward(Vector2.ZERO, speed)

	move_and_slide()

# Fungsi untuk dipanggil dari luar (misal oleh StoryManager saat dialog mulai)
func lock_movement() -> void:
	is_movement_locked = true
	# Tambahkan logika animasi diam (idle) di sini jika menggunakan AnimatedSprite2D

func unlock_movement() -> void:
	is_movement_locked = false
