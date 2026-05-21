# WMS System Deployment Guide / WMS 系统部署文档

## 系统概述

基于 Bomiot 框架构建的全栈仓储管理系统(WMS)，包含：
- **后端**: Django + Django REST Framework，商品管理、库位管理、库存管理、入库单(ASN)、出库单(DN)、供应商、客户、采购订单
- **前端**: Vue 3 + Quasar + Pinia + ECharts SPA
- **数据库**: MySQL 8.0

---

## 一键 Docker 部署（推荐）

零依赖，只需 Docker。自动启动 MySQL + Web 服务，前端已在镜像中构建完毕。

```bash
# 一键启动
bash deploy.sh

# 或使用 docker compose 直接启动
docker compose -f deploy/docker-compose.yml up -d
```

启动后访问: **http://localhost:8000**
默认账号: **admin** / **admin123**

```bash
bash deploy.sh logs     # 查看日志
bash deploy.sh down     # 停止服务
bash deploy.sh restart  # 重启 Web 服务
bash deploy.sh build    # 重新构建镜像
```

### 自定义配置

编辑 [deploy/.env](deploy/.env) 修改数据库密码：

```env
MYSQL_ROOT_PASSWORD=root123
MYSQL_DATABASE=wms
MYSQL_USER=wms_user
MYSQL_PASSWORD=wms_password
```

### 数据持久化

MySQL 数据存储在 Docker volume `mysql_data` 中，重启不丢失。

```bash
# 备份数据库
docker exec wms-mysql mysqldump -u root -proot123 wms > backup.sql

# 恢复数据库
docker exec -i wms-mysql mysql -u root -proot123 wms < backup.sql
```

---

## 本地开发部署

### 环境要求

| 依赖 | 版本 |
|------|------|
| Python | 3.9 ~ 3.13 |
| Node.js | 18+ |
| MySQL | 8.0 / MariaDB 10.x |

### 分步部署

```bash
# 1) 创建数据库
mariadb -u root -p < scripts/setup_db.sql

# 2) 编辑 setup.ini 填入数据库连接信息

# 3) 安装依赖
pip install -r requirements.txt mysqlclient

# 4) 数据库迁移
python bomiot/server/manage.py migrate

# 5) 创建管理员
python bomiot/server/manage.py createsuperuser

# 6) 构建前端
cd awesomewms/templates && npm install && npm run build && cd ../..

# 7) 启动
python bomiot/server/manage.py runserver
```

### 一键脚本（非 Docker）

```bash
# Linux / macOS
bash scripts/deploy_linux.sh

# Windows
scripts\deploy_windows.bat
```

---

## Docker 架构

```
docker-compose.yml
├── db (MySQL 8.0)      ← 数据持久化到 mysql_data volume
│   └── healthcheck     ← web 等待 db 就绪后启动
└── web (Python 3.11)
    ├── Dockerfile       ← 多阶段构建（前端 yarn build + 后端 pip install）
    ├── docker-entrypoint.sh  ← 自动生成 setup.ini → migrate → 创建管理员 → runserver
    └── 端口 8000
```

---

## 配置说明

### setup.ini 关键配置

```ini
[database]
engine = mysql          # sqlite / mysql / postgresql
name = wms
user = root
password = root123
host = 127.0.0.1
port = 3306

[jwt]
user_jwt_time = 86400   # Token 有效期（秒）

[file]
file_size = 104857600   # 上传文件大小限制（字节）
```

### 前端 API 地址

修改 [awesomewms/templates/src/boot/axios.js](awesomewms/templates/src/boot/axios.js):

```javascript
const baseURL = 'http://127.0.0.1:8000'
```

---

## 系统使用

### 菜单结构

**WMS 标签页**：仪表板 → 商品 → 库位 → 库存 → 入库单 → 出库单 → 供应商 → 客户 → 采购订单

**基础标签页**：用户、团队、部门、文件管理

**服务器标签页**：CPU / 内存 / 磁盘 / 网络监控

### 典型业务流程

1. 登录 → 创建商品 → 创建库位 → 添加供应商/客户
2. 入库：创建 ASN → 添加入库明细 → 确认收货 → 库存自动更新
3. 出库：创建 DN → 添加出库明细 → 确认发货 → 库存自动扣减
4. 仪表板查看 KPI 和低库存预警

---

## 常见问题

**Docker 构建失败？** 确保 Docker 版本 >= 20.10，磁盘空间充足。

**端口冲突？** 修改 `deploy/docker-compose.yml` 中的端口映射，如 `"8080:8000"`。

**数据库连接失败？** 确认 `deploy/.env` 中的密码与 `setup.ini` 中的一致。

**如何重置？**
```bash
bash deploy.sh down
docker volume rm deploy_mysql_data
bash deploy.sh up
```

---

## 项目结构

```
Bomiot/
├── bomiot/server/core/          # 框架核心（WMS 模型、API、JWT）
├── awesomewms/
│   ├── wmsapp/                  # WMS 业务逻辑（信号接收器、自定义 API）
│   └── templates/src/           # 前端 Vue/Quasar 源码
│       ├── pages/               # 页面组件（11 个 WMS 页面）
│       ├── components/wms/      # 通用 CRUD 组件
│       ├── router/ stores/ i18n/
├── deploy/
│   ├── Dockerfile               # 多阶段构建
│   ├── docker-compose.yml       # MySQL + Web
│   ├── docker-entrypoint.sh     # 容器启动脚本
│   └── .env                     # 环境变量
├── scripts/                     # 辅助脚本
├── deploy.sh                    # 一键 Docker 部署入口
├── setup.ini                    # 项目配置
└── requirements.txt
```
