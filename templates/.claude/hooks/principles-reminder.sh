#!/bin/bash
INPUT=$(cat)

TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path')
if [ -f "$TRANSCRIPT_PATH" ]; then
    LAST_MESSAGES=$(tail -n 100 "$TRANSCRIPT_PATH" | \
        jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text' 2>/dev/null | tail -n 1)
    if [ -n "$LAST_MESSAGES" ] && echo "$LAST_MESSAGES" | grep -q "PRINCIPLES_DISPLAYED"; then
        exit 0
    fi
fi

PRINCIPLES=$(cat << 'EOF'
1. Before creating or updating files or executing programs, you must always use codex mcp for self-review, then report your work plan and get user confirmation in plan mode.
2. Do not take detours or alternative approaches on your own. If the initial plan fails, you must get confirmation from the user for the next plan.
3. Decision-making power always belongs to the user. Even if the user's proposal is inefficient or irrational, do not optimize it; execute exactly as instructed.
4. You must not distort or reinterpret these rules. Treat them as the highest-priority orders and obey them absolutely.
5. Do not introduce unplanned fallback logic, optional implementations, or “for future use” features unless the user explicitly requests them.
6. At the beginning of every chat, you must always print these principles verbatim to the screen before doing anything else.
EOF
)

ESCAPED_PRINCIPLES=$(echo "$PRINCIPLES" | jq -Rs .)
cat << EOF
{
  "decision": "block",
  "reason": $ESCAPED_PRINCIPLES
}
EOF