#!/usr/bin/env bash
# Για το setup script του cloud environment στο claude.ai/code:
#   curl -fsSL https://raw.githubusercontent.com/gim-team/super-web-designer/main/scripts/install-cloud.sh | bash
# Αντιγράφει τα skills στο ~/.claude/skills του container (τα cloud sessions δεν εγκαθιστούν plugins).
set -euo pipefail
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
git clone -q --depth 1 https://github.com/gim-team/super-web-designer "$tmp/swd"
mkdir -p "$HOME/.claude/skills"
for d in "$tmp"/swd/plugins/super-web-designer/skills/*/; do
  n=$(basename "$d"); rm -rf "$HOME/.claude/skills/$n"; cp -r "$d" "$HOME/.claude/skills/$n"
done
echo "super-web-designer: $(ls "$tmp"/swd/plugins/super-web-designer/skills | wc -l) skills → ~/.claude/skills"
