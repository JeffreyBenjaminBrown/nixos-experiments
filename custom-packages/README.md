The easiest way to build any of these packages is by running `nix-build` from its root.

The `hello*` projects build. `hello-fetch` even fetches its source code before building.

`libmonome` doesn't work:
```
Error: Cannot unpack waf lib into /nix/store/dk3pnwg7z9q14f4yj35y2kaqdmahnhhh-libmonome/.waf-2.0.17-6b308e91b5eb321c61bd5469cd6d43aa
Move waf in a writable directory
```
