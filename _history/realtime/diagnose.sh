# Run on the NixOS host, writes results to the Docker-mounted nix/ dir.
# MUST run with: sudo bash /home/jeff/code/midi/nix/diagnose.sh

# Prevent systemctl/journalctl/bootctl from invoking a pager.
# SYSTEMD_PAGER affects systemctl/journalctl/bootctl.
# PAGER affects everything else.
# Both are needed because sudo -u jeff clears the environment,
# so we also pass them explicitly in sudo commands below.
export SYSTEMD_PAGER=""
export PAGER="cat"

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: must run as root (sudo). dmesg needs it."
    exit 1
fi

OUT="/home/jeff/code/midi/nix/audio-diagnostics.org"

rm -f "$OUT"
cat > "$OUT" <<'HEADER'
#+TITLE: Audio Diagnostics
#+DATE: $(date)
HEADER
sed -i "s|\$(date)|$(date)|" "$OUT"

section() {
    echo "" >> "$OUT"
    echo "* $1" >> "$OUT"
    echo "#+begin_example" >> "$OUT"
    SYSTEMD_PAGER="" PAGER="cat" eval "$2" >> "$OUT" 2>&1
    echo "#+end_example" >> "$OUT"
}

section "uname -a" "uname -a"
section "kernel command line" "cat /proc/cmdline"
section "lspci -v -s 00:1f.3 (audio)" "lspci -v -s 00:1f.3"
section "lspci -v -s 00:02.0 (GPU)" "lspci -v -s 00:02.0"

# === GPU DRIVER STATUS (the #1 issue) ===
section "lsmod | i915" "lsmod | grep i915 || echo 'i915 NOT loaded'"
section "lsmod | xe" "lsmod | grep xe || echo 'xe NOT loaded (check for drm_xe or just xe)'"
section "lsmod | simpledrm" "lsmod | grep simpledrm || echo 'simpledrm NOT loaded'"
section "GPU driver bound to 00:02.0" "readlink /sys/bus/pci/devices/0000:00:02.0/driver 2>/dev/null || echo 'NO driver bound to GPU PCI device'"
section "DRM devices" "ls -la /sys/class/drm/ 2>/dev/null | head -20"
section "modinfo i915" "modinfo i915 2>&1 | head -10"
section "modinfo xe" "modinfo xe 2>&1 | head -10"
section "kernel config DRM_I915" "zcat /proc/config.gz 2>/dev/null | grep -E 'CONFIG_DRM_I915[= ]' || echo 'CONFIG_DRM_I915 NOT FOUND — i915 not compiled in this kernel!'"
section "kernel config DRM_XE" "zcat /proc/config.gz 2>/dev/null | grep -E 'CONFIG_DRM_XE[= ]' || echo 'CONFIG_DRM_XE NOT FOUND'"
section "kernel config DRM_XE_FORCE_PROBE" "zcat /proc/config.gz 2>/dev/null | grep CONFIG_DRM_XE_FORCE_PROBE || echo 'not found'"
section "kernel config DRM_I915_FORCE_PROBE" "zcat /proc/config.gz 2>/dev/null | grep CONFIG_DRM_I915_FORCE_PROBE || echo 'not found'"

# dmesg around GPU probe — CRITICAL for understanding why xe/i915 did or didn't load
section "dmesg | xe driver" "dmesg | grep -iE 'xe[^a-z].*probe|xe[^a-z].*drm|xe[^a-z].*force|xe[^a-z].*a7a0|drm.*xe' | tail -30"
section "dmesg | i915 and drm" "dmesg | grep -iE 'i915|drm|simpledrm' | tail -60"

# === AUDIO / SOF STATUS ===
section "/proc/asound/cards" "cat /proc/asound/cards"
section "/proc/asound/modules" "cat /proc/asound/modules 2>/dev/null || echo 'not found'"
section "/dev/snd contents" "ls -la /dev/snd/ 2>/dev/null || echo '/dev/snd not found'"

