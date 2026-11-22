#!/usr/bin/env python3
"""Build the `shell` learn track: synthetic data, level dirs, expected outputs.

Usage:  python3 -I learn/tracks/shell/_gen/build.py

Deterministic (fixed seed). Re-run after editing LEVELS; it rewrites data/,
every level directory and track.json. Expected outputs come from running each
reference solution with the same checker environment (LC_ALL=C, macOS tools).
All data is synthetic: fictional people, example.com/.org/.net emails,
TEST-NET IP ranges (RFC 5737).
"""

from __future__ import annotations

import json
import math
import os
import random
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

TRACK = Path(__file__).resolve().parent.parent
DATA = TRACK / "data"
SEED = 2026

PREAMBLE = (
    "DATA=${LEARN_EXERCISE_DIR:-~/dotfiles/learn/tracks/shell/data}/../data\n"
    "export LC_ALL=C\n"
)
XP = {1: 10, 2: 20, 3: 30, 4: 40, 5: 60}

# --------------------------------------------------------------------------- data

FIRST = ["Ari", "Bea", "Cyrus", "Dana", "Eli", "Faye", "Gus", "Hana", "Ivo", "Jade", "Kai", "Lena",
         "Milo", "Nia", "Omar", "Pia", "Quinn", "Rhea", "Sol", "Tess", "Uma", "Vik", "Wren", "Yara",
         "Zane", "Ines", "Theo", "Mira", "Joss", "Kemi"]
LAST = ["Vance", "Okafor", "Lindqvist", "Moreau", "Tanaka", "Silva", "Novak", "Haddad", "Kim", "Rossi",
        "Weber", "Costa", "Ito", "Byrne", "Amari", "Falk", "Duarte", "Orsini", "Halloran", "Petrov"]


def write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


def gen_users(rng: random.Random) -> list[dict]:
    teams = ["platform"] * 16 + ["payments"] * 14 + ["search"] * 12 + ["growth"] * 10 + ["infra"] * 8
    countries = ["US"] * 18 + ["IN"] * 14 + ["DE"] * 11 + ["BR"] * 8 + ["JP"] * 6 + ["CA"] * 3
    plans = ["free"] * 30 + ["pro"] * 18 + ["team"] * 12
    for lst in (teams, countries, plans):
        rng.shuffle(lst)
    names: set[str] = set()
    users = []
    for i in range(60):
        while True:
            name = f"{rng.choice(FIRST)} {rng.choice(LAST)}"
            if name not in names:
                names.add(name)
                break
        first, last = name.lower().split()
        domain = "example.com" if i % 7 else rng.choice(["example.org", "example.net"])
        users.append({
            "id": f"u{i + 1:03d}", "name": name, "email": f"{first}.{last}@{domain}",
            "team": teams[i], "country": countries[i],
            "signup": f"2025-{rng.randint(1, 12):02d}-{rng.randint(1, 28):02d}", "plan": plans[i],
        })
    return users


def gen_app_log(rng: random.Random) -> str:
    services = ["api", "auth", "billing", "search", "worker"]
    paths = ["/api/orders", "/api/users", "/api/search", "/api/checkout", "/api/login", "/healthz"]
    info_msgs = ["ok", "cache hit", "served", "ok"]
    warn_msgs = ["slow query", "rate limited", "retrying after error", "3 errors suppressed"]
    err_msgs = ["upstream timeout", "Timeout waiting for lock", "db connection refused", "payment declined",
                "error_code=E503", "UPSTREAM TIMEOUT from search"]
    debug_msgs = ["client error ignored", "feature flag evaluated", "cache miss"]
    lines = []
    t = 9 * 3600
    panics = 0
    while t < 12 * 3600:
        hh, mm, ss = t // 3600, t % 3600 // 60, t % 60
        incident = 10 * 3600 + 15 * 60 <= t < 10 * 3600 + 30 * 60
        roll = rng.random()
        err_p = 0.45 if incident else 0.10
        if roll < err_p:
            level = "ERROR"
        elif roll < err_p + 0.12:
            level = "WARN"
        elif roll < err_p + 0.16:
            level = "DEBUG"
        else:
            level = "INFO"
        user = f"u{rng.randint(1, 60):03d}"
        if level == "ERROR":
            r = rng.random()
            user = "u042" if r < 0.22 else ("u017" if r < 0.32 else user)
            status = rng.choice([500, 502, 503, 503, 504])
            ms = rng.randint(800, 5000)
            if panics < 4 and rng.random() < 0.06:
                msg = "panic: nil pointer dereference"
                panics += 1
            else:
                msg = rng.choice(err_msgs)
            path = rng.choice(paths[:5])
        elif level == "WARN":
            status, ms, msg = rng.choice([400, 401, 404, 429]), rng.randint(50, 500), rng.choice(warn_msgs)
            path = rng.choice(paths)
        elif level == "DEBUG":
            status, ms, msg = 200, rng.randint(1, 30), rng.choice(debug_msgs)
            path = rng.choice(paths)
        else:
            status, ms, msg = rng.choice([200, 200, 200, 201, 304]), rng.randint(20, 300), rng.choice(info_msgs)
            path = rng.choice(paths)
        rid = f"{rng.getrandbits(24):06x}"
        lines.append(
            f"2026-03-14T{hh:02d}:{mm:02d}:{ss:02d}Z {level:<5} {rng.choice(services):<7} "
            f"request_id={rid} user={user} path={path} status={status} ms={ms} msg=\"{msg}\""
        )
        t += rng.randint(4, 30)
    return "\n".join(lines) + "\n"


