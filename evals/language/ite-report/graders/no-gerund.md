---
type: regex
# ite-check.py's GERUND regex and GERUND_STOP list, as one JavaScript pattern on whole words.
pattern: '(?<![a-zà-ÿ])(?!(?:quando|comando|mando|rimando|prendo|rendo|attendo|intendo|dipendo|vendo|scendo|stupendo|tremendo|orrendo|dividendo|reverendo|nefando|tendone)(?![a-zà-ÿ]))[a-zà-ÿ]+(?:ando|endo)(?:(?:se|me|te|ce|ve)(?:ne|lo|la|li|le)|lo|la|li|le|ne|ci|si|mi|ti|vi|gli|glielo|gliela|glieli|gliele|gliene)?(?![a-zà-ÿ])'
flags: i
match: not_contains
weight: 1
---
