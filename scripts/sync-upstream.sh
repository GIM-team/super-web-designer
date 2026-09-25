#!/usr/bin/env bash
# Τραβάει τις τελευταίες εκδόσεις των skills από τα upstream repos, αντικαθιστά τα
# αντίγραφα στο plugin, και ανεβάζει patch version αν άλλαξε κάτι.
# Τρέχει από το .github/workflows/sync-upstream.yml (εβδομαδιαία) ή με το χέρι.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SK="$ROOT/plugins/super-web-designer/skills"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# repo | φάκελος μέσα στο repo | όνομα στο plugin | αρχείο άδειας
UPSTREAM=(
  "pbakaus/impeccable|plugin/skills/impeccable|impeccable|LICENSE"
  "emilkowalski/skill|skills/emil-design-eng|emil-design-eng|LICENSE"
  "emilkowalski/skill|skills/animate|animate|LICENSE"
  "emilkowalski/skill|skills/review-animations|review-animations|LICENSE"
  "emilkowalski/skill|skills/improve-animations|improve-animations|LICENSE"
  "emilkowalski/skill|skills/find-animation-opportunities|find-animation-opportunities|LICENSE"
  "emilkowalski/skill|skills/animation-vocabulary|animation-vocabulary|LICENSE"
  "leonxlnx/taste-skill|skills/taste-skill|design-taste-frontend|LICENSE"
  "leonxlnx/taste-skill|skills/redesign-skill|redesign-existing-projects|LICENSE"
)

: > "$TMP/sources"
for line in "${UPSTREAM[@]}"; do
  IFS='|' read -r repo path name lic <<<"$line"
  dir="$TMP/${repo//\//__}"
  if [ ! -d "$dir" ]; then
    git clone -q --depth 1 "https://github.com/$repo" "$dir"
    echo "$repo $(git -C "$dir" rev-parse --short HEAD)" >> "$TMP/sources"
  fi
  [ -f "$dir/$path/SKILL.md" ] || { echo "ΣΦΑΛΜΑ: $repo/$path/SKILL.md λείπει (άλλαξε η δομή upstream)" >&2; exit 1; }
  rm -rf "$SK/$name"
  cp -r "$dir/$path" "$SK/$name"
  cp "$dir/$lic" "$SK/$name/LICENSE"
  [ -f "$dir/NOTICE.md" ] && cp "$dir/NOTICE.md" "$SK/$name/NOTICE.md"
  # Το name: του SKILL.md πρέπει να ταιριάζει με τον φάκελο
  got=$(sed -n 's/^name:[[:space:]]*//p' "$SK/$name/SKILL.md" | head -1)
  [ "$got" = "$name" ] || { echo "ΣΦΑΛΜΑ: $name/SKILL.md έχει name: $got" >&2; exit 1; }
done
sort -u "$TMP/sources" > "$ROOT/UPSTREAM.lock"

cd "$ROOT"
if git diff --quiet -- plugins UPSTREAM.lock && [ -z "$(git ls-files --others --exclude-standard plugins)" ]; then
  echo "Καμία αλλαγή upstream."; exit 0
fi
# patch bump στο plugin.json (το auto-update των χρηστών το βλέπει από εδώ)
PJ=plugins/super-web-designer/.claude-plugin/plugin.json
node -e '
const f=process.argv[1], fs=require("fs"), j=JSON.parse(fs.readFileSync(f));
const v=j.version.split(".").map(Number); v[2]++; j.version=v.join(".");
fs.writeFileSync(f, JSON.stringify(j,null,2)+"\n"); console.log("version →", j.version);' "$PJ"
