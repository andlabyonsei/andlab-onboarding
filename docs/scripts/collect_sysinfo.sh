#!/usr/bin/env bash

OUT="sysinfo_$(hostname)_$(date +%Y%m%d).txt"

{
  echo "===== BASIC ====="
  echo "Hostname: $(hostname)"
  echo "Date: $(date)"
  echo "Uptime: $(uptime -p)"

  echo
  echo "===== OS / KERNEL ====="
  echo "OS:"
  cat /etc/os-release 2>/dev/null
  echo
  echo "Kernel: $(uname -r)"

  echo
  echo "===== CPU ====="
  lscpu

  echo
  echo "===== MEMORY ====="
  free -h
  echo
  echo "Detailed (dmidecode, root only):"
  sudo dmidecode -t memory 2>/dev/null || echo "dmidecode not available or no permission"

  echo
  echo "===== DISKS / FILESYSTEMS ====="
  lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
  echo
  df -h

  echo
  echo "===== GPU (nvidia-smi) ====="
  if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi -L
    echo
    nvidia-smi
  else
    echo "nvidia-smi not found"
  fi

  echo
  echo "===== NETWORK ====="
  ip -brief addr
  echo
  echo "NICs:"
  lspci | grep -i -E 'ethernet|network'
} > "$OUT"

echo "Saved to $OUT"

