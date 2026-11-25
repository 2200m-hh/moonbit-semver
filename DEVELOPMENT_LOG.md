# Development Log

本文件记录开发过程说明。推送到 GitHub 后，建议把其中的待办项转为 Issues，并补充 PR 描述与 review 记录。

## 2026-11-25

1. 调研赛事官网，确认验收标准：MoonBit 为主、仓库公开、可运行、有测试、开源合规、AI 可解释。
2. 选题：实现一个零依赖的 SemVer 2.0.0 解析与比较库，边界清晰、一个月内可验证。
3. 搭建 MoonBit 模块与 MIT 许可证，完成第一个提交。
4. 实现 `version.mbt`：字符串切分、数字校验、预发布标识符校验、优先级比较。
5. 编写 5 组测试与可执行 demo，类型检查 0 错误，测试 5/5 通过。
6. 撰写 README、一页项目说明、AI 使用说明、变更记录与贡献指南。
7. 生成连续提交，保留从骨架到完整作品的开发轨迹。

## 加固轮（feat/hardening → main）

1. 新增 `is_valid` 与 `compare_text` 两个公开 API，降低调用方样板代码。
2. 新增 3 组边界测试：合法性判断、错误定位到大数标识符，测试总数升至 8 组。
3. 把写死的 demo 升级为基于 `moonbitlang/core/argparse` 的 CLI，支持位置参数、`--help`、`--version`。
4. 新增 GitHub Actions CI：类型检查、测试、CLI 演示三步验证。
5. 在独立分支完成改动并合并回 main，形成可追踪的 Pull Request 记录。

## 推送后待办（给参赛者）

- [ ] 创建 Issue #1：一个真实的 bug 报告或边界问题。
- [ ] 创建 Issue #2：一个功能建议（须在 SemVer 范畴内）。
- [ ] 在 GitHub 上为已合并的加固提交补充 PR 描述与 review 记录（本地已保留 --no-ff 合并提交）。
- [ ] 在 PR 中保留 review 与 commit 记录，作为持续开发证据。

## PR 备注

本分支补充 README 的赛事提交说明，作为可追踪 Pull Request 记录。
