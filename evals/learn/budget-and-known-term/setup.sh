#!/usr/bin/env bash
mkdir -p kit-data/study kit-data/reviewers
cat > kit-data/study/glossary.md <<'G'
# Glossario

### Idempotency — idempotenza
- In generale: ripetere la stessa operazione produce lo stesso risultato della prima volta.
- Nel codice: (esempio precedente)
- Visto in: acme/billing#7
G
printf '# Indice studi\n\n| Data | PR | Reviewer | File | Mosse | Commenti studiati |\n| --- | --- | --- | --- | --- | --- |\n' > kit-data/study/README.md
