# WMS System Deployment Guide / WMS 系统部署文档

## 系统概述

基于 Bomiot 框架构建的全栈仓储管理系统(WMS)，包含：
- **后端**: Django + Django REST Framework，提供商品管理、库位管理、库存管理、入库单(ASN)、出库单(DN)、供应商管理、客户管理、采购订单等完整 WMS 功能
- **前端**: Vue 3 + Quasar + Pinia + ECharts 单页应用(SPA)
- **数据库**: 默认 SQLite，支持切换至 PostgreSQL / MySQL

---

## 环境要求

| 依赖 | 版本 |
|------|------|
| Python | 3.9 ~ 3.13 |
| Node.js | 18+ |
| npm | 6.13.4+ |
| Git | 2.0+ |

---

## 一、本地开发环境部署

### 1.1 克隆项目

```bash
git clone <your-repo-url> Bomiot
cd Bomiot
```

### 1.2 创建虚拟环境 (推荐使用 Anaconda)

```bash
conda create -n wms python=3.11
conda activate wms
pip install -r requirements.txt
```

### 1.3 数据库初始化

项目默认使用 SQLite，数据库文件位于 `dbs/db.sqlite3`。

```bash
# Linux/Mac
python bomiot/server/manage.py migrate

# Windows
python bomiot\server\manage.py migrate
```

### 1.4 创建管理员账号

```bash
python bomiot/server/manage.py createsuperuser
# 按提示输入用户名、邮箱、密码
```

### 1.5 构建前端

```bash
cd awesomewms/templates
npm install
npm run build
cd ../..
```

构建产物输出到 `awesomewms/templates/dist/spa/`。

### 1.6 启动后端服务

```bash
python bomiot/server/manage.py runserver
```

默认访问地址: <http://127.0.0.1:8000>

### 1.7 开发模式启动前端 (可选)

```bash
cd awesomewms/templates
npm run dev
```

前端开发服务器支持热更新，API 请求会自动代理到后端。

---

## 二、Docker 部署

### 2.1 使用 Docker Compose (开发模式)

```bash
# 构建并启动
docker compose -f deploy/docker-compose.yml up -d

# 查看日志
docker compose -f deploy/docker-compose.yml logs -f

# 停止
docker compose -f deploy/docker-compose.yml down
```

访问: <http://localhost:8000>

### 2.2 使用 Docker Compose (生产模式 + PostgreSQL)

修改项目根目录 `setup.ini` 中的数据库配置：

```ini
[database]
engine = postgresql
name = wms
user = wms_user
password = wms_password
host = postgres
port = 5432
```

然后启动包含 PostgreSQL 的生产模式：

```bash
docker compose -f deploy/docker-compose.yml --profile production up -d
```

### 2.3 单独构建 Docker 镜像

```bash
docker build -f deploy/Dockerfile -t wms-system .
docker run -p 8000:8000 -v $(pwd)/dbs:/app/dbs -v $(pwd)/logs:/app/logs wms-system
```

---

## 三、生产环境部署 (Linux + Nginx + Supervisor)

### 3.1 安装依赖

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3 python3-pip nginx supervisor -y

# CentOS/RHEL
sudo yum install python3 python3-pip nginx supervisor -y
```

### 3.2 部署项目

```bash
# 创建部署目录
sudo mkdir -p /opt/wms
sudo cp -r . /opt/wms/
cd /opt/wms

# 安装 Python 依赖
pip3 install -r requirements.txt

# 构建前端
cd awesomewms/templates && npm install && npm run build && cd /opt/wms

# 初始化数据库
python3 bomiot/server/manage.py migrate
python3 bomiot/server/manage.py createsuperuser
```

### 3.3 配置 Supervisor

```bash
sudo cp deploy/supervisor.conf /etc/supervisor/conf.d/wms.conf
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start wms-server
```

### 3.4 配置 Nginx

```bash
sudo cp deploy/nginx.conf /etc/nginx/sites-available/wms
sudo sed -i 's|/app|/opt/wms|g' /etc/nginx/sites-available/wms
sudo sed -i 's|your-domain.com|your-domain.com|g' /etc/nginx/sites-available/wms
sudo ln -s /etc/nginx/sites-available/wms /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 3.5 配置 HTTPS (推荐)

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

---

## 四、配置说明

### 4.1 项目配置文件 (`setup.ini`)

