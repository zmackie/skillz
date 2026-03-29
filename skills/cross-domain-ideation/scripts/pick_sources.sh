#!/bin/bash
# Pick N random inspiration sources using /dev/urandom for true entropy.
# Usage: pick_sources.sh [N] [--exclude category1,category2]
#
# Sources are organized by category. The script guarantees:
# 1. No two sources from the same category (maximum diversity)
# 2. True randomness via /dev/urandom (not model preferences)
# 3. Optional category exclusion (to avoid near-domain sources)

N=${1:-3}
EXCLUDE=""
TMPFILE=$(mktemp)
trap "rm -f '$TMPFILE'" EXIT

# Parse --exclude flag
if [[ "$2" == "--exclude" ]]; then
    EXCLUDE="$3"
fi

# Full source pool: "category|source_name"
SOURCES=(
    # Biology: Animals
    "animals|Octopus"
    "animals|Ant Colony"
    "animals|Chameleon"
    "animals|Whale Migration"
    "animals|Immune System"
    "animals|Slime Mold"
    # Biology: Plants & Fungi
    "plants|Bamboo"
    "plants|Cactus"
    "plants|Venus Flytrap"
    "plants|Mycelium Network"
    "plants|Sourdough Starter"
    # Natural Systems
    "natural|Coral Reef"
    "natural|Beehive"
    "natural|Water Cycle"
    "natural|Tornado Formation"
    # Technological Systems
    "tech|Hydroelectric Dam"
    "tech|GPS Navigation"
    "tech|Printing Press"
    "tech|Submarine"
    # Physical Phenomena
    "physics|Crystallization"
    "physics|Erosion"
    "physics|Phase Transitions"
    "physics|Tidal Patterns"
    # Abstract / Human Systems
    "abstract|Jazz Improvisation"
    "abstract|Storytelling"
    "abstract|Democracy"
    "abstract|Hospital Triage"
    "abstract|Symphony Orchestra"
    "abstract|Open Source Community"
    # Food & Cooking
    "food|Fermentation"
    "food|Sous Vide"
    "food|Pickle"
    # Sports & Games
    "sports|Chess"
    "sports|Rock Climbing"
    "sports|Soccer"
)

# Filter out excluded categories
FILTERED=()
for entry in "${SOURCES[@]}"; do
    category="${entry%%|*}"
    if [[ -z "$EXCLUDE" ]] || ! echo ",$EXCLUDE," | grep -qi ",$category,"; then
        FILTERED+=("$entry")
    fi
done

# Shuffle using /dev/urandom
# Read random bytes, use them to generate a permutation
SHUFFLED=()
for entry in "${FILTERED[@]}"; do
    rand=$(od -A n -t u4 -N 4 /dev/urandom | tr -d ' ')
    echo "$rand $entry"
done | sort -n | while read -r _ entry; do
    echo "$entry"
done > "$TMPFILE"

# Pick N sources, enforcing one-per-category
PICKED_CATEGORIES=()
PICKED=()
COUNT=0

while IFS= read -r entry; do
    category="${entry%%|*}"
    source="${entry#*|}"

    # Skip if we already picked from this category
    skip=false
    for pc in "${PICKED_CATEGORIES[@]}"; do
        if [[ "$pc" == "$category" ]]; then
            skip=true
            break
        fi
    done

    if ! $skip; then
        PICKED+=("$source")
        PICKED_CATEGORIES+=("$category")
        COUNT=$((COUNT + 1))
        if [[ $COUNT -ge $N ]]; then
            break
        fi
    fi
done < "$TMPFILE"

# Output
echo "=== RANDOMLY SELECTED INSPIRATION SOURCES ==="
echo "Entropy source: /dev/urandom"
echo "Requested: $N sources from different categories"
if [[ -n "$EXCLUDE" ]]; then
    echo "Excluded categories: $EXCLUDE"
fi
echo ""
for i in "${!PICKED[@]}"; do
    echo "$((i+1)). ${PICKED[$i]} [${PICKED_CATEGORIES[$i]}]"
done
