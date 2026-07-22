#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"$ROOT_DIR/scripts/build.sh" >/dev/null

require_file() {
  [[ -f "$1" ]] || { echo "Missing required file: $1" >&2; exit 1; }
}

require_file "$ROOT_DIR/dist/ticket-writer-claude-plugin.zip"
require_file "$ROOT_DIR/dist/ticket-writer-chatgpt-skill.zip"
require_file "$ROOT_DIR/dist/claude-plugin/ticket-writer/.claude-plugin/plugin.json"
require_file "$ROOT_DIR/dist/chatgpt-skill/ticket-writer/SKILL.md"
require_file "$ROOT_DIR/dist/chatgpt-skill/ticket-writer/agents/openai.yaml"
require_file "$ROOT_DIR/dist/chatgpt-skill/ticket-writer/references/shared/gtp-conventions.md"

python3 - "$ROOT_DIR" <<'PY'
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
expected = sorted(p.parent.name for p in (root / "skills").glob("*/SKILL.md"))
actual = sorted(p.parent.name for p in (root / "dist/chatgpt-skill/ticket-writer/references/skills").glob("*/SKILL.md"))
if actual != expected:
    raise SystemExit(f"GPT skill scenarios differ: expected {expected}, got {actual}")

for path in (root / "dist/chatgpt-skill/ticket-writer/references/skills").glob("*/SKILL.md"):
    content = path.read_text(encoding="utf-8")
    if content.startswith("---"):
        raise SystemExit(f"Claude frontmatter was not removed: {path}")
    if "/ticket-writer:" in content:
        raise SystemExit(f"Claude slash command remains: {path}")
    if not re.search(r"^# Ticket Writer:", content, re.M):
        raise SystemExit(f"Missing GPT title: {path}")

entry = (root / "dist/chatgpt-skill/ticket-writer/SKILL.md").read_text(encoding="utf-8")
if not re.match(r"^---\nname: ticket-writer\n", entry):
    raise SystemExit("Invalid ChatGPT Skill frontmatter")

for path in (root / "dist/chatgpt-skill/ticket-writer").rglob("*.md"):
    if "/ticket-writer:" in path.read_text(encoding="utf-8"):
        raise SystemExit(f"Claude slash command remains in GPT artifact: {path}")
PY

diff -qr "$ROOT_DIR/.claude-plugin" "$ROOT_DIR/dist/claude-plugin/ticket-writer/.claude-plugin" >/dev/null
diff -qr "$ROOT_DIR/skills" "$ROOT_DIR/dist/claude-plugin/ticket-writer/skills" >/dev/null
unzip -t "$ROOT_DIR/dist/ticket-writer-claude-plugin.zip" >/dev/null
unzip -t "$ROOT_DIR/dist/ticket-writer-chatgpt-skill.zip" >/dev/null
echo "Artifact verification passed"