section "lsmod | sof" "lsmod | grep sof"
section "lsmod | snd" "lsmod | grep snd"
section "lsmod | avs" "lsmod | grep avs || echo 'snd_soc_avs NOT loaded (good — it is blacklisted)'"

section "snd-intel-dspcfg params" "cat /sys/module/snd_intel_dspcfg/parameters/dsp_driver 2>/dev/null || echo 'module not loaded or param not found'"

# Full dmesg audio trail
section "dmesg | audio-related" "dmesg | grep -iE 'snd|sound|sof|hda|audio|codec|firmware' | tail -120"
section "dmesg | errors and warnings" "dmesg | grep -iE '(snd|sof|hda).*([Ee]rr|[Ff]ail|[Ww]arn|[Dd]eny|timeout|abort)'"
section "dmesg | deferred probe" "dmesg | grep -i 'deferred\|probe' | tail -30"

# === FIRMWARE ===
section "hardware.firmware symlink" "ls -la /run/current-system/firmware 2>/dev/null || echo 'not found'"
section "SOF firmware in /run/current-system" "ls -la /run/current-system/firmware/intel/sof/ 2>/dev/null || echo 'none found'"
section "SOF IPC4 firmware" "ls /run/current-system/firmware/intel/sof-ipc4/ 2>/dev/null || echo 'none found'"
section "SOF topology files (sof-tplg, rpl)" "find /run/current-system/firmware/intel/sof-tplg/ -name '*rpl*' 2>/dev/null | head -10 || echo 'none'"
section "SOF topology files (sof-ipc4-tplg, rpl)" "find /run/current-system/firmware/intel/sof-ipc4-tplg/ -name '*rpl*' 2>/dev/null | head -10 || echo 'none'"
section "xe firmware (i915/)" "ls /run/current-system/firmware/i915/ 2>/dev/null | head -20 || echo 'none found (xe uses firmware from i915/ directory)'"
section "kernel firmware_class path" "cat /sys/module/firmware_class/parameters/path 2>/dev/null || echo 'not found'"

# === MODPROBE CONFIG ===
section "modprobe config (audio + gpu relevant)" "grep -iE 'snd|sof|hda|audio|firmware_class|dsp|i915|xe|avs' /etc/modprobe.d/* 2>/dev/null || echo 'none found'"
section "modprobe.d file listing" "ls -la /etc/modprobe.d/"
section "all nixos modprobe.d content" "for f in /etc/modprobe.d/nixos*.conf /etc/modprobe.d/extra*.conf; do echo \"=== \$f ===\"; cat \"\$f\" 2>/dev/null || echo 'not found'; done"

# === ALSA ===
section "ALSA info (aplay -l)" "aplay -l 2>&1"
section "ALSA info (aplay -L)" "aplay -L 2>&1 | head -40"

# === PIPEWIRE ===
section "PipeWire status" "sudo -u jeff SYSTEMD_PAGER='' XDG_RUNTIME_DIR=/run/user/1000 systemctl --user --no-pager status pipewire 2>&1 | head -20"
section "WirePlumber status" "sudo -u jeff SYSTEMD_PAGER='' XDG_RUNTIME_DIR=/run/user/1000 systemctl --user --no-pager status wireplumber 2>&1 | head -20"
section "pw-dump (sinks only)" "sudo -u jeff XDG_RUNTIME_DIR=/run/user/1000 pw-dump 2>/dev/null | grep -A5 '\"media.class\": \"Audio/Sink\"' | head -30 || echo 'pw-dump not available'"
section "wpctl status" "sudo -u jeff XDG_RUNTIME_DIR=/run/user/1000 wpctl status 2>&1 | head -40 || echo 'wpctl not available'"

