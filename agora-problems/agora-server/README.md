To run [agora-server](https://github.com/flancian/agora-server)
I've been starting a `nix-shell` from the following `shell.nix` file:
```
with import <nixpkgs> { };
mkShell {
  buildInputs = [
    memcached libmemcached
    ncurses
    uwsgi
    zlib
    python39Packages.setuptools
    python39Packages.markupsafe
    python39Packages.importlib-metadata
    python39Packages.flask
  ];
}
```

I then run
```
. venv/bin/activate
pip install -r requirements.txt 2>&1 | tee error.txt
```

and the process fails with
```
ERROR: Could not install packages due to an OSError: [Errno 30] Read-only file
 system: 'METADATA'
```

The full error can be found [here](./error.txt).

The only place in the project that I'm finding (via `grep`) the term `METADATA` is in `venv/`, which makes me believe it's referring to Python's `importlib-metadata`, which is one of the `nix-shell`'s `buildInputs`. But if I comment out that build input and start a new `nix-shell`, I get the same error.
