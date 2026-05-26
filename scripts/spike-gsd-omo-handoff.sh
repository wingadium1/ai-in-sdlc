#!/bin/bash
INPUT_FILE=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --input) INPUT_FILE="$2"; shift ;;
        *) shift ;;
    esac
    shift
done

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File not found: $INPUT_FILE" >&2
    exit 1
fi

TASKS=$(grep -E "^- \[ \]" "$INPUT_FILE")
if [ -z "$TASKS" ]; then
    echo "Error: Malformed plan, no tasks found" >&2
    exit 1
fi

COUNT=$(echo "$TASKS" | wc -l | xargs)
echo "Extracted $COUNT tasks."
echo ""
echo "$TASKS" | while read -r line; do
    DESC=$(echo "$line" | sed 's/^- \[ \] //')
    echo "task("
    echo "  category=\"deep\","
    echo "  load_skills=[],"
    echo "  description=\"$DESC\","
    echo "  prompt=\"Please implement: $DESC\","
    echo "  run_in_background=true"
    echo ")"
    echo ""
done
exit 0
