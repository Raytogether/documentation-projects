# Documentation Hub

A centralized repository for all personal documentation projects using Jekyll and GitHub Pages.

## 🌐 Live Site

Visit the live documentation hub at [https://raytogether.github.io/documentation-projects/](https://raytogether.github.io/documentation-projects/)

## 📋 Project Overview

This repository contains a collection of documentation projects organized into a cohesive documentation hub. The documentation covers various topics including:

- Comprehensive Backup Strategy
- Warp Terminal Keyboard Shortcuts and Tips
- Learning Resources for Git and Coding
- SSH Configuration and Security
- Additional technical guides and reference materials

Each section follows established documentation standards with consistent formatting, navigation, and structure.

## 📁 Directory Structure

```
docs/
├── _config.yml            # Jekyll configuration
├── Gemfile                # Ruby dependencies
├── index.md               # Main landing page
├── backup-strategy/       # Backup documentation
├── warp/                  # Warp terminal documentation
│   ├── keyboard-shortcuts/
│   └── tips-tricks/
├── learning/              # Learning resources
│   ├── git-journey/
│   └── journey-to-code/
└── ssh/                   # SSH documentation
```

## 🛠️ Technologies Used

- **Jekyll**: Static site generator
- **GitHub Pages**: Hosting platform
- **Markdown**: Content formatting
- **Ruby**: Required for Jekyll
- **Minima Theme**: Base Jekyll theme
- **Jekyll Plugins**: 
  - jekyll-feed
  - jekyll-seo-tag
  - jekyll-sitemap

## 🚀 Setup and Deployment

### GitHub Pages Deployment

This repository is configured to automatically deploy to GitHub Pages from the `gh-pages` branch. Any changes pushed to this branch will be automatically built and deployed.

To deploy changes:

1. Clone the repository
2. Make your changes
3. Commit and push to the `gh-pages` branch

```bash
git add .
git commit -m "Description of changes"
git push origin gh-pages
```

### Local Development

To run this documentation site locally:

1. Install Ruby and Bundler
2. Clone this repository
3. Install dependencies
4. Run the Jekyll server

```bash
# Install dependencies
cd docs
bundle install

# Start the Jekyll server
bundle exec jekyll serve
```

The site will be available at `http://localhost:4000/documentation-projects/`.

## 📝 Documentation Standards

All documentation in this repository follows these standards:

- Consistent front matter in Markdown files
- Clear table of contents for navigation
- Proper heading hierarchy
- Code examples with syntax highlighting where applicable
- Cross-linking between related documents
- Responsive design for mobile compatibility

## 📄 License

Content is licensed under MIT License unless otherwise specified.

## 🤝 Contributing

If you'd like to contribute to this documentation:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

Please follow the existing documentation standards when contributing new content.

