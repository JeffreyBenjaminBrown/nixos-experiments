# PITFALL: Profile names should not contain spaces.
# (If they do, deleting them becomes difficult.)

rebuild_branch () {
    local branch="$1"
    local profile_name="$2"

    git checkout "$branch"
    sudo ./bash/copy.sh
    sudo nixos-rebuild switch \
         --keep-failed \
         --profile-name "$profile_name"
}

sudo nix-channel --update nixos
cd ~/nix/jbb/
echo ""

rebuild_branch "xfce" "Xfce____llllll____Xfce"
rebuild_branch "kde"  "KDE________________KDE"

git push origin kde
git push origin xfce
