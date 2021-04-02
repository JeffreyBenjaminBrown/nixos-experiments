for i in `cat list-of-nix-files-to-copy.txt`; do
    echo ""
    echo "----"$i":"
    diff -u /etc/nixos/$i $i | diff-so-fancy
done

echo ""
echo "These file are at left, /etc/nixos/* files at right."

#diff configuration.nix /etc/nixos/configuration.nix
#diff emacs.nix /etc/nixos/emacs.nix
#diff packages.nix /etc/nixos/packages.nix
