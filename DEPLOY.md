# Bomiot WMS 部署指南

本指南面向**零基础用户**，手把手教你从 GitHub 下载项目到成功运行系统。

---

## 目录

- [第一步：下载项目](#第一步下载项目)
- [第二步：选择部署方式](#第二步选择部署方式)
- [方式A：Docker 一键部署（推荐，全平台通用）](#方式adocker-一键部署推荐全平台通用)
  - [A1. 安装 Docker](#a1-安装-docker)
  - [A2. 启动系统](#a2-启动系统)
- [方式B：本地部署（不用 Docker）](#方式b本地部署不用-docker)
  - [B1. Linux 本地部署](#b1-linux-本地部署)
  - [B2. Windows 本地部署](#b2-windows-本地部署)
  - [B3. macOS 本地部署](#b3-macos-本地部署)
- [访问系统](#访问系统)
- [常用运维命令](#常用运维命令)
- [常见问题排查](#常见问题排查)

---

## 第一步：下载项目

### 1.1 安装 Git

如果你已经有 Git，跳过此步。

**Windows**：
1. 打开浏览器，访问 https://git-scm.com/download/win
2. 下载后双击运行，一路点 "Next"（全部默认选项即可）
3. 安装完成后，在桌面右键菜单中会出现 "Git Bash Here"

**macOS**：
1. 打开 "终端"（在启动台搜索 "Terminal"）
2. 输入 `xcode-select --install`，按回车，弹出窗口点"安装"
3. 等待安装完成

**Linux (Ubuntu/Debian)**：
1. 按 `Ctrl+Alt+T` 打开终端
2. 输入 `sudo apt install git -y`，按回车，输入密码

### 1.2 克隆项目

**Windows**：
1. 在桌面右键 → "Git Bash Here"，会打开一个命令行窗口
2. 输入以下命令，按回车：
```bash
git clone https://github.com/Havensky-stack/Bomiot.git
```
3. 等待下载完成，桌面上会出现 `Bomiot` 文件夹

**macOS / Linux**：
1. 打开终端
2. 输入以下命令，按回车：
```bash
git clone https://github.com/Havensky-stack/Bomiot.git
```
3. 等待下载完成

进入项目目录（接下来的所有命令都在这个目录下执行）：
```bash
cd Bomiot
```

---

## 第二步：选择部署方式

| 方式 | 适合人群 | 优点 | 缺点 |
|------|---------|------|------|
| **A: Docker 部署** | 不想折腾环境的用户 | 一条命令启动，自动搞定所有依赖 | 需要安装 Docker（一次性） |
| **B: 本地部署** | 开发者、需要改代码的用户 | 灵活可控 | 需要手动安装 Python、Node.js、MySQL |

**强烈推荐方式 A**，除非你需要修改代码。

---

## 方式A：Docker 一键部署（推荐，全平台通用）

Docker 就像一个"集装箱"，把系统需要的所有东西打包好，你只需要装好 Docker 就能跑，不用管 Python、Node.js、MySQL 等环境。

### A1. 安装 Docker

#### Windows

1. 打开浏览器，访问 https://www.docker.com/products/docker-desktop/
2. 点击 "Download for Windows" 按钮，下载安装包
3. 双击运行，一路点 "OK" / "Next"，全部默认选项
4. 安装完成后**重启电脑**
5. 重启后 Docker 会自动启动，任务栏右下角会出现一个鲸鱼图标
6. 出现 "Docker Desktop is running" 弹窗即表示就绪

> **注意**：如果提示需要启用 WSL2，按照提示操作即可，Docker 会自动引导你完成。

#### macOS

1. 打开浏览器，访问 https://www.docker.com/products/docker-desktop/
2. 根据你的芯片选择下载：
   - M1/M2/M3 芯片 → "Download for Mac with Apple Silicon"
   - Intel 芯片 → "Download for Mac with Intel Chip"
   （不确定的话：点左上角苹果图标 → "关于本机" → 看"芯片"那一行）
3. 双击 `.dmg` 文件，把 Docker 图标拖到 Applications 文件夹
4. 在启动台找到 Docker 图标，双击打开
5. 首次启动会要求输入系统密码，输入后等待鲸鱼图标出现在顶部菜单栏

#### Linux (Ubuntu/Debian)

打开终端（Ctrl+Alt+T），逐条复制粘贴以下命令：

```bash
# 1. 卸载旧版本
sudo apt remove docker docker-engine docker.io containerd runc

# 2. 安装依赖
sudo apt update
sudo apt install -y ca-certificates curl

# 3. 添加 Docker 官方源
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. 安装 Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. 免 sudo 运行 Docker
sudo usermod -aG docker $USER
```

**重启电脑**后再继续。

### A2. 启动系统

所有平台的命令完全一样。

**Linux / macOS**：打开终端，进入项目目录：
```bash
cd ~/Bomiot      # 如果你克隆到了其他位置，改成对应路径
bash deploy.sh up
```

**Windows**：打开项目文件夹，双击 `deploy.bat` 文件即可。

或者在命令行中：
```cmd
cd C:\Users\你的用户名\Desktop\Bomiot
deploy.bat up
```

首次运行会下载镜像、构建项目，大约需要 **5-15 分钟**（取决于网络速度）。看到以下输出表示成功：

```
=== Deploy Complete ===
URL:  http://localhost
User: admin / admin123
```

之后在浏览器打开 **http://localhost** 就能看到登录页面了。

> **macOS 用户注意**：如果端口 80 被占用，编辑 `deploy/.env`，加一行 `PORT=8080`，然后访问 `http://localhost:8080`。

---

## 方式B：本地部署（不用 Docker）

如果你需要修改代码、或者不想装 Docker，可以选择本地部署。

### B1. Linux 本地部署

**适用系统**：Ubuntu 20.04+ / Debian 11+ / CentOS 7+ / 统信 UOS / 深度

#### 步骤 1：安装 Python

Ubuntu 22.04+ 自带 Python 3.10，可以直接用。检查：
```bash
python3 --version
```
如果显示 `Python 3.x.x` 即可。如果没装：
```bash
sudo apt update && sudo apt install python3 python3-pip -y
```

#### 步骤 2：安装 Node.js

```bash
# 添加 NodeSource 源（Node.js 20 LTS）
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install nodejs -y

# 验证
node --version   # 应显示 v20.x.x
npm --version    # 应显示 10.x.x
```

#### 步骤 3：安装 MySQL

```bash
sudo apt install mysql-server -y
sudo systemctl start mysql
sudo systemctl enable mysql

# 设置 root 密码（首次安装）
sudo mysql
```
在 MySQL 命令行中输入以下 SQL：
```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root123';
CREATE DATABASE wms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
exit;
```

#### 步骤 4：安装依赖并启动

```bash
cd ~/Bomiot

# 创建配置文件
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

# 安装 Python 依赖
pip install mysqlclient
pip install -r requirements.txt

# 数据库初始化
python bomiot/server/manage.py migrate

# 创建管理员（输入用户名 admin，密码 admin123）
python bomiot/server/manage.py createsuperuser

# 构建前端
cd awesomewms/templates
npm install
npm run build
cd ../..

# 启动
python bomiot/server/manage.py runserver 0.0.0.0:8000
```

访问 **http://127.0.0.1:8000**。

> **不想用 MySQL？** 将 `setup.ini` 中 `engine = mysql` 改成 `engine = sqlite`，跳过步骤 3，数据库文件会自动创建在 `dbs/` 目录下。

---

### B2. Windows 本地部署

#### 步骤 1：安装 Python

1. 打开浏览器，访问 https://www.python.org/downloads/
2. 点击黄色 "Download Python 3.x.x" 按钮
3. **重要**：安装时勾选底部的 **"Add Python to PATH"**，然后点 "Install Now"
4. 安装完成后，打开命令提示符（按 `Win+R`，输入 `cmd`，回车），验证：
```cmd
python --version
```
应显示 `Python 3.x.x`。

#### 步骤 2：安装 Node.js

1. 打开浏览器，访问 https://nodejs.org/
2. 点击左边的 "LTS" 版本下载（推荐 20.x）
3. 双击运行，一路 "Next"，全部默认选项
4. 安装完成后，打开命令提示符，验证：
```cmd
node --version
npm --version
```
都应显示版本号。

#### 步骤 3：安装 MySQL

1. 打开浏览器，访问 https://dev.mysql.com/downloads/installer/
2. 下载 `mysql-installer-community-8.0.x.x.msi`
3. 双击运行，选择 "Developer Default"，一路 Next
4. 在 "Accounts and Roles" 页面，设置 root 密码为 `root123`
5. 安装完成后，打开 MySQL Workbench，连接数据库
6. 新建一个名为 `wms` 的数据库，字符集选 `utf8mb4`

#### 步骤 4：安装依赖并启动

打开命令提示符（`Win+R` → `cmd` → 回车），进入项目目录：
```cmd
cd C:\Users\你的用户名\Desktop\Bomiot
```

然后**逐条**复制粘贴以下命令执行：

```cmd
rem 安装 MySQL 客户端
pip install mysqlclient

rem 安装 Python 依赖
pip install -r requirements.txt

rem 数据库初始化
python bomiot\server\manage.py migrate

rem 创建管理员
python bomiot\server\manage.py createsuperuser

rem 构建前端
cd awesomewms\templates
npm install
npm run build
cd ..\..

rem 启动服务器
python bomiot\server\manage.py runserver 0.0.0.0:8000
```

> **提示**：你也可以直接运行 `scripts\deploy_windows.bat`，它会交互式引导你完成以上所有步骤。

访问 **http://127.0.0.1:8000**。

---

### B3. macOS 本地部署

#### 步骤 1：安装 Homebrew（macOS 包管理器）

打开终端（启动台 → 搜索 "终端"），粘贴以下命令：
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
按照提示输入密码，等待安装完成。

#### 步骤 2：安装 Python、Node.js、MySQL

```bash
# 安装 Python 3.11
brew install python@3.11

# 安装 Node.js 20
brew install node@20

# 安装 MySQL
brew install mysql
brew services start mysql

# 创建数据库
mysql -u root -e "CREATE DATABASE wms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root123';"
```

#### 步骤 3：安装依赖并启动

```bash
cd ~/Bomiot

# 创建配置（同 Linux，见上方 setup.ini 内容）

# 安装依赖
pip install mysqlclient
pip install -r requirements.txt

# 初始化
python bomiot/server/manage.py migrate
python bomiot/server/manage.py createsuperuser

# 构建前端
cd awesomewms/templates
npm install
npm run build
cd ../..

# 启动
python bomiot/server/manage.py runserver 0.0.0.0:8000
```

访问 **http://127.0.0.1:8000**。

---

## 访问系统

启动后在浏览器打开对应地址，你会看到登录页面。

| 部署方式 | 访问地址 |
|---------|---------|
| Docker 部署 | http://localhost |
| 本地部署 | http://127.0.0.1:8000 |

**默认账号密码**：

| 用户名 | 密码 |
|--------|------|
| admin | admin123 |

> Docker 部署时管理员自动创建。本地部署时 `createsuperuser` 命令会让你手动输入。

---

## 常用运维命令

### Docker 部署

```bash
# 查看运行状态
docker ps

# 查看日志（实时滚动）
bash deploy.sh logs

# 停止所有服务
bash deploy.sh down

# 重启应用（更新代码后）
bash deploy.sh restart

# 备份数据库
docker exec wms-mysql mysqldump -u root -proot123 wms > backup.sql

# 恢复数据库
docker exec -i wms-mysql mysql -u root -proot123 wms < backup.sql

# 完全重置（清空数据重新来过）
bash deploy.sh down
docker volume rm deploy_mysql_data
bash deploy.sh up
```

### 本地部署

```bash
# 停止：在运行服务器的终端按 Ctrl+C

# 重新构建前端（修改前端代码后）
cd awesomewms/templates && npm run build && cd ../..

# 数据库备份（MySQL）
mysqldump -u root -proot123 wms > backup.sql

# 数据库恢复
mysql -u root -proot123 wms < backup.sql
```

---

## 常见问题排查

### Q1：Docker 提示 "permission denied"（Linux）

```bash
sudo usermod -aG docker $USER
```
然后**注销重新登录**。

### Q2：端口被占用

**Docker 部署**：编辑 `deploy/.env`，修改端口：
```
PORT=8080
```
然后访问 `http://localhost:8080`。

**本地部署**：启动时指定其他端口：
```bash
python bomiot/server/manage.py runserver 0.0.0.0:8888
```
访问 `http://127.0.0.1:8888`。

### Q3：Docker 构建失败

```bash
# 清理缓存重新构建
docker system prune -af
bash deploy.sh up
```

### Q4：`pip install mysqlclient` 失败（Linux）

```bash
# 安装编译依赖
sudo apt install python3-dev default-libmysqlclient-dev build-essential pkg-config -y
pip install mysqlclient
```

### Q5：`pip install mysqlclient` 失败（Windows）

去 https://www.lfd.uci.edu/~gohlke/pythonlibs/#mysqlclient 下载对应 Python 版本的 `.whl` 文件，然后：
```cmd
pip install 下载的文件名.whl
```

或者直接改用 SQLite 数据库（将 `setup.ini` 中 `engine = sqlite`）。

### Q6：`npm install` 很慢

```bash
npm config set registry https://registry.npmmirror.com
npm install
```

### Q7：页面打开是空白

1. 确认服务器正在运行（终端没有报错）
2. 确认访问的地址和端口正确
3. 按 F12 打开浏览器开发者工具，查看 Console 有没有红色报错
4. 如果是 Docker 部署，确认 Nginx 容器在运行：`docker ps | grep nginx`

### Q8：忘记管理员密码

Docker 部署：
```bash
docker exec wms-web python bomiot/server/manage.py shell -c "
from django.contrib.auth import get_user_model
u = get_user_model().objects.get(username='admin')
u.set_password('新密码')
u.save()
print('密码已重置')
"
```

本地部署：
```bash
python bomiot/server/manage.py changepassword admin
```

### Q9：如何让外网/局域网其他人访问？

**Docker 部署**：已经通过 Nginx 监听 80 端口，局域网其他设备直接访问 `http://你的IP` 即可。查看 IP：
- Linux/macOS：`ip addr` 或 `ifconfig`
- Windows：`ipconfig`

**本地部署**：启动时绑定所有网卡：
```bash
python bomiot/server/manage.py runserver 0.0.0.0:8000
```
局域网访问 `http://你的IP:8000`。

> **安全提醒**：不要将默认密码的系统直接暴露到公网。如需公网访问，请配置防火墙、HTTPS 并修改默认密码。

### Q10：macOS 提示"无法验证开发者"

系统偏好设置 → 安全性与隐私 → 通用 → 点击"仍要打开"。

---

## 部署架构（Docker）

```
浏览器 ──→ Nginx (:80) ──→ Gunicorn (:8000) ──→ Django App
                              │
                              ├──→ MySQL (:3306)
                              ├──→ Whitenoise (静态文件)
                              └──→ Media (上传文件)
```

- **Nginx**：接收用户请求，转发给后端
- **Gunicorn**：生产级 Python WSGI 服务器（2 worker × 4 threads）
- **MySQL**：数据库，数据持久化到 Docker volume
- **Whitenoise**：高效处理 CSS/JS/图片等静态资源
