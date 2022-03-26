I'm trying to run [agora-server](https://github.com/flancian/agora-server). The README for that project says to do this:
```
python3 -m venv venv
. venv/bin/activate
pip install -r requirements.txt
```

The [NixOS wiki page on Python](https://nixos.wiki/wiki/Python) says that's kosher -- it includes a nearly-identical passage:
```
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Those two passages only differ in that the second creates a folder called `.venv` instead of `venv`, and that the second uses python instead of python3. So I ran the first, except teeing stdout and stderr to a file because it's a few pages long:
```
python3 -m venv venv
. venv/bin/activate
pip install -r requirements.txt 2>&1 | tee error.txt
```

That produces [errors](https://github.com/JeffreyBenjaminBrown/nixos-experiments/tree/agora-problems/agora-problems/error-without-shell.txt). They involve the term "uWSGI", which I didn't think I'd installed so I installed [uwsgi, the package with the most similar name I could find](https://search.nixos.org/packages?channel=21.11&from=0&size=50&sort=relevance&type=packages&query=uwsgi). I then created a `shell.nix` file containing the following:
```
with import <nixpkgs> { };
mkShell {
  buildInputs = [
    uwsgi
  ];
}
(venv)
```

ran `nix-shell`, and tried again. That created [similar but not identical errors](https://github.com/JeffreyBenjaminBrown/nixos-experiments/tree/agora-problems/agora-problems/error-without-shell.txt).

The errors say to "Check the logs for full command output" but I don't know what logs it's talking about.
