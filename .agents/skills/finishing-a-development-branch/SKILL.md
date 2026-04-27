---
name: finishing-a-development-branch
description: Use after verification-before-completion passes and code review is clean, to close out the development branch
---

# Finishing a Development Branch

> **Type:** Technique | **Discipline:** Rigid

功能做完、验证通过、审查通过后，进入"收尾阶段"。防止一类遗漏：
- **改完就停手**：代码没 commit、分支没合并、PR 没建

**核心原则：** 验证通过 ≠ 任务结束。必须走完收尾四步。

## 四步收尾流程

### Step 1：盘点当前状态

```bash
git status
git log --oneline $(git merge-base HEAD master)..HEAD
git diff --stat master..HEAD
```

回答：工作区有未 commit 的改动吗？本分支比 master 多了几个有意义的 commit？

### Step 2：清理未提交改动

- **属于本次功能** → commit（Angular 规范：`<type>(<scope>): <subject>`）
- **不属于本次功能** → 询问用户保留/丢弃

**禁止：** `git add -A` 或 `git add .`，可能把 `.env` / Pods 等文件一起提交。

### Step 3：选择收尾路径

向用户呈现 4 个选项，不要擅自决定：

```
当前分支 <branch-name> 已准备好收尾，请选择：

A. 合并到 master（直接 merge，无 PR 审查）
B. 创建 PR（走 GitHub 审查流程）
C. 暂时保留分支（继续迭代或等待依赖）
D. 废弃分支（改动不再需要）
```

### Step 4：执行选定路径 + 清理

**路径 A（合并到 master）：**
```bash
git checkout master
git pull
git merge --no-ff <branch-name>
git push
# 清理
git branch -d <branch-name>
git push origin --delete <branch-name>
```

**路径 B（创建 PR）：**
- 按 Angular 规范写 PR title 和 description
- 使用 `gh pr create`

**路径 C/D：** 保留或删除分支

## 禁止行为

| 行为 | 原因 |
|------|------|
| 不问用户直接合并到 master | 合并是不可逆操作 |
| `git add -A` | 容易提交敏感文件 |

## Rationalizations

| Excuse | Reality |
|---|---|
| "验证通过就算完成了" | 没合并/没 PR = 交付还没落地 |
| "直接 push 到 master 快一点" | master 合并必须用户确认 |

## Red Flags

- "验证通过了，done" → 没走完四步就不算完成
- "直接合并到 master，用户不会介意" → 不可逆操作必须用户确认
- "用 `git add .` 快一点" → 可能把 Pods / .env 推上去

## 关联 skill

- **上游触发：** `verification-before-completion` 通过且 `sdk-code-review` 通过
