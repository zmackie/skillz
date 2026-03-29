#!/bin/bash
# Parse BACKLOG.md into machine-readable lines.
# Output: one line per idea as tab-separated fields:
#   slug\tstatus\tpriority\tattempts\tfitness\tlast_tried\ttitle
#
# Usage: parse_backlog.sh [path-to-BACKLOG.md]

BACKLOG="${1:-${IDEA_GARDEN_BACKLOG:-garden/BACKLOG.md}}"

if [[ ! -f "$BACKLOG" ]]; then
    echo "ERROR: BACKLOG.md not found at $BACKLOG" >&2
    exit 1
fi

awk '
/^## / {
    title = substr($0, 4)
    slug = tolower(title)
    gsub(/[^a-z0-9]+/, "-", slug)
    gsub(/-+/, "-", slug)
    gsub(/^-|-$/, "", slug)
    in_meta = 0
    status = ""; priority = ""; attempts = ""; fitness = ""; last_tried = ""
}
/<!-- garden-meta/ { in_meta = 1; next }
/-->/ {
    if (in_meta) {
        in_meta = 0
        printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n", slug, status, priority, attempts, fitness, last_tried, title
    }
    next
}
in_meta {
    gsub(/^ +/, "")
    n = split($0, kv, ": ")
    if (n >= 2) {
        key = kv[1]
        val = kv[2]
        if (key == "status") status = val
        else if (key == "priority") priority = val
        else if (key == "attempts") attempts = val
        else if (key == "fitness") fitness = val
        else if (key == "last_tried") last_tried = val
    }
}
' "$BACKLOG"
