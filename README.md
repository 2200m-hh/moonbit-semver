# moonbit-semver

一个用 MoonBit 编写、零第三方依赖的 Semantic Versioning 2.0.0 解析与比较库。

该项目为 2026 MoonBit 国产基础软件生态开源大赛 · 十一月黑客松而做，目标是提供一个边界清晰、可测试、可维护的小而实的基础组件。

## 功能

- 严格解析 `MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]`。
- 校验数字标识符无前导零，预发布标识符字符集合法。
- 按 SemVer 2.0.0 规则比较优先级：主版本/次版本/修订号逐项比较，预发布版本低于正式版本，数字标识符按数值比较，字母数字标识符按字典序比较。
- 保留 build metadata，但按规范在比较时忽略它。
- 提供可运行 demo 与 5 组测试。

## 目录结构

```
moonbit-semver/
├── moon.mod                  # 模块配置
├── README.md                 # 项目说明
├── PROJECT_PROPOSAL.md       # 报名用一页项目说明
├── AI_USAGE.md               # AI 使用说明（赛事验收项）
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE                   # MIT
├── src/
│   ├── moon.pkg              # 库包
│   ├── version.mbt           # 核心实现
│   ├── version_test.mbt      # 测试
│   └── cmd/
│       ├── moon.pkg          # 可执行 demo
│       └── main.mbt
└── .github/
    └── ISSUE_TEMPLATE/
        ├── bug_report.md
        └── feature_request.md
```

## 本地验证

安装 MoonBit 工具链后，在项目根目录执行：

```bash
moon check                 # 类型检查
moon test --target js      # 运行测试（5 passed）
moon run src/cmd --target js
```

> 说明：在部分受限环境中 Wasm 测试运行器可能缺少运行库，此时用 `--target js` 走 Node.js 后端即可正常执行；这不改变代码本身。

预期演示输出：

```
moonbit-semver demo
-------------------
1.0.0-alpha  <  1.0.0
1.0.0-alpha.1  <  1.0.0-alpha.beta
1.0.0-beta.2  <  1.0.0-beta.11
1.0.0+build.1  ==  1.0.0+build.2
parsed: 2.3.4-rc.1+sha.abc123
```

## API 示例

```moonbit
let v = @moonbit-semver.parse("1.0.0-alpha.1+build.5").unwrap()
println(@moonbit-semver.to_string(v))

let a = @moonbit-semver.parse("1.0.0-beta.2").unwrap()
let b = @moonbit-semver.parse("1.0.0-beta.11").unwrap()
println(@moonbit-semver.compare(a, b)) // -1
```

核心 API：

| 函数 | 说明 |
| --- | --- |
| `parse(String) -> Result[Version, String]` | 解析版本字符串，失败时返回可读错误 |
| `compare(Version, Version) -> Int` | 返回 `-1 / 0 / 1`，分别表示小于/等于/大于 |
| `to_string(Version) -> String` | 输出规范化版本字符串 |

数据类型：

```moonbit
pub(all) struct Version {
  major : Int
  minor : Int
  patch : Int
  pre : Array[String]
  build : Array[String]
}
```

## 边界与非目标

- 不实现版本范围语法（如 `^1.2.0`）。
- 不实现版本排序的网络分发或包管理逻辑。
- 不引入任何第三方依赖，保证可审计和可复现。

## 开源与 AI 使用

- 许可证：MIT，见 `LICENSE`。
- AI 参与方式与目标、路径、质量责任划分见 `AI_USAGE.md`。
- 本项目为原创实现，未移植其他语言代码，未复制第三方实现。

## 提交前清单（给参赛者）

1. 将 `moon.mod` 中的 `repository` 和本文中的占位 GitHub ID 替换为你的真实 ID。
2. 在 GitHub 新建公开仓库 `moonbit-semver`，把本地仓库推送上去。
3. 在仓库中创建 2 个 Issue（一个 bug 报告、一个功能建议）和 1 个 Pull Request（例如补充测试用例），保留可追踪记录。
4. 按赛事官网飞书表单报名，填入公开仓库地址与 `PROJECT_PROPOSAL.md`。
5. 加入赛事微信群并把群昵称改为你的 GitHub ID（影响奖金发放）。