# === KERNEL CONFIG (audio) ===
section "kernel config SOF" "zcat /proc/config.gz 2>/dev/null | grep -i CONFIG_SND_SOC_SOF || echo '/proc/config.gz not available'"
section "kernel config HDA" "zcat /proc/config.gz 2>/dev/null | grep -i CONFIG_SND_HDA || echo '/proc/config.gz not available'"
section "kernel config SND_SOC_INTEL" "zcat /proc/config.gz 2>/dev/null | grep -i CONFIG_SND_SOC_INTEL || echo '/proc/config.gz not available'"

# === MODULE INFO ===
section "kernel version detail" "uname -r && modinfo snd_sof 2>/dev/null | head -5 || echo 'snd_sof modinfo not available'"
section "modinfo snd_sof_pci_intel_tgl" "modinfo snd_sof_pci_intel_tgl 2>&1 | head -10"
section "modinfo snd_hda_intel" "modinfo snd_hda_intel 2>&1 | head -10"
section "modinfo snd_soc_avs" "modinfo snd_soc_avs 2>&1 | head -10"

# === BACKLIGHT (brightness keys) ===
section "/sys/class/backlight/" "ls -la /sys/class/backlight/ 2>/dev/null || echo 'empty or not found'"
section "backlight type and brightness" "for bl in /sys/class/backlight/*/; do echo \"=== \$(basename \$bl) ===\"; cat \"\${bl}type\" 2>/dev/null; echo \"brightness: \$(cat \"\${bl}brightness\" 2>/dev/null)\"; echo \"max: \$(cat \"\${bl}max_brightness\" 2>/dev/null)\"; done 2>/dev/null || echo 'no backlight devices'"

# === DISPLAY SERVER (X11 vs Wayland) ===
section "XDG_SESSION_TYPE" "sudo -u jeff XDG_RUNTIME_DIR=/run/user/1000 bash -c 'echo \$XDG_SESSION_TYPE' 2>&1 || echo 'unknown'"
section "loginctl show-session (display type)" "loginctl show-session \$(loginctl list-sessions --no-legend | awk '/jeff/{print \$1; exit}') -p Type -p Display -p Desktop 2>&1 || echo 'could not query session'"
section "kwinrc compositing setting" "cat /etc/xdg/kwinrc 2>/dev/null || echo 'not found'"
section "kwin_wayland or kwin_x11 running" "ps -eo comm | grep -E 'kwin_(wayland|x11)' | head -5 || echo 'neither kwin_wayland nor kwin_x11 found'"
section "wayland-related processes" "ps -eo comm | grep -i wayland | head -10 || echo 'none'"

# === CPU GOVERNOR ===
section "CPU governor (all cores)" "cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null | sort | uniq -c || echo 'not available'"
section "CPU frequency (all cores)" "cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq 2>/dev/null | sort | uniq -c || echo 'not available'"

# === POWER MANAGEMENT (what's overriding CPU governor?) ===
section "thermald running?" "systemctl --no-pager status thermald 2>&1 | head -5 || echo 'not found'"
section "power-profiles-daemon running?" "systemctl --no-pager status power-profiles-daemon 2>&1 | head -5 || echo 'not found'"
section "tlp running?" "systemctl --no-pager status tlp 2>&1 | head -5 || echo 'not found'"
section "powerdevil/KDE power management" "ps -eo comm | grep -iE 'power|energy' || echo 'none found'"
section "active power profile" "powerprofilesctl get 2>/dev/null || echo 'powerprofilesctl not available'"

