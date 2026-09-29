# 🛜 Armbian WiFi-ON untuk B860H / HG680P (Amlogic S905X)

[![License](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](LICENSE)
[![Kernel](https://img.shields.io/badge/Linux%20Kernel-6.1.y%20%7C%206.12.y-green.svg)]()
[![Hardware](https://img.shields.io/badge/Hardware-ZTE%20B860H%20%7C%20FiberHome%20HG680P-orange.svg)]()

Repository ini berisi panduan lengkap, script otomatis, dan prebuilt driver untuk mengaktifkan **WiFi Internal Realtek RTL8189FS** pada STB Amlogic S905X (B860H / HG680P) yang menjalankan Armbian modern (Kernel 6.1.y / 6.12.y).

---

## 📖 Latar Belakang Masalah

Banyak STB Amlogic S905X (seperti ZTE B860H dan FiberHome HG680P) yang beredar menggunakan chip WiFi **Realtek RTL8189FS** (SDIO). Sayangnya, Realtek tidak menyertakan driver `8189fs` ke dalam mainline kernel Linux sejak versi 5.15. 

Akibatnya, ketika pengguna menginstall atau meng-update Armbian ke kernel modern (6.1.y, 6.12.y), WiFi internal STB mati total dan tidak terdeteksi (`wlan0` tidak muncul).

Banyak pandangan keliru yang menyatakan bahwa masalah ini dapat diselesaikan dengan **memodifikasi Device Tree Blob (DTB)**. Faktanya, modifikasi DTB **tidak akan pernah menyelesaikan masalah ini** karena akar masalahnya adalah hilangnya *software driver*, bukan konfigurasi hardware.

Repository ini dibuat untuk memberikan solusi pasti: **Compile driver Realtek 8189fs dari source code out-of-tree**.

---

## 🛠️ Prasyarat

1. STB B860H / HG680P yang sudah terinstall Armbian (Kernel 6.1.y atau 6.12.y).
2. Akses root (`root` / `1234`).
3. Koneksi internet sementara (Kabel LAN atau USB Tethering dari HP).
4. USB Reader / Flashdisk (opsional, untuk transfer file).

---

## 🚀 Cara Cepat (Instalasi Otomatis)

Jika Anda telah men-download atau men-clone repository ini ke dalam STB, jalankan script instalasi otomatis:

```bash
cd Armbian-Wifi-on
chmod +x install-driver.sh
./install-driver.sh
```

Script akan secara otomatis:
1. Menginstall dependencies (`build-essential`, `linux-headers`, `bc`).
2. Compile source code menjadi `8189fs.ko`.
3. Memindahkan driver ke `/lib/modules/`.
4. Memuat driver ke kernel (`modprobe 8189fs`).
5. Mengatur agar driver otomatis dimuat saat boot.

---

## 🔧 Instalasi Manual (Jika Script Gagal)

Jika script otomatis gagal (biasanya karena gagal download `linux-headers`), ikuti langkah-langkah berikut:

### 1. Download Headers Manual dari Ophub
Kernel headers tidak tersedia di repository apt Debian, harus di-download manual dari GitHub ophub.

```bash
# Cek versi kernel
uname -r
# Contoh output: 6.12.107-ophub

# Download headers sesuai versi kernel
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
Jika muncul `wlan0`, WiFi berhasil diaktifkan!

### 6. Set Auto-Load Saat Boot
```bash
echo "8189fs" | tee /etc/modules-load.d/8189fs.conf
```

---

## ⚙️ Mengatasi Masalah "Dua WiFi" (Concurrent Mode)

Driver Realtek 8189fs secara default mengaktifkan *Concurrent Mode*, yang membagi satu chip WiFi menjadi dua interface (`wlan0` dan `wlan1`). Hal ini terkadang membuat NetworkManager (`nmtui`) bingung dan tidak menampilkan daftar WiFi.

Jika Anda mengalami hal ini, sambungkan WiFi menggunakan command line berikut:

```bash
# Sambungkan ke WiFi
nmcli device wifi connect "NAMA_WIFI" password "PASSWORD_WIFI" ifname wlan0

# Set agar auto-connect
nmcli device set wlan0 autoconnect yes
```

---

## 🙏 Credits & References

Proyek ini disusun berdasarkan pengalaman dan trial-and-error. Terima kasih kepada:

- **JhopanStore** - Untuk eksplorasi, dokumentasi, dan pengujian langsung pada device B860H.
- **[gustiarto/rtl8189fs-armbian](https://github.com/gustiarto/rtl8189fs-armbian)** - Repository source code driver RTL8189FS yang sudah di-patch untuk kernel modern.
- **[alive4ever/rtl8189fs-armbian-current-meson64](https://github.com/alive4ever/rtl8189fs-armbian-current-meson64)** - Referensi DKMS untuk kernel 6.12.
- **[ophub/amlogic-s9xxx-armbian](https://github.com/ohub/amlogic-s9xxx-armbian)** - Untuk image Armbian dan kernel packages Amlogic S905X.
- **[hafidhh/B860H-HG680P-Armbian](https://github.com/hafidhh/B860H-HG680P-Armbian)** - Referensi awal mengenai konfigurasi DTB B860H/HG680P.

---

## 📜 License

Source code driver Realtek RTL8189FS adalah hak milik Realtek dan dilisensikan di bawah GPL v2. Script dan dokumentasi dalam repository ini bebas digunakan.
