# Offline locale parse test

Verifies BrinyBest's parser against real localized journal text without a WoW
client: `fetch-descs.py` pulls all 34 fish descriptions per locale from
Wowhead's tooltip API (which mirrors in-game text), and `test-parse.lua` loads
the real `BrinyBest.lua` and its `Locales/` files under a stubbed WoW API and
reports scoreable/oddity counts and the zone table per locale. Which locales to
load, and in what order, is read from `BrinyBest.toc` — the same list the client
uses — so it never has to be kept in sync here.

    python3 fetch-descs.py
    lua test-parse.lua

Expected: every locale shows `scoreable=28 oddities=6 unparsed=0 rankword=28`.
Caveat: tooltip placeholders carry no score numbers, so score parsing and the
cutoff fallback are exercised only lightly; zone identity is the main signal.
