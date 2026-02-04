# Setting Up GitHub Repository

Since automatic GitHub repository creation requires authentication, here are manual steps to create and push the OpenClaw Workspace Organizer to GitHub.

## Option 1: Manual GitHub Setup

### 1. Create Repository on GitHub.com
1. Go to [GitHub.com](https://github.com)
2. Click the "+" icon in the top right → "New repository"
3. Repository name: `openclaw-workspace-organizer`
4. Description: "A comprehensive script to organize, secure, and backup any OpenClaw workspace"
5. Set to **Private** (recommended) or Public
6. **DO NOT** initialize with README, .gitignore, or license
7. Click "Create repository"

### 2. Push Local Repository
```bash
# Navigate to organizer directory
cd /tmp/openclaw-organizer

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/openclaw-workspace-organizer.git

# Push to GitHub
git push -u origin main
```

### 3. Set Repository Visibility (Optional)
```bash
# Make repository public (if desired)
gh repo edit --visibility public
# Or keep private
gh repo edit --visibility private
```

## Option 2: Using GitHub CLI

If you have GitHub CLI installed and authenticated:

```bash
# Create repository
gh repo create openclaw-workspace-organizer \
  --description "OpenClaw Workspace Organizer" \
  --private \
  --source=/tmp/openclaw-organizer \
  --remote=origin \
  --push
```

## Option 3: Using GitHub API with Token

```bash
# Set your GitHub token
export GITHUB_TOKEN=your_personal_access_token

# Create repository via API
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d '{
    "name": "openclaw-workspace-organizer",
    "description": "OpenClaw Workspace Organizer",
    "private": true,
    "auto_init": false
  }'

# Then push as in Option 1
```

## Option 4: Fork from Existing Repository

If someone else has already created this repository:

```bash
# Fork the repository
gh repo fork dazeb/openclaw-workspace-organizer

# Clone your fork
git clone https://github.com/YOUR_USERNAME/openclaw-workspace-organizer.git
cd openclaw-workspace-organizer

# Copy the organizer files
cp -r /tmp/openclaw-organizer/* .
git add .
git commit -m "Add organizer scripts"
git push
```

## Verification

After pushing, verify the repository:

```bash
# Check remote
git remote -v

# Check repository on GitHub
gh repo view --web

# Test the one-line installer
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/openclaw-workspace-organizer/main/install.sh | bash
```

## Making it Public

If you want to share the organizer with the OpenClaw community:

1. Change repository visibility to Public
2. Add topics: `openclaw`, `workspace`, `automation`, `organization`
3. Create a release: `gh release create v1.0.0 --title "v1.0.0" --notes "Initial release"`
4. Share the one-line installer URL

## Troubleshooting

### Authentication Issues
```bash
# Login with GitHub CLI
gh auth login

# Or set token manually
export GITHUB_TOKEN=your_token_here
```

### Permission Denied
```bash
# Check SSH keys
ssh -T git@github.com

# Or use HTTPS
git remote set-url origin https://github.com/YOUR_USERNAME/openclaw-workspace-organizer.git
```

### Repository Already Exists
```bash
# Remove existing remote
git remote remove origin

# Add new remote
git remote add origin https://github.com/YOUR_USERNAME/openclaw-workspace-organizer.git

# Force push (if you're sure)
git push -u origin main --force
```

## Next Steps

After setting up the GitHub repository:

1. **Test the installer**: `curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/openclaw-workspace-organizer/main/install.sh | bash`
2. **Create issues template**: Add `.github/ISSUE_TEMPLATE.md`
3. **Add contributing guidelines**: `CONTRIBUTING.md`
4. **Set up GitHub Actions**: For automated testing
5. **Share with community**: Post in OpenClaw Discord/community

## One-line Installer URL

Once published, the installer will be available at:
```
https://raw.githubusercontent.com/YOUR_USERNAME/openclaw-workspace-organizer/main/install.sh
```

Usage:
```bash
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/openclaw-workspace-organizer/main/install.sh | bash
```