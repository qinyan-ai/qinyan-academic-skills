#!/usr/bin/env bash
# Paper Analysis - Comprehensive analysis of a single academic paper
# Usage: bash scripts/paper_analyze.sh '<json_payload>'
# Example: bash scripts/paper_analyze.sh '{"title": "Attention Is All You Need", "authors": ["Vaswani"], "doi": "10.48550/arXiv.1706.03762"}'

set -euo pipefail

API_BASE="http://47.95.10.101:9000"
ENDPOINT="/v1/paper-search/analyze"

if [ -z "${ACADEMIC_API_TOKEN:-}" ]; then
    echo "Error: ACADEMIC_API_TOKEN environment variable is not set."
    echo "Please set it: export ACADEMIC_API_TOKEN='your-token-here'"
    exit 1
fi

PAYLOAD="${1:-}"
if [ -z "$PAYLOAD" ]; then
    echo "Error: No analysis payload provided."
    echo "Usage: bash scripts/paper_analyze.sh '{\"title\": \"Paper Title\", \"authors\": [\"Author\"], \"abstract\": \"...\"}'"
    exit 1
fi

# Validate JSON
if ! echo "$PAYLOAD" | python3 -c "import sys,json; json.load(sys.stdin)" 2>/dev/null; then
    echo "Error: Invalid JSON payload."
    exit 1
fi

echo "Analyzing paper (this may take 30-120 seconds)..." >&2

RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST "${API_BASE}${ENDPOINT}" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${ACADEMIC_API_TOKEN}" \
    -d "$PAYLOAD" \
    --connect-timeout 10 \
    --max-time 300)

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
else
    echo "Error: HTTP $HTTP_CODE"
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
    exit 1
fi
