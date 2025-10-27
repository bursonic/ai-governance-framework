---
description: Create project memory by asking the user about their project
---

# Memory Create - User-Guided Metadata

You are creating project memory by asking the user about their project plans.

## Context

This command is used when:
- Starting a brand new project (no code exists yet)
- User wants to define project metadata before implementation
- User prefers to describe their project rather than have it auto-discovered

## Important: Metadata Focus

Gather ONLY high-level project metadata. Do NOT ask about:
- Domain models or business logic
- API specifications or interfaces
- Database schemas or data structures
- Implementation details or code patterns

These will be handled by separate processes in later phases.

## Your Task

**Goal**: Gather project metadata through structured questions and create the memory file.

## Instructions

1. **Ask questions systematically** - Go through each metadata category:

   **Project Identity:**
   - What is the project name?
   - What is the purpose of this project? (1-2 sentences)
   - What type of project is this? (Library / Web App / CLI Tool / Service / API / etc.)
   - Where will the repository be located? (optional)

   **Project Structure:**
   - What will be the main directories in your project?
   - What will be your entry point files?
   - Any specific organization pattern you want to follow?

   **Technology Stack:**
   - What programming language(s) will you use?
   - What frameworks or libraries do you plan to use?
   - What package manager? (npm, pip, cargo, maven, etc.)
   - What other key tools? (build tools, testing frameworks, linters, etc.)

   **Development Workflow:**
   - What commands for setup/installation?
   - What commands for development? (dev server, watch mode, etc.)
   - What commands for building?
   - What commands for testing?
   - What is the deployment process? (if known)

   **Team Conventions:**
   - Any specific code organization principles?
   - Any naming conventions to follow?
   - What git workflow? (feature branches, trunk-based, etc.)
   - How will documentation be maintained?

2. **Ask incrementally**:
   - Don't overwhelm with all questions at once
   - Ask 2-3 questions, wait for answers
   - Adapt follow-up questions based on answers
   - Allow "TBD" or "Not sure yet" as valid answers

3. **Create the memory file**:
   - Copy the template from `.claude/templates/memory-structure.md`
   - Create `.ai-gov/memory.md` in the project root
   - Fill in all sections based on user's answers
   - Use [TBD] for anything the user hasn't decided yet
   - Update "Last Updated" with today's date + "Initial memory created from user input"

4. **Output**:
   - Thank the user for the information
   - Show a summary of the captured metadata
   - Inform them the memory file has been created at `.ai-gov/memory.md`
   - Suggest next steps (e.g., "Ready to start specification with /gov-spec-start")

## Success Criteria

- Memory file exists at `.ai-gov/memory.md`
- All sections are filled based on user responses
- Sections user hasn't decided are marked [TBD]
- No domain or implementation details are included
- User feels their vision is accurately captured

## Tips

- Be conversational but efficient
- Validate understanding by summarizing back to user
- If user is uncertain about something, that's fine - mark it [TBD]
- Focus on "what" and "how to work with it", not "why" or "how it works internally"
