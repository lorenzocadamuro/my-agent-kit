#!/usr/bin/env python3
"""Measures a reply against the ITE style's form rules (mods/my-language/output-styles/ITE.md).

A measure, not a gate: it always exits 0. It prints one finding per line, `<line>: <rule>: <excerpt>`,
and a last line `findings: <h> hard, <s> soft · <k> per 100 words`, k counted on the words in prose.
The word lists are Italian on purpose (.claude/CLAUDE.md).
Usage: python3 ite-check.py [file]  (default: stdin)
"""
import re
import sys

SENTENCE_MAX = 25
PARAGRAPH_MAX = 6
DI_WINDOW = 8

ABBREVIATIONS = {"es.", "ecc.", "cfr.", "pag.", "art."}
GERUND = re.compile(
    r"^\w+(ando|endo)((se|me|te|ce|ve)(ne|lo|la|li|le)"
    r"|lo|la|li|le|ne|ci|si|mi|ti|vi|gli|glielo|gliela|glieli|gliele|gliene)?$",
    re.IGNORECASE,
)
GERUND_STOP = {
    "quando", "comando", "mando", "rimando", "prendo", "rendo", "attendo", "intendo", "dipendo",
    "vendo", "scendo", "stupendo", "tremendo", "orrendo", "dividendo", "reverendo", "nefando", "tendone",
}
PASSIVE_AUX = {"viene", "vengono", "veniva", "venivano", "verrà", "verranno", "venne", "vennero"}
PASSIVE_ADVERBS = {"subito", "già", "sempre", "poi", "anche"}
# Regular endings, and irregular participles as word endings, so prefixed forms count (riscritto, tradotto).
PARTICIPLE = re.compile(
    r"(at|it|ut|scritt|lett|apert|chius|mess|fatt|pres|dett|scelt|risolt|inclus|esclus|corrett|rimoss"
    r"|moss|spent|acces|vist|rott|tolt|aggiunt|richiest|decis|post|dott|condivis|chiest|copert|offert)[oaie]$"
)
DI_WORDS = {"di", "del", "della", "dei", "degli", "delle", "dello"}
# Nouns that may follow "si" without making it a passive "si".
SI_NOUN_STOP = {
    "pagina", "riga", "volta", "nota", "regola", "chiave", "classe", "fase", "funzione",
    "versione", "sezione", "tabella", "cartella",
}
# "esegu..." and "proced..." are support verbs only before one of these links and an action noun.
SUPPORT_LINKS = {"una", "un", "il", "la", "lo", "i", "gli", "le", "a", "al", "alla", "alle", "ai", "agli"}
ACTION_NOUNS = {
    "verifica", "controllo", "analisi", "modifica", "aggiornamento", "correzione", "revisione",
    "valutazione", "installazione", "configurazione", "cancellazione", "rimozione", "creazione", "pulizia",
    "verifiche", "controlli", "modifiche", "aggiornamenti", "correzioni", "revisioni",
    "valutazioni", "installazioni", "configurazioni", "cancellazioni", "rimozioni", "creazioni", "pulizie",
}
# An elided link glued to its noun: "un'analisi", "l’installazione".
ELIDED = re.compile(r"^(un|l|all)['’](\w+)$")
HARD = {"sentence-length", "gerund", "passive", "support-verb", "di-chain"}

CLOSERS = "\"'”’»)]*_"
LIST_ITEM = re.compile(r"^\s*([-*+]|\d+[.)])\s+")


def norm(token):
    """A token without the punctuation around it, lowercased."""
    return re.sub(r"^\W+|\W+$", "", token).lower()


def is_word(token):
    return re.search(r"[^\W_]", token) is not None


def ends_sentence(token):
    bare = token.rstrip(CLOSERS)
    if not bare or bare[-1] not in ".?!":
        return False
    return bare.lstrip("(\"'“‘«").lower() not in ABBREVIATIONS


# Text in double quotes (straight, typographic, guillemets) is cited, not used.
QUOTED = re.compile(r'"[^"\n]*"|“[^”\n]*”|«[^»\n]*»')
QUOTED_TYPOGRAPHIC = re.compile(r'“[^”\n]*”|«[^»\n]*»')


def blank_quote(match):
    """A quoted span as neutral words: its length still counts, no form rule fires on it, and a
    sentence end inside it still ends the sentence."""
    span = match.group(0)
    words = ["x" for t in span.split() if is_word(t)]
    if words and re.search(r"[.?!]\W*$", span):
        words[-1] += "."
    return " " + " ".join(words) + " "


def strip_line(line):
    """The prose part of a line: no inline code, no URL, no quoted text; a link keeps its text."""
    line = re.sub(r"`[^`]*`", " ", line)
    line = re.sub(r"!?\[([^\]]*)\]\([^)]*\)", r"\1", line)
    line = re.sub(r"(https?://|www\.)\S+", " ", line)
    # An odd number of straight quotes (an inch mark, a quote left open) pairs nothing reliably.
    quoted = QUOTED if line.count('"') % 2 == 0 else QUOTED_TYPOGRAPHIC
    return quoted.sub(blank_quote, line)


