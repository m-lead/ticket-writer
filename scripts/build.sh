#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
CLAUDE_STAGE="$DIST_DIR/claude-plugin/ticket-writer"
GPT_STAGE="$DIST_DIR/chatgpt-skill/ticket-writer"

rm -rf "$DIST_DIR"
mkdir -p "$CLAUDE_STAGE" "$GPT_STAGE/references/skills"

# Claude uses the source layout unchanged.
cp -R "$ROOT_DIR/.claude-plugin" "$CLAUDE_STAGE/.claude-plugin"
cp -R "$ROOT_DIR/skills" "$CLAUDE_STAGE/skills"
cp "$ROOT_DIR/README.md" "$CLAUDE_STAGE/README.md"

# ChatGPT uses one entrypoint plus transformed, shared source references.
cp "$ROOT_DIR/openai/ticket-writer/SKILL.md" "$GPT_STAGE/SKILL.md"
mkdir -p "$GPT_STAGE/agents" "$GPT_STAGE/references/shared"
cp "$ROOT_DIR/openai/ticket-writer/agents/openai.yaml" "$GPT_STAGE/agents/openai.yaml"
cp "$ROOT_DIR/skills/shared/gtp-conventions.md" "$GPT_STAGE/references/shared/gtp-conventions.md"
cp -R "$ROOT_DIR/skills/." "$GPT_STAGE/references/skills/"
rm -rf "$GPT_STAGE/references/skills/shared"

# Claude-specific command metadata and command names are not part of ChatGPT Skills.
ROOT_DIR="$ROOT_DIR" GPT_STAGE="$GPT_STAGE" python3 - <<'PY'
from pathlib import Path
import os
import re

root = Path(os.environ["ROOT_DIR"])
stage = Path(os.environ["GPT_STAGE"])
for path in stage.rglob("*.md"):
    text = path.read_text(encoding="utf-8")
    if path.name == "SKILL.md" and "references/skills" in str(path):
        text = re.sub(r"^---\n.*?\n---\n", "", text, count=1, flags=re.S)
        text = re.sub(r"^# /ticket-writer:([^\n]+)$", r"# Ticket Writer: \1", text, flags=re.M)
    text = text.replace("/ticket-writer:", "@ticket-writer ")
    path.write_text(text, encoding="utf-8")
PY

(
  cd "$DIST_DIR/claude-plugin"
  zip -qr ../ticket-writer-claude-plugin.zip ticket-writer
)
(
  cd "$DIST_DIR/chatgpt-skill"
  zip -qr ../ticket-writer-chatgpt-skill.zip ticket-writer
)

echo "Built:"
echo "  $DIST_DIR/ticket-writer-claude-plugin.zip"
echo "  $DIST_DIR/ticket-writer-chatgpt-skill.zip"

