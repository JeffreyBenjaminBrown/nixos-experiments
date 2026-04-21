#!/usr/bin/env bash
# Step 6: end-to-end hardware check — blink every LED on the grid.
#
# Finds the device OSC port from the serialoscd journal (it's different
# on each restart), then sends /grid/led/all 1 (all LEDs on) and
# /grid/led/all 0 (all LEDs off), with a 1.5s pause in between.
#
# You should SEE the whole grid light up, then go dark.
#
# Output: ./06-blink.out

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/06-blink.out"

{
  echo "================================================================"
  echo "=== BLINK    $(date -Iseconds)"
  echo "================================================================"

  if ! command -v oscsend >/dev/null 2>&1; then
    echo "oscsend not on PATH. Aborting."
    exit 1
  fi

  echo "--- Pulling device id + server port from serialoscd journal ---"
  LINE="$(journalctl --user -u serialoscd.service --no-pager 2>/dev/null | grep -E 'connected, server running on port' | tail -n 1)"
  echo "line: $LINE"
  DEV="$(printf '%s\n' "$LINE" | sed -E 's/.*serialosc \[([^]]+)\]:.*/\1/')"
  PORT="$(printf '%s\n' "$LINE" | sed -E 's/.*running on port ([0-9]+).*/\1/')"
  echo "device: $DEV"
  echo "port:   $PORT"
  if [ -z "${PORT:-}" ] || [ "$PORT" = "$LINE" ]; then
    echo "Could not parse port; aborting."
    exit 1
  fi

  # Grid commands are filtered by a per-device prefix (see
  # https://monome.org/docs/serialosc/osc/). If we don't set it, our
  # /<prefix>/grid/... messages get silently dropped. The prefix is a
  # label we *assign* to the device via /sys/prefix; we pick it. This
  # device is the 256 that only needs one USB cable — Jeff calls it
  # "256-1-cable" — so that's what we set here.
  PREFIX=/256-1-cable
  echo "--- /sys/prefix s $PREFIX ---"
  oscsend localhost "$PORT" /sys/prefix s "$PREFIX"
  sleep 0.2

  echo
  echo "--- Sending /256-1-cable/grid/led/all 1 (all LEDs ON) ---"
  oscsend localhost "$PORT" /256-1-cable/grid/led/all i 1
  echo "Look at the grid now — every button should be lit."
  sleep 1.5

  echo
  echo "--- Sending /256-1-cable/grid/led/all 0 (all LEDs OFF) ---"
  oscsend localhost "$PORT" /256-1-cable/grid/led/all i 0
  echo "Grid should be dark again."
  sleep 0.3

  echo "=== END BLINK ==="
} >"$OUT" 2>&1

echo "Wrote $OUT ($(wc -l <"$OUT") lines)"
echo "Did the grid light up and then go dark? Tell Claude."
