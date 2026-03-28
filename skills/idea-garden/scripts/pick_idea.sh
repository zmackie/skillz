#!/bin/bash
# Pick a random idea from the backlog, weighted by priority and freshness.
# Uses /dev/urandom for true entropy (no model bias).
#
# Usage: pick_idea.sh [path-to-BACKLOG.md]
#
# Output: tab-separated line for the selected idea:
#   slug\tstatus\tpriority\tattempts\tfitness\tlast_tried\ttitle
#
# Eligibility: status=vapor or status=fermenting (with 24h rest)
# Weighting: priority + freshness bonus (vapor +2) + rest bonus (fermenting >3d +1)
#            - fitness penalty (0 < fitness < 0.3: -1)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKLOG="${1:-/Users/zander.mackie/go/src/github.com/DataDog/obsidian/work/garden/BACKLOG.md}"
ARTIFACTS_DIR="/Users/zander.mackie/go/src/github.com/DataDog/obsidian/work/garden/artifacts"
NOW_EPOCH=$(date +%s)
ONE_DAY=86400
THREE_DAYS=259200

# Parse the backlog
PARSED=$("$SCRIPT_DIR/parse_backlog.sh" "$BACKLOG")
if [[ -z "$PARSED" ]]; then
    echo "ERROR: No ideas found in backlog" >&2
    exit 1
fi

# Filter and weight eligible ideas
ELIGIBLE=""
while IFS=$'\t' read -r slug status priority attempts fitness last_tried title; do
    # Skip non-eligible statuses
    [[ "$status" != "vapor" && "$status" != "fermenting" ]] && continue

    # For fermenting ideas, enforce 24h rest period
    if [[ "$status" == "fermenting" && "$last_tried" != "null" && -n "$last_tried" ]]; then
        tried_epoch=$(date -j -f "%Y-%m-%d" "$last_tried" +%s 2>/dev/null || echo 0)
        elapsed=$((NOW_EPOCH - tried_epoch))
        [[ $elapsed -lt $ONE_DAY ]] && continue
    fi

    # Check for lockfile (skip if locked and not stale)
    lockfile="$ARTIFACTS_DIR/$slug/.lock"
    if [[ -f "$lockfile" ]]; then
        lock_epoch=$(stat -f %m "$lockfile" 2>/dev/null || echo 0)
        lock_age=$((NOW_EPOCH - lock_epoch))
        if [[ $lock_age -lt 7200 ]]; then
            continue  # Locked and not stale, skip
        else
            rm -f "$lockfile"  # Stale lock, clean up
        fi
    fi

    # Calculate weight
    weight=$priority

    # Freshness bonus: never-attempted ideas get +2
    [[ "$status" == "vapor" ]] && weight=$((weight + 2))

    # Rest bonus: fermenting ideas rested >3 days get +1
    if [[ "$status" == "fermenting" && "$last_tried" != "null" && -n "$last_tried" ]]; then
        tried_epoch=$(date -j -f "%Y-%m-%d" "$last_tried" +%s 2>/dev/null || echo 0)
        elapsed=$((NOW_EPOCH - tried_epoch))
        [[ $elapsed -gt $THREE_DAYS ]] && weight=$((weight + 1))
    fi

    # Fitness penalty: low but nonzero fitness gets -1
    if awk "BEGIN {exit !($fitness > 0 && $fitness < 0.3)}" 2>/dev/null; then
        weight=$((weight - 1))
    fi

    # Floor at 1
    [[ $weight -lt 1 ]] && weight=1

    ELIGIBLE="${ELIGIBLE}${weight}\t${slug}\t${status}\t${priority}\t${attempts}\t${fitness}\t${last_tried}\t${title}\n"
done <<< "$PARSED"

if [[ -z "$ELIGIBLE" ]]; then
    echo "ERROR: No eligible ideas (all shelved, frozen, locked, or resting)" >&2
    exit 1
fi

# Weighted random selection using /dev/urandom
# Expand each idea by its weight, then pick one uniformly at random
EXPANDED=""
while IFS=$'\t' read -r weight slug status priority attempts fitness last_tried title; do
    [[ -z "$weight" ]] && continue
    for ((i=0; i<weight; i++)); do
        EXPANDED="${EXPANDED}${slug}\t${status}\t${priority}\t${attempts}\t${fitness}\t${last_tried}\t${title}\n"
    done
done < <(echo -e "$ELIGIBLE")

# Count expanded entries
COUNT=$(echo -e "$EXPANDED" | grep -c .)

# Pick random index using /dev/urandom
RAND=$(od -A n -t u4 -N 4 /dev/urandom | tr -d ' ')
INDEX=$((RAND % COUNT))

# Select the line
SELECTED=$(echo -e "$EXPANDED" | sed -n "$((INDEX + 1))p")

echo -e "$SELECTED"
