#!/bin/bash
set -e

echo "=========================================================="
echo " Realtek RTL8189FS WiFi Driver Installer"
echo " Target: B860H / HG680P (Amlogic S905X) Armbian Kernel 6.x"
echo "=========================================================="

KERNEL_VER=$(uname -r)
TARGET_MODULE_DIR="/lib/modules/${KERNEL_VER}/kernel/drivers/net/wireless/realtek/rtl8189fs"

echo "[1/6] Install dependencies..."
apt update
apt install -y build-essential bc unzip wget

# Coba install headers via apt, jika gagal download manual dari ophub
echo "[2/6] Mengambil Linux Headers..."
if ! apt install -y linux-headers-${KERNEL_VER} 2>/dev/null; then
    echo "Headers tidak ada di apt, download manual dari ophub..."
    cd /root
    wget https://github.com/ophub/kernel/releases/download/kernel_stable/deb-${KERNEL_VER%-ophub}.tar.gz -O deb-kernel.tar.gz
    tar -xzf deb-kernel.tar.gz
    dpkg -i linux-headers-${KERNEL_VER}*.deb
    cd -
fi

echo "[3/6] Compile driver..."
make clean || true
make -j$(nproc) ARCH=arm64 KSRC=/lib/modules/${KERNEL_VER}/build

echo "[4/6] Install driver module..."
mkdir -p "${TARGET_MODULE_DIR}"
cp 8189fs.ko "${TARGET_MODULE_DIR}/"
depmod -a

echo "[5/6] Load driver..."
modprobe 8189fs

echo "[6/6] Enable auto-load at boot..."
echo "8189fs" | tee /etc/modules-load.d/8189fs.conf > /dev/null

echo ""
echo "=========================================================="
echo " SELESAI! WiFi driver telah diinstall dan dimuat."
echo " Cek interface: ip link show wlan0"
echo "=========================================================="
