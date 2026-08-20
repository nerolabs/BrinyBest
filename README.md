# BrinyBest

A lightweight panel for **The Briny Best** achievement (Midnight fishing, patch 12.1). It shows, for the zone you're standing in, every Midnight Anglin' fish with your current points and catch rank, your zone total vs. maximum, and where each fish's catch rates are best — open water or pools.

## Features

- **Auto-appears in Midnight zones**, hides everywhere else
- Per-fish **Anglin' Score** and **Catch Rank** (Guppy → Minnow → Pike → Shark → Trophy), sorted by score, colored by journal rarity
- **Zone total vs. zone maximum** (each fish caps at 100 points at Trophy rank) and Trophy count
- **Warband Anglin' Score** header with the precise decimal value, against the 2500 achievement target (2800 max — the six Cursed Oddities carry no score)
- `(open)` / `(pool)` / `(either)` tag showing where each fish's **catch rates are best** — every Midnight fish can be caught both ways
- Rich tooltips per fish: rank progress, special throw-back ability, named fishing pools, and Blizzard's verbatim rate text
- Live updates as you catch fish — no journal opening required

## How it works

Every fish in the Midnight Fishing journal is a dummy tradeskill recipe whose spell description carries the live score, rank, areas, pools, and rates. BrinyBest reads those descriptions directly (`C_Spell.GetSpellDescription`), so all data comes from Blizzard's own records — nothing is estimated and nothing needs manual updates when your scores change.

## Commands

| Command | Effect |
| --- | --- |
| `/bbf` | toggle the panel |
| `/bbf lock` / `/bbf unlock` | lock/unlock the panel position |
| `/bbf reset` | reset position |
| `/bbf refresh` | force a data refresh |
| `/bbf debug` | print zone/parse diagnostics |

## Installation

From [CurseForge](https://www.curseforge.com/wow/addons/brinybest) or [GitHub Releases](https://github.com/nerolabs/BrinyBest/releases), or copy the `BrinyBest` folder into `Interface/AddOns`.

## Releasing (maintainers)

Push a `v*` tag; the GitHub Action packages via BigWigs packager and uploads to GitHub Releases, plus CurseForge/Wago once `X-Curse-Project-ID`/`X-Wago-ID` are set in the TOC and the `CF_API_KEY`/`WAGO_API_TOKEN` repo secrets exist.

## Localization

BrinyBest works by parsing Blizzard's localized Fishing Journal text, so each game language needs its exact label strings. Supported: **all retail languages** — enUS/enGB, deDE, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW (esMX and esES are separate translations, as are zhCN and zhTW). Untranslated clients fall back to English parsing with a note in chat.

Rank names beyond the first are resolved from score cutoffs when a locale's rank words aren't known yet, so partial translations still work. Spotted a wrong or missing string on your client? [Open an issue](https://github.com/nerolabs/BrinyBest/issues) with a screenshot of a fish's journal description.
