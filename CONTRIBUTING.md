# Contributing to Documentation Hub

Thank you for your interest in contributing to the Documentation Hub! This guide will help you understand our documentation standards and contribution process.

## 📋 Contribution Process Overview

1. **Find or Create an Issue**: Before starting work, check if there's an existing issue for the documentation you want to add or update.
2. **Fork and Clone**: Fork the repository and clone it to your local machine.
3. **Create a Branch**: Create a branch for your changes (`git checkout -b feature/your-feature-name`).
4. **Make Changes**: Update or add documentation following the style guide below.
5. **Test Locally**: Build the site locally to ensure your changes appear correctly.
6. **Submit a Pull Request**: Push your changes and create a pull request.
7. **Review Process**: Your changes will be reviewed, and you may be asked to make adjustments.
8. **Merge**: Once approved, your changes will be merged into the main branch.

## 📝 Documentation Style Guide

### Markdown Formatting

- Use Markdown for all documentation files
- Include a table of contents for pages longer than 500 words
- Use proper heading hierarchy (H1 for title, H2 for main sections, etc.)
- Use **bold** for emphasis, *italic* for terminology, and `code` for code snippets
- Use fenced code blocks with language specification for multi-line code:

```bash
# This is a code example
echo "Hello World"
```

### Images and Media

- Store images in an `/assets/images/` directory within the relevant section
- Use descriptive filenames for images (e.g., `backup-strategy-diagram.png`)
- Include alt text for all images
- Optimize images for web before committing

### Links

- Use relative links for internal documentation
- Use descriptive link text rather than "click here" or "this link"
- Verify all external links are working before submitting

## 📁 File Naming Conventions

- Use lowercase for all filenames
- Use hyphens (-) instead of spaces or underscores
- Use descriptive names that reflect the content
- Place section index files in `index.md`
- Use the `.md` extension for all markdown files

Examples:
- `keyboard-shortcuts.md`
- `backup-implementation-guide.md`

## 📄 Front Matter Requirements

All Jekyll pages require proper front matter. Use this template:

```yaml
---
layout: default
title: Your Page Title
description: A brief but descriptive summary of the page content
---
```

Additional front matter options:
- `author`: Document author (optional)
- `date`: Last update date (YYYY-MM-DD format)
- `tags`: Comma-separated list of related tags
- `category`: Primary category for the document

## 🔀 Pull Request Process

1. **Create a descriptive PR title**: Clearly explain what your contribution adds or modifies
2. **Link to relevant issues**: Reference any issues your PR addresses
3. **Describe your changes**: Provide context for what you've done and why
4. **Self-review checklist**: 
   - [ ] Documentation builds without errors
   - [ ] Links are working
   - [ ] Images display correctly
   - [ ] Content follows style guide
   - [ ] Spell check completed
5. **Respond to feedback**: Be responsive to reviewer comments

## 💻 Local Development Setup

To test your changes locally:

1. Install prerequisites:
   ```bash
   # Install Ruby (if not already installed)
   sudo apt-get install ruby-full build-essential zlib1g-dev

   # Install Bundler
   gem install bundler
   ```

2. Clone the repository and install dependencies:
   ```bash
   git clone https://github.com/YOUR-USERNAME/documentation-projects.git
   cd documentation-projects/docs
   bundle install
   ```

3. Run the local Jekyll server:
   ```bash
   bundle exec jekyll serve
   ```

4. View your site at `http://localhost:4000/documentation-projects/`

## 🔍 Content Review Guidelines

Your contribution will be reviewed for:

- **Technical accuracy**: Is the information correct?
- **Completeness**: Does it cover the topic thoroughly?
- **Clarity**: Is it easy to understand?
- **Consistency**: Does it follow our style guide?
- **Value**: Does it provide useful information?

## ❓ Questions?

If you have any questions about contributing, please open an issue or reach out to the repository maintainers. We're happy to help!

---

Thank you for helping improve our documentation!