# === RT SCHEDULING ===
section "Reaper thread scheduling" "ps -eLo pid,tid,cls,rtprio,comm | grep -i reaper || echo 'Reaper not running'"
section "Reaper cgroup" "cat /proc/\$(pgrep -x .reaper-wrapped | head -1)/cgroup 2>/dev/null || echo 'Reaper not running'"
section "Reaper systemd unit" "sudo -u jeff SYSTEMD_PAGER='' XDG_RUNTIME_DIR=/run/user/1000 systemctl --user --no-pager status reaper-rt.service 2>/dev/null | head -8 || echo 'reaper-rt.service not found — Reaper was not launched via the RT wrapper'"
section "PipeWire thread scheduling (all related)" "ps -eLo pid,tid,cls,rtprio,comm | grep -iE 'pipewire|wireplumb|pw-' || echo 'PipeWire not running'"
section "All threads of PipeWire process" "ps -eLo pid,tid,cls,rtprio,comm -p \$(pgrep -x pipewire | head -1) 2>/dev/null || echo 'not found'"
section "PipeWire cgroup" "cat /proc/\$(pgrep -x pipewire | head -1)/cgroup 2>/dev/null || echo 'not found'"
section "cgroup cpu.rt values (if v1)" "find /sys/fs/cgroup -name 'cpu.rt_runtime_us' -exec sh -c 'echo {}; cat {}' \; 2>/dev/null | head -20 || echo 'no cpu.rt files (probably cgroupv2)'"
section "RT sched_setscheduler test" "sudo -u jeff chrt -f 50 true 2>&1 && echo 'RT scheduling works for jeff' || echo 'RT scheduling FAILS for jeff'"
section "rtkit status" "systemctl --no-pager status rtkit-daemon 2>&1 | head -10"
section "rtkit max RT priority" "cat /proc/sys/kernel/sched_rt_runtime_us 2>/dev/null; echo '---'; busctl get-property org.freedesktop.RealtimeKit1 /org/freedesktop/RealtimeKit1 org.freedesktop.RealtimeKit1 MaxRealtimePriority 2>/dev/null || echo 'busctl not available'"
section "ulimit -r for jeff" "sudo -u jeff bash -c 'ulimit -r' 2>&1"
section "/etc/security/limits.conf or limits.d (audio)" "grep -r audio /etc/security/limits.d/ 2>/dev/null; grep -r audio /etc/security/limits.conf 2>/dev/null; cat /etc/security/limits.d/*audio* 2>/dev/null || echo 'no audio limits files found'"
section "PAM limits loaded" "grep pam_limits /etc/pam.d/* 2>/dev/null | head -5 || echo 'pam_limits not found in pam.d'"
section "SDDM PAM config" "cat /etc/pam.d/sddm 2>/dev/null || echo 'not found'"
section "SDDM-autologin PAM config" "cat /etc/pam.d/sddm-autologin 2>/dev/null || echo 'not found'"
section "login PAM config" "cat /etc/pam.d/login 2>/dev/null || echo 'not found'"
section "PipeWire process limits" "cat /proc/\$(pgrep -x pipewire | head -1)/limits 2>/dev/null | grep -i 'rtprio\|nice\|realtime' || echo 'not found'"
section "Reaper process limits" "cat /proc/\$(pgrep -x .reaper-wrapped | head -1)/limits 2>/dev/null | grep -i 'rtprio\|nice\|realtime' || echo 'not found'"
section "limits.conf content" "cat \$(grep -m1 'conf=' /etc/pam.d/login 2>/dev/null | sed 's/.*conf=//;s/ .*//' ) 2>/dev/null || echo 'could not find limits.conf'"
section "systemd user slice RT limits" "systemctl --user show-property pipewire.service LimitRTPRIO LimitNICE 2>/dev/null || sudo -u jeff SYSTEMD_PAGER='' XDG_RUNTIME_DIR=/run/user/1000 systemctl --user --no-pager show pipewire.service 2>/dev/null | grep -iE 'LimitRT|LimitNICE|Limit.*priority'"
section "journalctl rtkit recent" "journalctl --user -u pipewire -b 2>/dev/null | grep -iE 'rtkit|realtime|sched|priority|denied|error' | tail -20 || echo 'no relevant logs'"
section "journalctl pipewire errors" "sudo -u jeff SYSTEMD_PAGER='' XDG_RUNTIME_DIR=/run/user/1000 journalctl --no-pager --user -u pipewire -b --no-pager 2>/dev/null | tail -30 || echo 'not available'"
section "journalctl pipewire RT messages" "sudo -u jeff SYSTEMD_PAGER='' XDG_RUNTIME_DIR=/run/user/1000 journalctl --no-pager --user -u pipewire -b --no-pager 2>/dev/null | grep -iE 'rt|realtime|sched|prio|RLIMIT' | tail -20 || echo 'no RT-related messages'"
section "PipeWire RT module status" "sudo -u jeff XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus pw-cli info 0 2>/dev/null | grep -iE 'quantum|rate|rt|sched' || echo 'not available'"
section "PipeWire loaded modules" "sudo -u jeff XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus pw-cli ls Module 2>/dev/null || echo 'not available'"
section "PipeWire config (context.modules)" "cat /etc/pipewire/pipewire.conf 2>/dev/null | grep -A5 -i 'module-rt' || find /nix/store -maxdepth 3 -path '*/pipewire/pipewire.conf' 2>/dev/null | head -1 | xargs grep -A5 'module-rt' 2>/dev/null || echo 'not found'"