def gen_access_log(rng: random.Random) -> str:
    heavy = {"203.0.113.42": 61, "198.51.100.7": 48, "192.0.2.15": 37, "203.0.113.9": 29}
    others = [f"192.0.2.{n}" for n in (3, 8, 21, 77, 130)] + \
             [f"198.51.100.{n}" for n in (12, 33, 54, 99, 201)] + \
             [f"203.0.113.{n}" for n in (5, 18, 64, 88, 150, 222)]
    ips = [ip for ip, n in heavy.items() for _ in range(n)]
    ips += [rng.choice(others) for _ in range(330)]
    rng.shuffle(ips)
    paths = ["/api/orders", "/api/users", "/api/search?q=shoes", "/api/checkout", "/login", "/static/app.js",
             "/static/style.css", "/favicon.ico", "/healthz"]
    agents = ["curl/8.4.0", "python-requests/2.31.0", "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_4) Firefox/124.0",
              "Mozilla/5.0 (X11; Linux x86_64) Chrome/123.0", "Go-http-client/1.1"]
    lines = []
    t = 9 * 3600
    for ip in ips:
        t += rng.randint(1, 20)
        hh, mm, ss = t // 3600, t % 3600 // 60, t % 60
        status = rng.choices([200, 304, 404, 500, 502, 503], weights=[70, 10, 8, 4, 3, 5])[0]
        method = rng.choice(["GET", "GET", "GET", "POST"])
        size = rng.randint(120, 9000) if status != 304 else 0
        lines.append(f'{ip} - - [14/Mar/2026:{hh:02d}:{mm:02d}:{ss:02d} +0000] "{method} {rng.choice(paths)} HTTP/1.1" '
                     f'{status} {size} "-" "{rng.choice(agents)}"')
    return "\n".join(lines) + "\n"


def gen_orders(rng: random.Random, users: list[dict]) -> str:
    rows = ["order_id,user_id,amount,currency,status,created_at"]
    for i in range(150):
        cur = rng.choices(["USD", "EUR", "GBP"], weights=[60, 25, 15])[0]
        status = rng.choices(["paid", "refunded", "pending", "failed"], weights=[70, 10, 12, 8])[0]
        rows.append(f"o{1001 + i},{rng.choice(users)['id']},{rng.randint(500, 49999) / 100:.2f},{cur},{status},"
                    f"2026-03-{rng.randint(1, 14):02d}")
    return "\n".join(rows) + "\n"


SERVICES_CONF = """\
# Nimbus service configuration
# Read once at boot. Restart the service after editing.

[web]
host = 0.0.0.0
port = 8000
debug = false
workers = 4

[database]
host = db.internal.example
port = 5432
user = nimbus
pool_size = 20   # max open connections
timeout = 30

[cache]
host = cache.internal.example
port = 6379
ttl = 300        # seconds

[worker]
concurrency = 8
debug = false
queue = default

[logging]
level = info
format = json
"""

DEPLOY_LOG = """\
2026-03-14T09:58:00Z deploy start version=2026.03.14-1
2026-03-14T09:58:04Z deploy step=build status=ok
2026-03-14T09:58:31Z deploy step=migrate status=FAILED
Traceback (most recent call last):
  File "deploy/migrate.py", line 88, in run
    conn = db.connect(settings.DATABASE_URL)
  File "deploy/db.py", line 12, in connect
    return socket.create_connection(addr)
ConnectionRefusedError: [Errno 61] Connection refused
2026-03-14T09:58:32Z deploy rollback version=2026.03.14-1
2026-03-14T10:05:10Z deploy start version=2026.03.14-2
2026-03-14T10:05:12Z deploy step=build status=ok
2026-03-14T10:06:02Z deploy step=migrate status=FAILED
Traceback (most recent call last):
  File "deploy/migrate.py", line 91, in run
    with lock.acquire(timeout=30):
TimeoutError: migration lock not acquired in 30s
2026-03-14T10:06:03Z deploy rollback version=2026.03.14-2
2026-03-14T10:12:40Z deploy start version=2026.03.14-3
2026-03-14T10:12:41Z deploy step=config status=FAILED
Traceback (most recent call last):
  File "deploy/config.py", line 20, in load
    url = os.environ["DATABASE_URL"]
KeyError: 'DATABASE_URL'
2026-03-14T10:12:41Z deploy rollback version=2026.03.14-3
2026-03-14T10:20:00Z deploy start version=2026.03.14-4
2026-03-14T10:20:01Z deploy step=build status=ok
2026-03-14T10:20:30Z deploy step=migrate status=ok
2026-03-14T10:20:44Z deploy step=assets status=FAILED
Traceback (most recent call last):
  File "deploy/assets.py", line 7, in publish
    shutil.copytree(src, "/var/lib/nimbus/static")
  File "/usr/lib/python3.12/shutil.py", line 600, in copytree
    os.makedirs(dst)
PermissionError: [Errno 13] Permission denied: '/var/lib/nimbus/static'
2026-03-14T10:20:45Z deploy rollback version=2026.03.14-4
2026-03-14T10:31:00Z deploy start version=2026.03.14-5
2026-03-14T10:31:58Z deploy step=migrate status=ok
2026-03-14T10:32:20Z deploy finished version=2026.03.14-5 status=ok
"""

SRC_FILES = {
    "api/handlers.py": """\
from api.models import Order


def list_orders(user_id):
    # TODO: paginate instead of returning everything
    return Order.for_user(user_id)


def checkout(cart):
    # FIXME: payment errors are swallowed here
    try:
        return cart.pay()
    except Exception:
        return None
""",
    "api/models.py": """\
class Order:
    @classmethod
    def for_user(cls, user_id):
        # TODO: cache this query
        return []
""",
    "api/handlers_test.py": """\
def test_checkout():
    # FIXME: flaky on CI
    assert True
""",
    "api/__init__.py": "",
    "web/app.js": """\
// TODO: debounce search input
export function search(q) {
  // FIXME: no error handling
  return fetch(`/api/search?q=${q}`);
}
// FIXME: remove before launch
console.log("debug");
""",
    "web/app_test.js": """\
// FIXME: mock fetch
test("search", () => {});
""",
    "worker/jobs.go": """\
package worker

// TODO: retry with backoff
func Run() error {
\t// FIXME: context is ignored
\treturn nil
}
""",
    "README.md": "# src\n\nTODO: write docs for the worker.\n",
    "vendor/lib.py": "# TODO: upstream bug, do not edit vendored code\n",
    ".ignore": "vendor/\n",
}


