# Image Generator - Claude Code Plugin / Claude Code 图片生成插件

[English](#english) | [中文](#中文)

---

<a id="english"></a>
## English

AI image generation plugin for Claude Code, powered by GenerateImage API. Built with the Mem9-style hook architecture — automatic auth check on startup, interactive API Key setup on first use.

### Install

**Method 1: Marketplace (Recommended)**

```bash
# Add marketplace
claude plugin marketplace add wolf521/solomkt-image

# Install plugin
claude plugin install image-generator@solomkt-image
```

**Method 2: Manual Install**

```bash
# Clone or download this repository
git clone https://github.com/wolf521/solomkt-image.git
cd solomkt-image

# Windows
powershell -ExecutionPolicy Bypass -File .\setup.ps1

# macOS / Linux
chmod +x setup.sh && ./setup.sh
```

**Method 3: Local Development Install**

```bash
# Install directly from local path
claude plugin install ./plugins/image-generator
```

### Quick Start

After installation, restart Claude Code (or start a new session). The plugin will check your configuration automatically.

In Claude Code, type:

```
/generate-image a cat sitting on a mountain at sunrise
```

**First use:** If you haven't configured an API Key yet, the plugin will guide you through setup — just provide your key when prompted.

### API Key Configuration

The API Key is stored at `${CLAUDE_PLUGIN_DATA}/auth.json` with the following structure:

```json
{
  "base_url": "https://prompt-manager-uat.issmart.com.cn",
  "api_key": "your-api-key",
  "created_at": "2026-04-10T00:00:00.000Z",
  "source": "manual_config"
}
```

**Three ways to configure:**

| Method | Description |
|--------|-------------|
| **Interactive** | Run `/generate-image`, the plugin will guide you through setup on first use |
| **Setup script** | Run `./setup.sh` (macOS/Linux) or `.\setup.ps1` (Windows), enter your key when prompted |
| **Manual** | Create `${CLAUDE_PLUGIN_DATA}/auth.json` with the structure shown above |

**To update an existing API Key**, simply run `/generate-image` — if your key is expired or invalid, the plugin will ask for a new one. Or delete `${CLAUDE_PLUGIN_DATA}/auth.json` and re-run setup.

### Usage Examples

```
/generate-image 一只坐在山顶看日出的猫
/generate-image futuristic city skyline at night, neon lights
/generate-image 水墨画风格的江南水乡
/generate-image a cozy coffee shop interior, warm lighting, detailed illustration
```

### API Reference

| Field | Value |
|-------|-------|
| Endpoint | `https://prompt-manager-uat.issmart.com.cn/app-system-prompt/api/GenerateImage` |
| Method | `POST` |
| Header | `X-API-Key: <your-api-key>` |
| Content-Type | `application/json` |
| Request Body | `{"prompt": "image description"}` |
| Response | `{"imageUrl": "generated image url"}` |

### Project Structure

```
soloMKT-image/
├── .claude-plugin/
│   └── marketplace.json              # Marketplace manifest
├── plugins/
│   └── image-generator/
│       ├── .claude-plugin/
│       │   └── plugin.json           # Plugin metadata
│       ├── hooks/
│       │   ├── hooks.json            # Hook definitions (SessionStart)
│       │   ├── common.sh             # Shared helper library
│       │   ├── session-start.sh      # Auto-check auth on startup
│       │   └── lib/
│       │       └── hook-json.mjs     # JSON parsing helper
│       └── skills/
│           └── generate-image/
│               └── SKILL.md          # /generate-image skill definition
├── setup.sh                          # macOS/Linux manual installer
├── setup.ps1                         # Windows manual installer
└── README.md
```

### Hook Flow

```
SessionStart (startup)
  → Check Node.js
  → Check ${CLAUDE_PLUGIN_DATA}/auth.json
  → If valid: emit "[image-generator] API Key configured."
  → If missing: emit reminder to run /generate-image for setup

User runs /generate-image
  → SKILL.md loads
  → Check auth.json for API Key
  → If missing: ask user for key → write auth.json
  → Call POST /app-system-prompt/api/GenerateImage
  → Display generated image
```

### Troubleshooting

| Problem | Solution |
|---------|----------|
| "API Key not configured" | Run `/generate-image` and provide your API Key when prompted |
| HTTP 401 error | Your API Key is invalid or expired. Delete `auth.json` and re-run `/generate-image` |
| Network timeout | Check your network connection. The API timeout is 120 seconds |
| "Node.js required" | Install Node.js 18+ from https://nodejs.org |
| Plugin not loading | Verify plugin is installed: `claude plugin list` |

### Uninstall

```bash
# Remove plugin
claude plugin uninstall image-generator

# Remove marketplace (optional)
claude plugin marketplace remove solomkt-image

# Clean auth data
rm "${CLAUDE_PLUGIN_DATA}/auth.json"
```

### Security

- API Key is stored locally in `${CLAUDE_PLUGIN_DATA}/auth.json`
- The plugin never prints or logs the API Key
- When displaying config status, keys are always masked (first 4 + last 4 characters shown)
- All API calls use HTTPS

---

<a id="中文"></a>
## 中文

基于 GenerateImage API 的 Claude Code AI 图片生成插件。采用与 Mem9 相同的钩子架构 — 启动时自动检查认证配置，首次使用时交互式引导完成 API Key 设置。

### 安装

**方式一：插件市场安装（推荐）**

```bash
# 添加插件市场
claude plugin marketplace add wolf521/solomkt-image

# 安装插件
claude plugin install image-generator@solomkt-image
```

**方式二：手动安装**

```bash
# 克隆或下载此仓库
git clone https://github.com/wolf521/solomkt-image.git
cd solomkt-image

# Windows
powershell -ExecutionPolicy Bypass -File .\setup.ps1

# macOS / Linux
chmod +x setup.sh && ./setup.sh
```

**方式三：本地开发安装**

```bash
# 从本地路径直接安装
claude plugin install ./plugins/image-generator
```

### 快速开始

安装完成后，重启 Claude Code（或开启新会话）。插件将自动检查您的配置状态。

在 Claude Code 中输入：

```
/generate-image 一只坐在山顶看日出的猫
```

**首次使用：** 如果尚未配置 API Key，插件将引导您完成设置 — 只需按提示提供您的 API Key 即可。

### API Key 配置

API Key 存储在 `${CLAUDE_PLUGIN_DATA}/auth.json`，数据结构如下：

```json
{
  "base_url": "https://prompt-manager-uat.issmart.com.cn",
  "api_key": "your-api-key",
  "created_at": "2026-04-10T00:00:00.000Z",
  "source": "manual_config"
}
```

**三种配置方式：**

| 方式 | 说明 |
|------|------|
| **交互式配置** | 运行 `/generate-image`，插件会在首次使用时引导您配置 |
| **安装脚本** | 运行 `./setup.sh`（macOS/Linux）或 `.\setup.ps1`（Windows），按提示输入 API Key |
| **手动配置** | 按上述结构创建 `${CLAUDE_PLUGIN_DATA}/auth.json` 文件 |

**更新已有 API Key**：直接运行 `/generate-image` — 如果 key 已过期或无效，插件会引导您输入新 key。也可以删除 `${CLAUDE_PLUGIN_DATA}/auth.json` 后重新设置。

### 使用示例

```
/generate-image 一只坐在山顶看日出的猫
/generate-image futuristic city skyline at night, neon lights
/generate-image 水墨画风格的江南水乡
/generate-image a cozy coffee shop interior, warm lighting, detailed illustration
```

### API 参考

| 字段 | 值 |
|------|-----|
| 接口地址 | `https://prompt-manager-uat.issmart.com.cn/app-system-prompt/api/GenerateImage` |
| 请求方法 | `POST` |
| 请求头 | `X-API-Key: <your-api-key>` |
| Content-Type | `application/json` |
| 请求体 | `{"prompt": "图片描述"}` |
| 响应 | `{"imageUrl": "生成的图片链接"}` |

### 项目结构

```
soloMKT-image/
├── .claude-plugin/
│   └── marketplace.json              # 插件市场清单
├── plugins/
│   └── image-generator/
│       ├── .claude-plugin/
│       │   └── plugin.json           # 插件元数据
│       ├── hooks/
│       │   ├── hooks.json            # 钩子定义（SessionStart）
│       │   ├── common.sh             # 共享辅助函数库
│       │   ├── session-start.sh      # 启动时自动检查认证
│       │   └── lib/
│       │       └── hook-json.mjs     # JSON 解析辅助
│       └── skills/
│           └── generate-image/
│               └── SKILL.md          # /generate-image 技能定义
├── setup.sh                          # macOS/Linux 手动安装脚本
├── setup.ps1                         # Windows 手动安装脚本
└── README.md
```

### 钩子流程

```
SessionStart（启动时）
  → 检查 Node.js 环境
  → 检查 ${CLAUDE_PLUGIN_DATA}/auth.json
  → 有效：提示 "[image-generator] API Key 已配置"
  → 缺失：提醒用户运行 /generate-image 进行配置

用户执行 /generate-image
  → 加载 SKILL.md
  → 检查 auth.json 中的 API Key
  → 如果缺失：引导用户输入 → 写入 auth.json
  → 调用 POST /app-system-prompt/api/GenerateImage
  → 展示生成的图片
```

### 常见问题

| 问题 | 解决方案 |
|------|----------|
| "API Key 未配置" | 运行 `/generate-image` 并按提示提供 API Key |
| HTTP 401 错误 | API Key 无效或已过期。删除 `auth.json` 后重新运行 `/generate-image` |
| 网络超时 | 检查网络连接。API 超时时间为 120 秒 |
| "需要 Node.js" | 从 https://nodejs.org 安装 Node.js 18+ |
| 插件未加载 | 验证插件已安装：`claude plugin list` |

### 卸载

```bash
# 移除插件
claude plugin uninstall image-generator

# 移除插件市场（可选）
claude plugin marketplace remove solomkt-image

# 清理认证数据
rm "${CLAUDE_PLUGIN_DATA}/auth.json"
```

### 安全性

- API Key 仅存储在本地 `${CLAUDE_PLUGIN_DATA}/auth.json` 文件中
- 插件不会在任何输出或日志中打印 API Key
- 显示配置状态时 Key 始终被遮盖（只显示前4位和后4位字符）
- 所有 API 调用均使用 HTTPS 加密传输
