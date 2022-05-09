for i in `cat config/nix-files-to-copy.txt`; do
    echo ""
    echo "----"$i":"
    diff -u /etc/nixos/$i config/$i # | diff-so-fancy
      # diff-so-fancy is not available even after this minimal install,
      # let alone before.
done

echo ""
