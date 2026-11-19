#!/usr/bin/env python3
"""Stay on the current workspace when you quit an app / close its last window.

macOS reacts to an app quitting (Cmd+Q) or closing its last window by activating
some other app, and AeroSpace follows that focus to the other app's workspace.
This watcher listens to AeroSpace's event stream and undoes that jump: if the
workspace changed *because the window you were focused on disappeared*, it
switches straight back to the workspace you were on (even if it is now empty).

A normal workspace switch (alt-<letter>, alt-tab, ...) is left alone, because
the window you were on still exists.

Started from after-startup-command in ~/.aerospace.toml. Single instance.
"""
import fcntl
import json
import os
import subprocess
import sys
import time

AEROSPACE = "/opt/homebrew/bin/aerospace"
LOCK = os.path.expanduser("~/Library/Caches/aerospace-stay-on-workspace.lock")


def window_exists(wid):
    out = subprocess.run(
        [AEROSPACE, "list-windows", "--all", "--format", "%{window-id}"],
        capture_output=True, text=True,
    ).stdout.split()
    return str(wid) in out


def aerospace_running():
    return subprocess.run(["pgrep", "-x", "AeroSpace"], capture_output=True).returncode == 0


def watch():
    # Last focused window per workspace (None = workspace was empty/no window).
    focused_in = {}
    proc = subprocess.Popen(
        [AEROSPACE, "subscribe", "focus-changed", "focused-workspace-changed"],
        stdout=subprocess.PIPE, text=True,
    )
    for line in proc.stdout:
        try:
            ev = json.loads(line)
        except ValueError:
            continue

        if ev.get("_event") == "focus-changed":
            ws = ev.get("workspace")
            if ws:
                focused_in[ws] = ev.get("windowId")
            continue

        if ev.get("_event") != "focused-workspace-changed":
            continue
        prev, cur = ev.get("prevWorkspace"), ev.get("workspace")
        if not prev or prev == cur:
            continue
        wid = focused_in.get(prev)
        if wid is None:
            continue  # you were on an empty workspace and switched away yourself
        # Give AeroSpace a moment to drop the dead window from its tree.
        gone = not window_exists(wid)
        if not gone:
            time.sleep(0.25)
            gone = not window_exists(wid)
        if gone:
            focused_in[prev] = None
            subprocess.run([AEROSPACE, "workspace", prev], capture_output=True)
    proc.wait()


def main():
    os.makedirs(os.path.dirname(LOCK), exist_ok=True)
    lock = open(LOCK, "w")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        sys.exit(0)  # already running

    while aerospace_running():
        try:
            watch()
        except Exception:
            pass
        time.sleep(2)  # subscription dropped; reconnect while AeroSpace is up


if __name__ == "__main__":
    main()
