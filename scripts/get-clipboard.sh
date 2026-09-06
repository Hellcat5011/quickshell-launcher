#!/usr/bin/env bash
# Fetches cliphist items and decodes text items to preserve formatting.
# Outputs JSON. Filters out primary selection fragments.

echo "["
FIRST=1
PREV_CONTENT=""

cliphist list | head -n 50 | while IFS=$'\t' read -r id content; do
    if [[ "$content" == *"[[ binary data"* ]]; then
        # It's an image
        if [ "$FIRST" = 0 ]; then echo ","; fi
        FIRST=0
        JSON_CONTENT=$(jq -R -s '.' <<< "$content")
        echo "{\"id\": \"$id\", \"isImage\": true, \"content\": $JSON_CONTENT}"
        PREV_CONTENT=""
    else
        # It's text, decode it fully to preserve newlines
        FULL_TEXT=$(cliphist decode "$id")
        
        # Deduplication logic for primary selection fragments:
        # If the PREV_CONTENT (which is newer in time) starts with FULL_TEXT,
        # it means FULL_TEXT is just a fragment that was copied while dragging the mouse.
        # We skip it to clean up the UI!
        if [ -n "$PREV_CONTENT" ]; then
            # Check if PREV_CONTENT starts with FULL_TEXT
            if [[ "$PREV_CONTENT" == "$FULL_TEXT"* ]]; then
                continue
            fi
            
            # Also check if it's identical (cliphist doesn't usually store identicals consecutively, but just in case)
            if [[ "$PREV_CONTENT" == "$FULL_TEXT" ]]; then
                continue
            fi
        fi
        
        if [ "$FIRST" = 0 ]; then echo ","; fi
        FIRST=0
        
        JSON_CONTENT=$(jq -R -s '.' <<< "$FULL_TEXT")
        echo "{\"id\": \"$id\", \"isImage\": false, \"content\": $JSON_CONTENT}"
        PREV_CONTENT="$FULL_TEXT"
    fi
done
echo "]"
