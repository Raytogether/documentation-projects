# Warp AI Session Management Guide

This guide outlines the effective use of two complementary tools for managing Warp AI terminal sessions:
1. `warp-ai` - For recording terminal activity
2. `warp-session-manager` - For documentation and session lifecycle management

Both tools share the same files directory (`~/Documents/warp-ai-sessions`) and use compatible file formats, allowing you to choose the right tool for each job while maintaining a unified session history.

## Understanding the Two-Tool Approach

### warp-ai (alias: wai)
- **Primary Focus**: Recording terminal sessions in real-time
- **Key Strength**: Captures commands and outputs exactly as they appear in the terminal
- **Best For**: Troubleshooting, complex command sequences, and capturing live terminal output
- **Core Feature**: Uses the `script` command to record everything that happens in a terminal session

### warp-session-manager (alias: wsm)
- **Primary Focus**: Documentation and session organization
- **Key Strength**: Session lifecycle management (start/stop/status)
- **Best For**: Creating documentation, taking notes, and organizing information
- **Core Feature**: Tracks active sessions and provides metadata for better organization

## When to Use Each Tool

### Use warp-ai (wai) when:
- You need to record a sequence of commands exactly as typed
- You're troubleshooting an issue and want to capture all terminal output
- You're performing a complex operation you want to reference later
- You want to search across all terminal session content

```bash
# Start a terminal recording session
wai start -t "Installing PostgreSQL"

# Find content across all sessions
wai search "permission denied"

# View a specific session by ID or number
wai view 2
```

### Use warp-session-manager (wsm) when:
- You need to organize documentation with clear start/stop points
- You're creating a structured set of notes about a process
- You want to track the active state of documentation sessions
- You need to clean up old sessions systematically

```bash
# Start a documentation session
wsm start "Setting up Docker containers"

# Check what session is currently active
wsm status

# End a session with proper footers
wsm stop

# List all sessions chronologically
wsm list

# Clean up sessions older than 30 days
wsm cleanup 30
```

## Common Workflows and Combinations

### Workflow 1: Recording a Complex Setup Process
1. Start recording: `wai start -t "Database setup"`
2. Perform all setup commands in terminal
3. End recording: `Ctrl+D` or `exit`
4. Search for specific errors later: `wai search "failed"`

### Workflow 2: Creating System Documentation
1. Start documentation: `wsm start "System Configuration Guide"`
2. Document the system configuration process
3. Check status as needed: `wsm status`
4. Finalize documentation: `wsm stop`

### Workflow 3: Hybrid Approach for Complex Tasks
1. Start documentation context: `wsm start "AWS Server Migration"`
2. Start terminal recording for specific section: `wai start -t "AWS CLI commands"`
3. Execute commands and capture output
4. End recording: `Ctrl+D` or `exit`
5. Reference the recording in documentation: `wai view 3`
6. Complete documentation: `wsm stop`

### Workflow 4: Review and Cleanup
1. List recent sessions: `wsm list`
2. Check disk usage: `du -sh ~/Documents/warp-ai-sessions`
3. Clean up old sessions: `wsm cleanup 60`

## Tips for Keeping Sessions Organized

### Naming Conventions
- Use consistent, descriptive session names
- Include key technology in the title: "MongoDB Replication Setup"
- For recurring tasks, include dates: "Weekly Backup - April 2025"

### Content Organization
- Keep session focused on a single topic
- Use markdown formatting in wsm sessions for better readability
- Include expected outcomes at the beginning of a session
- Document errors and their solutions

### Maintenance
- Run `wsm cleanup` regularly (monthly)
- Archive important sessions before cleaning up
- Use `wsm list` to review sessions before deletion

### Search Effectively
- Use `wai search` with specific error messages
- Search for command names to find usage examples
- Remember you can search across both wai and wsm sessions

## Quick Reference

| Task                          | Tool              | Command                                |
|-------------------------------|-------------------|-----------------------------------------|
| Record terminal session       | warp-ai           | `wai start -t "Session name"`          |
| Create documentation session  | warp-session-mgr  | `wsm start "Session name"`             |
| Check active documentation    | warp-session-mgr  | `wsm status`                           |
| Stop documentation session    | warp-session-mgr  | `wsm stop`                             |
| List all sessions             | warp-session-mgr  | `wsm list`                             |
| Search all sessions           | warp-ai           | `wai search "search term"`             |
| View recent session           | warp-ai           | `wai view 1`                           |
| Clean up old sessions         | warp-session-mgr  | `wsm cleanup 30`                       |

## Final Notes

The power of this two-tool approach is in the specialization: `warp-ai` excels at recording terminal output exactly as it appears, while `warp-session-manager` provides better organization and documentation structure. By using both tools appropriately, you can build a comprehensive knowledge base of terminal sessions and documentation.

