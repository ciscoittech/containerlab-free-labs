# Skill Auto-Activation Hook

**Event**: user-prompt-submit
**Timing**: BEFORE Claude reads your message
**Purpose**: Inject skill activation reminders based on prompt analysis

---

## How It Works

1. **Read Rules**: Load skill-rules.json configuration
2. **Analyze Prompt**: Check keywords, intent patterns, file triggers
3. **Activate Skills**: Identify relevant skills
4. **Inject Context**: Add skill reminder to system prompt

---

## Example Output

```
🎯 SKILL ACTIVATION CHECK

Based on your request, these skills may be relevant:

→ laravel-backend-guidelines
  (keyword match: "service", file trigger: editing Laravel service)
  Contains patterns for OpenRouter integration, queue jobs, validation

→ service-discovery
  (intent match: "create new service")
  Complete inventory of 25 PingToPass services to avoid duplication

Load these skills to ensure best practices and consistency.
```

---

## Implementation Notes

This hook:
- ✅ Runs BEFORE Claude sees your prompt
- ✅ Matches keywords (case-insensitive)
- ✅ Matches intent patterns (regex)
- ✅ Checks recently edited files
- ✅ Deduplicates skills
- ✅ Prioritizes high-priority skills

---

## How to Enable

1. Claude Code will read this file
2. System will detect it as a hook
3. It will automatically run on every prompt
4. Skills will be suggested before you submit

---

## Customization

Edit `skill-rules.json` to:
- Add new keywords
- Modify intent patterns
- Change file triggers
- Adjust priorities

---

## For Claude Code Settings

Add to `.claude/settings.local.json`:
```json
{
  "hooks": {
    "user-prompt-submit": {
      "enabled": true,
      "rulesFile": ".claude/hooks/skill-rules.json"
    }
  }
}
```

This hook integrates with Claude Code's native hook system to provide automatic skill activation based on context and intent.
