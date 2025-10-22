#!/usr/bin/env python3
"""Validate staged files do not contain disallowed unicode symbols."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path
from typing import List, Sequence

BANNED_TOKENS: Sequence[str] = (
    "✅",
    "❌",
    "⚠",
    "⚠️",
    "🚀",
    "📁",
    "💾",
    "🔍",
    "⏳",
    "⌛",
    "✨",
    "🎉",
    "🔄",
    "▶",
    "▶️",
    "→",
    "⇒",
    "➜",
    "●",
    "★",
    "♦",
    "■",
    "✓",
    "✗",
    "☑",
    "☒",
    "⚡",
    "⛔",
    "ℹ",
    "ℹ️",
    "💡",
    "📢",
    "📄",
    "👤",
    "👥",
    "╔",
    "╚",
    "╦",
    "╩",
    "╠",
    "╣",
    "╬",
    "═",
    "║",
)

SCRIPT_EXTENSIONS = {".sh", ".py", ".bash", ".ps1"}
SCRIPT_BASENAMES = {"Vagrantfile", "bootstrap.sh"}
SCRIPT_DIRECTORIES = {"bin", "scripts", "infrastructure", "config"}


def _read_staged_file(path: str) -> str:
    try:
        result = subprocess.run(
            ["git", "show", f":{path}"],
            check=True,
            capture_output=True,
            text=True,
            encoding="utf-8",
        )
    except subprocess.CalledProcessError as exc:  # pragma: no cover - git handles messaging
        raise RuntimeError(f"Unable to read staged contents for {path}") from exc
    return result.stdout


def _find_offenders(text: str) -> List[tuple[int, str]]:
    offenders: List[tuple[int, str]] = []
    for token in BANNED_TOKENS:
        start = 0
        while True:
            index = text.find(token, start)
            if index == -1:
                break
            line_number = text.count("\n", 0, index) + 1
            offenders.append((line_number, token))
            start = index + len(token)
    return offenders


def main(argv: Sequence[str]) -> int:
    staged_paths = list(argv)
    if not staged_paths:
        return 0

    failures: List[str] = []
    for path in staged_paths:
        if path == "infrastructure/git/policy/check_disallowed_unicode.py":
            # The policy definition itself must list the banned tokens.
            continue
        path_obj = Path(path)
        if (
            path_obj.suffix not in SCRIPT_EXTENSIONS
            and path_obj.name not in SCRIPT_BASENAMES
            and path_obj.parts[0] not in SCRIPT_DIRECTORIES
        ):
            continue
        try:
            content = _read_staged_file(path)
        except RuntimeError:
            continue
        if "\x00" in content:
            continue
        offenders = _find_offenders(content)
        if offenders:
            report_lines = ", ".join(
                f"line {line}: '{token}'" for line, token in sorted(offenders)
            )
            failures.append(f"  - {path}: {report_lines}")

    if failures:
        sys.stderr.write("[ERROR] Disallowed symbols detected in staged files:\n")
        for line in failures:
            sys.stderr.write(f"{line}\n")
        sys.stderr.write(
            "[INFO] Replace emojis or decorative unicode with the approved log format.\n"
        )
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
