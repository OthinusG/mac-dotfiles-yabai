# mac-dotfiles-yabai

> **yabai + skhd + SketchyBar + JankyBorders + Ghostty + Starship**

[中文](README_CN.md) | [English](README.md)

一套以 **键盘驱动、BSP 平铺、多显示器 Space 管理和原生 macOS 视觉** 为核心的 macOS dotfiles。

这套配置不是简单把几个工具拼在一起，而是围绕三个目标组织：

- **窗口操作尽量不离开键盘**
- **保留 macOS 的原生交互和视觉**
- **把菜单栏、Space、窗口管理、终端工作流整合成一个完整桌面环境**

![Desktop](images/insert.png)

---

# Highlights

## 1. yabai BSP：平铺、动画、透明度与多显示器 Space

窗口管理核心使用 [yabai](https://github.com/asmvik/yabai) 的 BSP layout。

当前配置开启：

```text
BSP tiling
Window animation
Window opacity
Window gaps / padding
Mouse move / resize
Stack
Space management
Multi-display navigation
```

窗口切换不仅有平铺逻辑，也保留了较柔和的动画和透明度反馈。

---

## 2. 原生 macOS Menu 与 Spaces 一键互换

SketchyBar 左侧并不是普通的静态 Workspace 列表。

它实现了两套可切换界面：

```text
Native macOS App Menu
        ↕
Spaces + App Icons
```

### Menu Mode

显示当前前台应用真实的 macOS 菜单：

```text
   File   Edit   View   Window   Help ...
```

![Desktop](images/insert2.png)

这些菜单不是仿制文本。

配置通过：

```text
SbarLua
C helper
macOS Accessibility / Menu API
```

读取当前应用菜单，并且可以直接点击执行。为了稳定性，我采用了透明化原生菜单栏的方案（SIP OFF），在点击菜单时其实拉起了原生菜单，1:1覆盖在sketchybar上。


### 切换方式

点击：

```text
Front App
```

或 Spaces indicator，即可在两种模式之间切换。

---

## 3. Reminders 可直接完成任务

SketchyBar 会读取：

```text
Reminders → Inbox
```
即名为Inbox列表中的任务，从新到旧，显示一个未完成任务。

快捷操作：

| Action | Function |
| --- | --- |
| `Ctrl + Left Click` | 完成当前 Reminder |
| `Ctrl + Right Click` | 打开 Reminders.app |

因此简单待办可以直接在菜单栏处理。

---

## 4. 输入法状态

SketchyBar 会显示当前输入法：

```text
中
英
日
韩
```

输入源 helper 使用 C 编写，并在 SketchyBar 启动时自动编译：

```text
helpers/input_source/input_source.c
```

---

## 5. clash verge状态显示
sketchybar右侧wifi图标默认显示为clash verge（仅支持clash verge，非mihomo内核特性）当前节点的连通性，断联将红色断开显示。也保留了原来wifi链接与否的逻辑，可将 `/.config/sketchybar/plugins/wifi_old.sh`改名成wifi.sh即可。

---
## 6. Music 控制

当前默认播放器：

```text
Apple Music
```
配置中同时保留：

```text
Spotify
MPD / rmpc
YouTube Music
```

的支持代码，但默认不启用，可自行启用。

状态栏显示：

```text
Track • Artist
```

操作：

| Action | Function |
| --- | --- |
| Left Click | Play / Pause |
| Right Click | Next |
| `Ctrl + Right Click` | Previous |

---

# Installation

当前 yabai 配置启用了：

```text
window opacity
window animation
advanced Space operations
```

并且 `yabairc` 会执行：

```bash
sudo yabai --load-sa
```

因此这套配置需要 **yabai scripting addition**。

---

## 1. Xcode Command Line Tools

首先安装：

```bash
xcode-select --install
```

它提供：

```text
git
clang
make
```

其中 `clang` / `make` 也用于编译 SketchyBar 的 C helpers 和 SbarLua。

---

## 2. macOS Settings

确保：

```text
System Settings
→ Desktop & Dock
→ Mission Control
→ Displays have separate Spaces
```

开启。

同时关闭：

```text
Automatically rearrange Spaces based on most recent use
```

因为当前快捷键依赖稳定的 Space 顺序。

在较新的 macOS 中，建议：

```text
System Settings
→ Desktop & Dock
→ Click wallpaper to reveal desktop
→ Only in Stage Manager
```

以避免 yabai 的 Space / Display focus 行为异常。

---

## 3. （可选的）Partially Disable SIP

> [!WARNING]
> 只有在你需要当前配置中的 **动画、透明度和高级 Space 控制** 时才需要这一步。
>
> 部分关闭 SIP 会降低 macOS 的部分系统保护能力。请先理解这一操作再继续。

### Apple Silicon + macOS 13 or newer

关机。

长按电源键进入：

```text
Startup Options
→ Options
→ Continue
```

打开：

```text
Utilities
→ Terminal
```

执行：

```bash
csrutil enable --without fs --without debug --without nvram
```

重启进入 macOS 后执行：

```bash
sudo nvram boot-args=-arm64e_preview_abi
```

再次重启。

检查：

```bash
csrutil status
```

新版本 macOS 在部分关闭 SIP 后可能显示：

```text
System Integrity Protection status: unknown (Custom Configuration)
```

完整说明：

https://github.com/asmvik/yabai/wiki/Disabling-System-Integrity-Protection

---

## 4. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

## 5. Install Core Packages

只安装这套桌面配置直接使用的顶层依赖。

```bash
brew tap asmvik/formulae
brew tap FelixKratz/formulae

brew install \
  asmvik/formulae/yabai \
  asmvik/formulae/skhd \
  sketchybar \
  borders \
  jq \
  lua \
  starship \
  zsh-syntax-highlighting \
  zsh-autosuggestions \
  zsh-completions
```

字体和 Ghostty：

```bash
brew install --cask \
  ghostty \
  font-hack-nerd-font \
  font-jetbrains-mono-nerd-font \
  font-sketchybar-app-font \
  sf-symbols
```

---

## 6. Install SbarLua

SketchyBar 左侧的：

```text
Native Menu
Spaces
Front App
```

由 SbarLua 驱动。

安装：

```bash
git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && \
cd /tmp/SbarLua && \
make install && \
cd ~ && \
rm -rf /tmp/SbarLua
```

SbarLua 会安装到：

```text
~/.local/share/sketchybar_lua/
```

当前 Lua 配置会直接从这里加载：

```lua
require("sketchybar")
```
也可从仓库中下载install_sbarlua.sh脚本自动安装

---

## 7. Clone & Overwrite

> [!CAUTION]
> 下面命令会直接删除原来的：
>
> ```text
> ~/.config
> ```
>
> 不会自动备份。

```bash
git clone https://github.com/OthinusG/mac-dotfiles-yabai.git ~/mac-dotfiles-yabai && \
rm -rf ~/.config && \
cp -R ~/mac-dotfiles-yabai/.config ~/.config && \
cp ~/mac-dotfiles-yabai/.zshrc ~/.zshrc && \
cp ~/mac-dotfiles-yabai/.zprofile ~/.zprofile && \
cp ~/mac-dotfiles-yabai/.bashrc ~/.bashrc && \
cp ~/mac-dotfiles-yabai/.bash_profile ~/.bash_profile
```

---

## 8. Configure yabai Scripting Addition

当前 `yabairc` 已经包含：

```bash
sudo yabai --load-sa
yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
```

因此需要允许这一条命令免密码执行。

运行：

```bash
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa" | \
sudo tee /private/etc/sudoers.d/yabai
```

> yabai 升级后 binary hash 会变化，需要重新执行这条命令。

---

## 9. Start

### yabai

```bash
yabai --start-service
```

首次启动后给予：

```text
System Settings
→ Privacy & Security
→ Accessibility
→ yabai
```

权限。

当前配置使用窗口动画，还需要按 yabai 提示授予相关 Screen Recording 权限。

---

### skhd

```bash
skhd --start-service
```

给予：

```text
Privacy & Security
→ Accessibility
→ skhd
```

权限。

---

### SketchyBar

```bash
brew services start sketchybar
```

重新加载：

```bash
sketchybar --reload
```

---

### JankyBorders

```bash
brew services start borders
```

重新启动：

```bash
brew services restart borders
```

---

# Configuration

# yabai

配置：

```text
~/.config/yabai/yabairc
```

---

## Mouse

按住：

```text
Fn + Mouse
```

即可：

```text
Mouse Button 1 → Move
Mouse Button 2 → Resize
Drop           → Swap
```

---

## Floating / Unmanaged Apps

以下应用默认不参与 BSP：

```text
LuLu
Calculator
Software Update
Dictionary
VLC
System Settings
Zoom
Photo Booth
Archive Utility
Python
LibreOffice
App Store
Steam
Alfred
Activity Monitor
```

另外对：

```text
Finder
Safari
System Information
Inkscape
```

的部分 Dialog / Preferences 窗口设置了专门规则。

---

# skhd

配置：

```text
~/.config/skhd/skhdrc
```

---

## Space

| Shortcut | Action |
| --- | --- |
| `Alt + 1...0` | Focus current display's Space 1–10 |
| `Shift + Alt + 1...0` | Move window to local Space and follow |
| `Shift + Alt + P` | Move to previous Space |
| `Shift + Alt + N` | Move to next Space |

---

## Focus

| Shortcut | Action |
| --- | --- |
| `Alt + H` | Focus west |
| `Alt + J` | Focus south |
| `Alt + K` | Focus north |
| `Alt + L` | Focus east |
| `Alt + U` | First window |
| `Alt + I` | Last window |

如果目标方向没有窗口：

```text
Alt + H/J/K/L
```

会继续尝试聚焦对应方向的 Display。

---

## Window State

| Shortcut | Action |
| --- | --- |
| `Alt + Space` | Float / Unfloat |
| `Alt + F` | Zoom parent |
| `Shift + Alt + F` | Zoom fullscreen |
| `Shift + Alt + S` | Toggle split |

---

## Move Window

| Shortcut | Action |
| --- | --- |
| `Shift + Alt + H` | Move / Warp west |
| `Shift + Alt + J` | Move / Warp south |
| `Shift + Alt + K` | Move / Warp north |
| `Shift + Alt + L` | Move / Warp east |

跨越当前 Display 边界时，会继续尝试把窗口移动到相邻 Display。

---

## Resize

| Shortcut | Action |
| --- | --- |
| `Ctrl + Alt + H/J/K/L` | Resize |
| `Ctrl + Alt + E` | Balance |
| `Ctrl + Alt + G` | Toggle gaps / padding |

---

## Stack

| Shortcut | Action |
| --- | --- |
| `Shift + Ctrl + H/J/K/L` | Stack in direction |
| `Shift + Ctrl + N` | Next window in stack |
| `Shift + Ctrl + P` | Previous window in stack |

---

## Insertion

| Shortcut | Action |
| --- | --- |
| `Shift + Ctrl + Alt + H` | Insert west |
| `Shift + Ctrl + Alt + J` | Insert south |
| `Shift + Ctrl + Alt + K` | Insert north |
| `Shift + Ctrl + Alt + L` | Insert east |
| `Shift + Ctrl + Alt + S` | Insert stack |

快速创建新窗口：

```text
Alt + S → Insert east  + Cmd + N
Alt + V → Insert south + Cmd + N
```

---

## Mirror

```text
Shift + Alt + X → Mirror X axis
Shift + Alt + Y → Mirror Y axis
```

---

#Sketchybar

## Weather

默认：

```text
Baidu Weather
```

配置：

```text
~/.config/sketchybar/settings.sh
```

当前值：

```bash
WEATHER_BAIDU_QUERY="上海闵行天气"
WEATHER_BAIDU_SRCID="4982"
```

另外保留：

```text
NMC
Open-Meteo
```

对应：

```bash
WEATHER_NMC_STATIONID="HIieJ"

WEATHER_METEO_LATITUDE=30.2416
WEATHER_METEO_LONGITUDE=120.1189
```

---

## Network Rate

配置：

```text
plugins/network_rates.sh
```

默认网卡：

```bash
INTERFACE="en1"
```

检查本机网卡：

```bash
networksetup -listallhardwareports
```

如果 Wi-Fi 是：

```text
en0
```

则修改为：

```bash
INTERFACE="en0"
```

---

## Proxy

开启：

```bash
proxy
```

关闭：

```bash
unproxy
```

当前，可自行更改端口：

```text
HTTP_PROXY   http://127.0.0.1:7897
HTTPS_PROXY  http://127.0.0.1:7897
ALL_PROXY    socks5h://127.0.0.1:7897
```

---

## AI Keys

`.zshrc` 会自动读取：

```text
~/.ai_keys
```

因此 API keys 可以和公开 dotfiles 分开保存。


---

## Karabiner

安装：

```bash
brew install --cask karabiner-elements
```

当前配置包含 Hyper Layer，用于：

```text
Cursor movement
Text selection
Text deletion
F1–F12
```

---

## Neovim

最低：

```bash
brew install neovim
```

完整使用当前 Telescope / fzf-native / Markdown Preview：

```bash
brew install \
  fd \
  ripgrep \
  cmake \
  node \
  yarn
```

---

# Per-machine Settings

复制后建议优先修改这几处。

| Setting | File | Current value |
| --- | --- | --- |
| Network interface | `sketchybar/plugins/network_rates.sh` | `en1` |
| Weather location | `sketchybar/settings.sh` | 上海闵行 |
| Weather coordinates | `sketchybar/settings.sh` | `30.2416, 120.1189` |
| Proxy | `.zshrc` | `127.0.0.1:7897` |

---

# References

- [yabai](https://github.com/asmvik/yabai)
- [skhd](https://github.com/asmvik/skhd)
- [SketchyBar](https://github.com/FelixKratz/SketchyBar)
- [SbarLua](https://github.com/FelixKratz/SbarLua)
- [JankyBorders](https://github.com/FelixKratz/JankyBorders)
- [Ghostty](https://ghostty.org/)
- [Starship](https://starship.rs/)
- [Herdr](https://herdr.dev/)
- [sketchybar-app-font](https://github.com/kvndrsslr/sketchybar-app-font)
- [Sinjhin/SketchyMenu](https://github.com/Sinjhin/SketchyMenu)
- [th-ch/youtube-music](https://github.com/th-ch/youtube-music)

---

## Disclaimer

These are personal dotfiles, not a plug-and-play macOS distribution.

当前配置使用 yabai scripting addition，并依赖部分关闭 SIP、macOS Accessibility 权限以及若干机器相关路径。请在使用前检查配置并根据自己的环境修改。