```ini
[project]
name = awesomewms       # 项目名称

[database]
engine = sqlite          # 数据库引擎: sqlite / postgresql / mysql
name = wms
user = wms_user
password = wms_password
host = 127.0.0.1
port = 5432

[locale]
time_zone = 'Asia/Shanghai'

[jwt]
user_jwt_time = 86400   # JWT Token 有效期 (秒)

[file]
file_size = 104857600   # 最大文件上传大小 (字节)
file_extension = py,png,jpg,jpeg,gif,pdf,xlsx,xls,doc,docx,csv

[throttle]
allocation_seconds = 1
throttle_seconds = 10

[request]
limit = 100
```

### 4.2 数据库切换

**SQLite (默认)**: 无需额外配置，数据库文件在 `dbs/db.sqlite3`

**PostgreSQL**:
1. 创建数据库: `CREATE DATABASE wms;`
2. 修改 `setup.ini` 中的 `[database]` 部分
3. 安装依赖: `pip install psycopg2-binary`

**MySQL**:
1. 创建数据库: `CREATE DATABASE wms CHARACTER SET utf8mb4;`
2. 修改 `setup.ini` 中的 `[database]` 部分
3. 安装依赖: `pip install mysqlclient`

### 4.3 前端 API 地址配置

修改 `awesomewms/templates/src/boot/axios.js` 中的 `baseURL`:

```javascript
const baseURL = 'http://127.0.0.1:8000'  // 改为你的后端地址
```

---

## 五、系统使用指南

### 5.1 基本流程

1. **登录系统**: 使用管理员账号登录
2. **创建商品**: 在 "商品管理" 页面添加商品信息
3. **创建库位**: 在 "库位管理" 页面设置仓库库位
4. **添加供应商/客户**: 在对应页面添加业务伙伴
5. **入库操作**: 创建 ASN (入库单) → 添加入库明细 → 确认收货 → 库存自动更新
6. **出库操作**: 创建 DN (出库单) → 添加出库明细 → 确认发货 → 库存自动扣减
7. **库存查看**: 在 "库存管理" 页面查看实时库存
8. **仪表板**: 查看 KPI 指标和低库存预警

### 5.2 菜单结构

**WMS 标签页**:
- 仪表板 - WMS 概览和 KPI
- 商品管理 - 商品的增删改查
- 库位管理 - 仓库库位管理
- 库存管理 - 库存查询
- 入库单(ASN) - 收货入库管理
- 出库单(DN) - 发货出库管理
- 供应商 - 供应商信息管理
- 客户 - 客户信息管理
- 采购订单 - 采购管理

**基础标签页**: 用户管理、团队管理、部门管理等
**服务器标签页**: CPU、内存、磁盘、网络监控

---

## 六、常见问题

### Q: 数据库迁移报错？
```bash
# 清除旧数据库重新迁移
rm dbs/db.sqlite3
python bomiot/server/manage.py migrate
python bomiot/server/manage.py createsuperuser
```

### Q: 前端页面空白？
确保已构建前端:
```bash
cd awesomewms/templates && npm run build
```

### Q: API 请求 401？
重新登录获取新 token，或清除浏览器 LocalStorage 后重新登录。

### Q: 端口被占用？
```bash
# 查找占用端口的进程
lsof -i :8000
# 或指定其他端口启动
python bomiot/server/manage.py runserver 0.0.0.0:8080
```

### Q: npm install 失败？
```bash
# 使用国内镜像
npm config set registry https://registry.npmmirror.com
npm install
```

---

## 七、项目结构

```
Bomiot/
  bomiot/                    # Bomiot 核心框架
    server/
      core/                  # 核心模型、序列化器、权限、JWT
        models.py            # 所有 WMS 数据模型
      function/              # WMS 业务逻辑函数模块
      server/
        settings.py          # Django 配置
        urls.py              # 主路由
  awesomewms/                # WMS 项目
    wmsapp/                  # Django 应用
      receiver.py            # 信号接收器 (业务逻辑)
      views.py               # 自定义 API 视图 (仪表板、确认入库/出库)
      serializers.py         # 自定义序列化器
      urls.py                # 自定义路由
      admin.py               # Django Admin 配置
    templates/               # 前端 Vue/Quasar 项目
      src/
        pages/               # 页面组件
        components/wms/      # WMS 通用组件
        router/              # 路由配置
        stores/              # Pinia 状态管理
        i18n/                # 国际化
  dbs/                       # SQLite 数据库
  logs/                      # 日志目录
  deploy/                    # 部署配置
    Dockerfile
    docker-compose.yml
    supervisor.conf
    nginx.conf
  setup.ini                  # 项目配置
  requirements.txt           # Python 依赖
```
