<div align="center">
  <img src="media/img/logo.png" alt="awesomewms logo" width="200" height="auto" />
  <h1>awesomewms - Warehouse Management System</h1>
  <p><strong>Full-Stack Warehouse Management System based on Bomiot Framework</strong></p>

![Python](https://img.shields.io/badge/Python-3.9+-yellowgreen)
![Django](https://img.shields.io/badge/Django-4.2+-yellowgreen)
![Quasar](https://img.shields.io/badge/Quasar-2.18+-yellowgreen)
![Vue](https://img.shields.io/badge/Vue-3.4+-yellowgreen)
![License](https://img.shields.io/badge/License-APLv2-blue)

</div>

---

## System Overview

awesomewms is a full-stack Warehouse Management System (WMS) built on the Bomiot framework. It provides complete inbound/outbound management, inventory tracking, basic data management, and system monitoring capabilities. The system supports multi-user role-based access control with fine-grained API-level permissions.

### Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend Framework | Django 4.2+ |
| API | Django REST Framework |
| Frontend Framework | Quasar v2 + Vue 3.4 |
| Database | SQLite / MySQL / PostgreSQL |
| Authentication | JWT Token |
| Monitoring | psutil (CPU, Memory, Disk, Network) |
| Charts | ECharts 5 |

---

## Core Features

### Warehouse Management

| Module | Description |
|--------|-------------|
| **Goods Management** | Product/item master data (code, name, spec, unit, price) |
| **Bin Management** | Storage location management (code, name, type, capacity) |
| **Stock Management** | Real-time inventory tracking with stock level alerts |
| **Supplier Management** | Supplier contact information and address management |
| **Customer Management** | Customer contact information and address management |

### Inbound / Outbound Operations

| Module | Description |
|--------|-------------|
| **ASN (Advanced Shipping Notice)** | Inbound order management with status tracking |
| **ASN Detail** | Line-item details for inbound orders |
| **DN (Delivery Note)** | Outbound order management with status tracking |
| **DN Detail** | Line-item details for outbound orders |
| **Purchase Orders** | Purchase order management linking suppliers and goods |

### Business Flow

```
[Create Supplier] → [Create Goods] → [Create Bin]
                                          ↓
[Create ASN] → [Create ASN Detail] → [Confirm ASN] → [Stock Updated ↑]
[Create DN] → [Create DN Detail] → [Confirm DN] → [Stock Updated ↓]
```

- **ASN Confirm**: When confirmed, stock quantities are automatically increased in the specified bins
- **DN Confirm**: When confirmed, stock quantities are automatically decreased from the specified bins
- **Low Stock Alert**: Dashboard displays all items with quantity below 10 units

---

## User Management & Permissions

### Permission Model

```
API List → Permission Entries → Team (grant permissions) → User (join team, inherit permissions)
```

1. **Create Permissions**: Permissions are defined in the database linking API endpoints to permission names
2. **Create Teams**: Assign permission sets to teams
3. **Create Users**: Users are created by administrators (default password = username)
4. **Assign Teams**: Users inherit all permissions from their team
5. **Re-login Required**: Permission changes take effect after re-login (JWT-based)

### Default Admin Account

- Username: `admin`
- Password: `admin123`
- Superuser with all permissions bypass

### Available Permission Categories

- **User Management**: Create user, change password, set team, lock/unlock, delete
- **Team Management**: Create team, set permissions, modify, delete
- **Department Management**: Create, modify, delete departments
- **WMS Entities**: CRUD permissions for Goods, Bin, Stock, Supplier, Customer, ASN, DN, Purchase

---

## System Monitoring

The system includes built-in server monitoring (requires `IS_LAN=true` environment variable):

| Monitor | Description |
|---------|-------------|
| **CPU** | Real-time CPU usage tracking with timeline charts |
| **Memory** | Used/free memory tracking with timeline charts |
| **Disk** | Per-partition disk usage statistics |
| **Network** | Bytes sent/received tracking with timeline charts |
| **PID** | Process-level memory usage tracking |
| **PID Tree** | Process memory usage treemap visualization |

---

## Navigation Structure

### WMS Tab
- **Dashboard** - KPI cards + inbound/outbound charts + low stock alerts
- **Goods** - Product master data CRUD
- **Bin** - Storage location CRUD
- **Stock** - Inventory view
- **ASN** - Inbound orders with confirm action
- **ASN Detail** - Inbound line items
- **DN** - Outbound orders with confirm action
- **DN Detail** - Outbound line items
- **Supplier** - Supplier CRUD
- **Customer** - Customer CRUD
- **Purchase** - Purchase order CRUD

### Standard Tab
- **Home** - Welcome page
- **README** - System documentation
- **User** - User management
- **Team** - Team and permission management
- **Department** - Department management
- **Upload** - File upload center
- **Doc** - Document center

### Server Tab (IS_LAN)
- PID, CPU, Memory, Disk, Network monitoring
- DashBoard, PID Tree charts

---

## API Reference

All API endpoints are prefixed with `/core/` except dashboard endpoints which use `/wmsapp/`.

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/login/` | Login, returns JWT token |
| POST | `/logout/` | Logout |
| GET | `/checktoken/` | Check token validity |

### WMS Entities

| Entity | List | Create | Update | Delete |
|--------|------|--------|--------|--------|
| Goods | GET `/core/goods/` | POST `/core/goods/create/` | POST `/core/goods/update/` | POST `/core/goods/delete/` |
| Bin | GET `/core/bin/` | POST `/core/bin/create/` | POST `/core/bin/update/` | POST `/core/bin/delete/` |
| Stock | GET `/core/stock/` | POST `/core/stock/create/` | POST `/core/stock/update/` | POST `/core/stock/delete/` |
| Supplier | GET `/core/supplier/` | POST `/core/supplier/create/` | POST `/core/supplier/update/` | POST `/core/supplier/delete/` |
| Customer | GET `/core/customer/` | POST `/core/customer/create/` | POST `/core/customer/update/` | POST `/core/customer/delete/` |
| ASN | GET `/core/asn/` | POST `/core/asn/create/` | POST `/core/asn/update/` | POST `/core/asn/delete/` |
| ASN Detail | GET `/core/asn/detail/` | POST `/core/asn/detail/create/` | POST `/core/asn/detail/update/` | POST `/core/asn/detail/delete/` |
| DN | GET `/core/dn/` | POST `/core/dn/create/` | POST `/core/dn/update/` | POST `/core/dn/delete/` |
| DN Detail | GET `/core/dn/detail/` | POST `/core/dn/detail/create/` | POST `/core/dn/detail/update/` | POST `/core/dn/detail/delete/` |
| Purchase | GET `/core/purchase/` | POST `/core/purchase/create/` | POST `/core/purchase/update/` | POST `/core/purchase/delete/` |

### WMS Business Operations

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/wmsapp/dashboard/` | Get dashboard KPIs |
| POST | `/wmsapp/asn/confirm/` | Confirm ASN receipt (updates stock) |
| POST | `/wmsapp/dn/confirm/` | Confirm DN shipment (updates stock) |

### User Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/core/user/` | List users |
| POST | `/core/user/create/` | Create user |
| POST | `/core/user/changepwd/` | Change password |
| POST | `/core/user/team/` | Set user team |
| POST | `/core/user/department/` | Set user department |
| POST | `/core/user/lock/` | Lock/unlock user |
| POST | `/core/user/delete/` | Delete user |
| GET | `/core/user/permission/` | List all permissions |

### Team Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/core/team/` | List teams |
| POST | `/core/team/create/` | Create team |
| POST | `/core/team/setpermission/` | Set team permissions |
| POST | `/core/team/change/` | Rename team |
| POST | `/core/team/delete/` | Delete team |

### Common Parameters

- **Pagination**: `?page=1&max_page=30`
- **Search**: `?params={"data__fieldname__icontains":"keyword"}`
- **Auth Header**: `token: <JWT_TOKEN>`

---

## Deployment

### Prerequisites

- Python 3.9+
- Node.js 18.19+ (for frontend build only)
- SQLite (default) or MySQL/PostgreSQL

### Quick Start

```bash
# 1. Clone and enter project
cd Bomiot/awesomewms

# 2. Create conda environment
conda create -n wms python=3.11 -y && conda activate wms

# 3. Install dependencies
pip install -r requirements.txt

# 4. Initialize database
cd ../ && PYTHONPATH=. python bomiot/server/manage.py migrate

# 5. Seed permissions and API data
PYTHONPATH=. python seed_api.py
PYTHONPATH=. python seed_permissions.py

# 6. Create admin user (via Django shell)
PYTHONPATH=. python bomiot/server/manage.py shell -c "
from django.contrib.auth import get_user_model
u = get_user_model().objects.create_superuser('admin', 'admin@wms.com', 'admin123')
"

# 7. Build frontend
cd awesomewms/templates && npm install && npm run build

# 8. Start server (with monitoring)
cd ../../
IS_LAN=true PYTHONPATH=. python bomiot/server/manage.py runserver 0.0.0.0:8000

# 9. Access system
# Open http://127.0.0.1:8000/
# Login: admin / admin123
```

### Docker Deployment

```bash
cd deploy
docker-compose up -d
```

### Configuration

Edit `awesomewms/setup.ini`:
```ini
[project]
name = awesomewms

[database]
engine = sqlite          # or mysql, postgresql, oracle
name = db_name
user = db_user
password = db_pwd
host = db_host
port = db_port

[jwt]
user_jwt_time = 1000000

[request]
limit = 5                # Max failed login attempts before lockout

[file]
file_size = 102400000    # Max upload size in bytes
```

---

## Project Structure

```
Bomiot/
├── awesomewms/                    # WMS project
│   ├── language/                  # i18n files (en-US.toml, zh-CN.toml)
│   ├── media/                     # Static assets and markdown docs
│   ├── templates/                 # Frontend (Quasar/Vue 3)
│   │   └── src/
│   │       ├── boot/              # Axios config, event bus
│   │       ├── components/        # Reusable components
│   │       │   ├── echarts/       # Chart components
│   │       │   ├── md/            # Markdown renderer
│   │       │   ├── user/          # User/Team/Department list components
│   │       │   └── wms/           # WMS CRUD table component
│   │       ├── i18n/              # Frontend translations
│   │       ├── layouts/           # Main layout with header/menu
│   │       ├── pages/             # Page components (one per route)
│   │       ├── router/            # Vue Router config
│   │       └── stores/            # Pinia stores
│   ├── wmsapp/                    # WMS backend app
│   │   ├── views.py               # Dashboard, ASN/DN confirm views
│   │   └── urls.py                # WMS-specific routes
│   ├── bomiotconf.ini             # Project identifier
│   ├── receiver.py                # Data signal handlers
│   └── setup.ini                  # Project configuration
├── bomiot/server/                 # Bomiot framework core
│   └── core/
│       ├── models.py              # All database models
│       ├── views.py               # User/Team/Department views
│       ├── urls.py                # Core URL routing
│       ├── function/              # WMS entity handlers
│       ├── client.py              # Server monitoring endpoints
│       ├── page.py                # Pagination classes
│       ├── jwt_auth.py            # JWT authentication
│       └── auth.py                # Custom authentication backend
├── seed_api.py                    # API table seed script
├── seed_permissions.py            # Permission table seed script
└── deploy/                        # Docker and deployment configs
```

---

<div align="center">

**awesomewms - Full-Stack Warehouse Management System**

</div>
