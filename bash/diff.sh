for i in `cat config/files-to-copy.txt`; do
    echo ""
    echo "----"$i":"
    diff -u /etc/nixos/$i config/$i | diff-so-fancy
done

echo ""
echo "These file are at left, /etc/nixos/* files at right."
