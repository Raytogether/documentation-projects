<!--
PROJECT METADATA
----------------
status: Complete - Documentation updated with official Linux shortcuts
phase: Ready for verification
session_path: /home/donaldtanner/Documents/warp-ai-sessions
last_updated: 2025-04-07
current_task: Updated documentation with official Linux shortcuts
next_steps: 
  - Verify shortcuts through practical testing
  - Make adjustments if any discrepancies found
  - Add additional Linux-specific notes where applicable
-->

# Warp Terminal Keyboard Shortcuts - Fedora Linux Guide

## Overview
Comprehensive guide for Warp Terminal keyboard shortcuts and context menus on Fedora Linux, focusing on keyboard-centric power user workflows.

## Quick Reference
Most commonly used Warp Terminal shortcuts:

| Action | Shortcut |
|--------|----------|
| New Terminal Window | `Ctrl+Shift+N` |
| New Tab | `Ctrl+T` |
| Close Tab | `Ctrl+Shift+W` |

| Split Pane Horizontally | `Ctrl+Shift+D` |
| Split Pane Vertically | `Ctrl+Shift+E` |
| Command Palette | `Ctrl+Shift+P` |
| Copy | `Ctrl+Shift+C` |
| Paste | `Ctrl+Shift+V` |

| Access Context Menu | `Menu key` or right-click |

## Table of Contents
1. Context Menus
   - Prompt Window Focus Menu
   - Block Selection Menu
2. Keyboard Access
3. General Shortcuts
4. Power User Tips

## Context Menus

### 1. Prompt Window Focus Menu (Cursor Area)
Location: Right-click at the terminal cursor/prompt area

Menu Items:
- Paste (`Ctrl+Shift+V`)
- Copy (`Ctrl+Shift+C`)
- Share Session (Create shareable URL of terminal session)
- Command Search (`Ctrl+Shift+R`)

- AI Command Search (`Alt+Space`)

- Hide Input hint text (Toggle visibility of hint text)
- Split pane right (`Ctrl+Shift+E`)
- Split pane down (`Ctrl+Shift+D`)
- Clear (`Ctrl+L`)
- Terminal Settings
- Help
- Keyboard Shortcuts

Keyboard Access: First select text using keyboard (`Shift+Arrow keys`), then press the dedicated Menu key to open this context menu. On keyboards without a Menu key, right-click on the selected text will open the context menu.
thout a Menu key, right-click will open the context menu.

### 2. Block Selection Menu
Location: Right-click on selected text/block area

Menu Items:
- Copy (`Ctrl+Shift+C`)
- Cut (`Ctrl+Shift+X`)
- Paste (`Ctrl+Shift+V`)
- Copy as RTF
- Select All (`Ctrl+A`)
- Open URL (if URL is selected)
- Search with Google (if text is selected)
- AI Explain Selected Command
- AI Fix Selected Command
- AI Improve Selected Command
- Custom Actions (if configured)

Differences from Prompt Menu:
- Includes text manipulation options (Copy, Cut, Select All)
- Contains AI actions specific to selected text/commands
- Provides web-related actions for selected content
- Lacks terminal management options (Split pane, etc.)

Keyboard Access: First select text using keyboard (`Shift+Arrow keys`), then press `Shift+F10` or the dedicated Menu key to open this context menu.

## General Warp Terminal Shortcuts

### Navigation
- Switch to next tab: `Ctrl+Tab`
- Switch to previous tab: `Ctrl+Shift+Tab`
- Navigate to tab by number: `Ctrl+[1-9]`
- Focus next pane: `Alt+Arrow keys`
- Maximize/minimize pane: `Ctrl+Shift+Enter`
- Scroll up/down: `Shift+PgUp/PgDn`
- Search in terminal: `Ctrl+F`

### Terminal Operations
- New terminal window: `Ctrl+Shift+N`
- New tab: `Ctrl+T`
- Close tab: `Ctrl+Shift+W`
- Clear terminal: `Ctrl+L`
- Zoom in: `Ctrl+Plus` or `Ctrl+=`
- Zoom out: `Ctrl+Minus` or `Ctrl+-`
- Reset zoom: `Ctrl+0`
- Split pane horizontally: `Ctrl+Shift+D`
- Split pane vertically: `Ctrl+Shift+E`
- Command palette: `Ctrl+Shift+P`

### Command History
- Command history search: `Ctrl+R`
- Previous command: `Up Arrow`
- Next command: `Down Arrow`
- Delete to start of line: `Ctrl+U`
- Delete to end of line: `Ctrl+K`
- Move cursor to start of line: `Ctrl+A`
- Move cursor to end of line: `Ctrl+E`

### AI Features
- AI Command Search: `Alt+Space`
- AI Command Menu: Right-click on selected text, then choose AI option
- AI Explain Selection: Select text + Context menu > AI Explain
- AI Fix Selection: Select text + Context menu > AI Fix
- AI Improve Selection: Select text + Context menu > AI Improve

## Power User Tips

### Warp Notebook Features (Linux)
- Execute command blocks: `Ctrl+Enter`
- Navigate between blocks: `Ctrl+Shift+↑` and `Ctrl+Shift+↓`
- Clear command output: `Ctrl+L`
- Create new block: `Enter` at the end of current block
- Edit previous command: `Up Arrow`
- Select entire command block: `Ctrl+A` in the block

### Keyboard-First Workflow Recommendations
- Master the command history search (`Ctrl+R`) to quickly find and reuse previous commands
- Use keyboard shortcuts for split panes instead of right-click menu
- Learn to navigate between panes with `Alt+Arrow keys` for multi-tasking
- Use `Ctrl+A` and `Ctrl+E` to jump to the beginning and end of command lines
- Combine `Ctrl+U` and `Ctrl+Y` to cut and paste entire command lines

### Efficiency Techniques
- Create aliases for frequently used commands in your `.bashrc` or `.zshrc`
- Use tab completion aggressively to reduce typing
- Leverage the AI Command Search (`Alt+Space`) for complex commands you don't remember
- When working with blocks of text, use keyboard selection (`Shift+Arrow keys`) followed by `Ctrl+Shift+C` to copy
- Use `Ctrl+L` to clear screen instead of typing `clear`
- Use `Alt+Arrow` keys to navigate between panes in split view

### Custom Shortcut Configurations
- Access Terminal Settings through the context menu to customize keyboard shortcuts
- Consider remapping less-used shortcuts to actions you perform frequently
- Create custom keybindings for common git operations
- Set up custom AI actions for project-specific tasks
- Configure your terminal theme to highlight important information with color

### Session Management
- Share sessions with colleagues using the "Share Session" context menu option
- Set up named workspaces for different projects
- Use split panes for related tasks rather than multiple tabs for better visibility
- Use command blocks in Warp's notebook interface for better organization
- Use `Ctrl+Shift+P` to access Command Palette for less common actions

### Linux-Specific Notes
- Warp Terminal on Linux uses `Ctrl` for most shortcuts that use `Cmd` on macOS
- The Menu key on Linux keyboards can be used to access context menus
- Warp supports standard Linux terminal keybindings (`Ctrl+A`, `Ctrl+E`, etc.)
- Terminal colors and themes follow system settings on Fedora Linux
- Command blocks use `Ctrl+Enter` to execute (instead of `Cmd+Enter` on macOS)
