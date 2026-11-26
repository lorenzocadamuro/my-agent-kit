## <id> · <skill> · open

- When: <date time>
- Kit: <`version` in ${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json, read when the writing skill started (the version the session follows), or "unknown">
- Where: <repo> · <branch or PR> · session <id if known>
- What happened: <one to three sentences, concrete>
- Why it was a problem: <what it cost the user: time lost, a wrong decision, a question asked again>
- Missing question: <the question or directive that, asked or applied at the start, would have avoided it, or "unknown">
- Expected: <what the kit should have done>
- Suspected cause: <skill step, principle, template, project profile, or "unknown">
- File: <the kit file the problem is about; optional, left out when not known>
- Leaves read: <the rule files the skill had loaded when it happened; optional, left out when not known>
- Signal: <decision reversed | question re-asked | free answer | question dismissed | reviewer correction | rework | surprise gate | review found unplanned issue | unplanned stop | other>
<!-- Zero or more lines, appended by `/my:note` from signals, after the yes, never by hand:
- Evidence: <date> · <skill> · <what happened> · <source> · kit <the signal's version, left out when the signal has none> -->
