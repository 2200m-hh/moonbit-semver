# 报名与领奖操作卡

作品已经做完，下面是你只需要照着点的事。所有链接来自赛事官网与官方公告。

## 1. 关键信息

| 项目 | 内容 |
| --- | --- |
| 赛事 | 2026 MoonBit 国产基础软件生态开源大赛 · 十一月黑客松 |
| 官网 | https://moonbitlang.github.io/Hackathon2026/ |
| 飞书报名表 | https://bxup9uklfcb.feishu.cn/share/base/form/shrcnWUMlgpbwHaXgzV7HmNhNhg |
| 赛事章程（飞书文档） | https://bxup9uklfcb.feishu.cn/wiki/Dx4Bwd6D1i3GfHkajQCcF7SznEd |
| 赛事微信群 | https://work.weixin.qq.com/gm/5b6b92c8677d0555f3fb6a3f1a081399 |
| 赛事小助手 | https://u.wechat.com/EA2rUlkjobqjS4EeOCKuKdY |
| 免费 | 是 |
| 月度支持 | 审核通过 150 元 + 验收通过 350 元 = 500 元 |
| 推荐奖励 | 50 元/人，最多 5 人（被推荐人需填你的 GitHub ID） |
| 季度奖金 | 一等奖 12,000 元，二等奖 6,000 元，三等奖 3,000 元 |
| 截止 | 官方页面写「以赛事官方通知为准」；第三方公告写 11 月 30 日验收，建议立刻提交 |

## 2. 你 10 分钟内要做的事

1. 在 GitHub 新建一个**公开仓库**，名字建议 `moonbit-semver`。
2. 把本目录 `E:\WorkBuddy\moonbit-semver` 里的文件推送上去：

   ```bash
   cd /e/WorkBuddy/moonbit-semver
   git remote add origin https://github.com/2200m-hh/moonbit-semver.git
   git push -u origin main
   ```

3. 占位 ID 已在 `moon.mod`（`name` / `repository`）、`README.md`、`src/cmd/moon.pkg` 中填入 `2200m-hh`，并已通过 `moon check` 验证。若换账号使用，需同步改这三处。
4. 打开飞书报名表，填入：姓名、GitHub ID、公开仓库地址、一页项目说明（直接用 `PROJECT_PROPOSAL.md` 的内容）。
5. 加入赛事微信群，**把群昵称改成你的 GitHub ID**。官网明确写：不改昵称会影响奖金发放。
6. 在 GitHub 仓库里创建 2 个 Issue（模板已放在 `.github/ISSUE_TEMPLATE/`），再从 main 建一个分支做一个小改进并提交 PR，保留 review 与合并记录。本地已有一条 `--no-ff` 合并记录，但 GitHub 上需要真实的 PR 对象来对应赛事「保留 PR」的要求。
7. 等审核。通过审核后有「启动支持 150 元」，验收通过后「完成支持 350 元」。

## 3. 需要注意的规则

- 赛事明确允许 AI 参与代码生成、接口设计、测试和文档；但参赛者必须能解释技术选择并对质量负责。作品已附 `AI_USAGE.md`，审核时可直接提交。
- 验收标准：MoonBit 为主、仓库公开、有 README/可运行示例/测试、开源合规、AI 可解释。本项目全部满足。
- 已有连续提交与一次独立分支的加固合并，开发轨迹可追踪。
- 奖金涉及实名与收款，必须由你本人完成，我无法代做。
- 三场比赛的完整规则核对表见 `E:\WorkBuddy\COMPLIANCE_CHECK.md`；另外两场文案赛未明确 AI 立场，投稿前请自行改写确认原创。

## 4. 本地验证结果（已完成）

```text
moon check                 → Finished, 0 errors
moon test --target js      → Total tests: 8, passed: 8, failed: 0
moon run src/cmd --target js -- 1.0.0-beta.2 1.0.0-beta.11 → 输出符合 SemVer 2.0.0
```