def units(lines):
    """Paragraphs and list items: (kind, [(line number, token)]). Code, tables and headings are skipped.

    Each line starts a new paragraph, as in a reply, which never wraps a paragraph: so text copied from
    the app, where list markers and headings are lost, keeps its lines apart. An indented line continues
    a list item. A line with a tab is a table row copied from the app.
    """
    out, current, fence = [], None, None
    for n, raw in enumerate(lines, 1):
        stripped = raw.strip()
        marker = re.match(r"^(```+|~~~+)", stripped)
        if fence:
            if marker and stripped.startswith(fence):
                fence = None
            continue
        if marker:
            fence, current = marker.group(1), None
            continue
        if not stripped or stripped.startswith("|") or "\t" in stripped or re.match(r"^#{1,6}(\s|$)", stripped):
            current = None
            continue
        text = re.sub(r"^\s*(>\s*)+", "", raw)
        item = LIST_ITEM.match(text)
        if item:
            current = ("item", [])
            out.append(current)
            text = text[item.end():]
        elif current is None or not raw[:1].isspace():
            current = ("paragraph", [])
            out.append(current)
        current[1].extend((n, t) for t in strip_line(text).split())
    return out


def sentences(tokens):
    """The sentences of a unit; the end of the unit ends the last one."""
    out, current = [], []
    for tok in tokens:
        current.append(tok)
        if ends_sentence(tok[1]):
            out.append(current)
            current = []
    if any(is_word(t) for _, t in current):
        out.append(current)
    return [s for s in out if any(is_word(t) for _, t in s)]


def excerpt(tokens, limit=8):
    text = " ".join(t for _, t in tokens[:limit])
    return text + (" …" if len(tokens) > limit else "")


def check_sentence(sent, find):
    words = [(n, t, norm(t)) for n, t in sent if is_word(t)]
    if len(words) > SENTENCE_MAX:
        find(sent[0][0], "sentence-length", f"{len(words)} words: {excerpt(sent)}")
    di_positions = []
    for i, (n, tok, w) in enumerate(words):
        nxt = words[i + 1][2] if i + 1 < len(words) else ""
        if GERUND.match(w) and w not in GERUND_STOP:
            find(n, "gerund", tok)
        if w in PASSIVE_AUX:
            adverb = nxt.endswith("mente") or nxt in PASSIVE_ADVERBS
            cand = words[i + 2][2] if adverb and i + 2 < len(words) else nxt
            if PARTICIPLE.search(cand) and cand not in PASSIVE_ADVERBS:
                find(n, "passive", " ".join(t for _, t, _ in words[i:i + (3 if adverb else 2)]))
        if w.startswith("effettu"):
            find(n, "support-verb", tok)
        elif w.startswith(("esegu", "proced")):
            after = words[i + 2][2] if i + 2 < len(words) else ""
            elided = ELIDED.match(nxt)
            if (nxt in SUPPORT_LINKS and after in ACTION_NOUNS) or (elided and elided.group(2) in ACTION_NOUNS):
                find(n, "support-verb", " ".join(t for _, t, _ in words[i:i + (2 if elided else 3)]))
        elif w.startswith("provved") and nxt in {"a", "al", "alla"}:
            find(n, "support-verb", f"{tok} {words[i + 1][1]}")
        if w == "si" and nxt and re.search(r"(a|e|ano|ono)$", nxt) and nxt not in SI_NOUN_STOP:
            find(n, "passive-si", f"{tok} {words[i + 1][1]}")
        bare = re.sub(r"^\W+", "", tok).lower()
        if w in DI_WORDS or re.match(r"^dell['’]", bare):
            di_positions.append(i)
    k = 0
    while k + 2 < len(di_positions):
        first, third = di_positions[k], di_positions[k + 2]
        if third - first < DI_WINDOW:
            find(words[first][0], "di-chain", " ".join(t for _, t, _ in words[first:third + 1]))
            k += 3
        else:
            k += 1


def main():
    text = open(sys.argv[1], encoding="utf-8").read() if len(sys.argv) > 1 else sys.stdin.read()
    findings, total = [], 0

    def find(line, rule, what):
        findings.append((line, rule, what))

    for kind, tokens in units(text.splitlines()):
        total += sum(1 for _, t in tokens if is_word(t))
        sents = sentences(tokens)
        for sent in sents:
            check_sentence(sent, find)
        if kind == "paragraph" and len(sents) > PARAGRAPH_MAX:
            find(tokens[0][0], "paragraph-length", f"{len(sents)} sentences: {excerpt(tokens)}")

    sys.stdout.reconfigure(encoding="utf-8")
    for line, rule, what in sorted(findings, key=lambda f: f[0]):
        print(f"{line}: {rule}: {what}")
    hard = sum(1 for f in findings if f[1] in HARD)
    soft = len(findings) - hard
    rate = (hard + soft) * 100 / total if total else 0.0
    print(f"findings: {hard} hard, {soft} soft · {rate:.1f} per 100 words")


if __name__ == "__main__":
    main()
