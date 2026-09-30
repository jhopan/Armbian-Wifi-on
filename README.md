<div align="center">

# 🛜 Armbian WiFi-ON untuk B860H / HG680P

### Driver WiFi Realtek RTL8189FS untuk Armbian Kernel Modern
### Tested on 3 Devices: B860H V1 (1GB) · B860H V2 (2GB) · HG680P

[![License](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](LICENSE)
[![Kernel](https://img.shields.io/badge/Linux%20Kernel-5.10%20%7C%205.15%20%7C%206.1%20%7C%206.6%20%7C%206.12-green.svg)]()
[![Distro](https://img.shields.io/badge/Distro-Armbian%20Trixie%20%7C%20Bookworm%20%7C%20Noble-blue.svg)]()
[![Hardware](https://img.shields.io/badge/Hardware-ZTE%20B860H%20%7C%20FiberHome%20HG680P-orange.svg)]()
[![Chip](https://img.shields.io/badge/WiFi%20Chip-Realtek%20RTL8189FS%20(SDIO)-red.svg)]()
[![Status](https://img.shields.io/badge/Status-Tested%20on%203%20Devices-brightgreen.svg)]()

### ⚡ One command. WiFi ON. Tanpa compile, tanpa ribet.

[Quick Install](#-cara-paling-cepat-one-liner) · [Prebuilt Drivers](releases) · [Ready-to-Flash Image](https://github.com/jhopan/Armbian-Trixie-WifiON) · [Report Issue](issues)

</div>

---

Repository ini berisi panduan lengkap, script otomatis, dan source code driver untuk mengaktifkan **WiFi Internal Realtek RTL8189FS** pada STB Amlogic S905X (B860H / HG680P) yang menjalankan Armbian dengan kernel modern.

### ✅ Tested & Working on 3 Devices

| Device | RAM | Kernel | Driver | Status |
|--------|-----|--------|--------|--------|
| **ZTE B860H V1** | 1GB | 6.12.107-ophub | `8189fs.ko` (dari STB) | ✅ WiFi ON |
| **ZTE B860H V2** | 2GB | 6.12.193-ophub | `8189fs.ko` (dari STB) | ✅ WiFi ON |
| **FiberHome HG680P** | - | 6.12.107-ophub | `8189fs.ko` (dari STB) | ✅ WiFi ON |

> ⭐ Driver `8189fs.ko` diambil langsung dari STB yang sudah berhasil WiFi ON. Inilah driver yang paling stabil dan sudah teruji di 3 device.

---

## ⚡ Cara Paling Cepat (One-Liner)

Buka terminal di STB, paste perintah ini, tekan Enter:

```bash
curl -sL https://raw.githubusercontent.com/jhopan/Armbian-Wifi-on/main/quick-install.sh | bash
```

**Tanpa compile, tanpa ribet.** Script akan otomatis:
1. Deteksi versi kernel Anda
2. Download prebuilt driver yang sesuai
3. Install dan load driver
4. Set auto-load saat boot

Setelah selesai, connect WiFi dengan:
```bash
nmtui
```

> **Butuh internet di STB untuk download.** Pakai kabel LAN atau USB Tethering HP sementara.

---

## 📖 Latar Belakang Masalah

Banyak STB Amlogic S905X (ZTE B860H dan FiberHome HG680P) yang beredar menggunakan chip WiFi **Realtek RTL8189FS** (SDIO). Sayangnya, Realtek tidak menyertakan driver `8189fs` ke dalam mainline kernel Linux sejak versi 5.15.

Akibatnya, ketika pengguna menginstall atau meng-update Armbian ke kernel modern, WiFi internal STB mati total dan tidak terdeteksi (`wlan0` tidak muncul).

### ❌ Mitos: "Ganti DTB Bisa Mengaktifkan WiFi"

Banyak yang percaya masalah WiFi bisa diselesaikan dengan **memodifikasi Device Tree Blob (DTB)**. Faktanya, modifikasi DTB **TIDAK PERNAH** menyelesaikan masalah ini karena:

1. DTB hanya memberi tahu kernel *"ada chip WiFi di jalur SDIO"*
2. Kernel sudah mendeteksi chip: `mmc0: new high speed SDIO card at address 0001`
3. Tapi driver `8189fs` tidak ada di kernel → WiFi tetap mati

**Akar masalahnya adalah hilangnya software driver, bukan konfigurasi hardware.**

---

## 📋 Dukungan Kernel

| Kernel | WiFi RTL8189FS | Cara | Status |
|--------|----------------|------|--------|
| **5.10.y** | ✅ Built-in | Driver sudah ada di kernel staging | 🟢 Instan |
| **5.15.y** | ⚠️ Hilang dari mainline | Compile sendiri | 🟡 Bisa |
| **6.1.y** | ⚠️ Hilang dari mainline | [Prebuilt](releases) atau compile | 🟡 Bisa |
| **6.6.y** | ⚠️ Hilang dari mainline | [Prebuilt](releases) atau compile | 🟡 Bisa |
| **6.12.y** | ⚠️ Hilang dari mainline | [Prebuilt](releases) atau compile | 🟡 Bisa (tested!) |
| **6.18.y** | ❌ API breaking changes | Tidak didukung | 🔴 Error |

### ❌ Kenapa Kernel 6.18 Tidak Didukung?
Kernel 6.18 mengubah 15+ API di subsistem `cfg80211` (WiFi). Parameter fungsi callback berubah dari `struct net_device *` menjadi `struct wireless_dev *`. Ini **breaking change** yang tidak dapat diatasi tanpa modifikasi source code driver secara mendalam.

### ✅ Metode Utama yang Berhasil

Metode yang terbukti berhasil dan stabil di 3 device:

1. **Install Armbian Trixie** (kernel 6.12.107-ophub) dari ophub
2. **Pilih board yang sesuai** saat first boot (`b860h` atau `hg680p`)
3. **Jangan ganti DTB** — DTB bawaan ophub sudah mengaktifkan jalur SDIO
4. **Download prebuilt driver** dari Release v1.0.0 (atau jalankan one-liner)
5. **Install driver** → `modprobe 8189fs` → `wlan0` muncul
6. **Connect WiFi** via `nmtui` atau `nmcli`

**Inti solusi:** Masalah WiFi bukan di DTB, bukan di kernel, tapi di ** hilangnya driver `8189fs` dari mainline kernel**. Solusinya adalah compile dan install driver out-of-tree.

### Kenapa Kernel 5.10 Itu Spesial?
Kernel 5.10 adalah **LTS (Long Term Support)** dan driver `8189fs` masih masuk di staging kernel pada era 5.x. Setelah kernel 5.15, Realtek menarik driver ini dari mainline karena dianggap "code quality rendah". Jadi setiap update kernel ke 6.x, driver hilang dan harus di-compile ulang.

### 🏆 Konfigurasi yang Disarankan (Recommended Setup)

Untuk hasil paling stabil, disarankan menggunakan kombinasi berikut:

| Komponen | Rekomendasi | Alasan |
|----------|-------------|--------|
| **Distro** | Armbian Trixie (Debian 13) | Kernel LTS 6.12, paket modern, stabil |
| **Kernel** | 6.12.107-ophub | Tested di 3 device, prebuilt driver tersedia |
| **STB** | B860H / HG680P (Amlogic S905X) | Sesuai target repo |
| **Chip WiFi** | Realtek RTL8189FS (Pantat Hitam) | `SDIO_ID=024C:F179` |
| **Driver** | `8189fs.ko` (dari Release) | Stabil, tidak perlu compile |

### 📦 Distro yang Didukung

| Distro | Kernel | Status | Catatan |
|--------|--------|--------|--------|
| **Armbian Trixie** (Debian 13) | 6.12.y | ✅ Tested & Working | Rekomendasi utama |
| **Armbian Bookworm** (Debian 12) | 6.1.y / 6.6.y | ✅ Didukung | Stabil, cocok untuk 1GB RAM |
| **Armbian Noble** (Ubuntu 24.04) | 6.6.y / 6.12.y | ✅ Didukung | Boros RAM, tidak disarankan untuk 1GB |

---

## 🔍 Identifikasi Hardware

### Cek Jenis Chip WiFi Anda

Tidak semua B860H/HG680P menggunakan chip yang sama. Ada dua varian:

| Varian | Chip WiFi | Ciri Fisik | Driver |
|--------|-----------|------------|--------|
| **Pantat Hitam** | Realtek RTL8189FS | Tidak ada garis putih di port HDMI/Power/WAN/AV | `8189fs.ko` |
| **Pantat Putih** | Realtek RTL8188FU | Ada garis putih di port HDMI/Power/WAN/AV | `8188fu.ko` |

> Repository ini khusus untuk chip **RTL8189FS** (Pantat Hitam).

### Verifikasi via Terminal

Jika Armbian sudah terinstall, cek chip WiFi Anda:

```bash
cat /sys/bus/sdio/devices/mmc0:0001:1/uevent
```

Jika output mengandung `SDIO_ID=024C:F179`, berarti chip Anda adalah **Realtek RTL8189FS** dan repository ini adalah solusinya.

### Verifikasi Bus SDIO

Cek apakah chip WiFi terdeteksi di bus SDIO:

```bash
dmesg | grep -iE "sdio|mmc0"
```

Jika muncul `mmc0: new high speed SDIO card at address 0001`, berarti **DTB sudah benar** dan jalur hardware sudah jalan. Masalahnya 100% di driver.

---

## 🛠️ Prasyarat

1. STB B860H / HG680P yang sudah terinstall Armbian (Kernel 5.15 / 6.1 / 6.6 / 6.12).
2. Akses root (`root` / `1234`).
3. Koneksi internet sementara:
   - Kabel LAN langsung ke router utama, **ATAU**
   - USB Tethering dari HP (colok kabel data, aktifkan USB Tethering di Settings HP).
4. USB Reader / Flashdisk (opsional, untuk transfer file jika tidak ada internet di STB).

---

## 🚀 Cara Cepat (Instalasi Otomatis)

Jika Anda telah men-download atau men-clone repository ini ke dalam STB:

```bash
cd Armbian-Wifi-on
chmod +x install-driver.sh
./install-driver.sh
```

Script akan secara otomatis:
1. Menginstall dependencies (`build-essential`, `linux-headers`, `bc`).
2. Jika `linux-headers` tidak ada di apt, script akan download manual dari GitHub ophub.
3. Compile source code menjadi `8189fs.ko`.
4. Memindahkan driver ke `/lib/modules/`.
5. Memuat driver ke kernel (`modprobe 8189fs`).
6. Mengatur agar driver otomatis dimuat saat boot.

---

## 🔧 Instalasi Manual (Jika Script Gagal)

Jika script otomatis gagal (biasanya karena gagal download `linux-headers`), ikuti langkah-langkah berikut:

### 1. Download Headers Manual dari Ophub

Kernel headers tidak tersedia di repository apt Debian. Harus di-download manual dari GitHub ophub.

```bash
# Cek versi kernel
uname -r
# Contoh output: 6.12.107-ophub

# Download headers sesuai versi kernel (ganti 6.12.107 dengan versi Anda)
cd /root
wget https://github.com/ophub/kernel/releases/download/kernel_stable/deb-6.12.107.tar.gz
tar -xzf deb-6.12.107.tar.gz
dpkg -i linux-headers-6.12.107-ophub*.deb
```

### 2. Install Compiler

```bash
apt update
apt install -y build-essential bc
```

### 3. Compile Driver

```bash
cd Armbian-Wifi-on
make -j4 ARCH=arm64 KSRC=/lib/modules/$(uname -r)/build
```

> **Note:** Jika muncul warning `"the compiler differs from the one used to build the kernel"`, abaikan saja. Ini normal dan tidak menyebabkan error.

### 4. Install dan Load Driver

```bash
mkdir -p /lib/modules/$(uname -r)/kernel/drivers/net/wireless/realtek/rtl8189fs
cp 8189fs.ko /lib/modules/$(uname -r)/kernel/drivers/net/wireless/realtek/rtl8189fs/
depmod -a
modprobe 8189fs
```

### 5. Cek WiFi

```bash
ip link show wlan0
```

Jika muncul `wlan0`, **WiFi berhasil diaktifkan!**

### 6. Set Auto-Load Saat Boot

```bash
echo "8189fs" | tee /etc/modules-load.d/8189fs.conf
```

---

## 📶 Connect ke WiFi

### Via nmtui (Menu Interaktif)

```bash
nmtui
```

Pilih `Activate a connection` → Pilih WiFi Anda → Masukkan password.

### Via nmcli (Command Line)

```bash
nmcli device wifi connect "NAMA_WIFI" password "PASSWORD_WIFI" ifname wlan0
```

### Set Auto-Connect

```bash
nmcli device set wlan0 autoconnect yes
```

---

## ⚙️ Troubleshooting

### Masalah: "wlan0 tidak muncul setelah modprobe"

**Solusi 1:** Cek apakah chip benar-benar terdeteksi:
```bash
dmesg | grep -iE "sdio|mmc0|8189"
```

**Solusi 2:** Cek apakah driver sudah ter-load:
```bash
lsmod | grep 8189fs
```

**Solusi 3:** Pastikan tidak ada konflik driver lain:
```bash
rmmod brcmfmac 2>/dev/null
modprobe 8189fs
```

---

### Masalah: "nmtui tidak menampilkan daftar WiFi"

Driver Realtek 8189fs secara default mengaktifkan **Concurrent Mode**, yang membagi satu chip WiFi menjadi dua interface (`wlan0` dan `wlan1`). Hal ini terkadang membuat NetworkManager bingung.

**Solusi:** Gunakan command line langsung:
```bash
nmcli device wifi connect "NAMA_WIFI" password "PASSWORD_WIFI" ifname wlan0
```

---

### Masalah: "Ada dua WiFi (wlan0 dan wlan1)"

Ini normal. Driver Realtek membuat dua interface virtual:
- `wlan0` → untuk connect ke WiFi (Station mode)
- `wlan1` → untuk Hotspot/AP atau WiFi Direct

Gunakan `wlan0` untuk koneksi internet. `wlan1` biarkan saja.

---

### Masalah: "WiFi connect tapi tidak bisa internet"

Cek IP address:
```bash
ip addr show wlan0
```

Jika tidak ada IP, restart NetworkManager:
```bash
systemctl restart NetworkManager
nmcli device wifi connect "NAMA_WIFI" password "PASSWORD_WIFI" ifname wlan0
```

---

### Masalah: "linux-headers tidak ditemukan di apt"

Ini wajar. Ophub tidak menyimpan headers di server apt Debian. Download manual dari:
```
https://github.com/ophub/kernel/releases/tag/kernel_stable
```

Cari file `deb-X.X.X.tar.gz` yang sesuai dengan versi kernel Anda (`uname -r`).

---

### Masalah: "make error: No rule to make target"

Pastikan Anda berada di dalam folder yang berisi `Makefile`:
```bash
cd Armbian-Wifi-on
ls Makefile
```

Jika `Makefile` ada, coba:
```bash
make clean
make -j4 ARCH=arm64 KSRC=/lib/modules/$(uname -r)/build
```

---

### Masalah: "Device STB tidak boot setelah install driver"

Jika STB tidak bisa boot setelah install driver, kemungkinan ada konflik module. Boot dari SD card/USB lain, lalu hapus driver dari eMMC:

```bash
# Mount eMMC
mkdir -p /mnt/emmc
mount /dev/mmcblk2p2 /mnt/emmc

# Hapus driver
rm -f /mnt/emmc/lib/modules/*/kernel/drivers/net/wireless/realtek/rtl8189fs/8189fs.ko
rm -f /mnt/emmc/etc/modules-load.d/8189fs.conf

# Reboot
reboot
```

---

## 🐳 Docker di B860H/HG680P

Setelah WiFi aktif, Anda bisa install Docker:

```bash
armbian-docker
```

Atau manual:
```bash
apt update && apt install -y docker.io docker-compose-v2
systemctl enable docker && systemctl start docker
```

### Spesifikasi Hardware B860H/HG680P:
- **CPU:** 4x ARM Cortex-A53 @ 1.5GHz (ARMv8-A, 64-bit aarch64)
- **RAM:** 2GB (atau 1GB di varian tertentu)
- **Storage:** 8GB eMMC + SD card/USB
- **Network:** 100Mbps Ethernet + WiFi (Realtek RTL8189FS)
- **Architecture:** arm64 (aarch64)

### Docker yang realistis untuk 2GB RAM:
- ✅ Nginx, Portainer, AdGuard Home, Pi-hole
- ✅ WireGuard, Unbound, Node-RED, MQTT broker
- ✅ Home Assistant (lightweight), Uptime Kuma, Netdata
- ⚠️ Nextcloud, Vaultwarden, Gitea (berat tapi masih bisa)
- ❌ Gitlab, Elasticsearch (terlalu berat untuk 2GB RAM)

---

## 🔄 Update Kernel

Jika Anda mengupdate kernel Armbian di masa depan, driver WiFi akan hilang dan harus di-compile ulang:

```bash
# Setelah update kernel & reboot
cd Armbian-Wifi-on
make clean
./install-driver.sh
```

> **Tips:** Simpan repository ini di internal storage STB agar tidak perlu download ulang saat update kernel.

---

## ❓ FAQ

**Q: Apakah perlu ganti/modifikasi DTB?**
A: TIDAK. DTB bawaan ophub sudah benar. Jalur SDIO sudah aktif. Masalahnya 100% di driver.

**Q: Apakah bisa pakai kernel 6.18?**
A: TIDAK. Kernel 6.18 mengubah 15+ API di `cfg80211` (`net_device` → `wireless_dev`). Driver ini belum support. Gunakan kernel 6.12.

**Q: Apakah work di Armbian Trixie (Debian 13)?**
A: YA. Sudah ditest di kernel 6.12.107-ophub dengan Armbian Trixie. Ini konfigurasi yang disarankan.

**Q: Kenapa WiFi saya ada dua (wlan0 dan wlan1)?**
A: Itu fitur Concurrent Mode dari driver Realtek. Normal. Pakai wlan0 saja.

**Q: Bagaimana jika chip saya bukan RTL8189FS?**
A: Cek dengan `cat /sys/bus/sdio/devices/mmc0:0001:1/uevent`. Jika bukan `SDIO_ID=024C:F179`, driver ini tidak cocok.

**Q: Kernel 6.6.193-ophub juga tested?**
A: YA. B860H V2 2GB RAM dengan kernel 6.6.193-ophub juga sudah berhasil WiFi ON.

**Q: Apakah perlu downgrade kernel?**
A: TIDAK. Driver bisa di-compile atau di-install prebuilt di kernel 6.12 tanpa downgrade.

**Q: Saya punya 1GB RAM, apakah bisa compile?**
A: Bisa, tapi disarankan pakai prebuilt driver dari Release v1.0.0. Tanpa compile, hemat RAM dan waktu.

**Q: Apakah driver bertahan setelah reboot?**
A: YA. Script otomatis membuat file `/etc/modules-load.d/8189fs.conf` yang memuat driver saat boot.

**Q: Bagaimana setelah update kernel?**
A: Driver harus di-install ulang. Jalankan lagi one-liner atau compile ulang.

---

## 🙏 Credits & References

Proyek ini disusun berdasarkan pengalaman langsung dan trial-and-error. Terima kasih kepada:

### 🧪 Tester
- **JhopanStore** - Pengujian langsung di 3 device:
  - ZTE B860H V1 (1GB RAM) - Kernel 6.12.107-ophub - Armbian Trixie ✅
  - ZTE B860H V2 (2GB RAM) - Kernel 6.6.193-ophub - Armbian Trixie ✅
  - FiberHome HG680P - Kernel 6.12.107-ophub - Armbian Trixie ✅

### 📚 Driver Source Code
- **[jwrdegoede/rtl8189ES_linux](https://github.com/jwrdegoede/rtl8189ES_linux)** - Source code asli driver RTL8189FS (branch `rtl8189fs`).
- **[gustiarto/rtl8189fs-armbian](https://github.com/gustiarto/rtl8189fs-armbian)** - Repository source code driver RTL8189FS yang di-patch untuk kernel 6.1.y / 6.12.y.
- **[alive4ever/rtl8189fs-armbian-current-meson64](https://github.com/alive4ever/rtl8189fs-armbian-current-meson64)** - Referensi DKMS untuk kernel 6.12.

### 🖥️ Armbian & Kernel
- **[ophub/amlogic-s9xxx-armbian](https://github.com/ophub/amlogic-s9xxx-armbian)** - Image Armbian dan kernel packages untuk Amlogic S905X.

### 🔧 Referensi DTB & Hardware
- **[hafidhh/B860H-HG680P-Armbian](https://github.com/hafidhh/B860H-HG680P-Armbian)** - Referensi awal konfigurasi DTB B860H/HG680P.
- **[Rureka](https://rureka.com/mengaktifkan-wifii-internal-manjaro-di-amlogic-s905x-stb-fiberhome-hg680p/)** - Referensi identifikasi varian pantat hitam vs putih.

### 📖 Referensi Tambahan
- **[Armbian Official - aml-s9xx-box](https://armbian.com/boards/aml-s9xx-box)** - Board support resmi.
- **[mregha/Armbian-Wifi](https://github.com/mregha/Armbian-Wifi)** - Referensi alternatif (wlan-black.deb, sudah deprecated).
- **[FarelRA - Revive Dead eMMC](https://gist.github.com/FarelRA/2d5bc9e23d2e718f1f30247b74638c32)** - Referensi install Armbian di B860H/HG680P.

---

## 📜 License

Source code driver Realtek RTL8189FS adalah hak milik Realtek dan dilisensikan di bawah GPL v2. Script dan dokumentasi dalam repository ini bebas digunakan.

---

## ⭐ Kontribusi

Jika Anda berhasil (atau gagal) di kernel/konfigurasi lain, silakan buat Issue atau Pull Request. Informasi Anda akan sangat membantu pengguna STB lainnya.

**Tested & Working:**
- ZTE B860H V1 (1GB RAM) - Kernel 6.12.107-ophub - Armbian Trixie ✅
- ZTE B860H V2 (2GB RAM) - Kernel 6.6.193-ophub - Armbian Trixie ✅
- FiberHome HG680P - Kernel 6.12.107-ophub - Armbian Trixie ✅
- Chip: Realtek RTL8189FS (SDIO_ID=024C:F179)
