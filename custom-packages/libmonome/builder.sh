set -e # Exit the build on any error
unset PATH # because it's initially a non-existant path
for p in $buildInputs; do
  export PATH=$p/bin${PATH:+:}$PATH
done

cd $repo

# I've tried with python2 and python3
python2 ./waf configure
python2 ./waf
sudo python2 ./waf install
