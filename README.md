# Planning with Files (docs/ edition)

> Fork of [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) — 将规划文件统一放到 `docs/` 目录，精简模板，适配实验开发规范。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blue)](https://code.claude.com/docs/en/plugins)
[![Based on](https://img.shields.io/badge/Based%20on-OthmanAdi%2Fplanning--with--files-gray)](https://github.com/OthmanAdi/planning-with-files)

## What is this?

A Claude Code skill that uses persistent markdown files as "working memory on disk" — the pattern from [Manus AI's context engineering](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus).

For every complex task, it creates 3 files to track planning, findings, and progress:

```
docs/
├── task_plan.md    # Phases, progress, decisions, errors
├── findings.md     # Research discoveries, technical decisions, resources
└── progress.md     # Session log, test results, error details
```

## Install

```
/plugin marketplace add linjh1118/planning-with-files
/plugin install planning-with-files@linjh1118-planning-with-files
```

Then use `/plan` to start a planning session, or `/plan:status` to check progress.

## What changed from upstream?

This fork makes two main changes:

### 1. Planning files go to `docs/` instead of project root

The original skill creates `task_plan.md`, `findings.md`, `progress.md` directly in the project root. This fork moves them all under `docs/`:

| Before (upstream) | After (this fork) |
|---|---|
| `./task_plan.md` | `./docs/task_plan.md` |
| `./findings.md` | `./docs/findings.md` |
| `./progress.md` | `./docs/progress.md` |

This keeps your project root clean and matches the common convention of putting documentation under `docs/`.

**All references updated:** hooks (`PreToolUse`, `PostToolUse`), init script (`init-session.sh`), completion checker (`check-complete.sh`), and commands (`plan.md`, `status.md`).

### 2. Templates simplified — removed tutorial comments

The original templates are heavily annotated with HTML comments explaining WHAT/WHY/WHEN/EXAMPLE for every section. This is great for learning but noisy for daily use:

**Before** (131 lines for task_plan.md):
```markdown
### Phase 1: Requirements & Discovery
<!--
  WHAT: Understand what needs to be done and gather initial information.
  WHY: Starting without understanding leads to wasted effort. This phase prevents that.
-->
- [ ] Understand user intent
- [ ] Identify constraints and requirements
- [ ] Document findings in findings.md
- **Status:** in_progress
<!--
  STATUS VALUES:
  - pending: Not started yet
  - in_progress: Currently working on this
  - complete: Finished this phase
-->
```

**After** (53 lines):
```markdown
### Phase 1: 需求分析与调研
- [ ] 理解用户意图和约束条件
- [ ] 识别关键需求
- [ ] 记录发现到 findings.md
- **Status:** in_progress
```

Line count reduction across templates:

| File | Before | After | Reduction |
|------|--------|-------|-----------|
| `task_plan.md` | 131 lines | 53 lines | **-60%** |
| `findings.md` | 96 lines | 27 lines | **-72%** |
| `progress.md` | 115 lines | 32 lines | **-72%** |
| `SKILL.md` | 249 lines | 166 lines | **-33%** |

### Other changes

- SKILL.md description translated to Chinese where appropriate
- Removed Windows PowerShell examples (not needed in my environment)
- Removed some low-signal sections (Read vs Write Decision Matrix, 5-Question Reboot Test)
- `init-session.sh` now runs `mkdir -p docs` before creating files

## How it works

The skill uses Claude Code hooks to maintain attention on your plan:

| Hook | Trigger | What it does |
|------|---------|-------------|
| `PreToolUse` | Before Read/Write/Edit/Bash/Glob/Grep | Reads first 30 lines of `docs/task_plan.md` into context |
| `PostToolUse` | After Write/Edit | Reminds to update plan status if a phase was completed |
| `Stop` | Session ending | Checks if all phases are marked complete |

### Core rules

1. **Create Plan First** — Start every complex task with `docs/task_plan.md`
2. **2-Action Rule** — After every 2 search/browse operations, save findings to `docs/findings.md`
3. **Read Before Decide** — Re-read plan before major decisions (hooks do this automatically)
4. **Log ALL Errors** — Track what failed and how you fixed it
5. **3-Strike Protocol** — After 3 failed attempts at the same thing, escalate to user

## Upstream

Original project: [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) (MIT License)

This fork is also MIT licensed.
