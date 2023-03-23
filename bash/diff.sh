for i in `cat config/nix-files-to-copy.txt`; do
    echo ""
    echo "----"$i":"
    diff -u config/$i /etc/nixos/$i | diff-so-fancy
done

echo ""
