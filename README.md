# Super Web Designer

Ένα plugin για το Claude Code με όλα τα design skills της GIM Agency, που ενημερώνεται μόνο του.

| Skill | Τι κάνει | Πηγή |
|---|---|---|
| `impeccable` | audit, critique, polish, typeset, layout, animate, harden… | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) · Apache-2.0 |
| `emil-design-eng` | Λεπτομέρειες UI, φιλοσοφία design engineering | [emilkowalski/skill](https://github.com/emilkowalski/skill) · MIT |
| `animate` · `review-animations` · `improve-animations` · `find-animation-opportunities` · `animation-vocabulary` | Κίνηση: υλοποίηση, review, audit, ορολογία | emilkowalski/skill · MIT |
| `design-taste-frontend` | Anti-slop frontend, landing pages | [leonxlnx/taste-skill](https://github.com/leonxlnx/taste-skill) · MIT |
| `redesign-existing-projects` | Αναβάθμιση υπάρχοντος site χωρίς να σπάσει | leonxlnx/taste-skill · MIT |
| `visual-check` | Screenshots desktop + κινητό με Playwright· αποτυγχάνει σε σφάλμα ή οριζόντιο scroll | GIM Agency |

Οι εκδόσεις upstream είναι στο `UPSTREAM.lock`. Κάθε skill κρατά το LICENSE της πηγής του.

## Εγκατάσταση

**Claude Code τοπικά (terminal, Desktop, VS Code)**
```
/plugin marketplace add gim-team/super-web-designer
/plugin install super-web-designer@gim-design
```
Μετά: `/plugin` → Marketplaces → `gim-design` → **Enable auto-update**. Είναι κλειστό by default
για marketplaces τρίτων. Τα skills καλούνται ως `/super-web-designer:impeccable` κ.λπ.

**Claude Code στο cloud (claude.ai/code)**: τα cloud sessions δεν εγκαθιστούν plugins. Βάλε
στο **Setup script** του environment:
```bash
curl -fsSL https://raw.githubusercontent.com/gim-team/super-web-designer/main/scripts/install-cloud.sh | bash
```
Τα skills μπαίνουν στο `~/.claude/skills`. Το environment κρατά cache έως ~7 ημέρες, οπότε μια
νέα έκδοση φτάνει μέσα σε μία εβδομάδα, ή αμέσως αν αλλάξεις κάτι στο setup script.

**claude.ai (chat / Cowork)**: ανέβασε κάθε φάκελο του `plugins/super-web-designer/skills/`
ως zip από Settings → Capabilities → Skills. Εκεί δεν υπάρχει auto-update.

## Auto-update

`.github/workflows/sync-upstream.yml` → κάθε Δευτέρα τραβάει τα upstream repos
(`scripts/sync-upstream.sh`). Αν άλλαξε κάτι, κάνει commit και ανεβάζει το patch version
στο `plugin.json`, και οι εγκαταστάσεις το παίρνουν στο επόμενο session. Χειροκίνητα:
Actions → Sync upstream skills → Run workflow.

Νέο upstream skill → πρόσθεσε μια γραμμή στο `UPSTREAM` του `sync-upstream.sh`.

## Κανόνες project

Τα skills έχουν δικές τους προτιμήσεις (π.χ. Tailwind, React, «όχι Inter»). Σε κάθε project
με δικό του stack ή brand, γράψε στο `CLAUDE.md` ότι οι κανόνες του project υπερισχύουν.
