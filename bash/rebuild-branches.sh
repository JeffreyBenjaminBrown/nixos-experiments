# PITFALL: Profile names should not contain spaces.
# (If they do, deleting them becomes difficult.)

# TODO: As of <2026-03-15 Sun> the only branch I want
# is the 'rt' branch, so I have commented out the others.
# I ought to clean up this code (and the branches) accordingly.

rebuild_branch () {
    local branch="$1"
    local profile_name="$2"
    git checkout "$branch"
    sudo ./bash/copy.sh
    sudo nixos-rebuild switch \
         --keep-failed \
         --profile-name "$profile_name"
}

exec &> ~/code/midi/nix/rebuild-branches.log

# sudo nix-channel --update nixos
cd ~/code/midi/nix/
echo ""

# rebuild_branch "xfce" "Xfce____llllll____Xfce"
# rebuild_branch "kde"  "KDE________________KDE"
rebuild_branch "rt"  "rt___256_________256___rt"

# git push origin kde
# git push origin xfce
git push origin rt
