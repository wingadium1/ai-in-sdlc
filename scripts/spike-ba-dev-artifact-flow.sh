#!/bin/bash
INPUT_FILE=""
ARTIFACT_TYPE=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --input) INPUT_FILE="$2"; shift ;;
        --type) ARTIFACT_TYPE="$2"; shift ;;
        *) shift ;;
    esac
    shift
done

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File not found" >&2
    exit 1
fi

if [[ "$ARTIFACT_TYPE" != "high-level-req" && "$ARTIFACT_TYPE" != "ui-spec" && "$ARTIFACT_TYPE" != "detailed-req" ]]; then
    echo "Warning: Unmappable artifact type $ARTIFACT_TYPE" >&2
fi

if grep -q "PlantUML" "$INPUT_FILE"; then
    echo "Warning: PlantUML diagrams are unmappable to Dev format" >&2
fi

echo "{"
echo "  \"kind\": \"Requirement\","
echo "  \"metadata\": {"
echo "    \"source\": \"BA $ARTIFACT_TYPE\""
echo "  },"
echo "  \"content\": {"
echo "    \"title\": \"$(grep "^title:" "$INPUT_FILE" | cut -d ' ' -f 2-)\","
echo "    \"acceptance_criteria\": \"Extracted criteria\""
echo "  }"
echo "}"
exit 0
