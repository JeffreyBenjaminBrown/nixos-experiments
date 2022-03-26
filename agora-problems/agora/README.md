Now I don't know if it's working or not. My two questions in brief are:

(1) How can I log into `anagora.org`? Automatically?
(2) Should I be getting a warning about each garden, repeatedly?

# Details

```
cd ~/agora
nix-shell
. venv/bin/activate

# Seems dumb to run `gh auth login` and still do this,
# but the other way definitely failed; let's see if this does.
# ssh-agent bash
# ssh-add

cd ~/agora-bridge # I seem to have to do this so that the
~/agora/bin/pull
```

If I do that, it hangs asking me for credentials for `git.anagora.org`. If I just press enter a few times it returns to what looks like checking peoples' gardens:
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

But then it eventually cycles into the `anagora.org` login again.