def gen_hosts(rng: random.Random) -> str:
    base = [f"api-0{i}.nimbus.example" for i in range(1, 5)] + ["db-01.nimbus.example", "cache-01.nimbus.example",
                                                                    "worker-01.nimbus.example", "edge.nimbus.example"]
    out = []
    for _ in range(45):
        h = rng.choice(base)
        style = rng.random()
        out.append(h.upper() if style < 0.2 else (h.title() if style < 0.35 else h))
    return "\n".join(out) + "\n"


def gen_metrics(rng: random.Random) -> str:
    hosts = ["api-01", "api-02", "api-03", "api-04", "db-01", "cache-01"]
    rows = ["timestamp\thost\tcpu\tmem_mb"]
    t = 9 * 3600
    for i in range(120):
        hh, mm, ss = t // 3600, t % 3600 // 60, t % 60
        cpu = round(rng.uniform(5, 85), 1)
        rows.append(f"2026-03-14T{hh:02d}:{mm:02d}:{ss:02d}Z\t{rng.choice(hosts)}\t{cpu}\t{rng.randint(800, 15000)}")
        t += 90
    # the incident: three distinct hot readings + three malformed rows
    rows[40] = rows[40].rsplit("\t", 2)[0] + "\t97.3\t14210"
    rows[41] = rows[41].rsplit("\t", 2)[0] + "\t99.1\t14388"
    rows[42] = rows[42].rsplit("\t", 2)[0] + "\t95.8\t13990"
    rows[57] = "2026-03-14T10:25:30Z\tdb-01\t41.0"
    rows[73] = "2026-03-14T10:49:30Z\tapi-03\t12.5\t4100\tOVERFLOW"
    rows[96] = "2026-03-14T11:24:00Z\tcache-01"
    return "\n".join(rows) + "\n"


def build_data() -> None:
    rng = random.Random(SEED)
    if DATA.exists():
        shutil.rmtree(DATA)
    users = gen_users(rng)
    write(DATA / "users.csv", "id,name,email,team,country,signup_date,plan\n" + "".join(
        f"{u['id']},{u['name']},{u['email']},{u['team']},{u['country']},{u['signup']},{u['plan']}\n" for u in users))
    write(DATA / "app.log", gen_app_log(rng))
    write(DATA / "access.log", gen_access_log(rng))
    write(DATA / "orders.csv", gen_orders(rng, users))
    write(DATA / "services.conf", SERVICES_CONF)
    write(DATA / "deploy.log", DEPLOY_LOG)
    write(DATA / "hosts.txt", gen_hosts(rng))
    write(DATA / "metrics.tsv", gen_metrics(rng))
    for rel, text in SRC_FILES.items():
        write(DATA / "src" / rel, text)
    write(DATA / "README.md", "# shell track data\n\nSynthetic, generated by `_gen/build.py`. "
          "Fictional people; example.com/.org/.net emails; RFC 5737 TEST-NET IPs.\n")


# --------------------------------------------------------------------------- levels
# Fields: slug, title, d(ifficulty), concepts, story, task, inputs, sol (body after preamble),
# hints; optional: mode (exact|ws|sorted), require/require_hint, forbid/forbid_hint,
# check_file (file-editing level), note (extra README text).

RG = r"(^|[^[:alnum:]_-])rg([^[:alnum:]_-]|$)"
SED = r"(^|[^[:alnum:]_-])sed([^[:alnum:]_-]|$)"
AWK = r"(^|[^[:alnum:]_-])awk([^[:alnum:]_-]|$)"

