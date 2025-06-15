# PITFALL: Profile names should not contain spaces.
# (If they do, deleting them becomes difficult.)

sudo nix-channel --update nixos
cd ~/nix/jbb/
echo ""

git checkout xfce
sudo ./bash/copy.sh
sudo nixos-rebuild switch \
     --keep-failed        \
     --profile-name "Xfce___l___l___l___Xfce"

git checkout kde
sudo ./bash/copy.sh
sudo nixos-rebuild switch \
     --keep-failed        \
     --profile-name "KDE________________KDE"

git push origin kde xfce
