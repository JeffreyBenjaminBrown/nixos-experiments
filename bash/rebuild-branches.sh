# PITFALL: Profile names should not contain spaces.
# (If they do, deleting them becomes difficult.)
#
# After this script finishes the system has NOT switched to either
# profile. To activate one, run:
#   bash/my-switch-config.sh xfce
#   bash/my-switch-config.sh kde

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
    sudo nixos-rebuild switch \
         --keep-failed \
         --cores 2 \
         --max-jobs 1 \
         --profile-name "$profile_name"
}

exec &> ~/code/midi/nix/rebuild-branches.log

sudo nix-channel --update nixos
cd ~/code/midi/nix/
echo ""

rebuild_branch "xfce" "xfce"
rebuild_branch "kde"  "kde"
