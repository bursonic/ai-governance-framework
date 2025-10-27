# Deployment and Update Management Plan

## Problem Statement

Users need to:
1. Easily install this framework in their projects (one command)
2. Get all commands, rules, and templates in the right places
3. Update the framework when new versions are released
4. Preserve their project-specific customizations during updates

## Deployment Approaches

### Option 1: npm Package (if targeting Node.js projects)

**Structure:**
```
@org/ai-governance-framework/
├── bin/
│   └── ai-gov (CLI tool)
├── lib/
│   ├── commands/
│   ├── rules/
│   └── templates/
└── package.json
```

**Installation:**
```bash
npm install -g @org/ai-governance-framework
cd my-project
ai-gov init
```

**Pros:**
- Familiar to JS developers
- Easy version management (npm update)
- Can have dependencies

**Cons:**
- Only works well for Node.js ecosystem
- Overkill if framework is just markdown files

---

### Option 2: Git Submodule

**Structure:**
```
my-project/
├── .claude/
│   └── ai-governance/  (git submodule)
│       ├── commands/
│       ├── rules/
│       └── templates/
└── .gitmodules
```

**Installation:**
```bash
cd my-project
git submodule add <repo-url> .claude/ai-governance
git submodule update --init
```

**Pros:**
- Language agnostic
- Git-native versioning
- Easy to track framework version

**Cons:**
- Submodules can be confusing
- Commands not directly in .claude/commands/ (need symlinks or copying)
- Not intuitive for non-git-experts

---

### Option 3: Install Script + Git Tags

**Structure:**
```
ai-governance-framework/  (this repo)
├── commands/
├── rules/
├── templates/
├── install.sh
└── update.sh
```

**Installation:**
```bash
curl -fsSL https://raw.githubusercontent.com/org/framework/main/install.sh | bash
# or
wget -qO- https://raw.githubusercontent.com/org/framework/main/install.sh | bash
```

**The script does:**
```bash
#!/bin/bash
# Clone framework to temp location
git clone --depth 1 https://github.com/org/framework.git /tmp/ai-gov

# Copy commands to .claude/commands/
mkdir -p .claude/commands
cp /tmp/ai-gov/commands/* .claude/commands/

# Copy templates to project root or .claude/
mkdir -p .claude/templates
cp /tmp/ai-gov/templates/* .claude/templates/

# Copy rules to .claude/
cp /tmp/ai-gov/rules/claude_code.md .claude/

# Record installed version
echo "v1.2.3" > .claude/ai-gov-version

# Cleanup
rm -rf /tmp/ai-gov
```

**Pros:**
- Simple, language agnostic
- Direct installation to right locations
- No extra tools needed
- Can check versions easily

**Cons:**
- Need to trust remote script execution
- Manual update process

---

### Option 4: Template Repository

**Structure:**
Make this repo itself a template repository on GitHub.

**Usage:**
1. Click "Use this template" on GitHub
2. Clone your new repo
3. Delete the framework's working-docs and git history
4. Start using

**Pros:**
- Dead simple
- No installation needed
- Everything is already in place

**Cons:**
- No easy way to get updates
- Each project is disconnected from framework
- Not suitable if framework evolves

---

### Option 5: Hybrid - Local CLI + Git Remote

**Structure:**
```
framework repo with:
├── commands/
├── rules/
├── templates/
├── cli.sh (or cli.py, cli.go, etc.)
└── versions/
    ├── v1.0.0/
    ├── v1.1.0/
    └── v2.0.0/
```

**Installation:**
```bash
# Install CLI globally
curl -fsSL <url>/cli.sh -o ~/bin/ai-gov
chmod +x ~/bin/ai-gov

# In your project
cd my-project
ai-gov install
```

**The CLI does:**
- `ai-gov install` - Install framework in current project
- `ai-gov update` - Update to latest version
- `ai-gov version` - Show installed version
- `ai-gov diff` - Show what changed between versions
- `ai-gov rollback <version>` - Rollback to specific version

**Pros:**
- Best of all worlds
- Easy install and updates
- Version management built-in
- Can diff before updating

**Cons:**
- More complex to build
- Requires maintaining CLI tool

---

## Recommended Solution: Option 3 (Install Script) + Option 5 (CLI) Hybrid

### Phase 1: Simple Install Script
Start with a simple install script for MVP:

```bash
curl -fsSL https://raw.githubusercontent.com/org/framework/main/install.sh | bash
```

### Phase 2: Add Simple CLI
Evolve to a simple shell script CLI:

```bash
# Install CLI
curl -fsSL https://raw.githubusercontent.com/org/framework/main/ai-gov.sh -o /usr/local/bin/ai-gov
chmod +x /usr/local/bin/ai-gov

# Use in projects
ai-gov install [version]
ai-gov update
ai-gov status
```

---

## Update Management Strategy

### Version Tracking

Store version info in project:
```
.claude/
├── ai-gov-version.txt  (content: "v1.2.3")
├── commands/
├── templates/
└── claude_code.md
```

### Update Process

1. **Check for updates:**
   ```bash
   ai-gov check
   # Output: Current: v1.2.3, Latest: v1.3.0
   ```

2. **Show what changed:**
   ```bash
   ai-gov diff v1.2.3 v1.3.0
   # Shows: New commands, modified rules, etc.
   ```

3. **Update:**
   ```bash
   ai-gov update
   # Backs up current version
   # Downloads new version
   # Merges (with conflict detection)
   ```

### Handling Customizations

**Strategy 1: Namespace separation**
```
.claude/commands/
├── memory-init.md           (framework)
├── memory-update.md         (framework)
├── memory-create.md         (framework)
└── custom-my-command.md     (user's - never touched by updates)
```

