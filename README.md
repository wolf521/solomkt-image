# Claude Code Plugin Marketplace

基于 GenerateImage API 的 Claude Code 插件市场，提供 AI 图片生成能力。

---

## 项目结构

```
soloMKT-image/
├── .claude-plugin/
│   └── marketplace.json              # 市场配置（插件注册表）
├── plugins/
│   └── image-generator/              # Image Generator 插件
│       ├── .claude-plugin/
│       │   └── plugin.json           # 插件元数据
│       ├── commands/
│       │   └── generate-image.md     # /generate-image slash command
│       ├── scripts/
│       │   └── generate_image.py     # API 调用脚本
│       ├── hooks/
│       │   └── hooks.json            # 事件钩子（安装/卸载/命令前检查）
│       └── .mcp.json                 # MCP 服务配置
├── setup.ps1                         # Windows 安装脚本
├── setup.sh                          # macOS/Linux 安装脚本
└── README.md
```

---

## 系统要求

- **Python 3.8+**（已加入系统 PATH）
- **Claude Code**（已安装并可使用）

---

## 安装

### Windows（PowerShell）

```powershell
# 交互式安装（会提示输入 API Key）
powershell -ExecutionPolicy Bypass -File .\setup.ps1

# 非交互式安装
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -ApiKey "your-api-key"
```

### macOS / Linux

```bash
# 交互式安装
chmod +x setup.sh
./setup.sh

# 非交互式安装
./setup.sh "your-api-key"
```

### 手动安装

```bash
# 1. 创建安装目录
mkdir -p ~/.claude-image-plugin

# 2. 复制脚本
cp plugins/image-generator/scripts/generate_image.py ~/.claude-image-plugin/

# 3. 配置 API Key
python ~/.claude-image-plugin/generate_image.py setup --api-key YOUR_API_KEY

# 4. 安装 slash command
mkdir -p ~/.claude/commands
cp plugins/image-generator/commands/generate-image.md ~/.claude/commands/
```

---

## API Key 配置

**首次安装时必须提供 API Key**，这是强制要求。

> 请联系系统管理员获取 API Key。  
> API 服务地址: `https://prompt-manager-uat.issmart.com.cn/app-system-prompt/api/GenerateImage`

API Key 存储位置：
| 系统 | 路径 |
|------|------|
| Windows | `C:\Users\<用户名>\.claude-image-plugin\config.json` |
| macOS/Linux | `~/.claude-image-plugin/config.json` |

更换 API Key：
```bash
python ~/.claude-image-plugin/generate_image.py setup
```

---

## 使用方法

在 Claude Code 中输入：

```
/generate-image 一只坐在山顶看日出的猫
```

Claude 会调用 API 生成图片并直接在对话中展示。

### 更多示例

```
/generate-image 一杯冒着热气的拿铁咖啡，背景是东京街景
/generate-image futuristic city skyline at night, neon lights
/generate-image 水墨画风格的山水画
```

---

## 插件说明

### marketplace.json

市场根配置文件，定义市场名称和所包含的插件列表。每个插件条目包括：
- `id` / `name` / `version` — 插件标识
- `path` — 插件目录路径
- `setup` — 安装时的配置要求（API Key 等）

### plugin.json

插件元数据文件，描述插件的：
- 基本信息（名称、版本、作者、描述）
- API 契约（端点、请求/响应格式）
- 安装钩子（`on_install` / `on_uninstall`）
- 配置项（`api_key` 类型、存储路径、环境变量回退）

### hooks.json

事件钩子配置，在以下时机触发：
| 事件 | 说明 |
|------|------|
| `plugin_install` | 安装时强制要求输入 API Key |
| `before_command` | 执行 `/generate-image` 前检查 API Key |
| `plugin_uninstall` | 卸载时询问是否清理配置 |

---

## API 参考

| 字段 | 说明 |
|------|------|
| 接口地址 | `https://prompt-manager-uat.issmart.com.cn/app-system-prompt/api/GenerateImage` |
| 请求方式 | `POST` |
| Header | `X-API-Key: <your-key>` |
| 请求体 | `{"prompt": "图片描述"}` |
| 响应体 | `{"imageUrl": "图片链接"}` |

---

## 添加新插件

要在此市场中添加新插件，按以下步骤操作：

1. 在 `plugins/` 下创建新目录（如 `plugins/my-new-plugin/`）
2. 创建 `plugins/my-new-plugin/.claude-plugin/plugin.json`
3. 添加 `commands/`、`scripts/`、`hooks/` 等目录
4. 在根目录 `.claude-plugin/marketplace.json` 的 `plugins` 数组中注册

---

## 故障排查

| 问题 | 解决方法 |
|------|---------|
| `API Key not configured` | 运行 `python ~/.claude-image-plugin/generate_image.py setup` |
| `command not found: /generate-image` | 重启 Claude Code，确保 slash command 已安装 |
| HTTP 401 | API Key 无效，请联系管理员 |
| 网络超时 | 检查网络连接，API 服务器需可访问 |

---

## 卸载

```bash
# Windows (PowerShell)
Remove-Item -Recurse -Force "$env:USERPROFILE\.claude-image-plugin"
Remove-Item -Force "$env:USERPROFILE\.claude\commands\generate-image.md"

# macOS/Linux
rm -rf ~/.claude-image-plugin
rm -f ~/.claude/commands/generate-image.md
```
