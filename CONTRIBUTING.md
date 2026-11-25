# Contributing

欢迎为 moonbit-semver 提交 Issue 和 Pull Request。本项目的赛事目标是保留清晰、可追踪的开发过程。

## 提交 Issue

- Bug 报告请包含：输入版本字符串、期望结果、实际结果、MoonBit 工具链版本。
- 功能建议请说明真实使用场景，并明确是否属于 SemVer 2.0.0 范畴。

## 提交 Pull Request

1. 从 `main` 建分支，命名如 `fix/leading-zero-check`。
2. 保持零第三方依赖。
3. 新增或修改行为时，必须补充对应测试。
4. 提交前运行：

```bash
moon check
moon test --target js
moon run src/cmd --target js
```

5. PR 描述中说明改动动机、验证结果和是否影响公开 API。

## 行为准则

- 遵守 SemVer 2.0.0 规范，不引入范围语法等非目标功能。
- 所有公开 API 必须有文档注释。
- 不复制第三方实现；如确需参考，请在 PR 中说明来源与许可证。
