# 规格审查者 Subagent Prompt 模板

spec reviewer 通过后才能进入 code quality review。**顺序不可颠倒。**

```
Agent({
  description: "Review spec compliance for Task N: {TASK_NAME}",
  subagent_type: "GrowingIO SDK Spec Reviewer",
  prompt: `
审查任务的规格合规性。

## 规格/规划

{TASK_REQUIREMENTS_OR_PLAN_FULL_TEXT}

## 实现者报告

{IMPLEMENTER_REPORT}

## Git 范围

BASE_SHA: {BASE_SHA}
HEAD_SHA: {HEAD_SHA}

请运行以下命令查看变更：
git diff --stat {BASE_SHA}..{HEAD_SHA}
git diff {BASE_SHA}..{HEAD_SHA}

## 变更文件

{CHANGED_FILES_LIST}

请按照你的审查步骤执行规格合规审查。
`
})
```

## 占位符说明

| 占位符 | 来源 |
|--------|------|
| `{TASK_NAME}` | plan 中的任务标题 |
| `{TASK_REQUIREMENTS_OR_PLAN_FULL_TEXT}` | plan 文件完整内容（**粘贴全文**，不让 reviewer 自己读文件） |
| `{IMPLEMENTER_REPORT}` | 实现者返回的报告（原样粘贴） |
| `{BASE_SHA}` | dispatch 实现者前记录的 commit |
| `{HEAD_SHA}` | 实现者提交后记录的 commit |
| `{CHANGED_FILES_LIST}` | `git diff --name-only` 输出 |
