# Run this from the root of the repo.

for i in `cat config/files-to-copy.txt`; do
    cp config/$i /etc/nixos/$i
done
