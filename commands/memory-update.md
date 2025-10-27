---
description: Update project memory metadata with new learnings
---

# Memory Update - Metadata Only

You are updating project memory for a repository you've already initialized.

## Important: Metadata Focus

Update ONLY high-level project metadata. Do NOT capture:
- Domain models or business logic
- API specifications or interfaces
- Database schemas or data structures
- Implementation details or code patterns

These will be handled by separate storage in later phases.

## Your Task

**Goal**: Read current memory, explore the next metadata aspect, and update memory.

**Follow the Read → Explore → Update cycle**

## Instructions

1. **Read existing memory**:
   - Load `.claude/memory.md`
   - Understand what metadata is already known
   - Identify what sections are still [TBD] or incomplete

2. **Determine next metadata exploration step**:
   - If **Project Identity** is incomplete → check README, package files for name/purpose
   - If **Project Structure** is incomplete → explore directory layout further
   - If **Technology Stack** is [TBD] → identify frameworks and tools from package files
   - If **Development Workflow** is [TBD] → check package.json scripts, Makefile, README for commands
   - If **Team Conventions** is [TBD] → look for .editorconfig, linting configs, CONTRIBUTING.md, git history patterns

3. **Explore incrementally (metadata only)**:
   - Focus on ONE section at a time
   - Stay at the metadata level - don't dive into code
   - Use appropriate tools:
     - `ls`, `tree` for structure
     - `Read` for README, package.json, config files
     - `Bash` with git commands for workflow/conventions
   - Stop at configuration files - don't read implementation code

4. **Update the memory file**:
   - Use the Edit tool to update ONLY the section(s) you explored
   - Keep updates concise and factual
   - Update "Last Updated" section with date and what was updated
   - Preserve all other sections unchanged

5. **Output**:
   - Inform the user what metadata section was updated
   - Show a brief summary of what was learned
   - Suggest what metadata to explore next (if sections remain [TBD])

## Success Criteria

- At least one metadata section is updated
- Updates are accurate and based on actual exploration
- "Last Updated" section reflects the changes
- No domain or implementation details are included
- The file remains well-structured and readable
- Progress is incremental and focused

## Tips

- Prioritize sections based on user's immediate needs
- If user asks to explore something specific, focus on that
- Don't overwrite good existing information
- Keep the memory file concise - it needs to fit in context window
