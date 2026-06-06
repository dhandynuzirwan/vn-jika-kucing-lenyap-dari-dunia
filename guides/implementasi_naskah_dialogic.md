# Panduan Implementasi Naskah Game ke Dialogic 2 & Godot 4

Dokumen ini mendokumentasikan panduan langkah demi langkah untuk mengonversi **NASKAH GAME.txt** (dari novel *"Jika Kucing Lenyap dari Dunia"*) ke dalam sistem **Dialogic 2** dan menghubungkannya dengan gameplay **2D Top-Down** di Godot 4.

---

## 1. Setup Karakter di Dialogic 2

Buka tab **Dialogic** di pojok kiri atas Godot, pergi ke bagian **Characters**, lalu buat karakter-karakter berikut:

| Nama Karakter (Display Name) | ID / Nama File | Warna Nama | Deskripsi / Catatan Visual |
| :--- | :--- | :--- | :--- |
| **Protagonis (MC)** | `mc` | Putih / Abu-abu Terang | Pemuda tukang pos, menggunakan seragam pos di akhir cerita. |
| **Aloha (Iblis)** | `aloha` | Merah / Ungu | Kembaran MC dengan pakaian mencolok (kemeja biru langit, kemeja hitam laut). |
| **Kubis (Kucing)** | `kubis` | Orange / Kuning | Berbicara dengan bahasa sopan sejarah (*"Tuanku"*, *"Sahaya"*) pada Hari 4. |
| **Ibu** | `ibu` | Hijau Lembut | Muncul dalam adegan kilas balik (*flashback*). |
| **Mantan Pacar** | `mantan` | Merah Muda / Pink | Gadis penjaga bioskop tua. |
| **Tsutaya** | `tsutaya` | Biru Muda | Penjaga persewaan DVD, berbicara terbata-bata jika panik/sedih. |

> **Tip Portrait:** Buatlah berkas gambar portrait ekspresi (misal: `idle`, `sedih`, `senang`, `syok`) di folder `res://assets/portraits/` lalu hubungkan ke masing-masing karakter di Dialogic Editor.

---

## 2. Setup Variabel Global (Dialogic Variables)

Di Dialogic Editor, masuk ke tab **Variables** dan daftarkan variabel berikut untuk mengontrol alur cerita bercabang:

*   `hari_ke` (Integer) - Nilai default: `1` (Mencatat hari/babak aktif).
*   `ponsel_lenyap` (Boolean) - Nilai default: `false` (Menjadi `true` setelah Babak 4).
*   `film_lenyap` (Boolean) - Nilai default: `false` (Menjadi `true` setelah Babak 6).
*   `pilihan_ending` (String) - Nilai default: `""` (Menyimpan pilihan `"true_ending"` atau `"bad_ending"`).

---

## 3. Pembagian Timeline Dialogic (Modular)

Untuk memudahkan pengelolaan dan menghindari file yang terlalu besar, buatlah timeline Dialogic terpisah di folder `res://dialogues/`:

1.  `timeline_prolog` (Babak 1)
    *   *Adegan:* Layar hitam, vonis dokter, jembatan senja, MC pingsan.
2.  `timeline_day1_aloha` (Babak 2)
    *   *Adegan:* Aloha muncul di kamar tidur MC, menawarkan kontrak umur, memakan cokelat.
3.  `timeline_flashback_ibu` (Babak 3)
    *   *Adegan:* Pertemuan pertama dengan kucing Selada dan Kubis, pesan terakhir Ibu.
4.  `timeline_day2_ponsel` (Babak 4)
    *   *Adegan:* Ponsel bergetar, Aloha menawarkan menghapus ponsel, MC menelepon Mantan.
5.  `timeline_day2_cafe` (Babak 5)
    *   *Adegan:* Pertemuan dengan Mantan di kafe, flashback Argentina, undangan nonton besok.
6.  `timeline_day3_film` (Babak 6)
    *   *Adegan:* Aloha menawarkan menghapus film, MC pergi ke toko DVD Tsutaya, menonton *Limelight* dengan Mantan.
7.  `timeline_day4_jam` (Babak 7)
    *   *Adegan:* Kubis bisa berbicara, jalan-jalan ke taman bunga, Kubis lupa ingatan tentang Ibu, Aloha mengumumkan kucing akan dilenyapkan.
8.  `timeline_day5_keputusan` (Babak 8)
    *   *Adegan:* Pagi jam 3, mencari Kubis, bertemu Mantan, membaca surat Ibu, pilihan menolak menghapus kucing.
9.  `timeline_ending_saturday` (Babak 9 & Akhir)
    *   *Adegan:* Penerimaan maut, perpisahan dengan Aloha, mengantar surat ke rumah Ayah.

---

## 4. Cara Menghubungkan Map Open World dengan Alur Cerita

Karena game Anda bersifat *Open World*, Player bisa berpindah map. Gunakan `StoryManager` untuk memantau babak dan mengatur isi map secara dinamis.

### A. Contoh Logika di Script Peta Utama (`rumahnya_protagonis.gd`):
```gdscript
extends Node2D

@onready var npc_aloha = $NPC_Aloha
@onready var npc_kucing = $NPC_Kucing

func _ready() -> void:
	# Atur kemunculan karakter berdasarkan hari cerita
	match StoryManager.current_day:
		1:
			npc_aloha.show()
			# Atur agar NPC Kucing menggunakan dialog Hari 1
			npc_kucing.timeline_name = "timeline_day1_aloha"
		2:
			# Hari ke-2, Aloha mungkin sedang tidak di kamar
			npc_aloha.hide()
			npc_kucing.timeline_name = "timeline_day2_ponsel"
		3:
			npc_aloha.show()
			npc_kucing.timeline_name = "timeline_day3_film"
		4:
			# Kucing mulai bisa bicara
			npc_aloha.show()
			npc_kucing.timeline_name = "timeline_day4_jam"
		5:
			# Kucing hilang dari kamar
			npc_kucing.hide()
```

### B. Transisi Antar Hari/Babak (Di akhir Dialogic Timeline):
Di akhir setiap Dialogic Timeline, Anda bisa memicu perpindahan hari dengan memanggil sinyal atau memodifikasi variabel Autoload Godot langsung dari Dialogic:

1.  Di Dialogic Editor, gunakan event **Call Node** atau **Set Variable**.
2.  Ubah variabel `hari_ke` di dalam `StoryManager` (misal: `StoryManager.current_day += 1`).
3.  Picu efek transisi layar hitam (*fade out*) di Godot, lalu muat ulang peta untuk menerapkan hari yang baru.

---

## 5. Implementasi Efek Visual & Audio Melalui Dialogic

Naskah Anda memiliki banyak instruksi visual dan audio (seperti layar buram, getar, suara mesin ketik, musik melankolis). Anda bisa memicu ini langsung di Dialogic Timeline:

*   **Efek Teks Mesin Ketik:** Aktifkan di Dialogic Theme settings agar teks muncul huruf demi huruf secara otomatis.
*   **Audio Mesin Ketik / Suara Kucing:** Gunakan event **Play Sound** di dalam Dialogic Timeline pada baris narasi yang bersesuaian.
*   **Layar Hitam / Transisi:** Gunakan event **Fading / Scene Transition** atau panggil fungsi kustom di Godot menggunakan event **Emit Signal** di Dialogic.
