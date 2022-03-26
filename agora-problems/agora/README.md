More progress! Now it's pulled a lot of gardens -- 39, specifically -- but it runs into this problem:

```
Process worker_process_1:
Traceback (most recent call last):
  File "/nix/store/y3inmdhijqkb4qj36yphj4cbllljhqzz-python3-3.9.6/lib/python3.9/multiprocessing/process.py", line 315, in _bootstrap
    self.run()
  File "/nix/store/y3inmdhijqkb4qj36yphj4cbllljhqzz-python3-3.9.6/lib/python3.9/multiprocessing/process.py", line 108, in run
    self._target(*self._args, **self._kwargs)
  File "/home/jeff/agora-bridge/pull.py", line 91, in worker
    task[0](*task[1:])
  File "/home/jeff/agora-bridge/pull.py", line 84, in fedwiki_import
    output = subprocess.run([f"{this_path}/fedwiki.sh", url, path], capture_output=True)
  File "/nix/store/y3inmdhijqkb4qj36yphj4cbllljhqzz-python3-3.9.6/lib/python3.9/subprocess.py", line 505, in run
    with Popen(*popenargs, **kwargs) as process:
  File "/nix/store/y3inmdhijqkb4qj36yphj4cbllljhqzz-python3-3.9.6/lib/python3.9/subprocess.py", line 951, in __init__
    self._execute_child(args, executable, preexec_fn, close_fds,
  File "/nix/store/y3inmdhijqkb4qj36yphj4cbllljhqzz-python3-3.9.6/lib/python3.9/subprocess.py", line 1821, in _execute_child
    raise child_exception_type(errno_num, err_msg, err_filename)
FileNotFoundError: [Errno 2] No such file or directory: '/home/jeff/code/graphs/agora-repos/agora/fedwiki.sh'
```
