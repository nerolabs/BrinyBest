#!/usr/bin/env python3
"""Fetch all 34 BrinyBest fish descriptions in every retail locale from Wowhead's
tooltip API and write descs_<locale>.lua data files for test-parse.lua.
Usage: python3 fetch-descs.py   (writes into the current directory)"""
import json, re, urllib.request, html, time

ids = "1225282 1295409 1225275 1225270 1225269 1225245 1295404 1295405 1225266 1225276 1225267 1295410 1225277 1225272 1225271 1295407 1225278 1225281 1295411 1225274 1295408 1225283 1225284 1225268 1225273 1225280 1295406 1225279 1305973 1305975 1305979 1305976 1305972 1305978".split()
locales = {"enUS":0, "koKR":1, "frFR":2, "deDE":3, "zhCN":4, "esES":6, "ruRU":7, "ptBR":8, "itIT":9, "zhTW":10, "esMX":11}

def tooltip_text(tt):
    text = re.sub(r"<br\s*/?>", "\n", tt)
    text = re.sub(r"</(td|tr|table|div)>", "\n", text)
    text = re.sub(r"<[^>]+>", "", text)
    return html.unescape(text)

for loc, num in locales.items():
    entries = []
    for sid in ids:
        url = f"https://nether.wowhead.com/tooltip/spell/{sid}?dataEnv=1&locale={num}"
        for attempt in range(3):
            try:
                with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent":"Mozilla/5.0"}), timeout=15) as r:
                    entries.append(f"  [{sid}] = [==[\n{tooltip_text(json.load(r).get('tooltip',''))}]==],")
                break
            except Exception:
                time.sleep(1)
        time.sleep(0.1)
    with open(f"descs_{loc}.lua","w") as f:
        f.write("return {\n" + "\n".join(entries) + "\n}\n")
    print(loc, len(entries))
