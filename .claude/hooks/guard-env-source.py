#!/usr/bin/env python3
"""PreToolUse(Bash) guard: block shell-sourcing of a .env file.

Why this exists
---------------
`source .env` (equivalently `. .env`, or the `set -a; . .env; set +a` idiom)
makes the shell *execute* the file instead of parsing it. A secret whose value
contains a shell metacharacter -- most commonly `&` in a URL that is itself the
bearer credential, or whitespace -- is then run as shell: `&` backgrounds a job
and the shell's job-control echoes the full command line (secret included) into
the session log. The credential leaks and must be rotated.

The safe path already exists in every scaffolded project: load `.env` with
python-dotenv, which parses values as data and never echoes them.

Contract
--------
Reads the PreToolUse payload as JSON on stdin; the command is at
`tool_input.command`. Exit 2 blocks the call and shows stderr to the agent.
Any other exit (including a parse failure) lets the call through -- the guard
fails open so it can never wedge a session.
"""
import json
import re
import sys

# A `source`/`.` builtin, in command position (start of line or right after a
# shell separator), whose target path contains `.env`. The command-position
# anchor is what keeps `find . -name .env`, `grep source .env`, and
# `source .venv/bin/activate` from tripping the guard.
_SOURCE_DOTENV = re.compile(
    r"(?:^|[;&|({])\s*(?:source|\.)\s+[^;&|]*\.env\b",
    re.IGNORECASE | re.MULTILINE,
)

_MESSAGE = (
    "BLOCKED: refusing to shell-source a .env file.\n"
    "\n"
    "Sourcing executes the file as shell code. A secret value containing '&' or\n"
    "spaces (e.g. a URL that is itself the credential) gets run as a background\n"
    "job and echoed into the session log -- leaking the secret, which then has\n"
    "to be rotated.\n"
    "\n"
    "Load .env via python-dotenv instead (parses values as data, never echoes):\n"
    "  one-off:  python -c 'from dotenv import dotenv_values; print(dotenv_values()[\"KEY\"])'\n"
    "  in code:  from dotenv import load_dotenv; load_dotenv()\n"
)


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0  # can't parse -- fail open, never wedge the session
    command = (payload.get("tool_input") or {}).get("command", "")
    if _SOURCE_DOTENV.search(command):
        sys.stderr.write(_MESSAGE)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
