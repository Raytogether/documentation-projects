<!--
PROJECT METADATA
----------------
status: Active Framework
phase: Documentation Standards
session_path: /home/donaldtanner/Documents/warp-ai-sessions
last_updated: 2025-04-07
current_task: Define comprehensive documentation framework and rules
next_steps:
  - Create example templates
  - Test framework with sample project
-->

# Documentation Framework Standards

## Overview
Standard structure and practices for all documentation projects, ensuring consistency and maintainability.

## Project Organization

### Directory Structure
```
~/Documents/[Project-Name]/
├── [ProjectName].md         # Main documentation
├── [ProjectName].txt        # Text version
├── [ProjectName].rtf        # Rich Text version
├── PROJECT_STATUS.md        # Project tracking
├── assets/                  # Images and diagrams
├── templates/               # Reusable sections
├── archive/                 # Older versions
└── .git/                    # Version control
```

### Required Files
1. Main Documentation ([ProjectName].md)
   - Project metadata header
   - Structured content sections
   - Clear hierarchy of information

2. Generated Formats
   - .txt version (via sync_docs.sh)
   - .rtf version (via sync_docs.sh)

3. Project Status (PROJECT_STATUS.md)
   - Current status
   - Verification needs
   - Project location
   - Next steps

### Metadata Header Format
```
<!--
PROJECT METADATA
----------------
status: [current status]
phase: [current phase]
version: [X.Y.Z]
author: [author name]
session_path: /home/donaldtanner/Documents/warp-ai-sessions
last_updated: [YYYY-MM-DD]
review_date: [YYYY-MM-DD]
current_task: [current focus]
dependencies:
  - [dependency 1]
  - [dependency 2]
related_projects:
  - [related project 1]
  - [related project 2]
next_steps:
  - [step 1]
  - [step 2]
-->
```

## Version Control Standards
1. Git Repository Requirements:
   - Initialize in project root
   - Regular meaningful commits
   - Track all project files (.md, .txt, .rtf)
   - Commit after significant changes

2. Git Branch Strategy:
   - main: stable, production-ready documentation
   - develop: work in progress documentation
   - feature/[name]: for significant additions
   - fix/[name]: for corrections and updates

3. Commit Message Format:
   - Structure: [type]: [brief description]
   - Types: docs, fix, feat, style, refactor
   - Example: "docs: Add server configuration section"
   - Include task reference when applicable

4. Tag Versioning Rules:
   - Format: vX.Y.Z
   - X: Major version (breaking changes)
   - Y: Minor version (new content, non-breaking)
   - Z: Patch version (fixes, small updates)
   - Tag after significant milestones

5. Automation Integration:
   - Use ~/bin/sync_docs.sh for format conversions
   - Manual Dropbox management
   - Maintain backup schedule via cron jobs
   - Generate PDF exports for distribution
   - Create HTML versions for web viewing
   - Automatic version number updates in files

## AI Session Management
### Template Prompts for Common Tasks
```bash
# Project initialization
"Initialize a new documentation project called [name] about [purpose]"

# Section expansion
"Expand the [section name] section with detailed information about [topic]"

# Review and refinement
"Review the current document for clarity, structure, and completeness"
```

### Starting New Projects
```bash
cd ~/Documents
mkdir [Project-Name]
cd [Project-Name]
cat ~/Documents/Documentation-Templates/Documentation-Framework.md
"I'd like to start a new documentation project following my framework above."
```

### Resuming Projects
```bash
cd ~/Documents/[Project-Name]
cat PROJECT_STATUS.md
"I'd like to resume this project. Above is the current status."
```

### Session Archival Strategy
- Archive AI sessions in ~/Documents/warp-ai-sessions/[Project-Name]/
- Name sessions with date prefix: YYYY-MM-DD-[description].md
- Maintain index of sessions in PROJECT_STATUS.md
- Reference significant sessions in documentation

### Progress Tracking Commands
```bash
# Check project status
cat PROJECT_STATUS.md

# View recent changes
git log -p -5

# Track completion percentage
grep -c "COMPLETED:" PROJECT_STATUS.md

# List outstanding tasks
grep "TODO:" PROJECT_STATUS.md
```
```

## File Naming Conventions
- Project directories: Title-Case-With-Hyphens
- Main doc: PascalCase.md
- Generated files: Same as main doc (.txt, .rtf)
- Status file: PROJECT_STATUS.md

## Best Practices

### Documentation Structure
- Clear hierarchical headers
- Consistent formatting
- Regular status updates
- Meaningful commit messages

### Content Organization
- Logical section grouping
- Progressive information flow
- Clear next steps
- Regular verification points

### Maintenance
- Regular status updates
- Consistent metadata updates
- Regular format conversions
- Git commit after significant changes

## Creating New Projects
1. Show framework to AI
2. Specify project name and purpose
3. Initialize following standards:
   - Create directory structure
   - Set up initial files
   - Initialize git repository
   - Run sync_docs.sh
4. Begin documentation process

## Framework Usage
1. Reference this document for new projects
2. Follow established conventions
3. Maintain all required files
4. Keep status updated
5. Use sync_docs.sh for conversions
