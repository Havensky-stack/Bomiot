<div align="center">
  <img src="media/img/logo.png" alt="awesomewms logo" width="200" height="auto" />
  <h1>awesomewms - 仓库管理系统</h1>
  <p><strong>基于 Bomiot 框架的全栈仓库管理系统</strong></p>

![Python](https://img.shields.io/badge/Python-3.9+-yellowgreen)
![Django](https://img.shields.io/badge/Django-4.2+-yellowgreen)
![Quasar](https://img.shields.io/badge/Quasar-2.18+-yellowgreen)
![Vue](https://img.shields.io/badge/Vue-3.4+-yellowgreen)
![License](https://img.shields.io/badge/License-APLv2-blue)

</div>

---

## 系统概述

awesomewms 是基于 Bomiot 框架构建的全栈仓库管理系统（WMS），提供完整的入库/出库管理、库存跟踪、基础数据管理和系统监控功能。系统支持多用户基于角色的访问控制，具备 API 级别的细粒度权限管理。

### 技术栈

| 层级 | 技术 |
|------|------|
| 后端框架 | Django 4.2+ |
| API | Django REST Framework |
| 前端框架 | Quasar v2 + Vue 3.4 |
| 数据库 | SQLite / MySQL / PostgreSQL |
| 认证 | JWT Token |
| 监控 | psutil (CPU、内存、磁盘、网络) |
| 图表 | ECharts 5 |

---

## 核心功能

### 仓库基础数据管理

| 模块 | 说明 |
|------|------|
| **商品管理** | 产品/物料主数据（编码、名称、规格、单位、价格） |
| **库位管理** | 存储位置管理（编码、名称、类型、容量） |
| **库存管理** | 实时库存跟踪，低库存预警 |
| **供应商管理** | 供应商联系信息及地址管理 |
| **客户管理** | 客户联系信息及地址管理 |

### 出入库业务

| 模块 | 说明 |
|------|------|
| **入库单 (ASN)** | 入库订单管理，支持状态跟踪 |
| **入库单明细** | 入库单行项目详情 |
| **出库单 (DN)** | 出库订单管理，支持状态跟踪 |
| **出库单明细** | 出库单行项目详情 |
| **采购订单** | 采购订单管理，关联供应商和商品 |

### 业务流程

```
[创建供应商] → [创建商品] → [创建库位]
                                ↓
[创建入库单] → [创建入库单明细] → [确认入库] → [库存增加 ↑]
[创建出库单] → [创建出库单明细] → [确认出库] → [库存减少 ↓]
```

- **确认入库**：入库单确认后，自动在指定库位增加库存
- **确认出库**：出库单确认后，自动从指定库位扣减库存
- **低库存预警**：仪表板展示所有数量低于 10 的商品

---

## 用户管理与权限

### 权限模型

```
API 列表 → 权限条目 → 团队（勾选权限） → 用户（加入团队，继承权限）
```

1. **创建权限**：权限在数据库中定义，关联 API 端点与权限名称
2. **创建团队**：为团队分配权限集
3. **创建用户**：由管理员创建用户（默认密码与用户名相同）
4. **分配团队**：用户加入团队后自动继承团队权限
5. **重新登录**：权限变更后需重新登录生效（JWT 机制）

### 默认管理员账号

- 用户名：`admin`
- 密码：`admin123`
- 超级用户，不受权限限制

### 权限分类

- **用户管理**：创建用户、修改密码、设置团队、锁定/解锁、删除
- **团队管理**：创建团队、设置权限、修改、删除
- **部门管理**：创建、修改、删除部门
- **WMS 实体**：商品、库位、库存、供应商、客户、入库单、出库单、采购订单的增删改查权限

---

## 系统监控

系统内置服务器监控功能（需设置环境变量 `IS_LAN=true`）：

| 监控项 | 说明 |
|--------|------|
| **CPU** | 实时 CPU 使用率追踪，含时间线图表 |
| **Memory** | 已用/空闲内存追踪，含时间线图表 |
| **Disk** | 各分区磁盘使用统计 |
| **Network** | 发送/接收字节数追踪，含时间线图表 |
| **PID** | 进程级内存使用追踪 |
| **PID Tree** | 进程内存使用矩形树图 |

---

## 导航结构

### WMS 标签页
- **仪表板** - KPI 卡片 + 出入库图表 + 低库存预警
- **商品** - 商品主数据增删改查
- **库位** - 存储位置增删改查
- **库存** - 库存查看
- **入库单** - 入库订单（含确认入库操作）
- **入库单明细** - 入库行项目
- **出库单** - 出库订单（含确认出库操作）
- **出库单明细** - 出库行项目
- **供应商** - 供应商增删改查
- **客户** - 客户增删改查
- **采购订单** - 采购订单增删改查

### 标准标签页
- **首页** - 欢迎页
- **README** - 系统说明文档
- **用户** - 用户管理
- **团队** - 团队及权限管理
- **部门** - 部门管理
- **上传** - 文件上传中心
- **文档** - 文档中心

### 服务器标签页（需 IS_LAN）
- PID、CPU、Memory、Disk、Network 监控
- DashBoard、PID Tree 图表

---

## API 参考

### 认证

| 方法 | 端点 | 说明 |
|------|------|------|
| POST | `/login/` | 登录，返回 JWT token |
| POST | `/logout/` | 登出 |
| GET | `/checktoken/` | 查看 token 信息 |

### WMS 实体

| 实体 | 列表 | 创建 | 更新 | 删除 |
|------|------|------|------|------|
| 商品 | GET `/core/goods/` | POST `/core/goods/create/` | POST `/core/goods/update/` | POST `/core/goods/delete/` |
| 库位 | GET `/core/bin/` | POST `/core/bin/create/` | POST `/core/bin/update/` | POST `/core/bin/delete/` |
| 库存 | GET `/core/stock/` | POST `/core/stock/create/` | POST `/core/stock/update/` | POST `/core/stock/delete/` |
| 供应商 | GET `/core/supplier/` | POST `/core/supplier/create/` | POST `/core/supplier/update/` | POST `/core/supplier/delete/` |
| 客户 | GET `/core/customer/` | POST `/core/customer/create/` | POST `/core/customer/update/` | POST `/core/customer/delete/` |
| 入库单 | GET `/core/asn/` | POST `/core/asn/create/` | POST `/core/asn/update/` | POST `/core/asn/delete/` |
| 入库单明细 | GET `/core/asn/detail/` | POST `/core/asn/detail/create/` | POST `/core/asn/detail/update/` | POST `/core/asn/detail/delete/` |
| 出库单 | GET `/core/dn/` | POST `/core/dn/create/` | POST `/core/dn/update/` | POST `/core/dn/delete/` |
| 出库单明细 | GET `/core/dn/detail/` | POST `/core/dn/detail/create/` | POST `/core/dn/detail/update/` | POST `/core/dn/detail/delete/` |
| 采购订单 | GET `/core/purchase/` | POST `/core/purchase/create/` | POST `/core/purchase/update/` | POST `/core/purchase/delete/` |

### WMS 业务操作

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/wmsapp/dashboard/` | 获取仪表板 KPI 数据 |
| POST | `/wmsapp/asn/confirm/` | 确认入库收货（更新库存） |
| POST | `/wmsapp/dn/confirm/` | 确认出库发货（更新库存） |

### 用户管理

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/core/user/` | 获取用户列表 |
| POST | `/core/user/create/` | 创建用户 |
| POST | `/core/user/changepwd/` | 修改密码 |
| POST | `/core/user/team/` | 设置用户团队 |
| POST | `/core/user/department/` | 设置用户部门 |
| POST | `/core/user/lock/` | 锁定/解锁用户 |
| POST | `/core/user/delete/` | 删除用户 |
| GET | `/core/user/permission/` | 获取所有权限列表 |

### 团队管理

| 方法 | 端点 | 说明 |
|------|------|------|
| GET | `/core/team/` | 获取团队列表 |
| POST | `/core/team/create/` | 创建团队 |
| POST | `/core/team/setpermission/` | 设置团队权限 |
| POST | `/core/team/change/` | 重命名团队 |
| POST | `/core/team/delete/` | 删除团队 |

### 通用参数

- **分页**：`?page=1&max_page=30`
- **搜索**：`?params={"data__字段名__icontains":"关键字"}`
- **认证头**：`token: <JWT_TOKEN>`

---

## 部署指南

### 环境要求

- Python 3.9+
- Node.js 18.19+（仅构建前端时需要）
- SQLite（默认）或 MySQL/PostgreSQL

### 快速启动

```bash
# 1. 进入项目目录
cd Bomiot

# 2. 创建 conda 环境
conda create -n wms python=3.11 -y && conda activate wms

# 3. 安装依赖
pip install -r requirements.txt

# 4. 初始化数据库
PYTHONPATH=. python bomiot/server/manage.py migrate

# 5. 填充权限和 API 数据
PYTHONPATH=. python seed_api.py
PYTHONPATH=. python seed_permissions.py

# 6. 创建管理员账号
PYTHONPATH=. python bomiot/server/manage.py shell -c "
from django.contrib.auth import get_user_model
u = get_user_model().objects.create_superuser('admin', 'admin@wms.com', 'admin123')
"

# 7. 构建前端
cd awesomewms/templates && npm install && npm run build && cd ../..

# 8. 启动服务（带监控）
IS_LAN=true PYTHONPATH=. python bomiot/server/manage.py runserver 0.0.0.0:8000

# 9. 访问系统 http://127.0.0.1:8000/，使用 admin/admin123 登录
```

### Docker 部署

```bash
cd deploy
docker-compose up -d
```

### 配置说明

编辑 `awesomewms/setup.ini`：
```ini
[project]
name = awesomewms

[database]
engine = sqlite          # 可选: mysql, postgresql, oracle
name = db_name
user = db_user
password = db_pwd
host = db_host
port = db_port

[jwt]
user_jwt_time = 1000000   # JWT 过期时间（秒）

[request]
limit = 5                 # 登录失败锁定次数

[file]
file_size = 102400000     # 最大上传文件大小（字节）
```

---

## 项目结构

```
Bomiot/
├── awesomewms/                    # WMS 项目目录
│   ├── language/                  # 国际化语言文件
│   ├── media/                     # 静态资源与 Markdown 文档
│   ├── templates/                 # 前端 (Quasar/Vue 3 SPA)
│   │   └── src/
│   │       ├── boot/              # Axios 配置、事件总线
│   │       ├── components/        # 可复用组件
│   │       │   ├── echarts/       # ECharts 图表组件
│   │       │   ├── md/            # Markdown 渲染器
│   │       │   ├── user/          # 用户/团队/部门管理组件
│   │       │   └── wms/           # WMS 通用 CRUD 表格
│   │       ├── i18n/              # 前端国际化翻译
│   │       ├── layouts/           # 主布局（页头+菜单）
│   │       ├── pages/             # 页面组件
│   │       ├── router/            # Vue Router 路由配置
│   │       └── stores/            # Pinia 状态管理
│   ├── wmsapp/                    # WMS 后端应用
│   │   ├── views.py               # 仪表板、ASN/DN 确认接口
│   │   └── urls.py                # WMS 路由注册
│   ├── bomiotconf.ini             # 项目标识
│   ├── receiver.py                # 数据信号处理器
│   └── setup.ini                  # 项目配置文件
├── bomiot/server/                 # Bomiot 框架核心
│   └── core/
│       ├── models.py              # 数据模型定义
│       ├── views.py               # 用户/团队/部门视图
│       ├── urls.py                # 核心路由
│       ├── function/              # WMS 各实体 CRUD 处理函数
│       ├── client.py              # 服务器监控 API
│       ├── page.py                # 分页器
│       ├── jwt_auth.py            # JWT 认证
│       └── auth.py                # 自定义认证后端
├── seed_api.py                    # API 表初始化脚本
├── seed_permissions.py            # 权限表初始化脚本
└── deploy/                        # Docker 部署配置
```

---

<div align="center">

**awesomewms - 全栈仓库管理系统**

</div>
