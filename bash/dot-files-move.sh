# Run this from wherever I want them moved to:
# bash /home/jeff/nix/jbb/config/dot-files-move.sh

for i in `cat /home/jeff/nix/jbb/bash/dot-files.txt`; do
    # echo $i
    rsync -avL /home/jeff/$i .
done
