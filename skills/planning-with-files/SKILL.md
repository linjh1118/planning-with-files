---
name: planning-with-files
version: "2.10.0"
description: Implements Manus-style file-based planning for complex tasks. Creates docs/task_plan.md, docs/findings.md, and docs/progress.md under the docs/ folder. Use when starting complex multi-step tasks, research projects, or any task requiring >5 tool calls. Now with automatic session recovery after /clear.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - WebFetch
  - WebSearch
hooks:
  PreToolUse:
    - matcher: "Write|Edit|Bash|Read|Glob|Grep"
      hooks:
        - type: command
          command: "cat docs/task_plan.md 2>/dev/null | head -30 || true"
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "echo '[planning-with-files] File updated. If this completes a phase, update docs/task_plan.md status.'"
  Stop:
    - hooks:
        - type: command
          command: |
            SCRIPT_DIR="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/plugins/planning-with-files}/scripts"

            IS_WINDOWS=0
            if [ "${OS-}" = "Windows_NT" ]; then
              IS_WINDOWS=1
            else
              UNAME_S="$(uname -s 2>/dev/null || echo '')"
              case "$UNAME_S" in
                CYGWIN*|MINGW*|MSYS*) IS_WINDOWS=1 ;;
              esac
            fi

            if [ "$IS_WINDOWS" -eq 1 ]; then
              if command -v pwsh >/dev/null 2>&1; then
                pwsh -ExecutionPolicy Bypass -File "$SCRIPT_DIR/check-complete.ps1" 2>/dev/null ||
                powershell -ExecutionPolicy Bypass -File "$SCRIPT_DIR/check-complete.ps1" 2>/dev/null ||
                sh "$SCRIPT_DIR/check-complete.sh"
              else
                powershell -ExecutionPolicy Bypass -File "$SCRIPT_DIR/check-complete.ps1" 2>/dev/null ||
                sh "$SCRIPT_DIR/check-complete.sh"
              fi
            else
              sh "$SCRIPT_DIR/check-complete.sh"
            fi
---

# Planning with Files

用持久化的 markdown 文件作为"磁盘上的工作记忆"，所有规划文件统一放在项目的 `docs/` 目录下。

## FIRST: Check for Previous Session

**Before starting work**, check for unsynced context from a previous session:

```bash
$(command -v python3 || command -v python) ${CLAUDE_PLUGIN_ROOT}/scripts/session-catchup.py "$(pwd)"
```

If catchup report shows unsynced context:
1. Run `git diff --stat` to see actual code changes
2. Read current planning files under `docs/`
3. Update planning files based on catchup + git diff
4. Then proceed with task

## Where Files Go

All planning files go under your **project's `docs/` directory** (create it if not exists):

| File | Purpose | When to Update |
|------|---------|----------------|
| `docs/task_plan.md` | 任务路线图：阶段划分、进度、决策、错误记录 | 每个阶段完成后 |
| `docs/findings.md` | 知识库：研究发现、技术决策、资源链接 | 每次有新发现时 |
| `docs/progress.md` | 会话日志：行动记录、测试结果、错误详情 | 整个会话过程中 |

> **Templates** are in `${CLAUDE_PLUGIN_ROOT}/templates/` for reference.

## Quick Start

Before ANY complex task:

1. `mkdir -p docs` — 确保 docs 目录存在
2. **Create `docs/task_plan.md`** — 参考 [templates/task_plan.md](templates/task_plan.md)
3. **Create `docs/findings.md`** — 参考 [templates/findings.md](templates/findings.md)
4. **Create `docs/progress.md`** — 参考 [templates/progress.md](templates/progress.md)
5. **Re-read plan before decisions** — 在注意力窗口中刷新目标
6. **Update after each phase** — 标记完成、记录错误

## Core Pattern

```
Context Window = RAM (volatile, limited)
Filesystem     = Disk (persistent, unlimited)

→ 重要的东西都写到磁盘上。
```

## Critical Rules

### 1. Create Plan First
开始复杂任务前必须先创建 `docs/task_plan.md`，没有例外。

### 2. The 2-Action Rule
> 每执行 2 次搜索/浏览操作后，**立即**将关键发现写入 `docs/findings.md`。

防止多模态信息（图片、浏览器内容）随上下文丢失。

### 3. Read Before Decide
做重要决策前，重新读取 plan 文件。将目标拉回到注意力窗口中。

### 4. Update After Act
每个阶段完成后：
- 标记阶段状态：`in_progress` → `complete`
- 记录遇到的错误
- 记录创建/修改的文件

### 5. Log ALL Errors
所有错误都记录到 plan 文件中，避免重复犯同样的错。

### 6. The 3-Strike Error Protocol

```
ATTEMPT 1: 诊断并修复 → 仔细阅读错误，定位根因，精准修复
ATTEMPT 2: 换个方法  → 同样的错误？换工具/库/方案，不要重复失败动作
ATTEMPT 3: 全面反思  → 质疑假设，搜索解决方案，考虑修改计划
3次失败后: 上报用户  → 说明尝试过什么，分享具体错误，请求指导
```

## When to Use This Pattern

**Use for:**
- Multi-step tasks (3+ steps)
- Research tasks
- Building/creating projects
- Tasks spanning many tool calls

**Skip for:**
- Simple questions
- Single-file edits
- Quick lookups

## Scripts

- `scripts/init-session.sh` — Initialize planning files under `docs/`
- `scripts/check-complete.sh` — Verify all phases complete
- `scripts/session-catchup.py` — Recover context from previous session

## Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| 把规划文件放在项目根目录 | 放到 `docs/` 目录下 |
| 说一次目标就忘 | 决策前重新读 plan |
| 悄悄重试不记录错误 | 所有错误记录到 plan 文件 |
| 把大量内容塞在上下文里 | 存到文件中 |
| 马上开始执行 | 先创建 plan 文件 |
| 重复失败的操作 | 记录尝试，改变方法 |