LEVELS: list[dict] = [
    dict(slug="first-grep", title="The pager goes off", d=1, concepts=["grep PATTERN FILE"],
         story="03:12. Your phone buzzes: *Nimbus API error rate > 5%*. You're on call. Time to read the logs.",
         task="Print every line of `app.log` whose level is `ERROR`.",
         inputs=["app.log"], sol='grep ERROR "$DATA/app.log"\n',
         hints=["`grep PATTERN FILE` prints the lines of FILE that contain PATTERN.",
                "Quote the path: `\"$DATA/app.log\"`."]),
    dict(slug="ignore-case", title="Timeout, TIMEOUT, timeout", d=1, concepts=["grep -i"],
         story="Half the errors look like timeouts, but every service spells it differently.",
         task="Print every line of `app.log` that mentions `timeout` in **any** letter case.",
         inputs=["app.log"], sol='grep -i timeout "$DATA/app.log"\n',
         hints=["One flag makes grep case-insensitive.", "`man grep` and search for `ignore-case` (type `/ignore`)."]),
    dict(slug="count", title="How bad is it?", d=1, concepts=["grep -c"],
         story="Your manager is awake too and wants one number.",
         task="Print the **number** of `ERROR` lines in `app.log` (just the number).",
         inputs=["app.log"], sol='grep -c ERROR "$DATA/app.log"\n',
         hints=["You could pipe into `wc -l`... or grep can count by itself.", "`-c` counts matching lines."]),
    dict(slug="invert-anchors", title="Strip the noise", d=2, concepts=["grep -v", "^ and $ anchors", "multiple -e"],
         story="Maybe it's a config problem. `services.conf` is mostly comments, though.",
         task="Print `services.conf` **without** comment lines (lines starting with `#`) and without blank lines. "
              "Inline comments after a value stay.",
         inputs=["services.conf"], sol="grep -v -e '^#' -e '^$' \"$DATA/services.conf\"\n",
         hints=["`-v` inverts the match: print lines that do NOT match.",
                "`^` anchors to the start of a line, `$` to the end. `^$` is an empty line.",
                "Give grep several patterns with repeated `-e`."]),
    dict(slug="line-numbers", title="Where did it panic?", d=2, concepts=["grep -n"],
         story="Someone in chat says a Go service *panicked*. You want line numbers to jump straight there in nvim.",
         task="Print every line of `app.log` containing `panic`, prefixed with its line number (`123:...`).",
         inputs=["app.log"], sol='grep -n panic "$DATA/app.log"\n',
         hints=["One flag adds `LINE:` in front of each match.",
                "Tip: `nvim +123 file` opens a file at line 123."]),
    dict(slug="only-matching", title="Collect the evidence", d=2, concepts=["pipes", "grep -o", "character classes"],
         story="The backend team wants the request IDs of every failed request.",
         task="For every `ERROR` line in `app.log`, print just its `request_id=...` field, one per line, in log order.",
         inputs=["app.log"], sol="grep ERROR \"$DATA/app.log\" | grep -o 'request_id=[0-9a-f]*'\n",
         hints=["Two greps in a pipeline: the first picks the lines, the second extracts.",
                "`-o` prints only the matched part instead of the whole line.",
                "IDs are lowercase hex: `[0-9a-f]*`."]),
    dict(slug="whole-word", title="error vs. errors", d=2, concepts=["grep -w", "word boundaries"],
         story="Searching for `error` also finds `errors` and `error_code=...`. You only want the word itself.",
         task="Print lines of `app.log` containing the lowercase **word** `error` (not `errors`, not `error_code`, "
              "not `ERROR`).",
         inputs=["app.log"], sol='grep -w error "$DATA/app.log"\n',
         hints=["Search is case-sensitive by default, so `ERROR` is already excluded.",
                "A flag matches whole words only. Underscore counts as a word character, so `error_code` is out."]),
    dict(slug="extended-regex", title="Five hundreds", d=2, concepts=["grep -E", "{n} repetition", "regex literals"],
         story="Switch to the edge proxy's `access.log`. Which requests got a 5xx?",
         task="Print every line of `access.log` whose HTTP status is 5xx. The status comes right after the quoted "
              "request: `\"GET /x HTTP/1.1\" 503 1234 ...`",
         inputs=["access.log"], sol="grep -E '\" 5[0-9]{2} ' \"$DATA/access.log\"\n",
         hints=["Extended regex (`-E`) gives you `{2}`, `+`, `?`, `|` and `()` without backslashes.",
                "Anchor on the closing quote and spaces: `\" 5..` followed by a space.",
                "Single-quote the pattern so the shell leaves the double quote alone."]),
    dict(slug="char-classes", title="Not from around here", d=2, concepts=["POSIX classes [[:alnum:]]", "alternation (a|b)"],
         story="Support says users with non-`.com` emails can't log in. Find their addresses.",
         task="Print every email address in `users.csv` at `example.org` or `example.net` (just the address), "
              "in file order.",
         inputs=["users.csv"], sol="grep -oE '[[:alnum:].]+@example\\.(org|net)' \"$DATA/users.csv\"\n",
         hints=["`[[:alnum:].]+` matches letters, digits and dots.",
                "Escape the literal dot in the domain: `example\\.`.",
                "`(org|net)` needs `-E`."]),
    dict(slug="rg-types", title="Enter ripgrep", d=3, concepts=["rg -t TYPE", "rg -l", ".ignore files"],
         story="Maybe the bug is in code. Ripgrep searches whole trees fast and skips junk for you.",
         task="From inside `$DATA/src`, list the **Python** files that contain `TODO` (paths relative to `src`, "
              "one per line). `vendor/` is listed in `src/.ignore`, so rg skips it: don't fight that.",
         inputs=[], sol='cd "$DATA/src" && rg -t py -l TODO\n', mode="sorted",
         require=RG, require_hint="rg (ripgrep)",
         hints=["`cd` into the directory first so paths come out relative.",
                "`rg -t py` restricts the search to Python files (`rg --type-list` shows all types).",
                "`-l` prints file names instead of matching lines."]),
    dict(slug="rg-globs", title="Not the tests", d=3, concepts=["rg -g '!glob'", "rg -c"],
         story="Count the FIXMEs per file, but leave the test files out of it.",
         task="From inside `$DATA/src`, print `path:count` of `FIXME` occurrences for every file **except** test "
              "files (names containing `_test.`).",
         inputs=[], sol="cd \"$DATA/src\" && rg -c FIXME -g '!*_test.*'\n", mode="sorted",
         require=RG, require_hint="rg (ripgrep)",
         hints=["`-c` prints a count per file.", "`-g GLOB` includes paths; `-g '!GLOB'` excludes them.",
                "Quote the glob so your shell doesn't expand it."]),
    dict(slug="rg-replace", title="Which endpoints?", d=3, concepts=["rg -o -r '$1'", "capture groups", "\\S"],
         story="Which endpoints returned 503? Ripgrep can print a capture group instead of the whole match.",
         task="Print the distinct `path` values from `app.log` lines with `status=503`, sorted.",
         inputs=["app.log"], sol="rg -o -r '$1' 'path=(\\S+) status=503' \"$DATA/app.log\" | sort -u\n",
         require=RG, require_hint="rg (ripgrep)",
         hints=["`path=(\\S+) status=503` captures the path. rg supports Perl-style `\\S`, `\\d`, `\\w`.",
                "`-o -r '$1'` replaces each match with capture group 1.",
                "`sort -u` sorts and removes duplicates."]),
    dict(slug="rg-multiline", title="Read the tracebacks", d=4, concepts=["rg -U multiline", "non-capturing groups (?:)"],
         story="The deploys before the incident failed. Each traceback ends with the line you actually care about.",
         task="Print the final exception line of every Python traceback in `deploy.log` (e.g. "
              "`KeyError: 'DATABASE_URL'`), in order.",
         inputs=["deploy.log"],
         sol="rg -U -o -r '$1' 'Traceback.*\\n(?:  .*\\n)+(.+)' \"$DATA/deploy.log\"\n",
         require=RG, require_hint="rg -U (multiline)",
         hints=["`-U` lets a pattern span lines; write newlines as `\\n`.",
                "A traceback is `Traceback...` then indented lines (two leading spaces), then the exception line.",
                "`(?:  .*\\n)+` repeats indented lines without capturing; capture the next line with `(.+)`."]),
    dict(slug="cut", title="Columns, please", d=2, concepts=["cut -d -f", "tail -n +2"],
         story="Comms wants to email everyone. Pull the email column from the user list.",
         task="Print the `email` column (3rd field) of `users.csv`, **without** the header line.",
         inputs=["users.csv"], sol='tail -n +2 "$DATA/users.csv" | cut -d, -f3\n',
         hints=["`tail -n +2` prints from line 2 onward, skipping the header.",
                "`cut -d, -f3` splits on commas and keeps field 3."]),
    dict(slug="sort-uniq", title="Team roster", d=2, concepts=["sort -u"],
         story="Which teams have users at all?",
         task="Print each distinct `team` from `users.csv` once, sorted alphabetically (no header).",
         inputs=["users.csv"], sol='tail -n +2 "$DATA/users.csv" | cut -d, -f4 | sort -u\n',
         hints=["Extract the column like the last level, then sort.", "`sort -u` = `sort | uniq`."]),
    dict(slug="frequency", title="Where are our users?", d=2, concepts=["uniq -c", "sort -rn"],
         story="Is the outage regional? Start with where users live.",
         task="Count users per `country` in `users.csv` and print `COUNT COUNTRY`, highest first.",
         inputs=["users.csv"], sol='tail -n +2 "$DATA/users.csv" | cut -d, -f5 | sort | uniq -c | sort -rn\n',
         mode="ws",
         hints=["`uniq -c` counts *adjacent* duplicates, so sort first.",
                "`sort -rn` sorts numerically, highest first.",
                "Padding before the count doesn't matter on this level."]),
    dict(slug="head-tail", title="Hottest moments", d=2, concepts=["sort -t -k", "head", "$'\\t'"],
         story="The metrics export is a TSV. When was the CPU hottest?",
         task="Print the 3 data rows of `metrics.tsv` with the highest `cpu` (3rd column), highest first. "
              "Skip the header.",
         inputs=["metrics.tsv"], sol="tail -n +2 \"$DATA/metrics.tsv\" | sort -t$'\\t' -k3,3nr | head -3\n",
         hints=["`sort -t SEP -k3,3n` sorts numerically by field 3 only.",
                "In bash, `$'\\t'` is a literal tab character.", "`head -3` keeps the first three lines."]),
    dict(slug="tr", title="SHOUTING hostnames", d=2, concepts=["tr", "input redirection <"],
         story="The inventory file has the same hosts in three different capitalisations.",
         task="Print the distinct hostnames from `hosts.txt`, lowercased, sorted.",
         inputs=["hosts.txt"], sol="tr '[:upper:]' '[:lower:]' < \"$DATA/hosts.txt\" | sort -u\n",
         hints=["`tr` translates characters; it only reads stdin, so redirect the file in with `<`.",
                "`tr '[:upper:]' '[:lower:]'` lowercases."]),
    dict(slug="wc", title="How many people noticed?", d=2, concepts=["wc -l", "pipeline composition"],
         story="How many distinct users hit at least one error?",
         task="Print the number of distinct `user=` values on `ERROR` lines in `app.log`.",
         inputs=["app.log"], sol="grep ERROR \"$DATA/app.log\" | grep -o 'user=u[0-9]*' | sort -u | wc -l\n",
         mode="ws",
         hints=["Combine: filter lines, extract the user, dedupe, count.", "`wc -l` counts lines."]),
    dict(slug="sed-substitute", title="Privacy, please", d=3, concepts=["sed s///", "negated classes [^,]"],
         story="You need to paste the user list into the incident channel, but not the email addresses.",
         task="Print `users.csv` with the part of each email **before** the `@` replaced by `***` "
              "(`***@example.com`). The header line stays unchanged.",
         inputs=["users.csv"], sol="sed 's/,[^,]*@/,***@/' \"$DATA/users.csv\"\n",
         require=SED, require_hint="sed",
         hints=["`sed 's/OLD/NEW/' file` replaces the first match on each line.",
                "Match from a comma up to the `@`: `,[^,]*@`. `[^,]` means \"anything except a comma\".",
                "Put the comma back in the replacement."]),
    dict(slug="sed-range", title="Just the database bits", d=3, concepts=["sed -n ... p", "address ranges /a/,/b/"],
         story="The DBA asks: \"what does the database section say?\"",
         task="Print the `[database]` section of `services.conf`: its header and its lines, but not the blank line "
              "after it.",
         inputs=["services.conf"], sol="sed -n '/^\\[database\\]/,/^$/{/./p;}' \"$DATA/services.conf\"\n",
         require=SED, require_hint="sed",
         hints=["`sed -n` prints nothing unless told to; `p` prints.",
                "`/START/,/END/` selects a range of lines. Escape the brackets: `\\[database\\]`.",
                "Inside the range, only print non-empty lines: `{/./p;}`."]),
    dict(slug="sed-delete", title="Config, minus the chatter", d=3, concepts=["sed -e (multiple)", "d command"],
         story="Diffing configs is easier without comments.",
         task="Print `services.conf` with all comments removed (whole-line **and** inline, plus the spaces before "
              "them) and no blank lines.",
         inputs=["services.conf"], sol="sed -e 's/[[:space:]]*#.*//' -e '/^$/d' \"$DATA/services.conf\"\n",
         require=SED, require_hint="sed",
         hints=["First delete comments with `s/...//`, then delete lines that became empty.",
                "`[[:space:]]*#.*` matches optional spaces, the `#`, and everything after it.",
                "`/^$/d` deletes empty lines. Chain commands with `-e ... -e ...`."]),
    dict(slug="sed-capture", title="Dates for the Berlin office", d=3, concepts=["sed -E", "capture groups \\1"],
         story="Finance in Berlin wants the orders export with dates as `DD.MM.YYYY`.",
         task="Print `orders.csv` with every `YYYY-MM-DD` date rewritten as `DD.MM.YYYY`.",
         inputs=["orders.csv"],
         sol="sed -E 's/([0-9]{4})-([0-9]{2})-([0-9]{2})/\\3.\\2.\\1/' \"$DATA/orders.csv\"\n",
         require=SED, require_hint="sed",
         hints=["`sed -E` enables extended regex: `( )` groups and `{4}`, the same on macOS and Linux.",
                "Refer to groups in the replacement with `\\1`, `\\2`, `\\3`."]),
    dict(slug="sed-inplace", title="Hotfix the config", d=3, concepts=["sed -i (BSD vs GNU)", "ranges + several commands"],
         story="Root cause: web is on the wrong port with debug off. Fix the file **in place**, like you would on the "
               "box.",
         task="Edit `./services.conf` in place so that, **in the `[web]` section only**, `port = 8080` and "
              "`debug = true`. The `[worker]` section's `debug` must stay `false`. Leave no backup file behind.",
         inputs=["services.conf"],
         sol="sed -i.bak '/^\\[web\\]/,/^$/{s/^port = .*/port = 8080/;s/^debug = .*/debug = true/;}' services.conf "
             "&& rm services.conf.bak\n",
         check_file="services.conf", require=SED, require_hint="sed -i",
         note="**Portability trap:** macOS (BSD) sed needs `sed -i '' ...`, GNU sed wants `sed -i ...`. "
              "`sed -i.bak ...` works on both: it keeps a backup, which you then delete.\n\n"
              "The checker runs your script in a scratch directory containing a fresh `services.conf`, then "
              "compares the edited file. Your workspace has its own copy to experiment on.",
         hints=["Restrict commands to a range: `/^\\[web\\]/,/^$/{ ...; }`.",
                "Inside the braces, separate commands with `;` and end with `;}` (BSD sed needs it).",
                "`sed -i.bak ... && rm services.conf.bak`."]),
    dict(slug="awk-fields", title="Who pays us?", d=3, concepts=["awk -F", "$N fields", "pattern {action}"],
         story="Product wants to reach out to affected **pro** customers personally.",
         task="Print `NAME <EMAIL>` for every user on the `pro` plan in `users.csv`, in file order.",
         inputs=["users.csv"], sol="awk -F, '$7 == \"pro\" {print $2 \" <\" $3 \">\"}' \"$DATA/users.csv\"\n",
         require=AWK, require_hint="awk",
         hints=["`awk -F, 'CONDITION {ACTION}'` runs ACTION on lines where CONDITION holds.",
                "Fields are `$1`, `$2`, ...; compare strings with `==`.",
                "Juxtaposition concatenates: `print $2 \" <\" $3 \">\"`."]),
    dict(slug="awk-nr-nf", title="Malformed metrics", d=3, concepts=["NF (field count)", "NR (record number)"],
         story="The metrics pipeline choked on some rows. Find the broken ones.",
         task="Print `LINE: ROW` for every line of `metrics.tsv` that does not have exactly 4 tab-separated fields "
              "(`LINE` is the line number in the file).",
         inputs=["metrics.tsv"], sol="awk -F'\\t' 'NF != 4 {print NR \": \" $0}' \"$DATA/metrics.tsv\"\n",
         require=AWK, require_hint="awk",
         hints=["`NF` is the number of fields on the line, `NR` the line number.", "Use `-F'\\t'` for tabs.",
                "`$0` is the whole line."]),
    dict(slug="awk-sum", title="Revenue check", d=3, concepts=["accumulators", "END block", "printf %.2f"],
         story="Finance asks whether payments still worked during the incident.",
         task="Print the total `amount` of `paid` orders in `USD` from `orders.csv`, with 2 decimals.",
         inputs=["orders.csv"],
         sol="awk -F, '$5 == \"paid\" && $4 == \"USD\" {s += $3} END {printf \"%.2f\\n\", s}' \"$DATA/orders.csv\"\n",
         require=AWK, require_hint="awk",
         hints=["Variables start at 0 (or empty), so `s += $3` just works.",
                "`END { ... }` runs after the last line.", "`printf \"%.2f\\n\", s`."]),
    dict(slug="awk-groupby", title="Revenue by currency", d=4, concepts=["associative arrays", "for (k in arr)"],
         story="Same question, broken down by currency.",
         task="For `paid` orders, print `CURRENCY TOTAL` (2 decimals) per currency, sorted by currency.",
         inputs=["orders.csv"],
         sol="awk -F, '$5 == \"paid\" {s[$4] += $3} END {for (c in s) printf \"%s %.2f\\n\", c, s[c]}' "
             "\"$DATA/orders.csv\" | sort\n",
         require=AWK, require_hint="awk",
         hints=["Use the currency as an array key: `s[$4] += $3`.",
                "`for (k in arr)` order is unspecified (and differs between awks): pipe into `sort`."]),
    dict(slug="awk-printf", title="A report your manager can read", d=4,
         concepts=["printf widths %-10s %5d", "piping inside awk", "close()"],
         story="Your manager wants a tidy table, not raw counts.",
         task="Print this table from `users.csv`: a header row, one row per team (sorted by team name), and a "
              "`TOTAL` row. Team left-aligned in 10 columns, then a space, then the count right-aligned in 5.\n\n"
              "```text\nTEAM       USERS\ngrowth        10\n...\nTOTAL         60\n```",
         inputs=["users.csv"],
         sol="awk -F, 'NR > 1 {n[$4]++} END {\n"
             "  printf \"%-10s %5s\\n\", \"TEAM\", \"USERS\"\n"
             "  for (t in n) printf \"%-10s %5d\\n\", t, n[t] | \"sort\"\n"
             "  close(\"sort\")\n"
             "  printf \"%-10s %5d\\n\", \"TOTAL\", NR - 1\n"
             "}' \"$DATA/users.csv\"\n",
         require=AWK, require_hint="awk",
         hints=["`%-10s` is left-aligned width 10; `%5d` is right-aligned width 5.",
                "Inside awk, `print ... | \"sort\"` pipes rows through sort; `close(\"sort\")` flushes it before "
                "you print TOTAL.",
                "Or build it in pieces with the shell: `{ echo header; awk ... | sort; awk ... total; }`."]),
    dict(slug="awk-join", title="Which team spends the most?", d=4, concepts=["NR==FNR two-file join", "next"],
         story="Orders know user IDs; users know teams. Join them.",
         task="Join `users.csv` and `orders.csv` and print `TEAM TOTAL` (2 decimals) of `paid` **USD** orders per "
              "team, biggest total first.",
         inputs=["users.csv", "orders.csv"],
         sol="awk -F, 'NR == FNR {team[$1] = $4; next} $5 == \"paid\" && $4 == \"USD\" {s[team[$2]] += $3}\n"
             "  END {for (t in s) printf \"%s %.2f\\n\", t, s[t]}' \"$DATA/users.csv\" \"$DATA/orders.csv\" "
             "| sort -k2,2nr\n",
         require=AWK, require_hint="awk",
         hints=["With two files, `NR == FNR` is only true while reading the first one.",
                "Load the lookup table from file 1 (`team[$1] = $4; next`), then use it on file 2.",
                "`sort -k2,2nr` sorts by the 2nd column, numeric, descending."]),
    dict(slug="top-n", title="Top talkers", d=4, concepts=["top-N pipeline", "awk '{print $1}'"],
         story="Is someone hammering the edge proxy?",
         task="Print the 3 client IPs with the most requests in `access.log` as `COUNT IP`, most first.",
         inputs=["access.log"], sol="awk '{print $1}' \"$DATA/access.log\" | sort | uniq -c | sort -rn | head -3\n",
         mode="ws",
         hints=["The IP is the first whitespace-separated field.", "sort, `uniq -c`, `sort -rn`, `head`."]),
    dict(slug="time-window", title="The 15 minutes that mattered", d=4, concepts=["substr()", "string comparison", "split()"],
         story="The dashboard shows the spike between 10:15 and 10:30. Zoom in.",
         task="For `ERROR` lines in `app.log` with a time from `10:15:00` up to (not including) `10:30:00`, print "
              "`HH:MM:SS PATH STATUS` (values only, e.g. `10:16:03 /api/checkout 503`).",
         inputs=["app.log"],
         sol="awk '$2 == \"ERROR\" && substr($1, 12, 5) >= \"10:15\" && substr($1, 12, 5) < \"10:30\" {\n"
             "  split($6, p, \"=\"); split($7, s, \"=\"); print substr($1, 12, 8), p[2], s[2]\n"
             "}' \"$DATA/app.log\"\n",
         require=AWK, require_hint="awk",
         hints=["`substr($1, 12, 8)` cuts `HH:MM:SS` out of `2026-03-14T10:16:03Z`.",
                "Zero-padded times compare correctly as strings.",
                "`split($6, p, \"=\")` puts the part after `=` into `p[2]`."]),
    dict(slug="flatten-config", title="Config to env vars", d=5, concepts=["regex FS", "gsub", "toupper", "state across lines"],
         story="The new deploy system wants environment variables, not INI files.",
         task="Turn `services.conf` into `SECTION_KEY=VALUE` lines (uppercase section and key, inline comments "
              "dropped), e.g. `WEB_PORT=8000`, in file order. Skip comments and blank lines.",
         inputs=["services.conf"],
         sol="awk -F' *= *' '/^\\[/ {gsub(/[][]/, \"\"); s = toupper($0); next}\n"
             "  /^[a-z]/ {sub(/ *#.*/, \"\", $2); print s \"_\" toupper($1) \"=\" $2}' \"$DATA/services.conf\"\n",
         require=AWK, require_hint="awk",
         hints=["`-F' *= *'` makes the separator an `=` with optional spaces around it.",
                "On a `[section]` line, strip the brackets (`gsub`), remember the name, and `next`.",
                "On `key = value` lines, drop an inline comment from `$2` with `sub(/ *#.*/, \"\", $2)`."]),
    dict(slug="incident-report", title="Boss: incident report", d=5,
         concepts=["multi-field aggregation", "averages", "multi-key sort"],
         story="Post-mortem time. Which endpoints failed, how often, and how slowly?",
         task="From `app.log`, for each `path` with **at least 3** responses with status ≥ 500, print "
              "`PATH COUNT AVG_MS`. `AVG_MS` is the mean `ms` of those 5xx responses, with 1 decimal. Sort by "
              "count (highest first), then by path.",
         inputs=["app.log"],
         sol="awk '{split($6, p, \"=\"); split($7, s, \"=\"); split($8, m, \"=\")}\n"
             "  s[2] >= 500 {n[p[2]]++; t[p[2]] += m[2]}\n"
             "  END {for (k in n) if (n[k] >= 3) printf \"%s %d %.1f\\n\", k, n[k], t[k] / n[k]}' "
             "\"$DATA/app.log\" | sort -k2,2nr -k1,1\n",
         require=AWK, require_hint="awk",
         hints=["Split each `key=value` field, then aggregate count and total ms per path.",
                "Average = total / count, in the END block.",
                "`sort -k2,2nr -k1,1`: by count descending, then path ascending."]),
    dict(slug="culprit", title="Final boss: find the culprit", d=5, concepts=["command substitution $( )", "joins", "everything"],
         story="One account triggered more errors than anyone else. Is it a bot? Find out who it is.",
         task="Find the user with the most `ERROR` lines in `app.log`, then print their `NAME,EMAIL` from "
              "`users.csv`.",
         inputs=["app.log", "users.csv"],
         sol="id=$(grep ERROR \"$DATA/app.log\" | grep -o 'user=u[0-9]*' | sort | uniq -c | sort -rn | head -1 "
             "| cut -d= -f2)\n"
             "grep \"^$id,\" \"$DATA/users.csv\" | cut -d, -f2,3\n",
         hints=["Step 1: get the top user ID with the frequency pipeline from earlier levels.",
                "Store it with `id=$( ... )`, then look it up: `grep \"^$id,\"`.",
                "Golfers: one awk can do the whole thing with an NR==FNR join."]),
]

