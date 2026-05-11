#!/bin/bash

# ==========================================
# KVM Installation & Setup Script
# Ubuntu/Debian Based Systems
# ==========================================

set -e

echo "=========================================="
echo " Checking Virtualization Support"
echo "=========================================="

VIRT_CHECK=$(egrep -c '(vmx|svm)' /proc/cpuinfo)

if [ "$VIRT_CHECK" -eq 0 ]; then
    echo "❌ Virtualization is NOT supported or disabled in BIOS."
    exit 1
else
    echo "✅ Virtualization supported"
fi

echo ""
echo "=========================================="
echo " Updating System"
echo "=========================================="

sudo apt update && sudo apt upgrade -y

echo ""
echo "=========================================="
echo " Installing KVM Packages"
echo "=========================================="

sudo apt install -y \
qemu-kvm \
libvirt-daemon-system \
libvirt-clients \
bridge-utils \
virt-manager \
virtinst \
cpu-checker

echo ""
echo "=========================================="
echo " Starting libvirt Service"
echo "=========================================="

sudo systemctl enable --now libvirtd

echo ""
echo "=========================================="
echo " Adding Current User to Groups"
echo "=========================================="

sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER

echo ""
echo "=========================================="
echo " Verifying KVM Installation"
echo "=========================================="

kvm-ok || true

echo ""
echo "=========================================="
echo " Checking KVM Modules"
echo "=========================================="

lsmod | grep kvm || true

echo ""
echo "=========================================="
echo " KVM Installation Complete"
echo "=========================================="

echo ""
echo "IMPORTANT:"
echo "1. Logout and login again OR reboot"
echo "2. Start Virtual Machine Manager using:"
echo "      virt-manager"
echo ""
echo "3. To list VMs:"
echo "      virsh list --all"
echo ""
echo "4. To create a VM:"
echo "      virt-install"
echo ""