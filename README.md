# tsk

A command-line task manager with a `mail`-like interface.

Tasks are stored as plain CSV — greppable, scriptable, no lock-in.

## Installation

```sh
git clone https://github.com/cristianrz/tsk.git
cd tsk
make
sudo make install
```

## Usage

```sh
tsk        # interactive mode
tsk p      # print task list
tsk a      # add a task
tsk d ID   # mark a task done
```

See `man tsk` after installing, or read [`tsk.md`](https://github.com/cristianrz/tsk/blob/master/tsk.md) online.

## Storage

| File | Purpose |
|---|---|
| `~/.cache/tsk/pending.csv` | Open tasks |
| `~/.cache/tsk/done.log` | Completed tasks |
| `~/.cache/tsk/backup.csv` | Pre-mutation backup |

## License

BSD 3-Clause
