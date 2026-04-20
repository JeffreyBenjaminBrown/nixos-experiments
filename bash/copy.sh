# Run this from the root of the repo.

for i in `cat config/nix-files-to-copy.txt`; do
    cp config/$i /etc/nixos/$i
done

# Ship the custom packages tree so that `monome.nix` (and any future
# modules using ../custom-packages/...) can find their derivations
# when nixos-rebuild reads from /etc/nixos.
rm -rf /etc/nixos/custom-packages
cp -r custom-packages /etc/nixos/custom-packages