# --------------------------------------------------------------------------- build


def code_chars(text: str) -> int:
    return sum(len(line.strip()) for line in text.splitlines()
               if line.strip() and not line.strip().startswith("#"))


def header(num: int, lvl: dict) -> str:
    edit = ("# Edit ./services.conf in place (the checker gives you a fresh copy).\n"
            if lvl.get("check_file") else "# Inputs are in $DATA, e.g. \"$DATA/app.log\". Print the answer to stdout.\n")
    return (f"#!/usr/bin/env bash\n# Level {num:02d} · {lvl['title']}\n"
            f"# Task: README.md · run: bash solution.sh · check: learn check\n{edit}{PREAMBLE}")


def check_sh(lvl: dict, par: int) -> str:
    lines = ["#!/usr/bin/env bash", "# Generated by _gen/build.py: compares this level against expected.txt.",
             f"MODE={lvl.get('mode', 'exact')}", f"PAR={par}"]
    for key in ("require", "require_hint", "forbid", "forbid_hint", "check_file"):
        if lvl.get(key):
            val = lvl[key].replace("'", "'\\''")
            lines.append(f"{key.upper()}='{val}'")
    lines.append('. "$LEARN_EXERCISE_DIR/../_lib/check.sh"')
    return "\n".join(lines) + "\n"


