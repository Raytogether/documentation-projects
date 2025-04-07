<!--
PROJECT METADATA
----------------
status: Initial Documentation
phase: Documentation
session_path: /home/donaldtanner/Documents/warp-ai-sessions
last_updated: 2025-04-07
current_task: Document AI session continuation methods
next_steps: 
  - Add more Warp tips and tricks as discovered
  - Verify all methods work as documented
-->

# Warp Terminal Tips and Tricks - AI Session Continuation

## Overview
Guide for continuing AI sessions in Warp Terminal, focusing on maintaining context and project state across sessions.

## AI Session Continuation Methods

### Basic Project Resume
1. Navigate to project directory
2. Show project status
3. Resume project with context

Example:
```bash
cd ~/project-directory
cat PROJECT_STATUS.md
"I'd like to resume the project. Above is the current status."
```

### Resume with Specific Findings
When you've tested features or found issues:
```bash
cd ~/project-directory
cat PROJECT_STATUS.md
"I've tested [feature] and found [issue]. Here's the current status, let's update the documentation."
```

### Resume with Multiple Files
When you need to show multiple files for context:
```bash
cd ~/project-directory
cat PROJECT_STATUS.md main-doc.md
"I'd like to resume the project. Above are both the status and main documentation."
```

### Resume with Change History
When changes history is relevant:
```bash
cd ~/project-directory
cat PROJECT_STATUS.md
git log --pretty=format:"%h %s" -n 5
"I want to resume the project. Above is the current status and recent changes."
```

## Best Practices

### Project Organization
1. Maintain PROJECT_STATUS.md in each project
2. Keep documentation in markdown format
3. Use ~/bin/sync_docs.sh for format conversion
4. Store AI sessions in /home/donaldtanner/Documents/warp-ai-sessions

### Status File Components
- Current project status
- Verification needs
- Next steps
- Project location
- Main documentation file
- Current phase

### Tips for Effective Continuation
1. Always show PROJECT_STATUS.md when resuming
2. Include specific findings or issues
3. Reference relevant files for context
4. Use git history when discussing changes
5. Keep project structure consistent

## Additional Notes
- AI sessions are preserved in /home/donaldtanner/Documents/warp-ai-sessions
- PROJECT_STATUS.md is key for maintaining context
- Multiple resume methods available based on needs
- Consistent project structure helps AI understand context

