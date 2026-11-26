#!/usr/bin/env bash
# The glossary that /my:learn keeps, at the default data root of the eval's own home
# (the workspace is <home>/cwd), names the concept of the last message "landing slot";
# the re-pitch uses that term. The prompt names no data root, so nothing points to it but the skill.
case "$PWD" in
  */e-*/home/cwd) ;;
  *) echo "setup.sh: unexpected workspace $PWD, the glossary goes only under the eval's home" >&2; exit 1 ;;
esac
mkdir -p ../.my-agent-kit/study
cat > ../.my-agent-kit/study/glossary.md <<'P'
# Glossary

- **landing slot:** the board position where a generated item lands; the code computes it in `place_item()`. Seen in: PR 12 reading.
- **board sync:** the background job that writes the board's state to storage every few seconds. Seen in: PR 12 reading.
P
