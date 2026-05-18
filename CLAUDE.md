# Aemeath Claude Code Pet

Q 版像素爱弥斯桌宠，与 Claude Code 实时联动。

## 安装

### Windows

1. 启动 Aemeath.exe（宠物显示在桌面 + 托盘图标）
2. 将 [docs/hooks.json](docs/hooks.json) 合并到 `~/.claude/settings.json`（注意替换 exe 路径）
3. 将 [docs/mcp.json](docs/mcp.json) 写入 `~/.claude/.mcp.json`
4. 重启 Claude Code

### Linux

```bash
# 1. 安装系统依赖（Arch Linux）
sudo pacman -S webkit2gtk-4.1 libappindicator-gtk3 gtk3 libsoup3

# 2. 构建
npm install
cargo build --manifest-path src-tauri/Cargo.toml --release

# 3. 配置 Claude Code 联动
chmod +x setup-linux.sh
./setup-linux.sh

# 4. 重启 Claude Code
```

> 其他发行版请参考 [Tauri 官方文档](https://v2.tauri.app/start/prerequisites/) 安装对应依赖。

## 启动

- 桌宠会自动随 Claude Code 启动（通过 hooks 配置）
- 手动启动：`./src-tauri/target/release/aemeath-claude &`

## 端口

- HTTP: 127.0.0.1:9527
- MCP: 127.0.0.1:9528

## 构建

```bash
npm install
cargo build --manifest-path src-tauri/Cargo.toml --release
```

产出在 `src-tauri/target/release/`。

## 前置要求

- [Rust](https://rustup.rs/) (stable toolchain)
- [Node.js](https://nodejs.org/) >= 18
- Windows 10+ 或 Linux（需要 webkit2gtk）

## 目录结构

```
aemeath-claude/
├── src-tauri/
│   ├── Cargo.toml              # Rust 依赖
│   ├── tauri.conf.json         # 透明窗口 / 置顶 / 托盘配置
│   ├── icons/
│   └── src/
│       ├── main.rs             # 入口，启动 HTTP + MCP + Tauri
│       ├── state.rs            # 状态机 + 气泡文案映射 + 状态锁
│       ├── http.rs             # axum HTTP Server (:9527) + hook 端点
│       ├── mcp.rs              # MCP JSON-RPC Server (:9528)
│       └── tray.rs             # 系统托盘
├── src/
│   ├── index.html              # 宠物渲染页面
│   ├── pet.css                 # 精灵 / 气泡 / 透明窗口样式
│   ├── sprite-animator.js      # CSS spritesheet 帧动画引擎
│   ├── bubble.js               # 气泡消息队列组件
│   ├── app.js                  # 主逻辑 + 拖拽 + 轮询 + 气泡锁
│   ├── spritesheet.webp        # 精灵图集 (1536x3120)
│   └── validation.json         # 帧元数据
├── docs/
│   ├── hooks.json              # Windows hooks 配置模板
│   ├── hooks.linux.json        # Linux hooks 配置模板
│   └── mcp.json                # MCP 配置模板
├── setup-linux.sh              # Linux 一键配置脚本
├── .claude/settings.json       # 项目级 hooks 模板
├── CLAUDE.md
├── LICENSE
└── package.json
```
