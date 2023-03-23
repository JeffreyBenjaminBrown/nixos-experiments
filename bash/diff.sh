for i in `cat config/nix-files-to-copy.txt`; do
    echo ""
    echo "----"$i":"
    diff -u /etc/nixos/$i config/$i | diff-so-fancy
done

echo ""
