#!/bin/bash
# Quick Install RTL8189FS WiFi Driver - No Compile Needed
# For B860H / HG680P (Amlogic S905X) Armbian Kernel 6.1 / 6.6 / 6.12
# Repo: https://github.com/jhopan/Armbian-Wifi-on

set -e

KVER=$(uname -r | cut -d- -f1)
KFULL=$(uname -r)
RELEASE_URL="https://github.com/jhopan/Armbian-Wifi-on/releases/download/v1.0.0"
DEST_DIR="/lib/modules/${KFULL}/kernel/drivers/net/wireless/realtek/rtl8189fs"

echo "=========================================================="
echo "  Quick Install RTL8189FS WiFi Driver"
echo "  Kernel: ${KFULL}"
echo "=========================================================="

# Cek apakah ada prebuilt untuk kernel ini
echo "Mencari prebuilt driver untuk kernel ${KVER}..."
HTTP_CODE=$(curl -sL -o /dev/null -w "%{http_code}" "${RELEASE_URL}/8189fs-${KVER}.ko")

if [[ "${HTTP_CODE}" == "200" ]]; then
    echo "✅ Prebuilt driver ditemukan untuk kernel ${KVER}!"
    echo ""
    echo "Downloading..."
    curl -sL -o /tmp/8189fs.ko "${RELEASE_URL}/8189fs-${KVER}.ko"
    
    echo "Installing..."
    mkdir -p "${DEST_DIR}"
    cp /tmp/8189fs.ko "${DEST_DIR}/8189fs.ko"
    depmod -a
    modprobe 8189fs
    
    echo "8189fs" | tee /etc/modules-load.d/8189fs.conf > /dev/null
    rm -f /tmp/8189fs.ko
    
    echo ""
    echo "=========================================================="
    echo "  ✅ DRIVER BERHASIL DIPASANG!"
    echo "=========================================================="
    echo ""
    echo "Cek WiFi:"
    ip link show wlan0 2>/dev/null && echo "" || echo "wlan0 belum muncul, coba: modprobe 8189fs"
    echo "Connect WiFi:"
    echo "  nmtui"
    echo ""
    echo "Atau dengan nmcli:"
    echo "  nmcli device wifi connect \"NAMA_WIFI\" password \"PASSWORD_WIFI\" ifname wlan0"
    echo ""
    echo "Repo: https://github.com/jhopan/Armbian-Wifi-on"
else
    echo "❌ Tidak ada prebuilt untuk kernel ${KVER}."
    echo ""
    echo "Pilihan:"
    echo "  1. Gunakan kernel yang didukung: 6.1.188, 6.6.157, atau 6.12.107"
    echo "  2. Clone repo dan compile sendiri:"
    echo "     git clone https://github.com/jhopan/Armbian-Wifi-on.git"
    echo "     cd Armbian-Wifi-on && chmod +x install-driver.sh && ./install-driver.sh"
    echo ""
    exit 1
fi