def run_reference(exdir: Path, script: Path, check_file: str | None) -> str:
    env = {**os.environ, "LC_ALL": "C", "LEARN_EXERCISE_DIR": str(exdir)}
    with tempfile.TemporaryDirectory() as tmp:
        if check_file:
            shutil.copy(exdir / check_file, Path(tmp) / check_file)
        res = subprocess.run(["bash", str(script)], cwd=tmp, env=env, capture_output=True, text=True, timeout=30)
        if res.returncode != 0 or res.stderr:
            sys.exit(f"reference failed in {exdir.name}: rc={res.returncode}\n{res.stderr}")
        return (Path(tmp) / check_file).read_text() if check_file else res.stdout


def sample(path: Path, n: int = 2) -> str:
    return "\n".join(path.read_text().splitlines()[:n])


def readme(num: int, lvl: dict, expected: str, par: int) -> str:
    out = [f"# Level {num:02d} · {lvl['title']}", "", f"> {lvl['story']}", "", f"**Task:** {lvl['task']}", ""]
    for name in lvl["inputs"]:
        out += [f"**Input** `$DATA/{name}` (first lines):", "```text", sample(DATA / name), "```", ""]
    if lvl["slug"].startswith("rg-") and not lvl["inputs"]:
        out += ["**Input:** the source tree in `$DATA/src` (`ls -R \"$DATA/src\"` to look around).", ""]
    exp_lines = expected.rstrip("\n").splitlines()
    shown = "\n".join(exp_lines[:6])
    label = "Expected result" + (" (the edited file)" if lvl.get("check_file") else "")
    out += [f"**{label}**{' (first lines)' if len(exp_lines) > 6 else ''}:", "```text", shown, "```",
            f"_{len(exp_lines)} line{'s' if len(exp_lines) != 1 else ''} in total._", ""]
    if lvl.get("note"):
        out += [lvl["note"], ""]
    mode_note = {"ws": "Leading and repeated spaces are ignored when checking.",
                 "sorted": "Line order is ignored when checking."}.get(lvl.get("mode", "exact"))
    if mode_note:
        out += [f"_{mode_note}_", ""]
    out += ["---", "",
            "- `$DATA` points at the shared data directory (`learn/tracks/shell/data`). Every level uses the same "
            "synthetic files.",
            "- Run it: `bash solution.sh` · check it: `learn check` · stuck? `learn hint`",
            f"- ⛳ Golf: ★★★ needs a solution of **≤ {par} characters**, counting code only (comments and the "
            "indentation don't count).",
            f"- Concepts: {', '.join(f'`{c}`' for c in lvl['concepts'])}", ""]
    return "\n".join(out)


