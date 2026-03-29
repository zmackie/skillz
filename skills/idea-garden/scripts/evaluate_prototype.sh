#!/bin/bash
# Mechanical fitness checks for a prototype artifact.
# Checks the first 3 fitness criteria (code exists, runs, produces output).
# Returns a partial fitness score (0.0-0.4) and pass/fail details.
#
# Usage: evaluate_prototype.sh <artifact-dir> <run-command>
# Example: evaluate_prototype.sh garden/artifacts/my-idea/attempt-1 "uv run script.py"
#
# Output: JSON-like summary to stdout

ARTIFACT_DIR="$1"
RUN_CMD="$2"

if [[ -z "$ARTIFACT_DIR" || -z "$RUN_CMD" ]]; then
    echo "Usage: evaluate_prototype.sh <artifact-dir> <run-command>" >&2
    exit 1
fi

FITNESS=0
DETAILS=""

# Check 1: Code file exists (+0.1)
CODE_FILES=$(find "$ARTIFACT_DIR" -maxdepth 1 -type f \( -name "*.py" -o -name "*.sh" -o -name "*.html" -o -name "*.js" \) 2>/dev/null | head -5)
if [[ -n "$CODE_FILES" ]]; then
    FITNESS=$(echo "$FITNESS + 0.1" | bc)
    DETAILS="${DETAILS}PASS: code_exists ($(echo "$CODE_FILES" | wc -l | tr -d ' ') file(s))\n"
else
    DETAILS="${DETAILS}FAIL: code_exists (no .py/.sh/.html/.js files found)\n"
fi

# Check 2: Runs without error (+0.2)
if [[ -n "$CODE_FILES" ]]; then
    cd "$ARTIFACT_DIR" || exit 1
    OUTPUT=$(eval "$RUN_CMD" 2>&1)
    EXIT_CODE=$?
    cd - > /dev/null || true

    if [[ $EXIT_CODE -eq 0 ]]; then
        FITNESS=$(echo "$FITNESS + 0.2" | bc)
        DETAILS="${DETAILS}PASS: runs_clean (exit code 0)\n"
    else
        DETAILS="${DETAILS}FAIL: runs_clean (exit code $EXIT_CODE)\n"
    fi

    # Save output
    echo "$OUTPUT" > "$ARTIFACT_DIR/output.txt"

    # Check 3: Non-empty meaningful output (+0.1)
    OUTPUT_LEN=${#OUTPUT}
    if [[ $OUTPUT_LEN -gt 20 ]]; then
        FITNESS=$(echo "$FITNESS + 0.1" | bc)
        DETAILS="${DETAILS}PASS: has_output ($OUTPUT_LEN chars)\n"
    elif [[ $OUTPUT_LEN -gt 0 ]]; then
        DETAILS="${DETAILS}FAIL: has_output (only $OUTPUT_LEN chars — too short to be meaningful)\n"
    else
        DETAILS="${DETAILS}FAIL: has_output (empty output)\n"
    fi
else
    DETAILS="${DETAILS}SKIP: runs_clean (no code to run)\n"
    DETAILS="${DETAILS}SKIP: has_output (no code to run)\n"
fi

echo "=== MECHANICAL FITNESS CHECK ==="
echo "Artifact: $ARTIFACT_DIR"
echo "Command: $RUN_CMD"
echo "Mechanical fitness: $FITNESS / 0.4"
echo ""
echo "Details:"
echo -e "$DETAILS"
echo "mechanical_fitness=$FITNESS"