**Strategy 2: Customization files**
```
.claude/
├── commands/               (framework - can be overwritten)
├── commands-custom/        (user's - never touched)
└── ai-gov-config.json      (user preferences)
```

**Strategy 3: Backup before update**
```bash
ai-gov update
# Creates: .claude/backup-v1.2.3/
# Then updates commands/rules/templates
# If issues: ai-gov rollback
```

---

## Distribution Formats

### Minimal (Phase 1)
- GitHub repository
- Install via curl script
- Manual updates

### Standard (Phase 2)
- GitHub repository with releases
- Simple CLI tool (shell script)
- Automated update checks

### Advanced (Future)
- Package managers (npm, pip, homebrew, etc.)
- Cross-platform CLI (Go binary)
- Plugin system for extensions
- Marketplace for custom commands

---

## Implementation Priority

1. **Now:** Structure this repo for easy copying
2. **Next:** Create install.sh script
3. **Then:** Create simple ai-gov CLI (shell script)
4. **Later:** Package for distribution (npm, pip, etc.)

---

## Decisions Made

### 1. Install Method: Copy Files
**Decision:** Copy all files directly to `.claude/`
- Simple and portable
- Works everywhere without path dependencies
- Clean separation from framework repo

### 2. Conflict Strategy: Always Overwrite
**Decision:** Framework files always replace project versions during updates
- Clean and predictable updates
- User must manually back up any customizations before updating
- Simple to implement and understand

### 3. File Permissions: Read-Only
**Decision:** Mark framework files as read-only after installation
- Prevents accidental edits
- Clear signal that these are framework-managed files
- Users know these will be overwritten on updates

### 4. Customization: Naming Convention
**Decision:** Users add custom commands with `custom-*` or `*-custom` prefix/suffix
- Framework never creates files matching these patterns
- Simple to understand and implement
- Example: `custom-my-feature.md` or `my-feature-custom.md`
- Update scripts will ignore these files

### Implementation Details

**Directory structure after install:**
```
.claude/
├── commands/
│   ├── memory-init.md          (framework, read-only)
│   ├── memory-update.md        (framework, read-only)
│   ├── memory-create.md        (framework, read-only)
│   └── custom-my-command.md    (user's, writable, never touched by updates)
├── templates/
│   └── memory-structure.md     (framework, read-only)
├── claude_code.md              (framework rules, read-only)
└── ai-gov-version.txt          (framework metadata)
```

**Update behavior:**
- Framework files are overwritten
- Files matching `custom-*` or `*-custom` patterns are preserved
- User's `.claude/memory.md` (project memory) is preserved
- Version file is updated

---

## Future Upgrade Path: Option 5 (Full CLI)

### When to Upgrade

Consider upgrading from simple install script (Option 3) to full CLI (Option 5) when:
- Framework has frequent updates
- Users need better version management
- Rollback functionality becomes important
- Community grows and needs better tooling

### Migration Path

**Step 1: Add CLI wrapper**
Create `ai-gov.sh` that wraps existing install/update scripts:
```bash
#!/bin/bash
case "$1" in
  install) ./install.sh "$@" ;;
  update)  ./update.sh "$@" ;;
  version) cat .claude/ai-gov-version.txt ;;
  *)       echo "Usage: ai-gov {install|update|version}" ;;
esac
```

**Step 2: Add version management**
- Create tagged releases (v1.0.0, v1.1.0, etc.)
- Store version metadata in releases
- Add `ai-gov install v1.2.3` to install specific versions

**Step 3: Add diff capability**
- Store checksums of installed files
- Compare against remote versions
- Show `ai-gov diff` before updates

**Step 4: Add rollback**
- Keep backups of previous versions in `.claude/backups/`
- Implement `ai-gov rollback v1.2.3`

**Step 5: Enhanced features**
- `ai-gov check` - Check for updates
- `ai-gov list` - List available versions
- `ai-gov doctor` - Verify installation integrity
- `ai-gov migrate` - Handle breaking changes

### CLI Architecture (Future)

```
ai-gov/
├── ai-gov.sh (or Go binary)
├── lib/
│   ├── install.sh
│   ├── update.sh
│   ├── version.sh
│   ├── diff.sh
│   └── rollback.sh
└── manifest.json (version metadata)
```

### Advanced Features (Long-term)

1. **Interactive Updates:**
   ```bash
   ai-gov update --interactive
   # Shows: memory-init.md changed (3 lines)
   # Prompt: [v]iew diff, [u]pdate, [s]kip
   ```

2. **Selective Updates:**
   ```bash
   ai-gov update --only=commands
   ai-gov update --except=templates
   ```

3. **Configuration File:**
   ```json
   {
     "version": "1.2.3",
     "autoUpdate": false,
     "customPatterns": ["custom-*", "*-custom"],
     "preserveFiles": [".claude/memory.md"]
   }
   ```

4. **Plugin System:**
   ```bash
   ai-gov plugin install community/advanced-planning
   ai-gov plugin list
   ai-gov plugin update
   ```

### Migration Strategy for Users

When upgrading from Option 3 to Option 5:
1. Existing installations continue to work
2. Users install new CLI: `curl -fsSL <url>/ai-gov.sh -o /usr/local/bin/ai-gov`
3. First run detects existing installation: `ai-gov migrate`
4. Migrate creates version tracking for existing files
5. All future operations use new CLI

### Backward Compatibility

- Option 5 CLI must support Option 3 installations
- `install.sh` continues to work standalone
- CLI is optional enhancement, not requirement
