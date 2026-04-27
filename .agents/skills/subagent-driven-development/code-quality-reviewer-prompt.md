# 代码质量审查者 Subagent Prompt 模板

**只在 spec reviewer 通过后才 dispatch。**

```
Agent({
  description: "Code quality review for Task N: {TASK_NAME}",
  subagent_type: "GrowingIO SDK Code Reviewer",
  prompt: `
审查代码质量。

## 变更内容

{CHANGE_DESCRIPTION}

## 对应规划

{PLAN_FILE_PATH}

## Git 范围

BASE_SHA: {BASE_SHA}
HEAD_SHA: {HEAD_SHA}

请运行以下命令查看变更：
git diff --stat {BASE_SHA}..{HEAD_SHA}
git diff {BASE_SHA}..{HEAD_SHA}

## 变更文件

{CHANGED_FILES_LIST}

请按照你的审查步骤执行代码质量审查。
`
})
```

## 占位符说明

| 占位符 | 来源 |
|--------|------|
| `{CHANGE_DESCRIPTION}` | 本次完成了什么（简短描述） |
| `{PLAN_FILE_PATH}` | plan 文件路径（供参考背景） |
| `{BASE_SHA}` | 任务开始前的 commit |
| `{HEAD_SHA}` | 实现者提交后的 commit |
| `{CHANGED_FILES_LIST}` | `git diff --name-only` 输出 |