def build_levels() -> list[str]:
    for old in TRACK.iterdir():
        if old.is_dir() and old.name[:2].isdigit():
            shutil.rmtree(old)
    order = []
    for num, lvl in enumerate(LEVELS, start=1):
        name = f"{num:02d}-{lvl['slug']}"
        exdir = TRACK / name
        exdir.mkdir()
        head = header(num, lvl)
        starter = head + "\n# your command(s) here:\n\n"
        reference = head + "\n" + lvl["sol"]
        body_chars = code_chars(reference) - code_chars(PREAMBLE)
        par = code_chars(PREAMBLE) + body_chars + max(4, math.ceil(body_chars * 0.10))
        write(exdir / "solution.sh", starter)
        write(exdir / "solution" / "solution.sh", reference)
        files = ["solution.sh"]
        if lvl.get("check_file"):
            shutil.copy(DATA / lvl["check_file"], exdir / lvl["check_file"])
            files.append(lvl["check_file"])
        expected = run_reference(exdir, exdir / "solution" / "solution.sh", lvl.get("check_file"))
        if not expected.strip():
            sys.exit(f"empty expected output for {name}")
        write(exdir / "expected.txt", expected)
        check = exdir / "check.sh"
        write(check, check_sh(lvl, par))
        check.chmod(0o755)
        write(exdir / "README.md", readme(num, lvl, expected, par))
        meta = {"title": lvl["title"], "difficulty": lvl["d"], "xp": XP[lvl["d"]], "concepts": lvl["concepts"],
                "files": files, "open": "solution.sh", "check": "check.sh", "par": par, "hints": lvl["hints"]}
        write(exdir / "exercise.json", json.dumps(meta, indent=2, ensure_ascii=False) + "\n")
        order.append(name)
    return order


def main() -> None:
    build_data()
    order = build_levels()
    track = {"name": "Shell: grep, rg, sed, awk", "slug": "shell", "language": "bash",
             "description": "On call at Nimbus (a fictional SaaS): dig through logs, CSVs and configs with grep, "
                            "ripgrep, cut/sort/uniq, sed and awk. Every level is checked, most have a golf par.",
             "order": order}
    write(TRACK / "track.json", json.dumps(track, indent=2) + "\n")
    print(f"built {len(order)} levels")


if __name__ == "__main__":
    main()
