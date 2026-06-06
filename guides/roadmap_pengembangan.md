# Roadmap & Checklist Pengembangan Game: "Jika Kucing Lenyap dari Dunia"

Dokumen ini adalah panduan langkah demi langkah (milestones) yang dapat Anda dan teman Anda gunakan sebagai acuan kerja harian dari awal proyek hingga rilis.

---

## 🚀 FASE 1: Uji Coba Integrasi (Prototype Mekanik)
*Fokus: Memastikan mekanik pergerakan top-down dan interaksi dialog berjalan sinkron tanpa bug.*

- [ ] **Langkah 1:** Buka proyek Godot Anda. Buat scene peta uji coba (`res://scenes/maps/test_room.tscn`) dengan lantai sederhana.
- [ ] **Langkah 2:** Masukkan scene Player (`player.tscn`) ke dalam `test_room.tscn`. Cobalah jalankan game untuk memastikan karakter bisa bergerak 8 arah dengan W-A-S-D/Panah.
- [ ] **Langkah 3:** Daftarkan `story_manager.gd` sebagai Autoload/Global di Project Settings.
- [ ] **Langkah 4:** Buka editor Dialogic, buat satu timeline percobaan bernama `timeline_test` dengan isi beberapa baris teks sederhana.
- [ ] **Langkah 5:** Buat scene Area2D interaksi (`interactable.tscn` / `npc_test.tscn`), pasang skrip `interactable.gd`, dan atur **Timeline Name** di Inspector menjadi `timeline_test`. Masukkan NPC ini ke `test_room.tscn`.
- [ ] **Langkah 6:** Jalankan game. Dekati NPC, tekan **Space/Enter**.
  - *Kriteria Sukses:* Kotak teks dialog muncul, karakter Anda tidak bisa berjalan saat dialog berlangsung, dan setelah dialog ditutup (Space terus sampai habis), karakter Anda bisa berjalan kembali.

---

## 📖 FASE 2: Database Karakter & Penulisan Dialog (Dialogic)
*Fokus: Memindahkan naskah cerita dari berkas teks ke dalam database Dialogic.*

- [ ] **Langkah 1:** Daftarkan semua karakter (`mc`, `aloha`, `kubis`, `mantan`, `tsutaya`, `ibu`) di Dialogic editor beserta warna nama mereka.
- [ ] **Langkah 2:** Buat variabel global di Dialogic: `hari_ke` (int), `ponsel_lenyap` (bool), `film_lenyap` (bool), `pilihan_ending` (string).
- [ ] **Langkah 3:** Buat 9 timeline Dialogic terpisah dan salin dialog dari `NASKAH GAME.txt` ke masing-masing timeline tersebut.
- [ ] **Langkah 4:** Tambahkan event pilihan cerita (*choices*) di Dialogic untuk babak yang membutuhkan keputusan pemain (misal: pilihan menghapus ponsel pada Hari 2 dan kucing pada Hari 5).

---

## 🗺️ FASE 3: Desain Dunia Game (Map & Level Design)
*Fokus: Menggambar dan mendesain lingkungan permainan agar pemain bisa bereksplorasi.*

- [ ] **Langkah 1:** Cari atau gambar aset grafis Tileset 2D top-down (contoh: gaya perkotaan Jepang modern/pixel art). Anda bisa mencari aset gratis di situs seperti [itch.io](https://itch.io/game-assets/free/tag-pixel-art/tag-top-down).
- [ ] **Langkah 2:** Buat scene-scene map utama:
  - `rumahnya_protagonis.tscn` (kamar tidur & ruang tamu MC)
  - `jalanan_kota.tscn` (jalan utama, kedai mie soba, taman bunga)
  - `kafe.tscn` (tempat bertemu mantan kekasih)
  - `bioskop_tua.tscn` (bioskop tempat mantan kekasih bekerja)
  - `toko_dvd.tscn` (toko rental tempat Tsutaya bekerja)
- [ ] **Langkah 3:** Terapkan collision pada dinding/pembatas map agar Player tidak bisa keluar batas.
- [ ] **Langkah 4:** Aktifkan **Y-Sort** pada semua objek map dan Player agar efek tumpang tindih visual (depan/belakang) terlihat realistis.
- [ ] **Langkah 5:** Buat skrip portal pemindah scene (Area2D yang jika dimasuki player akan memuat map lain, misal keluar rumah menuju jalanan kota).

---

## ⚙️ FASE 4: Logika Hari Dinamis & Konsekuensi Cerita
*Fokus: Menghubungkan map fisik dengan variabel cerita global agar dunia berubah setiap hari.*

- [ ] **Langkah 1:** Buat fungsi ganti hari di `StoryManager.gd` (misal fungsi `ganti_hari()` yang menambah variabel `current_day` dan memuat ulang map).
- [ ] **Langkah 2:** Pasang logika pengecekan hari pada NPC/Objek di setiap map.
  - Contoh: Di `jalanan_kota.tscn`, pastikan tiang telepon/kotak telepon umum disembunyikan (`hide()`) jika `StoryManager.current_day >= 3`.
- [ ] **Langkah 3:** Buat scene transisi layar hitam (*Fade Transition*) dengan efek teks *"Hari ke-X"* saat hari berganti untuk memperkuat nuansa waktu berjalan.

---

## 🎨 FASE 5: Poles Tampilan & Efek Suara (Polishing)
*Fokus: Membuat UI Visual Novel dan atmosfer game terasa sangat estetik dan emosional.*

- [ ] **Langkah 1:** Kustomisasi tema Dialogic (kotak dialog, jenis font, ukuran teks, nama pembicara) agar memiliki estetika premium (gunakan warna harmonis lembut, semi-transparan/glassmorphism).
- [ ] **Langkah 2:** Masukkan efek suara mengetik teks (*typewriter sound effect*).
- [ ] **Langkah 3:** Pasang musik latar (BGM) melankolis yang berganti di tiap babak untuk membangun emosi kesedihan dan kepasrahan.
- [ ] **Langkah 4:** Tambahkan efek layar (misal: efek *glitch/rusak* saat MC pingsan, atau kamera bergetar ketika MC merasakan dadanya sakit).

---

## 🧪 FASE 6: Pengujian Akhir & Rilis (Deployment)
*Fokus: Memastikan game bebas bug dan merilisnya ke publik.*

- [ ] **Langkah 1:** Lakukan *playtest* penuh dari awal prolog hingga akhir credit scene. Catat jika ada teks dialog yang keluar batas kotak atau scene yang macet.
- [ ] **Langkah 2:** Unduh Export Templates di Godot.
- [ ] **Langkah 3:** Ekspor game ke platform **Web (HTML5)**.
- [ ] **Langkah 4:** Buat akun di **itch.io**, buat halaman game baru, lalu unggah berkas HTML5 Anda agar game bisa langsung dimainkan lewat browser browser tanpa perlu download.
- [ ] **Langkah 5:** Ekspor versi desktop (Windows `.exe`) sebagai opsi unduhan bagi pemain.
