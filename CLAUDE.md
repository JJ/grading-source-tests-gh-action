@.gemini/GEMINI.md

## Encoding: no `use utf8;` anywhere, README is kept as raw bytes

`pre_objetivo_0` (`lib/Objetivos.pm`) calls `utf8::encode($README)` before
returning it, and no file in this project uses `use utf8;`. That means all
string/regex literals with accented characters are, and must stay,
byte-level UTF-8 (each accented letter is 2 raw bytes), consistently with
the README content they're matched against.

This has a sharp edge for regexes: a **character class** containing an
accented letter, e.g. `[óo]`, is broken in byte mode — the 2-byte UTF-8
sequence gets treated as two separate single-byte alternatives instead of
matching as one unit. Use an alternation group instead: `(?:ó|o)`.

Also, `\b` immediately after an accented character is unreliable in byte
mode, since the accent's bytes aren't ASCII `\w`. Use a `(?!\w)` lookahead
instead of a trailing `\b` when an alternative can end in an accented
letter.

## objetivo_0: README problem-description checks

`objetivo_0` validates the student's problem description using pattern
(regex) based checks in `lib/AnalisisProblema.pm`, instead of literal
string bans — a literal ban (the old approach) is both trivial to dodge and
prone to false positives (e.g. banning the bare word "aplicación" anywhere
in the text). Each check is its own sub, independently unit-tested in
`t/02-analisis-problema.t`.

### Fatal vs. warning split

Only two checks are wired as fatal (fail the Action):

- `detecta_solucion_tecnica` — explicit solution-announcing phrasing
  ("quiero hacer una aplicación...", "mi aplicación hará...").
- `detecta_verbos_crud_exclusivos` — fires only when prohibited CRUD/storage
  verbs are found **and** zero business-logic verbs are present anywhere in
  the text. Requiring the absence of any positive signal, not just the
  presence of a negative one, is what keeps this check from false-positive.

Everything else from the assignment guión that's inherently fuzzier —
"el cliente quiere..." wish-framing, a vague "el problema de..." opening,
scope creep ("además"/"también queremos"), missing logic verbs, a too-short
description — is wired as a warning, not an error.

This is a deliberate reclassification relative to the assignment guión
(`../IV/documentos/proyecto/0.Repositorio.md`), which lists some of these as
fatal. Students get only three formative-evaluation chances before the
objective is failed outright, so a false positive on a fatal check is
costly. Default new content-based fatal checks to warning-level unless the
pattern is nearly unambiguous.
