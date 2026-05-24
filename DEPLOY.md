# Bomiot WMS 部署指南

本指南面向**完全零基础用户**，从安装 Git 到成功运行系统，每一步都有详细说明。即使你从未接触过命令行、编程或服务器，跟着本文操作也能完成部署。

---

## 目录

- [准备工作：理解你要做的事情](#准备工作理解你要做的事情)
- [第一步：下载项目到你的电脑](#第一步下载项目到你的电脑)
  - [1.1 安装 Git（项目的下载工具）](#11-安装-git项目的下载工具)
  - [1.2 使用 Git 下载项目](#12-使用-git-下载项目)
  - [1.3 进入项目目录](#13-进入项目目录)
- [第二步：选择部署方式](#第二步选择部署方式)
- [方式A：Docker 一键部署（推荐，最简单）](#方式adocker-一键部署推荐最简单)
  - [A1. 什么是 Docker（用人话解释）](#a1-什么是-docker用人话解释)
  - [A2. 在 Windows 上安装 Docker](#a2-在-windows-上安装-docker)
  - [A3. 在 macOS 上安装 Docker](#a3-在-macos-上安装-docker)
  - [A4. 在 Linux 上安装 Docker](#a4-在-linux-上安装-docker)
  - [A5. 启动系统（所有平台通用）](#a5-启动系统所有平台通用)
  - [A6. 验证系统是否正常运行](#a6-验证系统是否正常运行)
  - [A7. 登录系统](#a7-登录系统)
- [方式B：本地部署（不需要 Docker，适合开发者）](#方式b本地部署不需要-docker适合开发者)
  - [B1. 理解本地部署需要什么](#b1-理解本地部署需要什么)
  - [B2. Linux 本地部署（Ubuntu/Debian/CentOS/统信UOS/深度）](#b2-linux-本地部署ubuntudebiancentos统信uos深度)
  - [B3. Windows 本地部署](#b3-windows-本地部署)
  - [B4. macOS 本地部署](#b4-macos-本地部署)
- [访问系统](#访问系统)
- [让局域网其他人访问系统](#让局域网其他人访问系统)
- [日常运维操作](#日常运维操作)
  - [Docker 部署的日常操作](#docker-部署的日常操作)
  - [本地部署的日常操作](#本地部署的日常操作)
- [常见问题排查（20个常见问题）](#常见问题排查20个常见问题)
- [部署架构说明（给想了解原理的人）](#部署架构说明给想了解原理的人)

---

## 准备工作：理解你要做的事情

在开始之前，先用通俗的语言解释一下整个过程，让你心里有数：

**这个项目是什么？** Bomiot 是一个仓储管理系统（WMS），用网页浏览器打开使用。就像你打开百度、淘宝一样，只不过这个网页跑在你自己的电脑上。

**部署是什么？** 就是把项目代码"跑起来"，让它变成一个可以访问的网页。这个项目需要三样东西才能跑：

1. **Python**（后端程序）— 负责处理业务逻辑，就像餐厅的后厨
2. **MySQL**（数据库）— 负责存储数据，就像餐厅的冰柜和储物柜
3. **Nginx**（前端网页服务器）— 把网页显示给你看，就像餐厅的服务员

**Docker 是什么？** Docker 把上面三样东西全部打包好，你只要装好 Docker，一条命令就能把整套系统跑起来。不用分别安装 Python、MySQL、Nginx，Docker 帮你全搞定了。这就是为什么我们推荐 Docker 部署。

**本地部署是什么？** 就是手动安装 Python、Node.js、MySQL 这三样东西，然后一条条命令启动系统。步骤多一些，但你对系统有完全的控制权。

**你需要准备什么？**

- 一台能上网的电脑（Windows / macOS / Linux 都可以）
- 大约 30 分钟时间（Docker 方式）/ 1 小时（本地部署方式）
- 大约 5GB 可用硬盘空间（Docker 方式）/ 2GB（本地部署方式）
- 耐心和愿意动手尝试的心

---

## 第一步：下载项目到你的电脑

### 1.1 安装 Git（项目的下载工具）

Git 是一个"下载工具"，用来从 GitHub（一个代码托管网站）把项目代码下载到你的电脑。

#### 如何确认你电脑有没有装 Git？

**Windows**：

1. 按键盘上的 `Win` 键（Windows 图标键，在 Ctrl 和 Alt 之间）+ `R` 键
2. 在弹出的"运行"窗口中输入 `cmd`，按回车
3. 在打开的黑窗口中输入 `git --version`，按回车
4. 如果显示 `git version 2.x.x`，说明已安装，跳到 [1.2](#12-使用-git-下载项目)
5. 如果显示"不是内部或外部命令"，说明没装，按下面步骤安装

**macOS**：

1. 打开"终端"（方法：点击桌面右上角的放大镜图标，输入"终端"或"Terminal"，双击第一个结果）
2. 输入 `git --version`，按回车
3. 如果显示 `git version 2.x.x`，说明已安装，跳到 [1.2](#12-使用-git-下载项目)
4. 如果显示 "command not found" 或弹出安装提示，按下面步骤安装

**Linux**：

1. 按 `Ctrl+Alt+T` 打开终端
2. 输入 `git --version`，按回车
3. 如果显示 `git version 2.x.x`，说明已安装，跳到 [1.2](#12-使用-git-下载项目)
4. 如果没有显示版本号，按下面步骤安装

#### Windows 安装 Git

1. 打开浏览器（Edge、Chrome、Firefox 都可以）
2. 在地址栏输入 `https://git-scm.com/download/win`，按回车
3. 网站会自动弹出下载，如果没有，点击页面上的 "Click here to download manually"
4. 下载完成后，在浏览器底部或右上角的下载列表中，点击刚下载的文件（名称类似 `Git-2.xx.x-64-bit.exe`）
5. 弹出安装向导窗口，所有步骤都点 "Next"（下一步），用默认选项即可。**总共大约要点 10 次 Next**
6. 在 "Choosing the default editor" 这一步，默认是 Vim（一个很难用的编辑器），建议改为 "Use Visual Studio Code as Git's default editor" 或保持默认也行（不影响使用）
7. 安装完成后，**在桌面空白处右键**，你会看到菜单中多了两个选项：
   - "Git GUI Here"（图形界面，不用管）
   - "Git Bash Here"（命令行界面，我们后面主要用这个）
8. 验证安装：在桌面右键 → "Git Bash Here"，输入 `git --version`，回车。看到 `git version 2.xx.x` 就成功了

#### macOS 安装 Git

1. 打开"终端"（在启动台搜索"终端"或"Terminal"）
2. 输入以下命令，按回车：

   ```text
   xcode-select --install
   ```

3. 屏幕会弹出一个对话框，点击"安装"（Install）
4. 等待安装完成（大约 5 分钟，取决于网速）
5. 验证：终端中输入 `git --version`，看到版本号就成功了。

   > 如果还是显示 "command not found"，说明你的 Mac 版本较老，去 https://git-scm.com/download/mac 下载安装包，双击安装即可。

#### Linux 安装 Git

1. 按 `Ctrl+Alt+T` 打开终端
2. 输入以下命令，按回车（需要输入你的登录密码，输入时屏幕不会显示任何字符，这是正常的）：

   ```bash
   sudo apt install git -y
   ```

3. 等待安装完成（通常不到 1 分钟）
4. 验证：输入 `git --version`，看到版本号就成功了。

---

### 1.2 使用 Git 下载项目

这一步把 Bomiot 项目从 GitHub 网站下载到你的电脑。

#### Windows

1. 在桌面上找一个空白位置，**右键** → 点击 **"Git Bash Here"**
2. 一个黑色背景、白色文字的命令行窗口会打开
3. 在这个窗口中输入以下命令（建议直接复制粘贴，粘贴快捷键是 `Ctrl+Shift+V` 或 `Shift+Insert`）：

   ```bash
   git clone https://github.com/Havensky-stack/Bomiot.git
   ```

4. 按回车，你会看到类似下面的输出：

   ```text
   Cloning into 'Bomiot'...
   remote: Enumerating objects: 1234, done.
   remote: Counting objects: 100% (1234/1234), done.
   remote: Compressing objects: 100% (567/567), done.
   Receiving objects: 100% (1234/1234), 15.23 MiB, done.
   Resolving deltas: 100% (456/456), done.
   ```

5. 等待下载完成（通常 1-5 分钟，取决于网速）
6. 下载完成后，你的**桌面上会出现一个名为 `Bomiot` 的文件夹**

> 如果显示 `fatal: unable to access...` 且长时间卡住，可能是网络问题。尝试：

> - 检查网络连接是否正常（打开浏览器试试能不能访问百度）
> - 如果人在国内，GitHub 连接可能较慢，多等一会或换个网络环境重试

#### macOS / Linux

1. 打开终端
2. 输入以下命令，按回车：

   ```bash
   git clone https://github.com/Havensky-stack/Bomiot.git
   ```

3. 等待下载完成
4. 输入 `ls` 命令查看当前目录，你应该能看到 `Bomiot` 文件夹

---

### 1.3 进入项目目录

所有后续操作都需要在项目目录下执行。先把命令行的工作目录切换到项目文件夹。

#### Windows（Git Bash）

```bash
cd ~/Desktop/Bomiot
```

> 如果你把项目克隆到了其他位置，把 `~/Desktop/Bomiot` 替换为实际路径。例如克隆到了 D 盘根目录，就是 `cd /d/Bomiot`。

验证是否在正确的位置：

```bash
pwd
```

输出应该包含 `/Bomiot` 字样。

```bash
ls
```

你应该看到 `bomiot`、`awesomewms`、`deploy`、`deploy.sh`、`deploy.bat`、`DEPLOY.md` 等文件和文件夹。

#### macOS / Linux

```bash
cd ~/Bomiot
```

> 如果克隆到了其他位置，替换为对应路径，例如 `cd ~/Downloads/Bomiot`。

验证是否在正确的位置：

```bash
pwd
```

输出应该包含 `/Bomiot`。

```bash
ls
```

你应该看到 `bomiot`、`awesomewms`、`deploy`、`deploy.sh`、`DEPLOY.md` 等文件和文件夹。

---

## 第二步：选择部署方式

| 特性 | Docker 部署（推荐） | 本地部署 |
|------|---------------------|----------|
| 适合谁 | 想快速上手、不想折腾环境的人 | 开发者、需要改代码的人 |
| 需要装什么 | **只装 Docker** | Python + Node.js + MySQL |
| 启动命令 | 1 条 | 10+ 条 |
| 需要的时间 | 15-30 分钟 | 1-2 小时 |
| 出问题概率 | 低（环境一致） | 中（环境差异） |
| 可以改代码吗 | 可以但不方便 | 方便 |

**我们的建议：**

- 如果你是第一次接触这类项目 → 选 **Docker 部署**
- 如果你是开发者，需要改代码 → 选 **本地部署**
- 如果你的电脑配置较低（内存 < 8GB）→ 选 **本地部署**（Docker 比较吃内存）

---

## 方式A：Docker 一键部署（推荐，最简单）

### A1. 什么是 Docker（用人话解释）

如果你还不了解 Docker，花 2 分钟看一下这个解释：

**Docker 像一个"集装箱"**。就好比你要开一家餐厅，需要厨房设备、冰箱、桌椅等。没有 Docker，你需要分别去买每样东西、自己安装、自己调试。有了 Docker，就像买了一个"集装箱餐厅"——里面厨房、冰箱、桌椅全配好了，你只要把集装箱放好、插上电就行。

在软件世界里：

- Docker 就是这个"集装箱系统"
- `docker-compose.yml` 文件定义了"集装箱里需要什么东西"（MySQL 数据库、Python 程序、Nginx 网页服务器）
- `docker compose up -d` 命令就是"把集装箱放好、通电启动"
- 你用浏览器访问 `http://localhost` 就是"来餐厅吃饭"

**Docker 的三个核心概念：**

- **镜像（Image）**：一个已经配好环境的"模板"，就像菜谱。MySQL 镜像就是一个装好 MySQL 的模板。
- **容器（Container）**：镜像启动后变成一个运行中的容器，就像照着菜谱做出的菜。
- **docker-compose**：用来管理多个容器的工具，我们这个项目需要 3 个容器（数据库、后端、网页服务器），用 docker-compose 一条命令全搞定。

---

### A2. 在 Windows 上安装 Docker

**前提条件：**

- Windows 10 或 11（版本号 ≥ 19041）
- 如果用的是 Windows 10，需要是专业版、企业版或教育版（家庭版也可以，但需要额外配置 WSL）
- 电脑需要开启虚拟化（绝大多数电脑默认已开启）

#### 第一步：检查系统版本

1. 按 `Win + R`，输入 `winver`，按回车
2. 会弹出一个窗口显示 Windows 版本号。如果版本号 ≥ 19041（也就是 20H1 以上），可以继续
3. 如果版本号太低，先通过 Windows 更新升级系统

#### 第二步：检查虚拟化是否开启

1. 按 `Ctrl+Shift+Esc` 打开任务管理器
2. 点击"性能"标签
3. 点击左侧的"CPU"
4. 在右侧信息中找"虚拟化"，看是"已启用"还是"已禁用"
5. 如果是"已启用"，继续下一步
6. 如果是"已禁用"，需要重启电脑进入 BIOS 开启（具体方法因电脑品牌而异，一般是在开机时按 F2 或 Delete 键进入 BIOS 设置，找到 "Virtualization Technology" 或 "SVM Mode" 设为 "Enabled"）

#### 第三步：下载 Docker Desktop

1. 打开浏览器，访问 `https://www.docker.com/products/docker-desktop/`
2. 页面会自动识别你的系统是 Windows，显示 "Download for Windows" 按钮
3. 点击按钮，开始下载。文件大约 600MB，下载需要几分钟
4. 下载完成后，双击 `Docker Desktop Installer.exe` 运行

#### 第四步：安装 Docker Desktop

1. 双击安装文件后，会出现安装向导
2. 确保勾选了以下选项：
   - **"Use WSL 2 instead of Hyper-V"**（推荐勾选，性能更好）
   - **"Add shortcut to desktop"**（可选，在桌面创建快捷方式）
3. 点击 "OK" 开始安装
4. 等待安装进度条走完（大约 3-5 分钟）
5. 安装完成后，会提示 **"Installation succeeded"**，点击 "Close and restart"（关闭并重启电脑）
6. **电脑重启后**，Docker Desktop 会自动启动（第一次启动需要 1-2 分钟）
7. 任务栏右下角会出现一个**鲸鱼图标**（Docker 的标志）
8. 点击这个鲸鱼图标，会弹出 Docker Desktop 窗口
9. 首次启动会要求你接受服务协议（Service Agreement），勾选 "I accept the terms"，点击 "Accept"
10. 可能会问你是否要登录，选择 "Continue without signing in"（不登录也能用）或 "Skip"
11. 等待鲸鱼图标右下角的黄色小点消失，变成稳定的鲸鱼图标，说明 Docker 准备好了

#### 第五步：验证 Docker 安装

1. 打开命令提示符（`Win+R` → 输入 `cmd` → 回车）
2. 输入以下命令，按回车：

   ```cmd
   docker --version
   ```

3. 应该显示类似 `Docker version 24.x.x, build xxxxx`
4. 再输入：

   ```cmd
   docker run hello-world
   ```

5. 如果看到一段以 "Hello from Docker!" 开头的信息，说明 Docker 安装成功！

> **提示**：如果 docker run hello-world 报错说 "error during connect"，说明 Docker 引擎还没完全启动。再等 1-2 分钟，观察任务栏的鲸鱼图标是否还有小黄点，等黄点消失再试。

---

### A3. 在 macOS 上安装 Docker

#### 第一步：确定你的 Mac 芯片类型

1. 点击屏幕左上角的苹果图标（）
2. 选择"关于本机"（About This Mac）
3. 在弹出的窗口中看"芯片"（Chip）或"处理器"（Processor）这一行：
   - 如果显示 **Apple M1 / M2 / M3 / M4** → 选 "Apple Silicon" 版本
   - 如果显示 **Intel** → 选 "Intel Chip" 版本

#### 第二步：下载 Docker Desktop

1. 打开浏览器，访问 `https://www.docker.com/products/docker-desktop/`
2. 页面会自动识别系统，显示下载按钮：
   - Apple Silicon 版：**"Download for Mac with Apple Silicon"**
   - Intel 版：**"Download for Mac with Intel Chip"**
3. 点击对应的按钮，开始下载。文件大约 500MB

#### 第三步：安装 Docker Desktop

1. 下载完成后，打开下载文件夹（Finder → 左侧"下载"）
2. 双击 `.dmg` 文件（例如 `Docker.dmg`）
3. 会弹出一个窗口，左边是 Docker 图标，右边是 Applications 文件夹
4. **用鼠标把 Docker 图标拖到右边的 Applications 文件夹**
5. 关闭弹出窗口
6. 打开启动台（Launchpad，底部的火箭图标或触控板四指收缩）
7. 找到 Docker 图标（蓝色鲸鱼），**双击打开**
8. 首次打开时，系统可能会提示"从互联网下载的应用程序"，点击"打开"
9. 会要求你输入系统密码（你的 Mac 登录密码），输入后点击"安装帮助程序"（Install Helper）
10. Docker 图标会出现在屏幕顶部菜单栏的右侧
11. 点击菜单栏的 Docker 图标，看状态是否显示 "Docker Desktop is starting..."
12. 等待状态变为 "Docker Desktop is running"（首次启动约 1-2 分钟）

#### 第四步：验证 Docker 安装

1. 打开终端（启动台搜索"终端"或"Terminal"）
2. 输入以下命令：

   ```bash
   docker --version
   ```

3. 看到 `Docker version 24.x.x, build xxxxx` 就成功了
4. 再输入：

   ```bash
   docker run hello-world
   ```

5. 看到 "Hello from Docker!" 就完全 OK 了

---

### A4. 在 Linux 上安装 Docker

以下步骤适用于 Ubuntu 20.04+ / Debian 11+，其他发行版请参考 Docker 官方文档。

#### 第一步：打开终端

按 `Ctrl+Alt+T` 打开终端。接下来的命令逐条复制粘贴执行。

#### 第二步：卸载旧版本（如果有的话）

```bash
sudo apt remove docker docker-engine docker.io containerd runc 2>/dev/null
```

> 这条命令尝试卸载旧版本的 Docker。如果提示找不到这些包，说明没有旧版本，不用管它。

#### 第三步：更新软件包列表并安装依赖

```bash
sudo apt update
```

你会看到终端拉取软件包信息。等待命令完成（出现命令提示符 `$`）。

```bash
sudo apt install -y ca-certificates curl
```

`-y` 参数意思是自动回答"yes"，不需要手动确认。这个命令安装两个必要的工具：

- `ca-certificates`：用来验证下载源的 SSL 证书
- `curl`：用来从网上下载文件

#### 第四步：添加 Docker 官方软件源

逐条执行（每条复制粘贴后按回车）：

```bash
sudo install -m 0755 -d /etc/apt/keyrings
```

> 创建一个目录，存放 Docker 的密钥文件。

```bash
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
```

> 下载 Docker 的 GPG 密钥（用来验证软件包是否真的是 Docker 官方发布的）。

```bash
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

> 确保所有用户都能读取密钥文件。

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

> 把 Docker 的下载地址添加到系统的软件源列表中。这条命令看起来长，但就是"告诉系统去哪里下载 Docker"。

#### 第五步：安装 Docker

```bash
sudo apt update
```

> 更新软件包列表，让系统知道新添加的 Docker 源。

```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

> 安装 Docker 及配套工具：

> - `docker-ce`：Docker 引擎本体
> - `docker-ce-cli`：Docker 命令行工具
> - `containerd.io`：容器运行时
> - `docker-buildx-plugin`：增强的构建工具
> - `docker-compose-plugin`：docker compose 功能（很重要，后面部署要用）

#### 第六步：验证 Docker 安装

```bash
docker --version
```

看到 `Docker version 24.x.x, build xxxxx` 就成功了。

#### 第七步：免 sudo 运行 Docker

默认情况下，Docker 命令需要加 `sudo`（管理员权限）。下面的命令让你可以不加 `sudo` 也能运行 Docker：

```bash
sudo usermod -aG docker $USER
```

> 把当前用户加入 `docker` 用户组。

然后**必须执行**以下两步：

1. **关闭终端窗口**
2. **重新打开终端**（或者注销重新登录）

> **这是很多人忽略的一步！** 不重新登录的话，免 sudo 配置不会生效。如果你跳过了这一步，后面可能会遇到 "permission denied" 错误。

验证免 sudo 是否生效：

```bash
docker run hello-world
```

如果能正常运行（看到 "Hello from Docker!"）就说明配置成功了。

---

### A5. 启动系统（所有平台通用）

Docker 装好后，所有平台（Windows/macOS/Linux）的启动步骤完全一样。

#### Linux / macOS

1. 打开终端
2. 确保在项目目录中。如果不确定，执行：

   ```bash
   cd ~/Bomiot
   ```

3. 在终端中执行：

   ```bash
   bash deploy.sh up
   ```

#### Windows

**方法一（最简单）**：打开 `Bomiot` 文件夹，**双击 `deploy.bat`** 文件即可。

**方法二（命令行）**：打开命令提示符（`Win+R` → `cmd` → 回车），输入：

```cmd
cd C:\Users\你的用户名\Desktop\Bomiot
deploy.bat up
```

> 把 `你的用户名` 替换为你当前登录 Windows 的用户名。如果不确定用户名，打开文件资源管理器，看 `C:\Users\` 下面有哪些文件夹。

#### 启动过程解读

当你执行启动命令后，会依次发生以下事情（你可以在终端中看到进度）：

1. **拉取镜像**（首次需要 5-15 分钟，之后只需几秒）：
   - 从 Docker Hub 下载 MySQL 镜像（约 500MB）
   - 从 Docker Hub 下载 Nginx 镜像（约 50MB）
   - 用项目自带的 Dockerfile 构建后端镜像（约 300MB）

2. **启动 MySQL 容器**：启动数据库，创建 `wms` 数据库，等待数据库就绪

3. **启动 Web 容器**：等数据库就绪后，运行数据库迁移（自动建表）、收集静态文件、创建管理员账号，然后启动 Gunicorn（Python 应用服务器）

4. **启动 Nginx 容器**：启动网页服务器，监听 80 端口

最终你会看到类似以下的输出：

```text
=== Deploy Complete ===
URL:  http://localhost
User: admin / admin123
```

> **首次启动注意事项：**
>
> - 下载镜像的过程可能比较慢，取决于你的网络速度。建议连接 Wi-Fi 或使用有线网络。
> - 如果在下载过程中终端卡住了（几分钟没有新输出），不要关闭窗口。检查一下网络连接，继续等待。
> - 国内用户访问 Docker Hub 可能比较慢，可以配置 Docker 镜像加速器（自行搜索 "Docker 国内镜像加速"）。
> - 如果看到 `Error response from daemon: Port 80 is already in use`，见 [Q2 端口被占用](#q2端口被占用)。

---

### A6. 验证系统是否正常运行

启动完成后，需要验证三个容器是否都在正常运行。

打开终端/命令行，输入：

```bash
docker ps
```

你应该看到类似这样的输出（三行，分别是 nginx、web、mysql）：

```text
CONTAINER ID   IMAGE          STATUS          PORTS                NAMES
abc123def456   nginx:alpine   Up 2 minutes    0.0.0.0:80->80/tcp   wms-nginx
def456abc789   deploy-web     Up 2 minutes    8000/tcp              wms-web
ghi789jkl012   mysql:8.0      Up 2 minutes    3306/tcp              wms-mysql
```

关键信息解读：

- **STATUS 列**：都应该显示 `Up X minutes`（运行中），不能是 `Exited`（已退出）或 `Restarting`（反复重启）
- **NAMES 列**：三个容器名分别是 `wms-nginx`、`wms-web`、`wms-mysql`
- 如果有容器显示 `Exited`，说明启动失败了。执行 `bash deploy.sh logs`（Linux/macOS）或 `deploy.bat logs`（Windows）查看错误日志。

检查 Nginx 是否在监听端口：

- Linux/macOS：`curl -I http://localhost`
- Windows：打开浏览器，访问 `http://localhost`

如果返回 HTTP 200 或跳转到登录页面，说明一切正常。

---

### A7. 登录系统

1. 打开浏览器（Chrome、Edge、Firefox 都可以）
2. 在地址栏输入 `http://localhost`，按回车
3. 你会看到一个登录页面，输入：
   - 用户名：`admin`
   - 密码：`admin123`
4. 点击"登录"按钮
5. 登录成功后进入系统首页（仪表板），可以看到 KPI 卡片和菜单

> **安全提醒：** 登录后建议第一时间修改默认密码：左侧菜单 → 右上角头像 → 修改密码。

---

## 方式B：本地部署（不需要 Docker，适合开发者）

### B1. 理解本地部署需要什么

本地部署需要手动安装以下三样东西：

| 组件 | 作用 | 类比 |
|------|------|------|
| **Python 3.10+** | 运行后端程序 | 后厨的炉灶 |
| **Node.js 20.x** | 构建前端页面 | 装修工具 |
| **MySQL 8.0**（或 SQLite） | 存储数据 | 仓库 |

每个操作系统的安装方法不同，下面分别说明。

---

### B2. Linux 本地部署（Ubuntu/Debian/CentOS/统信UOS/深度）

以下步骤以 Ubuntu 22.04 为例，其他 Linux 发行版大同小异。

#### 步骤 1：安装 Python

**检查是否已安装：**

```bash
python3 --version
```

如果显示 `Python 3.10.x` 或更高版本，跳到步骤 2。如果显示 `Python 3.8.x` 或更低版本，需要升级。

**安装 Python 3.10+：**

```bash
sudo apt update
sudo apt install python3 python3-pip python3-dev -y
```

> - `python3`：Python 解释器
> - `python3-pip`：Python 包管理器（用来安装 Python 依赖）
> - `python3-dev`：Python 开发头文件（编译某些 Python 包时需要）

验证：

```bash
python3 --version  # 应显示 Python 3.10+
pip3 --version     # 应显示 pip 22.x+
```

#### 步骤 2：安装 Node.js 20.x

Node.js 是用来构建前端的（把 Vue 代码打包成浏览器能直接用的 HTML/JS/CSS）。

```bash
# 添加 Node.js 20.x 官方源
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
```

> 这条命令连接 NodeSource 网站，下载安装脚本并执行，把 Node.js 20.x 的源添加到你的系统。

```bash
# 安装 Node.js
sudo apt install nodejs -y
```

验证：

```bash
node --version   # 应显示 v20.x.x
npm --version    # 应显示 10.x.x
```

#### 步骤 3：安装 MySQL

```bash
sudo apt install mysql-server -y
sudo systemctl start mysql       # 启动 MySQL 服务
sudo systemctl enable mysql      # 设置为开机自动启动
```

**设置 root 密码并创建数据库：**

```bash
sudo mysql
```

你现在进入了 MySQL 的命令行（提示符会变成 `mysql>`）。逐条输入以下 SQL 语句（每条按回车执行）：

```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root123';
FLUSH PRIVILEGES;
CREATE DATABASE wms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
exit;
```

逐条解释：

- 第一条：把 root 用户的密码设置为 `root123`，使用 `mysql_native_password` 认证方式
- 第二条：刷新权限让密码生效
- 第三条：创建 `wms` 数据库，字符集设为 `utf8mb4`（支持中文和 Emoji）
- 第四条：退出 MySQL 命令行

> **不想用 MySQL？** 可以用 SQLite（文件型数据库，不需要安装任何数据库软件）。只需跳过步骤 3，在步骤 4 的配置文件中将 `engine = mysql` 改为 `engine = sqlite`。程序会自动在 `dbs/` 目录创建数据库文件。SQLite 适合个人使用或测试，但不适合多人同时使用。

#### 步骤 4：创建配置文件

在项目目录中创建 `setup.ini` 配置文件。在终端中确保在项目目录下（`cd ~/Bomiot`），然后执行：

```bash
cat > setup.ini << 'EOF'
[project]
name = awesomewms

[database]
engine = mysql
name = wms
user = root
password = root123
host = 127.0.0.1
port = 3306

[templates]
name = templates/dist/spa/index.html

[locale]
time_zone = 'Asia/Shanghai'

[throttle]
allocation_seconds = 1
throttle_seconds = 10

[request]
limit = 100

[jwt]
user_jwt_time = 86400

[file]
file_size = 104857600
file_extension = py,png,jpg,jpeg,gif,bmp,webp,txt,md,html,htm,js,css,json,xml,csv,xlsx,xls,ppt,pptx,doc,docx,pdf

[mail]
email_host =
email_port = 465
email_host_user =
email_host_password =
default_from_email =
email_from =
email_use_ssl = True
EOF
```

验证文件是否正确创建：

```bash
cat setup.ini
```

应该看到上面写入的所有内容。

配置文件各段说明：

| 配置段 | 作用 |
|--------|------|
| `[project]` → `name` | 项目名称，决定模板目录和 App 加载路径 |
| `[database]` | 数据库连接信息（引擎类型、数据库名、用户名、密码、地址、端口） |
| `[templates]` → `name` | 前端入口文件路径 |
| `[locale]` → `time_zone` | 时区，`Asia/Shanghai` 是"亚洲/上海"（UTC+8） |
| `[throttle]` | API 限流：`allocation_seconds=1` 表示每秒允许 1 个请求窗口，`throttle_seconds=10` 表示 10 秒内限制请求次数 |
| `[request]` → `limit` | 请求体大小限制（MB） |
| `[jwt]` → `user_jwt_time` | JWT Token 有效期（秒），86400 = 24 小时 |
| `[file]` | 上传文件限制：`file_size` 最大文件大小（字节），`file_extension` 允许的文件后缀 |
| `[mail]` | 邮件配置（可选，发送邮件通知用，不填不影响基本功能） |

#### 步骤 5：安装 Python 依赖

```bash
# 如果使用 MySQL，需要先安装 MySQL 客户端开发库
sudo apt install default-libmysqlclient-dev build-essential pkg-config -y
```

> 这些是编译 `mysqlclient`（Python 连接 MySQL 的库）所需的系统级依赖。

```bash
# 安装 mysqlclient（Python 连接 MySQL 的工具）
pip install mysqlclient
```

```bash
# 安装项目所有 Python 依赖
pip install -r requirements.txt
```

> `requirements.txt` 文件里列出了项目需要的所有 Python 包，pip 会按列表逐一安装。如果安装过程中某个包报错，通常是缺少系统级依赖，查看终端中的错误信息，搜索对应的 `apt install` 命令来安装。

#### 步骤 6：初始化数据库

```bash
python bomiot/server/manage.py migrate
```

这条命令会：

1. 读取 `setup.ini` 中的数据库配置
2. 连接到数据库
3. 自动创建所有需要的表（用户表、商品表、库存表等）

正常输出类似：

```text
Operations to perform:
  Apply all migrations: core
Running migrations:
  Applying core.0001_initial... OK
  Applying core.0002_xxx... OK
```

#### 步骤 7：创建管理员账号

```bash
python bomiot/server/manage.py createsuperuser
```

系统会交互式地询问：

```text
用户名 (leave blank to use 'xxx'): admin
邮箱: admin@example.com
密码: admin123
密码 (再次输入): admin123
```

> 注意：输入密码时屏幕不会显示任何字符（连星号也没有），这是安全设计，直接输入后回车即可。

也可以用一条命令直接创建（不交互）：

```bash
python bomiot/server/manage.py bomiot_initadmin
```

#### 步骤 8：构建前端

```bash
cd awesomewms/templates
npm install
npm run build
cd ../..
```

逐条解释：

- `cd awesomewms/templates`：进入前端项目目录
- `npm install`：安装前端依赖（Vue、Quasar 等），大约需要 2-5 分钟
- `npm run build`：构建前端代码（把 Vue 组件编译成浏览器能识别的 HTML/JS/CSS）
- `cd ../..`：回到项目根目录

构建成功后，你会看到类似输出：

```text
Build succeeded
...
```

构建产物存放在 `awesomewms/templates/dist/spa/` 目录下。

> **提示**：`npm install` 在国内可能较慢，可以先设置国内镜像：

> ```bash
> npm config set registry https://registry.npmmirror.com

> npm install

> ```text

#### 步骤 9：启动服务器

```bash
python bomiot/server/manage.py runserver 0.0.0.0:8000
```

出现以下输出说明成功：

```text
System check identified no issues.
Starting development server at http://0.0.0.0:8000/
Quit the server with CONTROL-C.
```

> **关于 `0.0.0.0:8000`**：
>
> - `0.0.0.0` 表示监听所有网络接口（允许局域网其他设备访问），如果只在本机访问可以改为 `127.0.0.1`
> - `8000` 是端口号，可以改成其他数字（比如 `8080`、`8888`）

#### 步骤 10：访问系统（同 Docker 部署）

打开浏览器，访问 `http://127.0.0.1:8000`，用 `admin` / `admin123` 登录。

---

### B3. Windows 本地部署

> Windows 上对零基础用户执行命令行有较高要求。如果只是想快速体验系统，强烈建议用 [Docker 部署](#方式adocker-一键部署推荐最简单)。

#### 步骤 1：安装 Python

1. 打开浏览器，访问 `https://www.python.org/downloads/`
2. 网站会自动显示最新的 Python 版本和一个**黄色的大按钮**（"Download Python 3.xx.x"）
3. 点击黄色按钮下载安装包（约 25MB）
4. 下载完成后，在浏览器下载列表中找到 `python-3.xx.x-amd64.exe`，双击运行
5. **重要！重要！重要！** 在安装向导的第一个页面：
   - **必须勾选底部的 "Add Python to PATH"**（把 Python 添加到系统环境变量）
   - 如果不勾这个，后面执行 `python` 命令会提示"找不到命令"
6. 然后点击 "Install Now"（立即安装）
7. 等待进度条走完，看到 "Setup was successful" 就安装完成了

验证安装：

1. 按 `Win+R`，输入 `cmd`，回车，打开命令提示符
2. 在黑色窗口中输入 `python --version`，回车
3. 应该显示 `Python 3.xx.x`
4. 再输入 `pip --version`，回车，应该显示 `pip 2x.x.x`

如果显示"不是内部或外部命令"：

- 说明安装时没勾 "Add Python to PATH"
- 解决方法：重新运行安装包，选 "Modify"（修改），勾选 "Add Python to PATH"，再点 Install

#### 步骤 2：安装 Node.js

1. 打开浏览器，访问 `https://nodejs.org/`
2. 页面中间有两个绿色的下载按钮：
   - 左边 **"LTS"**（长期支持版，推荐大多数用户使用）— 选这个
   - 右边 "Current"（最新版，可能有不稳定因素）
3. 点击左边的 LTS 按钮（通常显示为 20.xx.x LTS）
4. 下载完成后，双击 `node-v20.xx.x-x64.msi` 运行安装
5. 安装向导：一路点 "Next"，全部默认选项即可
6. 最后点 "Install"，等待完成

验证安装：

1. 打开命令提示符（`Win+R` → `cmd` → 回车）
2. 输入 `node --version`，应该显示 `v20.x.x`
3. 输入 `npm --version`，应该显示 `10.x.x`

#### 步骤 3：安装 MySQL

1. 打开浏览器，访问 `https://dev.mysql.com/downloads/installer/`
2. 页面中有两个下载选项，选**较大的那个**（约 400MB，包含更多组件）：
   - `mysql-installer-community-8.0.xx.x.msi`（较大，推荐）
   - `mysql-installer-web-community-8.0.xx.x.msi`（较小，但安装时还需联网下载）
3. 下载完成后，双击 `.msi` 文件运行
4. 安装向导步骤较多，按顺序说明：

   **Choosing a Setup Type（选择安装类型）：**

   - 选 "Developer Default"（开发者默认），点 Next
   - 系统可能会提示缺少一些依赖（如 Visual C++ Redistributable），点 "Execute" 自动安装

   **Product Configuration（产品配置）：**

   - 一路点 Next 直到 "Accounts and Roles" 页面

   **Accounts and Roles（账号设置）：**

   - 在 "MySQL Root Password" 输入：`root123`
   - 在 "Repeat Password" 再输入：`root123`
   - **记住这个密码！后面要用！**
   - 点 Next

   **Windows Service（Windows 服务）：**

   - 确保 "Configure MySQL Server as a Windows Service" 勾选了
   - 点 Next → Execute → Finish

5. 安装完成后，MySQL 会在后台自动运行

**创建 wms 数据库：**

方法一（使用 MySQL Workbench 图形界面）：

1. 在开始菜单找到 "MySQL Workbench 8.0"，打开
2. 点击 "Local instance MySQL80" 连接
3. 输入 root 密码 `root123`，连接
4. 在左侧导航栏的 "SCHEMAS" 区域右键 → "Create Schema"
5. Name 输入 `wms`，Character Set 选 `utf8mb4`，Collation 选 `utf8mb4_unicode_ci`
6. 点 "Apply" → "Apply" → "Finish"

方法二（使用命令行）：

1. 打开命令提示符
2. 输入 `mysql -u root -p`，回车，输入密码 `root123`（输入时看不到字符）
3. 在 `mysql>` 提示符下输入：

   ```sql
   CREATE DATABASE wms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

4. 输入 `exit;` 退出

#### 步骤 4：创建配置文件

在项目目录中创建 `setup.ini`。打开命令提示符，切换到项目目录：

```cmd
cd C:\Users\你的用户名\Desktop\Bomiot
```

然后创建一个文本文件 `setup.ini`。最简单的方法：

1. 打开文件资源管理器，进入 `Bomiot` 文件夹
2. 右键 → 新建 → 文本文档
3. 重命名为 `setup.ini`（确保后缀是 `.ini` 不是 `.ini.txt`；如果不显示后缀，在文件资源管理器顶部菜单点"查看"→ 勾选"文件扩展名"）
4. 用记事本打开 `setup.ini`，粘贴以下内容：

```ini
[project]
name = awesomewms

[database]
engine = mysql
name = wms
user = root
password = root123
host = 127.0.0.1
port = 3306

[templates]
name = templates/dist/spa/index.html

[locale]
time_zone = 'Asia/Shanghai'

[throttle]
allocation_seconds = 1
throttle_seconds = 10

[request]
limit = 100

[jwt]
user_jwt_time = 86400

[file]
file_size = 104857600
file_extension = py,png,jpg,jpeg,gif,bmp,webp,txt,md,html,htm,js,css,json,xml,csv,xlsx,xls,ppt,pptx,doc,docx,pdf

[mail]
email_host =
email_port = 465
email_host_user =
email_host_password =
default_from_email =
email_from =
email_use_ssl = True
```

5. 保存并关闭。

> 如果不想用 MySQL，把 `engine = mysql` 改为 `engine = sqlite`，就可以跳过步骤 3（不用安装 MySQL）。

#### 步骤 5：安装 Python 依赖

在命令提示符中，确保在项目目录下（`C:\Users\你的用户名\Desktop\Bomiot>`），逐条执行：

```cmd
pip install mysqlclient
```

> 如果报错，可能是缺少 Visual C++ 编译工具。有以下解决方案：

> 1. 去 https://visualstudio.microsoft.com/visual-cpp-build-tools/ 下载安装 "Microsoft C++ Build Tools"
> 2. 或者直接改用 SQLite（把 setup.ini 中的 `engine = mysql` 改为 `engine = sqlite`），就完全不需要 MySQL 和 mysqlclient 了，这是最简单的方法

```cmd
pip install -r requirements.txt
```

> 这条命令会安装所有需要的 Python 包，可能需要 5-10 分钟

#### 步骤 6：初始化数据库

```cmd
python bomiot\server\manage.py migrate
```

> 注意 Windows 上路径分隔符是反斜杠 `\`，而不是 Linux/macOS 的 `/`

#### 步骤 7：创建管理员账号

```cmd
python bomiot\server\manage.py createsuperuser
```

按提示输入用户名（admin）、邮箱（随便填）、密码（admin123）。

#### 步骤 8：构建前端

```cmd
cd awesomewms\templates
npm install
npm run build
cd ..\..
```

#### 步骤 9：启动服务器

```cmd
python bomiot\server\manage.py runserver 0.0.0.0:8000
```

看到以下输出说明启动成功：

```text
Starting development server at http://0.0.0.0:8000/
```

**保持这个命令行窗口开着！** 关闭窗口 = 服务器停止。可以用 `Ctrl+C` 来停止服务器。

#### 步骤 10：访问系统

打开浏览器，访问 `http://127.0.0.1:8000`，用 `admin` / `admin123` 登录。

---

### B4. macOS 本地部署

#### 步骤 1：安装 Homebrew（macOS 上的软件包管理器）

Homebrew 就像一个"应用商店"，但专为开发者设计，通过命令行安装软件。

检查是否已安装：

```bash
brew --version
```

如果显示 `Homebrew 4.x.x`，跳到步骤 2。如果显示 "command not found"，按以下步骤安装。

安装 Homebrew：

1. 打开终端（启动台搜索"终端"）
2. 复制以下命令，粘贴到终端，按回车：

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. 脚本会告诉你将要安装什么，按回车继续
4. 输入你的 Mac 登录密码（输入时看不到字符）
5. 等待安装完成（约 5-10 分钟）
6. 安装完成后，根据终端提示，可能还需要执行一两条命令（脚本会明确告诉你），将 Homebrew 添加到 PATH

#### 步骤 2：安装 Python、Node.js、MySQL

使用 Homebrew 一条命令安装所有：

```bash
# 安装 Python
brew install python@3.11

# 安装 Node.js 20
brew install node@20

# 安装 MySQL
brew install mysql
```

安装完成后启动 MySQL：

```bash
brew services start mysql
```

> `brew services start mysql` 会让 MySQL 在后台持续运行，并且每次开机自动启动。

创建数据库：

```bash
# 登录 MySQL（首次安装默认没有密码）
mysql -u root

# 如果你之前设置过 root 密码（比如安装过程中提示设置的），使用：
# mysql -u root -p
```

在 MySQL 命令行中执行：

```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root123';
FLUSH PRIVILEGES;
CREATE DATABASE wms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
exit;
```

#### 步骤 3：创建配置文件

在项目目录中创建 `setup.ini`：

```bash
cd ~/Bomiot

cat > setup.ini << 'EOF'
[project]
name = awesomewms

[database]
engine = mysql
name = wms
user = root
password = root123
host = 127.0.0.1
port = 3306

[templates]
name = templates/dist/spa/index.html

[locale]
time_zone = 'Asia/Shanghai'

[throttle]
allocation_seconds = 1
throttle_seconds = 10

[request]
limit = 100

[jwt]
user_jwt_time = 86400

[file]
file_size = 104857600
file_extension = py,png,jpg,jpeg,gif,bmp,webp,txt,md,html,htm,js,css,json,xml,csv,xlsx,xls,ppt,pptx,doc,docx,pdf

[mail]
email_host =
email_port = 465
email_host_user =
email_host_password =
default_from_email =
email_from =
email_use_ssl = True
EOF
```

#### 步骤 4：安装 Python 依赖

```bash
pip install mysqlclient
pip install -r requirements.txt
```

> 如果 `pip install mysqlclient` 报错，可能需要先安装 MySQL 客户端库：

> ```bash
> brew install mysql-client pkg-config

> ```text

> 然后再重试。或者你也可以改用 SQLite，把 setup.ini 中 `engine = mysql` 改为 `engine = sqlite`。

#### 步骤 5：初始化数据库

```bash
python bomiot/server/manage.py migrate
```

#### 步骤 6：创建管理员

```bash
python bomiot/server/manage.py createsuperuser
```

按提示输入用户名、邮箱、密码。

#### 步骤 7：构建前端

```bash
cd awesomewms/templates
npm install
npm run build
cd ../..
```

#### 步骤 8：启动服务器

```bash
python bomiot/server/manage.py runserver 0.0.0.0:8000
```

#### 步骤 9：访问系统

打开浏览器，访问 `http://127.0.0.1:8000`。

---

## 访问系统

启动后在浏览器打开对应地址，你会看到登录页面。

| 部署方式 | 访问地址 | 什么时候用 |
|---------|---------|------------|
| Docker 部署 | `http://localhost` | 默认 80 端口 |
| 本地部署 | `http://127.0.0.1:8000` | 默认 8000 端口 |

**默认账号密码：**

| 用户名 | 密码 | 说明 |
|--------|------|------|
| admin | admin123 | Docker 部署自动创建，本地部署手动创建 |

> **登录后第一件事：** 建议立刻修改默认密码，特别是如果允许局域网其他人访问的话。

---

## 让局域网其他人访问系统

如果你想让同事在同一 WiFi/局域网下也能访问系统：

### Docker 部署

Docker 部署默认通过 Nginx 监听 80 端口，局域网其他设备访问 `http://你的电脑IP` 即可。

**如何查看你的电脑 IP 地址：**

- **Windows**：`Win+R` → 输入 `cmd` → 回车 → 输入 `ipconfig` → 找到"IPv4 地址"，类似 `192.168.1.xxx`
- **macOS**：系统设置 → 网络 → Wi-Fi → 查看 IP 地址。或终端输入 `ipconfig getifaddr en0`
- **Linux**：终端输入 `ip addr show | grep "inet "` 或 `hostname -I`

**防火墙注意事项：**

- **Windows**：首次启动 Docker 并暴露 80 端口时，Windows 防火墙可能会弹出"允许访问"的提示，点击"允许"
- **macOS**：通常不需要额外配置
- **Linux**：如果其他设备无法访问，可能需要开放防火墙：

  ```bash
  sudo ufw allow 80/tcp
  ```

  或（如果使用 firewalld）：

  ```bash
  sudo firewall-cmd --add-port=80/tcp --permanent
  sudo firewall-cmd --reload
  ```

### 本地部署

启动时绑定所有网卡：

```bash
python bomiot/server/manage.py runserver 0.0.0.0:8000
```

局域网其他设备访问 `http://你的电脑IP:8000`。

> **安全提醒：**
>
> - 默认账号密码 `admin/admin123` 不要直接暴露到公网（互联网）
> - 如需公网访问，请配置防火墙、HTTPS（SSL 证书），并修改默认密码
> - 这个系统设计用于内网环境，不要直接暴露到公网上

---

## 日常运维操作

### Docker 部署的日常操作

所有命令在项目目录下执行。

```bash
# 查看运行状态（三个容器是否都在运行）
docker ps
# 或者只看 Bomiot 相关的容器
docker ps --filter "name=wms"
```

```bash
# 查看日志（实时滚动，按 Ctrl+C 退出日志）
bash deploy.sh logs          # Linux/macOS
deploy.bat logs              # Windows
# 只看某个服务的日志：
docker logs -f wms-web       # 只看后端日志
docker logs -f wms-mysql     # 只看数据库日志
docker logs -f wms-nginx     # 只看 Nginx 日志
```

```bash
# 停止所有服务（系统将无法访问，数据保留）
bash deploy.sh down          # Linux/macOS
deploy.bat down              # Windows
```

```bash
# 启动已停止的服务（不重新构建）
docker compose -f deploy/docker-compose.yml up -d
```

```bash
# 重启应用（比如修改了代码后，只重启 web 服务，不影响数据库）
bash deploy.sh restart       # Linux/macOS
deploy.bat restart           # Windows
```

```bash
# 备份数据库（将数据库导出为 SQL 文件，保存到当前目录）
docker exec wms-mysql mysqldump -u root -proot123 wms > backup_$(date +%Y%m%d_%H%M%S).sql
# 执行后检查当前目录，会多一个 backup_20260101_120000.sql 文件
# 把这个文件复制到安全的地方保存
```

```bash
# 恢复数据库（从备份的 SQL 文件恢复）
docker exec -i wms-mysql mysql -u root -proot123 wms < backup_20260101_120000.sql
# 把文件名换成你实际的备份文件名
```

```bash
# 完全重置（清空所有数据，恢复到最初状态）
bash deploy.sh down          # 先停止
docker volume rm deploy_mysql_data   # 删除数据库数据卷
docker volume rm deploy_media_data   # 删除上传文件数据卷（可选）
bash deploy.sh up            # 重新启动
# 警告：此操作不可逆！数据库中的所有数据都会被删除
```

### 本地部署的日常操作

```bash
# 停止服务器：在运行服务器的终端窗口按 Ctrl+C

# 重新启动：回到项目目录，重新执行
python bomiot/server/manage.py runserver 0.0.0.0:8000
```

```bash
# 修改了前端代码后重新构建：
cd awesomewms/templates
npm run build
cd ../..
# 然后重启服务器
```

```bash
# 修改了后端代码后：直接重启服务器即可（Ctrl+C 停止，再启动）
```

```bash
# 数据库备份（MySQL）
mysqldump -u root -proot123 wms > backup.sql
# 文件保存在当前目录

# 数据库恢复（MySQL）
mysql -u root -proot123 wms < backup.sql
```

```bash
# 数据库备份（SQLite，如果用的是 SQLite）
cp dbs/db.sqlite3 dbs/db_backup_$(date +%Y%m%d).sqlite3
# 把 dbs/db.sqlite3 文件复制一份就是备份
```

---

## 常见问题排查（20个常见问题）

### Q1：Docker 提示 "permission denied"（Linux）

**完整错误信息：**

```text
permission denied while trying to connect to the Docker daemon socket
```

**原因：** 当前用户没有权限访问 Docker 守护进程。安装 Docker 后默认为 `root` 用户和 `docker` 组成员才有权限。

**解决方法：**

```bash
sudo usermod -aG docker $USER
```

然后**注销重新登录**（或者重启电脑）。这一步必须做，不重新登录配置不生效。

**验证修复：**

```bash
docker run hello-world
```

能运行就说明 OK 了。

---

### Q2：端口被占用

**完整错误信息：**

```text
Error response from daemon: driver failed programming external connectivity on endpoint wms-nginx:
Bind for 0.0.0.0:80 failed: port is already allocated
```

**原因：** 80 端口已经被其他程序占用了。常见的占用者：

- 另一个正在运行的 Web 服务器（如 Apache、IIS、Nginx）
- 其他 Docker 容器
- Skype（Skype 有时会占用 80 端口）
- Windows 的 IIS 服务

**解决方法：**

**方法 1（推荐）：修改 Bomiot 使用的端口**

编辑 `deploy/.env` 文件。如果不存在则创建：

```text
PORT=8080
```

然后重启：

```bash
bash deploy.sh down && bash deploy.sh up
```

之后访问 `http://localhost:8080`。

**方法 2：查找并关闭占用 80 端口的程序**

- **Windows**：

  ```cmd
  netstat -ano | findstr :80
  ```

  记下最后一列的 PID（进程 ID），在任务管理器中找到对应进程并结束。

- **Linux**：

  ```bash
  sudo lsof -i :80
  ```

  查看是哪个进程，根据需要关闭。

- **macOS**：

  ```bash
  sudo lsof -i :80
  ```

  查看是哪个进程。macOS 的内置 Apache 可能占用了 80 端口，关闭命令是：

  ```bash
  sudo apachectl stop
  ```

**本地部署端口占用：** 启动时用其他端口：

```bash
python bomiot/server/manage.py runserver 0.0.0.0:8888
```

然后访问 `http://127.0.0.1:8888`。

---

### Q3：Docker 构建失败

**可能的原因和解决方法：**

1. **磁盘空间不足**：Docker 需要至少 5GB 可用空间。清理磁盘后重试。

2. **网络问题导致下载失败**：

   ```bash
   # 清理 Docker 缓存
   docker system prune -af
   # 重新启动
   bash deploy.sh up
   ```

3. **国内下载慢**：配置 Docker 镜像加速器。编辑 Docker 配置文件：
   - Windows/macOS：打开 Docker Desktop → Settings → Docker Engine → 添加：

     ```json
     {
       "registry-mirrors": ["https://registry.cn-hangzhou.aliyuncs.com"]
     }
     ```

   - Linux：编辑 `/etc/docker/daemon.json`，添加相同内容，重启 `sudo systemctl restart docker`

---

### Q4：`pip install mysqlclient` 失败（Linux）

**常见错误信息：**

```text
mysql_config: not found
```

或

```text
fatal error: mysql.h: No such file or directory
```

**解决方法：**

```bash
# Ubuntu/Debian
sudo apt install python3-dev default-libmysqlclient-dev build-essential pkg-config -y

# CentOS/RHEL/Fedora
sudo yum install python3-devel mysql-devel gcc pkg-config -y

# 安装系统依赖后再重新安装 mysqlclient
pip install mysqlclient
```

**如果还是不行：** 改用 SQLite，把 `setup.ini` 中 `engine = mysql` 改为 `engine = sqlite`，完全不需要 MySQL。

---

### Q5：`pip install mysqlclient` 失败（Windows）

Windows 上编译 mysqlclient 比较困难。有以下解决方案：

**方案 1（推荐）：改用 SQLite**
把 `setup.ini` 中的 `engine = mysql` 改为 `engine = sqlite`，跳过所有 MySQL 相关步骤。SQLite 不需要安装任何数据库，数据文件自动创建在 `dbs/` 目录。

**方案 2：安装 C++ 编译工具**

1. 去 https://visualstudio.microsoft.com/visual-cpp-build-tools/ 下载 Build Tools
2. 安装时勾选 "C++ build tools" 和 "Windows 10 SDK"
3. 重启电脑后再试 `pip install mysqlclient`

**方案 3：使用预编译包**
去 https://www.lfd.uci.edu/~gohlke/pythonlibs/#mysqlclient 下载对应 Python 版本的 `.whl` 文件，然后：

```cmd
pip install 下载的文件名.whl
```

---

### Q6：`npm install` 很慢或失败

**原因：** npm 默认从境外服务器下载，国内访问较慢。

**解决方法：配置国内镜像源**

```bash
# 设置淘宝/阿里云 npm 镜像
npm config set registry https://registry.npmmirror.com

# 验证设置
npm config get registry

# 再重新安装
npm install
```

如果还是失败，尝试清除 npm 缓存：

```bash
npm cache clean --force
npm install
```

---

### Q7：页面打开是空白

排查步骤（按顺序逐一检查）：

1. **确认服务器在运行**：
   - Docker 部署：`docker ps` 看三个容器是否都在 `Up` 状态
   - 本地部署：运行服务器的终端没有报错，没有退出

2. **确认访问的地址正确**：
   - Docker：`http://localhost`（不要加端口号）
   - 本地：`http://127.0.0.1:8000`（注意是冒号，不是句号）

3. **按 F12 打开浏览器开发者工具**：
   - 点 "Console"（控制台）标签，看有没有红色错误信息
   - 点 "Network"（网络）标签，刷新页面，看哪个请求失败了

4. **检查静态文件**：
   - Docker 部署：确认 Nginx 容器在运行（`docker ps | grep nginx`）
   - 本地部署：确认执行过 `npm run build`，`awesomewms/templates/dist/spa/` 目录存在

5. **Docker 部署下查看 Nginx 日志**：

   ```bash
   docker logs wms-nginx
   ```

---

### Q8：忘记管理员密码

**Docker 部署：**

```bash
docker exec wms-web python bomiot/server/manage.py shell -c "
from django.contrib.auth import get_user_model
u = get_user_model().objects.get(username='admin')
u.set_password('新密码')
u.save()
print('密码已重置为新密码')
"
```

把 `新密码` 替换成你想设置的密码。

**本地部署：**

```bash
python bomiot/server/manage.py changepassword admin
```

按提示输入新密码。

---

### Q9：数据库连接失败（本地部署）

**错误信息：**

```text
django.db.utils.OperationalError: (2003, "Can't connect to MySQL server on '127.0.0.1'")
```

**检查项：**

1. **MySQL 服务是否在运行：**
   - Linux：`sudo systemctl status mysql`
   - macOS：`brew services list | grep mysql`
   - Windows：任务管理器 → 服务 → 找 MySQL80

2. **setup.ini 中的配置是否正确**：用户名、密码、主机、端口

3. **数据库 wms 是否已创建**：`mysql -u root -proot123 -e "SHOW DATABASES;"`

4. **如果以上都正确但仍然连不上，尝试用 SQLite**（最省心）：
   修改 `setup.ini`：`engine = sqlite`，删除或注释掉 `[database]` 段的其他行

---

### Q10：容器反复重启（Docker 部署）

**现象：** `docker ps` 看到某个容器的 STATUS 是 `Restarting` 或 `Up X seconds`（时间一直很短）

**排查方法：**

```bash
docker logs wms-web      # 看后端日志
docker logs wms-mysql    # 看数据库日志
```

常见原因：

- **数据库未就绪**：web 容器在数据库完全启动前就尝试连接。Docker Compose 的 `depends_on` 和 `healthcheck` 已经处理了这个问题，但如果还是出现，手动重启 web：

  ```bash
  docker compose -f deploy/docker-compose.yml restart web
  ```

- **端口冲突**：见 Q2
- **磁盘空间不足**：`df -h` 查看磁盘使用情况

---

### Q11：macOS 提示"无法验证开发者"

**错误提示：**

```text
"Docker" cannot be opened because the developer cannot be verified.
```

**解决方法：**

1. 打开"系统设置"（System Settings）
2. 点击"隐私与安全性"（Privacy & Security）
3. 向下滚动找到"安全性"部分
4. 你会看到关于 Docker 的提示，旁边有一个"仍要打开"（Open Anyway）按钮
5. 点击"仍要打开"
6. 输入你的 Mac 密码确认

---

### Q12：Docker Desktop 启动后一直转圈（Windows）

**现象：** Docker Desktop 窗口显示 "Docker Desktop is starting..."，但等了很久都没有好。

**解决方法：**

1. 先确认 WSL 2 是否已安装：
   - 以管理员身份打开 PowerShell（右键开始菜单 → Windows PowerShell (管理员)）
   - 输入 `wsl --install`，按回车，等待安装完成
   - 重启电脑
2. 如果 WSL 已经安装但仍然卡住，在 PowerShell（管理员）中运行：

   ```cmd
   wsl --update
   ```

3. 还不行的话，可以尝试关闭 Hyper-V 相关功能后重装 Docker Desktop

---

### Q13：Linux 执行 `deploy.sh` 提示 Permission denied

**解决方法：**

```bash
chmod +x deploy.sh
bash deploy.sh up
```

或者直接用 `bash deploy.sh up` 运行（不需要执行权限）。

---

### Q14：`python bomiot/server/manage.py migrate` 报错 "No module named bomiot"

**原因：** Python 找不到 bomiot 模块。可能不在正确的目录，或者 bomiot 包没有安装。

**解决方法：**

1. 确认当前在项目根目录（`~/Bomiot` 或类似路径）：`pwd`
2. 确认 bomiot 目录存在：`ls bomiot/`
3. 安装 bomiot 包：`pip install -e .` 或 `pip install -r requirements.txt`
4. 确认 Python 路径包含当前目录：`python -c "import sys; print(sys.path)"`

---

### Q15：`npm run build` 报错，提示内存不足

**解决方法：**

1. 关闭其他占用内存的软件（浏览器、IDE 等）
2. 增加 Node.js 可用内存：

   ```bash
   export NODE_OPTIONS="--max-old-space-size=4096"
   npm run build
   ```

3. 如果还是不行，考虑使用 Docker 部署，让 Docker 来负责构建

---

### Q16：数据库迁移报错 "Table already exists"

**原因：** 数据库中已经存在同名表，可能是之前迁移过。

**解决方法（注意：以下操作会导致数据丢失，仅在开发环境使用）：**

MySQL：

```sql
DROP DATABASE wms;
CREATE DATABASE wms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

SQLite：直接删除数据库文件：

```bash
rm dbs/db.sqlite3
```

然后重新执行 migrate。

---

### Q17：浏览器访问 localhost 时显示"连接被重置"或"无法访问此网站"

**排查步骤：**

1. Docker 部署：`docker ps` 确认 `wms-nginx` 容器的 PORTS 列显示 `0.0.0.0:80->80/tcp`
2. 确认没有代理或 VPN 干扰（尝试关闭 VPN/代理）
3. 尝试用 `http://127.0.0.1` 代替 `http://localhost`
4. 如果改了端口，确认访问地址中包含了正确的端口号（如 `http://localhost:8080`）
5. 清除浏览器缓存后再试

---

### Q18：修改代码后前端没有变化

**原因：** 前端需要重新构建才能生效。

**Docker 部署：**

```bash
bash deploy.sh down
bash deploy.sh up
```

> Docker 会在 `up` 时重新构建镜像，包括前端代码。

**本地部署：**

```bash
cd awesomewms/templates
npm run build
cd ../..
```

然后重启后端服务器。

---

### Q19：Docker 占用太多磁盘空间

**查看 Docker 占用的空间：**

```bash
docker system df
```

**清理不用的镜像、容器、数据卷：**

```bash
docker system prune -a
```

> 注意：这会删除所有停止的容器和未使用的镜像。正在运行的 Bomiot 容器和数据卷不受影响。但如果在 `down` 状态下执行，会删除 Bomiot 的镜像，下次 `up` 时需要重新构建。

---

### Q20：如何在服务器上设置开机自启动？

**Docker 部署：** docker-compose.yml 中已经设置了 `restart: unless-stopped`，只要 Docker 服务本身是开机启动的，系统就会自动启动。

确保 Docker 开机自启：

- **Linux**：`sudo systemctl enable docker`
- **Windows**：Docker Desktop → Settings → General → 勾选 "Start Docker Desktop when you log in"
- **macOS**：Docker Desktop → Settings → General → 勾选 "Start Docker Desktop when you log in"

**本地部署：** 需要自行配置 systemd（Linux）、launchd（macOS）或 Windows 任务计划来实现开机启动，建议生产环境使用 Docker 部署。

---

## 部署架构说明（给想了解原理的人）

### Docker 部署架构

```text
                         ┌─────────────────────────────────┐
                         │         Docker Network          │
                         │                                 │
  浏览器                  │  ┌──────────┐                  │
  ──────── HTTP :80 ───────→│  Nginx   │                  │
  用户电脑                │  │ (:80)    │                  │
                         │  └────┬─────┘                  │
                         │       │ proxy_pass             │
                         │       │ http://web:8000         │
                         │       ▼                         │
                         │  ┌──────────┐                  │
                         │  │ Gunicorn │                  │
                         │  │ (:8000)  │                  │
                         │  │ 2 worker │                 │
                         │  │ ×4 thread│                 │
                         │  └───┬──┬──┘                  │
                         │      │  │                       │
                         │      │  └──────────┐           │
                         │      ▼              ▼           │
                         │  ┌──────────┐ ┌──────────┐    │
                         │  │  MySQL   │ │ Whitenoise│    │
                         │  │ (:3306)  │ │ (static) │    │
                         │  └──────────┘ └──────────┘    │
                         │                                 │
                         └─────────────────────────────────┘
```

**各组件说明：**

| 组件 | 端口 | 作用 |
|------|------|------|
| **Nginx** | 80（对外） | 接收用户浏览器请求，转发给后端 Gunicorn。生产级 Web 服务器，处理高并发、静态文件缓存 |
| **Gunicorn** | 8000（内部） | Python WSGI 服务器，2 个 worker 进程，每个 4 个线程，共 8 个并发处理能力 |
| **MySQL** | 3306（内部） | 关系型数据库，数据存储到 Docker Volume `mysql_data`，即使容器删除数据也不丢失 |
| **Whitenoise** | 内嵌在 Gunicorn | 高效处理 CSS、JS、图片等静态文件，无需 Nginx 额外配置 |

**数据流向：**

1. 你在浏览器输入 `http://localhost`，按回车
2. 请求到达 Nginx（80 端口）
3. Nginx 判断请求类型：
   - 如果是静态文件（CSS/JS/图片），由 Whitenoise 直接返回
   - 如果是 API 请求（如 `/core/goods/`），转发给 Gunicorn
4. Gunicorn 处理业务逻辑，需要数据时查询 MySQL
5. 处理结果通过 Nginx 返回给浏览器

### 为什么不直接用 `python manage.py runserver`？

Django 自带的 `runserver` 是**开发服务器**，设计用于单用户本地调试，有以下限制：

- **性能低**：单线程处理请求，多人同时访问会排队等待
- **不安全**：没有生产级别的安全防护
- **不稳定**：长时间运行可能出现内存泄漏
- **不会处理静态文件**：生产环境下 CSS/JS/图片需要专门的服务器处理

Gunicorn 是**生产级 WSGI 服务器**：

- 多进程+多线程处理并发请求
- 自动重启崩溃的 worker 进程
- 资源管理更高效
- 配合 Nginx 实现完整的生产方案

---

> **最后的话：** 如果按照指南操作仍然遇到问题，可以到 https://github.com/Havensky-stack/Bomiot/issues 提交 Issue，描述你遇到的问题、操作系统、部署方式（Docker/本地）、以及完整的错误信息。
