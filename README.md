# Claude Code Plugin Marketplace

基于 GenerateImage API 的 Claude Code 插件市场，提供 AI 图片生成能力。

---

## 快速安装（Marketplace）

在 Claude Code 中直接运行：

```
/plugin marketplace add wolf521/solomkt-image
```

安装过程中会**强制要求输入 API Key**（请联系系统管理员获取）。

安装完成后即可使用：

```
/generate-image 一只坐在山顶看日出的猫
```

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

## 安装方式

### 方式一：Marketplace 安装（推荐）

在 Claude Code 中运行：

```
/plugin marketplace add wolf521/solomkt-image
```

### 方式二：脚本安装

**Windows（PowerShell）：**
```powershell
# 交互式安装（会提示输入 API Key）
powershell -ExecutionPolicy Bypass -File .\setup.ps1

# 非交互式安装
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -ApiKey "your-api-key"
```

**macOS / Linux：**
```bash
chmod +x setup.sh
./setup.sh

# 或非交互式
./setup.sh "your-api-key"
```

### 方式三：手动安装

```bash
mkdir -p ~/.claude-image-plugin
cp plugins/image-generator/scripts/generate_image.py ~/.claude-image-plugin/
python ~/.claude-image-plugin/generate_image.py setup --api-key YOUR_API_KEY
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

```
/generate-image 一杯冒着热气的拿铁咖啡，背景是东京街景
/generate-image futuristic city skyline at night, neon lights
/generate-image 水墨画风格的山水画
```

---

## 插件元数据说明

### marketplace.json

市场根配置文件：

| 字段 | 说明 |
|------|------|
| `source` | 市场标识符，用于 `/plugin marketplace add` 命令 |
| `url` | 市场托管地址 |
| `plugins[].id` | 插件唯一标识（命名空间/名称 格式） |
| `plugins[].install` | 直接安装命令 |
| `plugins[].download` | 插件下载信息（URL + 文件列表） |
| `plugins[].setup` | 安装时配置要求（API Key 等） |

### plugin.json

插件元数据文件：

| 字段 | 说明 |
|------|------|
| `id` | 插件标识（`wolf521/solomkt-image`） |
| `install_command` | Marketplace 安装命令 |
| `download` | 下载信息（URL、文件列表、校验和） |
| `api` | API 契约（端点、请求/响应格式） |
| `setup.on_install` | 安装时钩子（强制 API Key 配置） |
| `configuration` | 配置项定义（类型、存储路径、环境变量回退） |

### hooks.json

事件钩子配置：

| 事件 | 触发时机 | 说明 |
|------|---------|------|
| `marketplace_add` | `/plugin marketplace add` 执行时 | 通知用户可用插件列表 |
| `plugin_install` | 插件安装时 | 强制要求输入 API Key |
| `before_command` | 执行 `/generate-image` 前 | 检查 API Key 是否已配置 |
| `plugin_uninstall` | 卸载插件时 | 询问是否清理本地配置 |

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

1. 在 `plugins/` 下创建新目录
2. 创建 `plugins/<name>/.claude-plugin/plugin.json`
3. 添加 `commands/`、`scripts/`、`hooks/` 等
4. 在 `.claude-plugin/marketplace.json` 的 `plugins` 数组中注册
5. 用户通过 `/plugin marketplace add <namespace>/<name>` 安装

---

## 故障排查

| 问题 | 解决方法 |
|------|---------|
| `API Key not configured` | 重新安装：`/plugin marketplace add wolf521/solomkt-image` |
| `command not found: /generate-image` | 重启 Claude Code |
| HTTP 401 | API Key 无效，联系管理员 |
| 网络超时 | 检查 API 服务器可达性 |

---

## 卸载

```bash
# 删除插件配置
rm -rf ~/.claude-image-plugin

# 删除 slash command
rm -f ~/.claude/commands/generate-image.md
```
