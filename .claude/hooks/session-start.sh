#!/usr/bin/env bash
# SessionStart hook for GrowingIO iOS SDK project.
#
# Injects the full content of the `using-growingio-sdk-skills` meta-skill
# into the session via hookSpecificOutput.additionalContext — so that the
# main controller agent always sees the meta-skill regardless of persona
# state, /clear, or auto-compact.

set -euo pipefail

if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
    PROJECT_ROOT="$CLAUDE_PROJECT_DIR"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
fi

META_SKILL_PATH="${PROJECT_ROOT}/.agents/skills/using-growingio-sdk-skills/SKILL.md"

if [ ! -f "$META_SKILL_PATH" ]; then
    echo "session-start hook: meta-skill file missing at $META_SKILL_PATH" >&2
    printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":""}}\n'
    exit 0
fi

meta_skill_content=$(cat "$META_SKILL_PATH")

escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

wrapper_header='<EXTREMELY-IMPORTANT>
You are operating in the GrowingIO iOS SDK project.

Below is the FULL content of the `using-growingio-sdk-skills` meta-skill,
injected automatically. You do NOT need to call the Skill tool to load it
again — it is already in your context. Follow its rules exactly.

If you were dispatched as a subagent (code-reviewer, spec-reviewer,
implementer, etc.), honor the `<SUBAGENT-STOP>` marker inside the skill
and ignore the meta-skill routing; just execute your assigned task.

--- BEGIN using-growingio-sdk-skills SKILL.md ---
'

wrapper_footer='
--- END using-growingio-sdk-skills SKILL.md ---
</EXTREMELY-IMPORTANT>'

combined="${wrapper_header}${meta_skill_content}${wrapper_footer}"
escaped=$(escape_for_json "$combined")

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$escaped"
