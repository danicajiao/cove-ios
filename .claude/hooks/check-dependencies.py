#!/usr/bin/env python3
# .claude/hooks/check-dependencies.py
#
# PreToolUse hook — fires before every Write or Edit call.
# Reads the current git branch name to find the active issue number,
# then checks GitHub for any unresolved "Blocked by #N" dependencies.
# Exits 2 (blocking) if any blocking issues are still open.
#
# Caches a passing result in .claude/.dep-cleared-<issue> so the
# GitHub API is only called once per worktree session.

import re
import subprocess
import sys
from pathlib import Path

REPO = "danicajiao/cove-ios"
CACHE_DIR = Path(".claude")


def run(cmd: list[str]) -> str | None:
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        return None


def get_issue_number(branch: str) -> str | None:
    match = re.search(r"/(\d+)-", branch)
    return match.group(1) if match else None


def get_blocking_issues(issue_number: str) -> list[str]:
    body = run(["gh", "issue", "view", issue_number, "--repo", REPO, "--json", "body", "-q", ".body"])
    if not body:
        return []
    return re.findall(r"(?i)blocked by #(\d+)", body)


def is_closed(issue_number: str) -> bool:
    state = run(["gh", "issue", "view", issue_number, "--repo", REPO, "--json", "state", "-q", ".state"])
    return state == "CLOSED"


def main():
    branch = run(["git", "rev-parse", "--abbrev-ref", "HEAD"])
    if not branch:
        sys.exit(0)

    issue_number = get_issue_number(branch)
    if not issue_number:
        sys.exit(0)

    cache_file = CACHE_DIR / f".dep-cleared-{issue_number}"
    if cache_file.exists():
        sys.exit(0)

    blockers = get_blocking_issues(issue_number)
    if not blockers:
        cache_file.touch()
        sys.exit(0)

    open_blockers = [f"#{b}" for b in blockers if not is_closed(b)]

    if open_blockers:
        blockers_str = ", ".join(open_blockers)
        verb = "has" if len(open_blockers) == 1 else "have"
        print(
            f"Dependency gate: Issue #{issue_number} is blocked by {blockers_str}, "
            f"which {verb} not been closed yet. Resolve the dependency before writing code.",
            file=sys.stderr,
        )
        sys.exit(2)

    cache_file.touch()
    sys.exit(0)


if __name__ == "__main__":
    main()
