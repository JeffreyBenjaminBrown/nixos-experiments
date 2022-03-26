Now it does stuff! But it issues a lot of warnings, and then gets stuck asking for credentials for `anagora.org`.

# Details

Here's how I start it:

```
cd ~/agora
nix-shell
. venv/bin/activate

cd ~/agora-bridge # I seem to have to do this so that `this_path` is defined correctly in `~/agora-bridge/pull.py`
~/agora/bin/pull
```

After doing that, it issues a lot of warnings about gardens already existing, thenhangs asking me for credentials for `git.anagora.org`. If I just press enter a few times it returns to what looks like checking peoples' gardens:
```
...
WARNING:pull:/home/jeff/agora/garden/flancia.org exists, won't clone to it.
WARNING:pull:/home/jeff/agora/garden/maya exists, won't clone to it.
WARNING:pull:/home/jeff/agora/garden/Jayu exists, won't clone to it.
WARNING:pull:/home/jeff/agora/garden/darlim doesn't exist, couldn't pull to it.
Username for 'https://git.anagora.org': Username for 'https://git.anagora.org':
Password for 'https://git.anagora.org': Password for 'https://git.anagora.org':
WARNING:pull:/home/jeff/agora/garden/melanocarpa exists, won't clone to it.
WARNING:pull:/home/jeff/agora/garden/evan doesn't exist, couldn't pull to it.
WARNING:pull:/home/jeff/agora/garden/darlim doesn't exist, couldn't pull to it.
WARNING:pull:/home/jeff/agora/garden/protopian doesn't exist, couldn't pull to it.
WARNING:pull:/home/jeff/agora/garden/evan doesn't exist, couldn't pull to it.
...
```

But then it eventually gets stuck at the `anagora.org` login again.
