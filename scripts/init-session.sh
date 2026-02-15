#!/bin/bash
# Initialize planning files under docs/ directory
# Usage: ./init-session.sh [project-name]

set -e

PROJECT_NAME="${1:-project}"
DATE=$(date +%Y-%m-%d)
DOCS_DIR="docs"

echo "Initializing planning files for: $PROJECT_NAME"

# Create docs directory if it doesn't exist
mkdir -p "$DOCS_DIR"

# Create docs/task_plan.md if it doesn't exist
if [ ! -f "$DOCS_DIR/task_plan.md" ]; then
    cat > "$DOCS_DIR/task_plan.md" << 'EOF'
# Task Plan: [Brief Description]

## Goal
[One sentence describing the end state]

## Current Phase
Phase 1

## Phases

### Phase 1: Requirements & Discovery
- [ ] Understand user intent
- [ ] Identify constraints
- [ ] Document in findings.md
- **Status:** in_progress

### Phase 2: Planning & Structure
- [ ] Define approach
- [ ] Create project structure
- **Status:** pending

### Phase 3: Implementation
- [ ] Execute the plan
- [ ] Write to files before executing
- **Status:** pending

### Phase 4: Testing & Verification
- [ ] Verify requirements met
- [ ] Document test results
- **Status:** pending

### Phase 5: Delivery
- [ ] Review outputs
- [ ] Deliver to user
- **Status:** pending

## Decisions Made
| Decision | Rationale |
|----------|-----------|

## Errors Encountered
| Error | Resolution |
|-------|------------|
EOF
    echo "Created $DOCS_DIR/task_plan.md"
else
    echo "$DOCS_DIR/task_plan.md already exists, skipping"
fi

# Create docs/findings.md if it doesn't exist
if [ ! -f "$DOCS_DIR/findings.md" ]; then
    cat > "$DOCS_DIR/findings.md" << 'EOF'
# Findings & Decisions

## Requirements
-

## Research Findings
-

## Technical Decisions
| Decision | Rationale |
|----------|-----------|

## Issues Encountered
| Issue | Resolution |
|-------|------------|

## Resources
-
EOF
    echo "Created $DOCS_DIR/findings.md"
else
    echo "$DOCS_DIR/findings.md already exists, skipping"
fi

# Create docs/progress.md if it doesn't exist
if [ ! -f "$DOCS_DIR/progress.md" ]; then
    cat > "$DOCS_DIR/progress.md" << EOF
# Progress Log

## Session: $DATE

### Current Status
- **Phase:** 1 - Requirements & Discovery
- **Started:** $DATE

### Actions Taken
-

### Test Results
| Test | Expected | Actual | Status |
|------|----------|--------|--------|

### Errors
| Error | Resolution |
|-------|------------|
EOF
    echo "Created $DOCS_DIR/progress.md"
else
    echo "$DOCS_DIR/progress.md already exists, skipping"
fi

echo ""
echo "Planning files initialized!"
echo "Files: $DOCS_DIR/task_plan.md, $DOCS_DIR/findings.md, $DOCS_DIR/progress.md"
