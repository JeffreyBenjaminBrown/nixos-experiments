#!/usr/bin/env bash
# Baseline diagnostics for the monome resurrection project.
#
# Run this twice:
#   1. with the monome UNPLUGGED
#   2. with the monome PLUGGED IN (wait ~3s after plugging before running)
#
# Both runs append to the same report file so I can diff them.
# Output lands next to this script regardless of where the repo lives.

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/01-diagnose.out"
LABEL="${1:-unspecified}"

{
  echo
  echo "================================================================"
  echo "=== RUN: $LABEL    $(date -Iseconds)"
  echo "================================================================"

  echo "--- nixos version ---"
  nixos-version 2>&1 || true

  echo "--- uname -a ---"
  uname -a 2>&1 || true

  echo "--- current channels (sudo needed on some setups; skip if it prompts) ---"
  nix-channel --list 2>&1 || true
  sudo -n nix-channel --list 2>&1 || echo "(sudo would prompt; skipped)"

  echo "--- kernel modules of interest ---"
  lsmod 2>&1 | grep -E '^(usbserial|ftdi_sio|cdc_acm)\b' || echo "(none of usbserial/ftdi_sio/cdc_acm loaded)"

  echo "--- lsusb (full) ---"
  lsusb 2>&1 || echo "(lsusb not available)"

  echo "--- lsusb | grep -i monome ---"
  lsusb 2>&1 | grep -i -E 'monome|ftdi|future technology' || echo "(no monome/ftdi match)"

  echo "--- /dev/ttyUSB* and /dev/ttyACM* ---"
  ls -l /dev/ttyUSB* /dev/ttyACM* 2>&1 || true

  echo "--- dmesg last 40 lines (need sudo on NixOS by default; skip if prompts) ---"
  sudo -n dmesg 2>&1 | tail -n 40 || echo "(sudo would prompt; re-run with: sudo dmesg | tail -n 40 and paste manually if needed)"

  echo "--- groups of user $USER ---"
  id 2>&1

  echo "--- is serialoscd on PATH? ---"
  command -v serialoscd 2>&1 || echo "(not on PATH)"
  command -v monomeserial 2>&1 || echo "(monomeserial not on PATH — expected)"

  echo "--- does udev already have any monome rules? ---"
  grep -rEl 'monome|ftdi' /etc/udev/rules.d /run/udev/rules.d 2>/dev/null || echo "(no matching udev rule files)"
  grep -rEl 'monome|ftdi' /run/current-system/etc/udev 2>/dev/null || true

  echo "--- existing /nix/nixpkgs clone? (leftover from old imperative install) ---"
  if [ -d /nix/nixpkgs ]; then
    echo "FOUND: /nix/nixpkgs exists"
    git -C /nix/nixpkgs log -1 --oneline 2>&1 || true
    git -C /nix/nixpkgs branch --show-current 2>&1 || true
  else
    echo "(not present — good, we won't need it)"
  fi

  echo "--- is serialoscd user service defined/running? ---"
  systemctl --user list-unit-files 2>&1 | grep -i serial || echo "(no serialosc user unit)"
  systemctl --user status serialoscd.service 2>&1 | head -5 || true

  echo "=== END RUN: $LABEL ==="
} >>"$OUT" 2>&1

echo "Appended run '$LABEL' to $OUT"
echo "Size: $(wc -l <"$OUT") lines"
