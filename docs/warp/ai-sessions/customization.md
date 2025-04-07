# Session System Customization Guide

## Core Configuration Points

1. **Template Location** (in .session_helper.sh):
```bash
local template="$HOME/Documents/warp-ai-sessions/session-template.md"
```

2. **Date/Time Formats**:
- Session dates: `$(date +%Y%m%d)`
- Display dates: `$(date +%Y-%m-%d)`
- Timestamps: `$(date +"%Y-%m-%d %H:%M %Z")`

3. **File Naming**:
- Current: "${safe_topic,,}-${session_date}.md"
- Alternatives:
  - "session-${session_date}-${RANDOM}.md"
  - "${USER}-${safe_topic}.md"

4. **Template Sections**:
Required sections are in session-template.md:
- Session Topic
- Key Discussion Points  
- Commands/Code Used
- Session Info

## Example Customizations

1. Adding new section:
```markdown
## Environment
- OS: {%OS%}
- Shell: {%SHELL%}
```

2. Changing date format:
```bash
local session_date=$(date +%Y-%b-%d) # 2025-Apr-07
```

3. Additional automation:
```bash
# Auto-open in editor after creation
${EDITOR:-nano} "$target"
```

## Verification
After changes:
1. Run test session
2. Check:
- File creation
- README updating
- Date formatting

