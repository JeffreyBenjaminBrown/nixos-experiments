set -e # Exit the build on any error
unset PATH # because it's initially a non-existant path
for p in $buildInputs; do
  export PATH=$p/bin${PATH:+:}$PATH
done

tar -xf $src

# There should be exactly one folder here now. Enter it.
for d in *; do
  if [ -d "$d" ]; then
    cd "$d"
    break
  fi
done

./configure --prefix=$out
make
make install
