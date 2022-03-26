# The situation

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
  ];
}
```

I then run
```
. venv/bin/activate
pip install -r requirements.txt 2>&1 | tee error.txt
```

and the second of those commands fails with
```
ERROR: Could not install packages due to an OSError: [Errno 30] Read-only file
 system: 'METADATA'
```

The full output + error is [here](./error.txt).

# `METADATA` must refer to Python's `importlib-metadata`.

The only place in the project that I find (via `grep`) the term `METADATA` is in `venv/`, which makes me believe it's referring to Python's `importlib-metadata`, which is one of the `nix-shell`'s `buildInputs`. But if I comment out that build input and start a new `nix-shell`, I get the same error.

# `shell.nix` vs. `requirements.txt`

`importlib-metadata` is also one of the requirements listed in the project's [`requirements.txt`](https://github.com/flancian/agora-server/blob/main/requirements.txt), which would lead me to believe I don't need to include it in `shell.nix` -- except that so is `MarkupSafe`, and if I don't include that in `shell.nix` I get this error about it:
```
Read-only file system: '/nix/store/y3inmdhijqkb4qj36yphj4cbllljhqzz-python3-3.9.6/lib/python3.9/site-packages/MarkupSafe-1.1.1.dist-info'
```
