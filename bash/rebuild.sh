echo "Some of these commands need sudo."
sudo echo "Apparently you can sudo."

git checkout xfce
# PITFALL: Profile names should not contain spaces.
# (If they do, deleting them becomes difficult.)
sudo nixos-rebuild switch --profile-name "Xfce___l___l___l___Xfce"

git checkout kde
# PITFALL: Profile names should not contain spaces.
# (If they do, deleting them becomes difficult.)
sudo nixos-rebuild switch --profile-name "KDE________________KDE"
