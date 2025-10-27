---
description: Initialize project memory metadata for a new repository
---

# Memory Init - Metadata Only

You are initializing project memory for a repository you're seeing for the first time.

## Important: Metadata Focus

This command creates ONLY high-level project metadata. Do NOT capture:
- Domain models or business logic
- API specifications or interfaces
- Database schemas or data structures
- Implementation details or code patterns

These will be handled by separate storage in later phases.

## Your Task

**Goal**: Capture minimal metadata to understand what this project is and how to work with it.

**Step 1 - Focus ONLY on Project Identity and Structure**

## Instructions

1. **Explore the project basics**:
   - Run `ls -la` to see root-level contents
   - Run `tree -L 2` (or equivalent) to see directory hierarchy
   - Identify key files (README, package.json, etc.)
   - Check for project name/purpose in README or package files

2. **Create the memory file**:
   - Copy the template from `templates/memory-structure.md` (if available in the framework)
   - Create `.claude/memory.md` in the project root
   - Fill in ONLY these sections:
     - **Last Updated**: Today's date + "Initial memory creation"
     - **Project Identity**: Name, purpose (1-2 sentences), type, repo
     - **Project Structure**: Root layout, key directories, entry points
     - **Technology Stack**: Languages and package manager (what's obvious from files)
   - Leave all other sections as-is (with placeholder text)

3. **Keep it minimal and metadata-focused**:
   - Don't read source code
   - Only scan README/package files for name and basic purpose
   - Don't explore implementation details
   - Use [TBD] for sections you can't fill from surface observation

4. **Output**:
   - Inform the user that memory has been initialized
   - Show the Project Identity and Project Structure sections
   - Suggest next steps (e.g., "Run /memory-update to fill in remaining metadata")

## Success Criteria

- Memory file exists at `.claude/memory.md`
- Project Identity section has name, purpose, type
- Project Structure section shows directory layout
- Technology Stack has language and package manager
- All other sections remain as placeholders
- No domain or implementation details are included
