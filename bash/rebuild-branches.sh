# PITFALL: Profile names should not contain spaces.
# (If they do, deleting them becomes difficult.)

sudo echo ""

git checkout xfce
sudo ./bash/copy.sh
sudo nixos-rebuild switch --profile-name "Xfce___l___l___l___Xfce"

git checkout kde
sudo ./bash/copy.sh
sudo nixos-rebuild switch --profile-name "KDE________________KDE"
