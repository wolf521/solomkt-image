# Claude Code Image Generation Plugin

基于 GenerateImage API 的 Claude Code 图片生成插件。在 Claude Code 中使用 `/generate-image` 命令即可快速生成 AI 图片。

---

## 功能

- 在 Claude Code 中通过 `/generate-image <描述>` 快速生成图片
- 自动返回图片链接，Claude 会直接展示图片
- API Key 安全存储在本地配置文件中
- 支持 Windows / macOS / Linux

---

## 系统要求

- **Python 3.8+**（已加入系统 PATH）
- **Claude Code**（已安装并可使用）

---

## 安装

### Windows（PowerShell）

```powershell
# 1. 克隆或下载本仓库
git clone <your-repo-url>
cd soloMKT-image

# 2. 运行安装脚本（会提示输入 API Key）
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

### macOS / Linux

```bash
# 1. 克隆或下载本仓库
git clone <your-repo-url>
cd soloMKT-image

# 2. 运行安装脚本（会提示输入 API Key）
chmod +x setup.sh
./setup.sh
```

### 手动安装

如果安装脚本无法运行，可手动完成：

```bash
# 1. 创建插件目录
mkdir -p ~/.claude-image-plugin

# 2. 复制脚本
cp scripts/generate_image.py ~/.claude-image-plugin/

# 3. 配置 API Key
python ~/.claude-image-plugin/generate_image.py setup --api-key YOUR_API_KEY

# 4. 安装 slash command（全局）
mkdir -p ~/.claude/commands
cp .claude/commands/generate-image.md ~/.claude/commands/
```

---

## 初次安装 - API Key 配置

安装过程中，**必须提供 API Key**。获取方式：

> 请联系系统管理员获取您的 API Key，该 Key 用于访问 GenerateImage API 服务。

API Key 存储位置：
- **Windows**: `C:\Users\<用户名>\.claude-image-plugin\config.json`
- **macOS/Linux**: `~/.claude-image-plugin/config.json`

如需更换 API Key，运行：
```bash
python ~/.claude-image-plugin/generate_image.py setup
```

---

## 使用方法

在 Claude Code 中输入：

```
/generate-image 一只坐在山顶看日出的猫
```

Claude 会调用 API 生成图片并展示结果。

### 更多示例

```
/generate-image 一杯冒着热气的拿铁咖啡，背景是东京街景
/generate-image futuristic city skyline at night, neon lights
/generate-image 水墨画风格的山水画
```

---

## 文件结构

```
soloMKT-image/
├── .claude/
│   └── commands/
│       └── generate-image.md    # Claude Code slash command 定义
├── scripts/
│   └── generate_image.py        # 核心 API 调用脚本
├── setup.ps1                    # Windows 安装脚本
├── setup.sh                     # macOS/Linux 安装脚本
└── README.md
```

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

## 故障排查

| 问题 | 解决方法 |
|------|---------|
| `API Key not configured` | 运行 `python ~/.claude-image-plugin/generate_image.py setup` |
| `No module named 'urllib'` | Python 版本过低，请升级至 3.8+ |
| `command not found: /generate-image` | 重启 Claude Code，确保 slash command 已安装 |
| HTTP 401 | API Key 无效，请联系管理员 |
| 网络超时 | 检查网络连接，API 服务器地址需可访问 |

---

## 卸载

```bash
# 删除插件文件
rm -rf ~/.claude-image-plugin

# 删除 slash command
rm -f ~/.claude/commands/generate-image.md
```