# === SDDM SESSION STATE ===
section "SDDM state file" "cat /var/lib/sddm/state.conf 2>/dev/null || echo 'not found'"
section "Available xsessions" "ls -la /run/current-system/sw/share/xsessions/ 2>/dev/null || echo 'none'"
section "Available wayland-sessions" "ls -la /run/current-system/sw/share/wayland-sessions/ 2>/dev/null || echo 'none'"
section "SDDM config" "cat /etc/sddm.conf 2>/dev/null || echo 'not found'"

# === USER@ SERVICE LIMITS ===
section "user@1000 LimitRTPRIO and LimitMEMLOCK (configured)" "systemctl show user@1000.service 2>/dev/null | grep -iE 'LimitRT|LimitMEMLOCK'"
section "user@1000 actual process limits" "cat /proc/\$(pgrep -u jeff -x systemd | head -1)/limits 2>/dev/null | grep -i 'rtprio\|nice\|realtime\|memlock' || echo 'not found'"
section "user@.service drop-ins" "SYSTEMD_PAGER='' systemd-delta --no-pager --type=extended 2>/dev/null | grep 'user@' || SYSTEMD_PAGER='' systemctl --no-pager cat user@1000.service 2>/dev/null | head -20 || echo 'not available'"

# === WIFI ===
section "nmcli device status" "nmcli device status 2>&1"
section "nmcli radio" "nmcli radio 2>&1"
section "ip link (wireless)" "ip link show 2>/dev/null | grep -A1 -i wl"
section "lspci | network" "lspci | grep -i network 2>&1"
section "dmesg | wifi/iwlwifi" "dmesg | grep -iE 'iwl|wifi|wlan|wlo|network.*error|firmware.*wifi|rfkill' | tail -30"
section "rfkill list" "rfkill list 2>&1"
section "iwlwifi module exists?" "modinfo iwlwifi 2>&1 | head -5"
section "iwlwifi firmware files" "ls /run/current-system/firmware/iwlwifi-* 2>/dev/null | head -5 || echo 'no iwlwifi firmware found'"
section "modprobe iwlwifi attempt" "modprobe iwlwifi 2>&1; sleep 2; nmcli device status 2>&1"

# === JACK/PIPEWIRE ROUTING ===
section "pw-jack info" "sudo -u jeff XDG_RUNTIME_DIR=/run/user/1000 pw-jack jack_lsp -c 2>/dev/null || echo 'pw-jack not available'"
section "pw-cli list-links" "sudo -u jeff XDG_RUNTIME_DIR=/run/user/1000 pw-cli list-links 2>/dev/null | head -40 || echo 'not available'"
section "pw-dump REAPER nodes" "sudo -u jeff XDG_RUNTIME_DIR=/run/user/1000 pw-dump 2>/dev/null | grep -B2 -A10 -i reaper | head -60 || echo 'not available'"

# === BOOT ENTRY VERIFICATION ===
section "bootctl list (first 30 lines)" "SYSTEMD_PAGER='' bootctl --no-pager list 2>&1 | head -30"

echo ""
echo "Wrote diagnostics to $OUT"
