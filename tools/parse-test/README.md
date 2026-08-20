# Offline locale parse test

Verifies BrinyBest's parser against real localized journal text without a WoW
client: `fetch-descs.py` pulls all 34 fish descriptions per locale from
Wowhead's tooltip API (which mirrors in-game text), and `test-parse.lua` loads
the real `BrinyBest.lua` under a stubbed WoW API and reports scoreable/oddity
counts and the zone table per locale.

    python3 fetch-descs.py
    lua test-parse.lua

Expected: every locale shows `scoreable=28 oddities=6 unparsed=0 rankword=28`.
Caveat: tooltip placeholders carry no score numbers, so score parsing and the
cutoff fallback are exercised only lightly; zone identity is the main signal.
