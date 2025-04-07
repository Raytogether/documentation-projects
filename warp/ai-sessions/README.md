# Warp AI Sessions Documentation

## Session Index
| Date | Session Topic | File |
|------|---------------|------|
| 2025-04-07 | Backup Check System Setup | [backup-check-setup-20250407.md](backup-check-setup-20250407.md) |
| 2025-04-07 | Session Saving Feature | [session-saving-feature-20250407.md](session-saving-feature-20250407.md) |

## Usage
1. To automatically document a session:

**Bash**:
```bash
source ~/Documents/warp-ai-sessions/.session_helper.sh
save-session "Session topic description" 
```

**Zsh**:
```zsh
source ~/Documents/warp-ai-sessions/.session_helper.zsh
save-session "Session topic description" 
```

**Fish**:
```fish
source ~/Documents/warp-ai-sessions/.session_helper.fish
save-session "Session topic description" 
```

2. To manually use the template:
```bash
cp ~/Documents/warp-ai-sessions/session-template.md new-session-$(date +%Y%m%d).md
```

3. To view or modify configuration:
```bash
# View current configuration
show-session-config

# Edit configuration
$EDITOR ~/.warp-sessions-config
```

## Last Updated
2025-04-07 05:15 AM CDT

---

For help: `warp ai "How to document my Warp sessions"`

