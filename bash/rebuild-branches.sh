# PITFALL: Profile names should not contain spaces.
# (If they do, deleting them becomes difficult.)
#
# After this script finishes the system has NOT switched to either
# profile. To activate one, run:
#   bash/my-switch-config.sh xfce
#   bash/my-switch-config.sh kde

echo "NOTE: Updating KDE is disabled."

rebuild_branch () {
    local branch="$1"
    local profile_name="$2"
    git checkout "$branch"
    sudo ./bash/copy.sh
    # --cores / --max-jobs limit CPU use so the laptop doesn't
    # overheat during long builds (esp. the RT kernel). These are
    # the only knobs nix honors for thermal politeness — nice/ionice
    # on nixos-rebuild don't propagate to nix-daemon, which does the
    # actual work.
    sudo nixos-rebuild build \
         --keep-failed \
         --cores 2 \
         --max-jobs 1 \
         --profile-name "$profile_name"
}

# Ask BEFORE redirecting stdout to the log, so the prompt is visible.
# The RT kernel is separately pinned in audio-configuration.nix, so a channel
# update does not move it.  bash/update-kernel-pin.sh updates that pin.
read -r -p "Update nix channel? [y/N] " reply
case "$reply" in
    [yY]|[yY][eE][sS]) update_channel=1 ;;
    *)                 update_channel=0 ;;
esac

exec &> ~/nix/jbb/rebuild-branches.log

if [[ "$update_channel" == 1 ]]; then
    sudo nix-channel --update nixos
fi

rebuild_branch "xfce" "xfce"
# rebuild_branch "kde"  "kde"
