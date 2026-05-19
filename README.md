# Aemeath Claude Code Pet

Q 版像素爱弥斯桌宠，通过 HTTP hooks 与 Claude Code 实时联动。基于 MIT 像素小人素材制作，参考《鸣潮》爱弥斯官方视觉设定。

> 这是粉丝制作的桌宠项目，不是库洛游戏或《鸣潮》的官方项目。

## 功能

- 15 种像素动画状态，随 Claude Code 操作实时切换
- 气泡消息精准反馈 Claude 当前行为，工具间保持最小停留时间不闪烁
- 空闲时随机展示动画（跳跃 / 招手 / 待机变体）
- 透明无边框桌面悬浮窗，始终置顶，可拖拽，不占任务栏
- 系统托盘驻留，左键切换显隐，右键菜单
- 随 Claude Code 自动启动，不重复创建实例
- 权限请求时 waving + 气泡提醒

## 联动效果

| Claude 操作 | 宠物动画 | 气泡 |
|---|---|---|
| 收到消息 | chatting | "正在组织回复..." |
| Read / Grep / Glob | running | "正在读取文件..." |
| Write / Edit | building | "正在构建..." |
| Bash | running | "正在执行命令..." |
| Agent / Task | analyzing | "正在分析..." |
| WebFetch | fetching | "正在获取网络内容..." |
| WebSearch | searching | "正在搜索网络..." |
| 其他工具 | running | "工作中..." |
| 工具执行完毕 | celebrating | "太棒了!" |
| 权限请求 | waving | "等待指示..." |
| 空闲 | idle | — |

## 架构

```
Claude Code
  ├── HTTP hooks → POST :9527/api/hook/*
  └── MCP Client → :9528/mcp

Aemeath Pet (Tauri Desktop App)
  ├── HTTP Server (:9527)   → 接收 hook 推送 + 前端轮询
  ├── MCP Server (:9528)    → 富交互（tools / resources）
  ├── State Manager (Rust)  → 状态机 + 气泡锁
  └── WebView Frontend      → CSS sprite 动画 + 气泡 + 拖拽
```

## 安装

### Windows

```bash
npm install
cargo build --manifest-path src-tauri/Cargo.toml --release
```

产出在 `src-tauri/target/release/aemeath-claude.exe`。

将 [docs/hooks.json](docs/hooks.json) 合并到 `~/.claude/settings.json`，将 [docs/mcp.json](docs/mcp.json) 写入 `~/.claude/.mcp.json`，然后重启 Claude Code。注意替换 hooks.json 中 `SessionStart` 里 `aemeath-claude.exe` 的实际路径。

### macOS

**前置要求：** [Rust](https://rustup.rs/)、[Node.js](https://nodejs.org/) >= 18

```bash
# 构建
npm install
npm run tauri build

# 自动配置 Claude Code hooks + MCP
chmod +x setup-macos.sh
./setup-macos.sh
```

产出：
- App Bundle: `src-tauri/target/release/bundle/macos/Aemeath Claude Pet.app`
- DMG: `src-tauri/target/release/bundle/dmg/Aemeath Claude Pet_0.1.0_aarch64.dmg`

> macOS 自带 WebKit，无需额外系统依赖。

### Linux

**前置要求：** Rust、Node.js、webkit2gtk 等（[Tauri 前置条件](https://v2.tauri.app/start/prerequisites/)）

```bash
# Arch Linux
sudo pacman -S webkit2gtk-4.1 libappindicator-gtk3 gtk3 libsoup3

# 构建
npm install
cargo build --manifest-path src-tauri/Cargo.toml --release

# 自动配置 Claude Code hooks + MCP
chmod +x setup-linux.sh
./setup-linux.sh
```

产出在 `src-tauri/target/release/aemeath-claude`。

> 其他发行版请参考 Tauri 文档安装对应依赖。

## 端口

| 端口 | 用途 | 方向 |
|---|---|---|
| 9527 | HTTP — hooks 推送状态 + 前端轮询 | Claude → Pet |
| 9528 | MCP — 富交互（tools / resources） | Claude ↔ Pet |

## 构建

### 前置要求

- [Rust](https://rustup.rs/) stable toolchain（需 windows-gnu + MinGW-w64）
- [Node.js](https://nodejs.org/) >= 18
- Windows 10+

### 命令

```bash
npm install
cargo build --manifest-path src-tauri/Cargo.toml --release
```

## 目录结构

```
aemeath-claude/
├── src-tauri/        # Rust 后端 (Tauri + axum)
├── src/              # WebView 前端 (HTML/CSS/JS)
├── docs/             # hooks 与 MCP 配置模板
├── CLAUDE.md         # 项目指南
├── LICENSE
└── package.json
```

详细文件说明见 [CLAUDE.md](CLAUDE.md)。

## 来源与授权

- 像素小人素材来源：[lzy-buaa-jdi/ameath](https://gitee.com/lzy-buaa-jdi/ameath)，MIT License
- 爱弥斯、《鸣潮》及相关官方视觉设定归其权利方所有
- 本仓库仅包含整理后的桌宠代码、精灵图集，不含官方立绘原图
