<div align="center">
  <img src="media/img/logo.png" alt="awesomewms logo" width="200" height="auto" />
  <h1>awesomewms - System Documentation</h1>
  <p><strong>Full-Stack Warehouse Management System — Complete User Manual</strong></p>
</div>

---

## 1. System Overview

awesomewms is a full-stack WMS built on the Bomiot framework. It provides end-to-end warehouse operations: goods management, bin (storage location) management, inventory tracking, supplier/customer management, purchase orders, inbound orders (ASN), and outbound orders (DN). All stock changes are audit-traced through ASN/DN confirmations.

### Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Django 4.2+ / Django REST Framework |
| Frontend | Quasar v2 + Vue 3.4 + Pinia |
| Database | SQLite (default) / MySQL / PostgreSQL |
| Auth | JWT Token + API-level permissions |
| Charts | ECharts 5 |
| Monitoring | psutil (CPU, Memory, Disk, Network) |

---

## 2. First-Time Setup

### Starting the Server

```bash
cd Bomiot
conda activate wms
IS_LAN=true PYTHONPATH=. python bomiot/server/manage.py runserver 0.0.0.0:8000
```

Open `http://127.0.0.1:8000/` in your browser.

### Default Admin Account

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | `admin123` |

The `admin` account is a superuser — it bypasses all permission checks and can access every feature.

### Login Flow

1. Navigate to `http://127.0.0.1:8000/`
2. Enter `admin` / `admin123`
3. Click **Login** — you land on the homepage

### Homepage Layout

After login you see:

- **Welcome Banner** — system name and description
- **KPI Cards** — totals for Goods, Bins, Stock Items, Suppliers, Customers, and Weekly Inbound count
- **Low Stock Warning** — yellow banner if any item's quantity is below 10
- **Quick Actions** — 8 shortcut cards to jump directly to Goods, Bins, ASN, DN, Stock, Suppliers, Customers, Purchase
- **Recent Activity** — timeline of the last 5 inbound/outbound transactions
- **Dashboard Preview** — today's inbound/outbound counts with a button to the full dashboard

---

## 3. Navigation Structure

The left sidebar has four tabs:

### WMS Tab
Dashboard, Goods, Bin, Stock, ASN, ASN Detail, DN, DN Detail, Supplier, Customer, Purchase

### Standard Tab
Home, Documentation, User List, Team List, Department, Upload Center, Doc Center

### Server Tab (only when `IS_LAN=true`)
PID, CPU, Memory, Disk, Network, DashBoard, PID Tree

### API Tab
API Explorer, Example

---

## 4. Base Data Setup (Step-by-Step)

Before creating warehouse transactions, configure your base data in the following order. Each entity depends on a previously created one.

### 4.1 Create a Supplier

Suppliers provide the goods you receive in inbound orders.

1. Click **Supplier** in the sidebar or homepage quick actions
2. Click the **New** button (top-right)
3. Fill in the dialog:
   - **Supplier Name**: e.g. "ABC Electronics (Shanghai) Ltd."
   - **Contact**: e.g. "Zhang Wei"
   - **Phone**: e.g. "138-0000-1234"
   - **Address**: e.g. "No. 100, Zhangjiang Rd, Pudong, Shanghai"
4. Click **Submit** — the new supplier appears in the list

### 4.2 Create a Customer

Customers receive goods from your outbound orders.

1. Click **Customer** in the sidebar
2. Click **New**
3. Fill in the same fields as Supplier (Name, Contact, Phone, Address)
4. Click **Submit**

### 4.3 Create a Goods Record

Goods are your products/materials that flow through the warehouse.

1. Click **Goods** in the sidebar
2. Click **New**
3. Fill in:
   - **Goods Name**: e.g. "Stainless Steel Washer - 10mm"
   - **Goods Code**: e.g. "WASHER-10MM-SS" (unique identifier)
   - **Specification**: e.g. "OD 20mm, ID 10mm, thickness 2mm, 304 stainless steel"
   - **Unit**: e.g. "pcs", "kg", "box", "roll"
   - **Price**: Unit price as a decimal number (e.g. 0.50)
   - **Description**: Optional notes (e.g. "Used for assembly line A, sourced from Germany")
4. Click **Submit**

> Create several goods records so you can test full workflows.

### 4.4 Create a Bin (Storage Location)

Bins are physical locations where goods are stored.

1. Click **Bin** in the sidebar
2. Click **New**
3. Fill in:
   - **Bin Code**: e.g. "A-01-03" (shelf-row-level numbering)
   - **Bin Name**: e.g. "Shelf A, Row 1, Level 3"
   - **Bin Type**: e.g. "shelf", "pallet", "floor", "cold-storage"
   - **Capacity**: Maximum quantity the location can hold (e.g. 500)
4. Click **Submit**

> Create bins first, then assign goods to bins when creating ASN details.

---

## 5. Purchase Orders

Purchase orders represent procurement requests sent to suppliers.

### 5.1 Create a Purchase Order

1. Click **Purchase** in the sidebar
2. Click **New**
3. Fill in:
   - **Purchase Code**: e.g. "PO-2026-001" (your internal order number)
   - Select **Supplier** and **Goods** from dropdowns
   - Enter quantity and any notes
4. Click **Submit**

Purchase orders are reference documents — they do NOT affect stock levels. Stock only changes when you create and confirm an ASN or DN.

---

## 6. Inbound Operations (ASN - Advanced Shipping Notice)

An ASN records goods coming INTO the warehouse.

### 6.1 Create an Inbound Order

1. Click **ASN** in the sidebar
2. Click **New**
3. Fill in:
   - **ASN Code**: e.g. "ASN-2026-001" (unique inbound order number)
   - **ASN Type**: One of "purchase_receipt" (Purchase Receipt), "return" (Return), "transfer" (Transfer)
   - **Expected Time**: Expected arrival date/time
   - **Status**: Leave as **pending** (auto-updates on confirmation)
4. Click **Submit**

### 6.2 Add Line Items (ASN Details)

Each line item specifies what goods, how many, and where to put them.

1. Click **ASN Detail** in the sidebar
2. Click **New**
3. Fill in:
   - **ASN ID**: Enter the numeric ID of the ASN you just created (e.g. `1`)
   - **Goods ID**: Enter the numeric ID of the goods being received (e.g. `1`)
   - **Bin ID**: Enter the numeric ID of the storage bin (e.g. `1`)
   - **Quantity**: Number of units (e.g. `100`)
   - **Batch No**: (Optional) Batch/lot number for traceability
4. Click **Submit**
5. Repeat for each product line in the order

### 6.3 Confirm Receipt - Auto-Updates Stock

1. Go back to the **ASN** list page
2. Find the ASN you want to confirm
3. Click the **Confirm** button (checkmark icon)
4. A success notification confirms: "ASN confirmed and stock updated"

**What happens automatically:**
- If stock for this goods+bin combination already exists: quantity is increased
- If no stock record exists yet: a new stock record is created
- The ASN status changes from "pending" to "confirmed"

> **Warning**: Confirm only after verifying all line items. Confirmed ASNs cannot be reverted from the UI.

---

## 7. Outbound Operations (DN - Delivery Note)

A DN records goods going OUT of the warehouse.

### 7.1 Create an Outbound Order

1. Click **DN** in the sidebar
2. Click **New**
3. Fill in:
   - **DN Code**: e.g. "DN-2026-001"
   - **DN Type**: e.g. "sales_delivery", "transfer_out", "return_to_supplier"
   - **Expected Time**: Expected shipment date
   - **Status**: Leave as **pending**
4. Click **Submit**

### 7.2 Add Line Items (DN Details)

1. Click **DN Detail** in the sidebar
2. Click **New**
3. Fill in:
   - **DN ID**: Numeric ID of the DN (e.g. `1`)
   - **Goods ID**: Numeric ID of the goods
   - **Bin ID**: Numeric ID of the bin to pick from
   - **Quantity**: Number of units to ship (e.g. `30`)
4. Click **Submit**

### 7.3 Confirm Shipment - Auto-Deducts Stock

1. Go back to the **DN** list page
2. Find the DN to confirm
3. Click the **Confirm** button
4. A success notification: "DN confirmed and stock updated"

**What happens automatically:**
- Stock quantity for the specified goods+bin is reduced
- If you try to ship more than available stock, quantity is clamped to zero (no negatives)
- The DN status changes from "pending" to "confirmed"

---

## 8. Inventory Management

### 8.1 View Stock

1. Click **Stock** in the sidebar
2. The table shows:
   - **Goods Name** - which product
   - **Bin Code** - where it's stored
   - **Quantity** - current on-hand count
   - **Source ASN** - which inbound order created this stock

### 8.2 Low Stock Alert

- The dashboard and homepage show a yellow warning banner when any item has **quantity below 10**
- The banner shows the count of affected items: "8 item(s) below stock threshold of 10"
- Click the banner or go to the **WMS Dashboard** to see the full low-stock list

### 8.3 Stock Audit Trail

Every stock change is triggered by an ASN or DN confirmation. There is **no manual stock adjustment** — this ensures full audit traceability. To trace a stock change:
- Find the stock record, note the Goods ID and Bin ID
- Check ASN Detail records for that goods+bin combination, trace the ASN
- Check DN Detail records, trace the DN

---

## 9. Dashboard & Analytics

### 9.1 WMS Dashboard

Access via **Dashboard** in the WMS tab or the homepage button.

The dashboard shows:
- **KPI Cards**: Total Goods, Bins, Stock Items, Suppliers, Customers
- **Inbound/Outbound Chart**: Stacked bar chart comparing ASN vs DN counts for Today and This Week
- **Low Stock List**: Items with quantity < 10, with clickable rows

### 9.2 Data Refresh

Data refreshes automatically when:
- You switch language (English / Chinese)
- You log in/out and the token changes
- You navigate to the dashboard page

---

## 10. User & Permission Management

### 10.1 Permission Architecture

```
API Endpoint -> Permission Entry -> Team (assigned permissions) -> User (joins team, inherits permissions)
```

Permissions are API-level — each operation (list, create, update, delete) on each entity requires a specific permission.

### 10.2 Permission Categories

| Category | Available Permissions |
|----------|----------------------|
| User Management | Create User, Change Password, Set Team, Set Department, Lock/Unlock, Delete User |
| Team Management | Create Team, Change Team Name, Set Permission, Delete Team |
| Department Management | Create Department, Change Name, Delete Department |
| Goods | List, Create, Update, Delete |
| Bin | List, Create, Update, Delete |
| Stock | List, Create, Update, Delete |
| Supplier | List, Create, Update, Delete |
| Customer | List, Create, Update, Delete |
| ASN | List, Create, Update, Delete |
| ASN Detail | List, Create, Update, Delete |
| DN | List, Create, Update, Delete |
| DN Detail | List, Create, Update, Delete |
| Purchase | List, Create, Update, Delete |

### 10.3 Create a Team with Permissions

1. Click **Team List** in the sidebar (Standard tab)
2. Click **New Team**, enter a team name like "Warehouse Operators", **Submit**
3. Find the new team, click the **shield/lock** icon (Set Permission)
4. In the permission dialog, check the boxes for needed permissions. Recommended groupings:

   **Warehouse Operator**: ASN (Create, Update, List), ASN Detail (All), DN (Create, Update, List), DN Detail (All), Stock (List)

   **Inventory Manager**: All WMS entities (Goods, Bin, Stock: all CRUD)

   **Procurement**: Supplier (All), Customer (All), Purchase (All)

   **View-Only / Auditor**: All entities with only "List" permission

5. Click **Submit**

### 10.4 Create a User and Assign to Team

1. Click **User List** in the sidebar
2. Click **New User**, enter username (e.g. "operator01"), **Submit**
   - Default password = the username you entered
3. Find the new user, click the **team/people** icon (Set Team)
4. Select a team (e.g. "Warehouse Operators"), **Submit**
5. (Optional) Click the **building** icon to set a Department
6. (Optional) Click the **key** icon to change the user's password

### 10.5 Important Permission Notes

- **Re-login required**: After changing a user's team or permissions, the user must log out and log back in. Permissions are embedded in the JWT token at login time.
- **Superuser bypass**: The `admin` account has `admin: true` in its JWT and bypasses all permission checks.
- **Locked users**: Click the lock icon to prevent a user from logging in. The lock/unlock state takes effect immediately.

### 10.6 Department Management

1. Click **Department** in the sidebar
2. Click **New Department**, enter name (e.g. "Logistics Dept"), **Submit**
3. Departments are organizational labels - they do NOT affect permissions
4. To assign a user to a department: go to User List, click the department icon, select department

---

## 11. File Management

### 11.1 Upload Center

The Upload Center lets you upload files to the server.

1. Click **Upload Center** in the sidebar (Standard tab)
2. Click **Add files** to select files from your computer
3. Click **Upload to server** to start uploading
4. Each file shows its upload status: idle -> uploading -> uploaded
5. Use **Abort** to cancel an in-progress upload
6. Use **Delete** to remove a file from the list
7. **Clear All** removes all files from the list

> Max file size is configurable in `awesomewms/setup.ini` under `[file] file_size` (default 102400000 bytes).

### 11.2 Doc Center (File Sharing)

The Doc Center lets you browse, download, and share uploaded files.

1. Click **Doc Center** in the sidebar (Standard tab)
2. The list shows all uploaded files with Name, Type, Size, and Owner
3. **Download**: Click the download icon to save a file to your computer
4. **Share**: Click the share icon, select a user to share the file with
5. **Delete**: Click the trash icon, confirm to remove the file permanently

---

## 12. API Explorer

The API Explorer shows all registered API endpoints in the system.

1. Click **API** in the API tab (or sidebar if visible)
2. The table displays:
   - **Method**: HTTP method (GET, POST, etc.)
   - **API Path**: The endpoint URL
   - **Function Name**: Backend handler name
   - **Name**: Human-readable label
3. Use the search box to filter endpoints by keyword

---

## 13. System Monitoring (Server Tab)

When the server starts with `IS_LAN=true`, real-time hardware monitoring pages are available.

### 13.1 CPU Monitor

Shows CPU model, physical/logical core counts, current/min/max frequency, and a real-time usage percentage chart with history timeline.

### 13.2 Memory Monitor

Shows total/used/free RAM, swap usage, and a timeline chart of memory utilization.

### 13.3 Disk Monitor

Shows all mounted partitions with device path, mount point, total/used/free capacity, and usage percentage.

### 13.4 Network Monitor

Shows bytes sent/received counters and a timeline chart tracking network throughput over time.

### 13.5 PID Monitor

Lists all running processes with PID, process name, memory usage, and CPU usage.

### 13.6 PID Tree

A treemap visualization of process memory consumption - larger rectangles = more memory used.

### 13.7 DashBoard

A combined server health overview panel.

---

## 14. Data Operations

### 14.1 Searching

Every list page has a search input above the table:
- Type a keyword and press **Enter** to filter results
- Search runs across all text fields of the entity (case-insensitive contains match)
- Clear the search box and press **Enter** to show all records

### 14.2 Pagination

- Use the controls at the bottom of each table to navigate pages
- Adjust **Rows per page** to show more/fewer records
- Total record count is displayed in the pagination bar

### 14.3 Editing Records

1. Click the **pencil/edit** icon on any table row
2. Modify fields in the dialog that appears
3. Click **Submit** to save

### 14.4 Deleting Records

1. Click the **trash/delete** icon on any row
2. A confirmation dialog appears: "Delete data can not revert, please confirm"
3. Click **Submit** to permanently delete

> **Note**: Internally the system uses soft-delete (is_delete flag). Deleted records are hidden from the UI but remain in the database. Database-level recovery requires administrator access.

---

## 15. Language Switching

The system supports English and Chinese (Simplified).

1. Click the **globe** icon in the top-right toolbar
2. Select your preferred language
3. All UI text, menu labels, and documentation switch immediately
4. Data entered by users (goods names, codes, addresses) does NOT change, only the UI language

---

## 16. Dark Mode

1. Click the **dark mode** toggle button in the top-right toolbar (moon/sun icon)
2. The entire UI switches between light and dark themes
3. Your preference persists for the browser session

---

## 17. Configuration Reference

Edit `awesomewms/setup.ini` to customize system behavior:

```ini
[project]
name = awesomewms              # Project identifier

[database]
engine = sqlite                # sqlite, mysql, postgresql, or oracle
name = db_name
user = db_user
password = db_password
host = db_host
port = db_port

[jwt]
user_jwt_time = 1000000        # JWT token expiry in seconds

[request]
limit = 5                      # Max failed login attempts before account lockout

[file]
file_size = 102400000          # Max file upload size in bytes
```

After changing database settings, restart the server.

---

## 18. Deployment Options

### 18.1 Local Development

```bash
conda create -n wms python=3.11 -y && conda activate wms
pip install -r requirements.txt
PYTHONPATH=. python bomiot/server/manage.py migrate
PYTHONPATH=. python seed_api.py
PYTHONPATH=. python seed_permissions.py
PYTHONPATH=. python bomiot/server/manage.py shell -c "
from django.contrib.auth import get_user_model
get_user_model().objects.create_superuser('admin', 'admin@wms.com', 'admin123')
"
cd awesomewms/templates && npm install && npm run build && cd ../..
IS_LAN=true PYTHONPATH=. python bomiot/server/manage.py runserver 0.0.0.0:8000
```

### 18.2 Docker

```bash
cd deploy
docker-compose up -d
```

This starts the web application with a MySQL database in containers.

---

## 19. FAQ & Troubleshooting

### Q: I can't see certain menu items after logging in.
Your user account lacks the required permissions. Ask an admin to:
1. Go to Team List, find your team, Set Permission, grant needed permissions
2. Then you must log out and log back in (JWT token refresh)

### Q: The low stock alert shows items I just received.
The threshold is 10 units. Confirm your ASN to increase stock levels above the threshold.

### Q: Can I adjust stock manually without creating an ASN or DN?
No. All stock changes must go through ASN confirm (increase) or DN confirm (decrease). This ensures full audit traceability.

### Q: I can't log in - "Please Login First" keeps appearing.
Possible causes:
- Your JWT token expired (check user_jwt_time in setup.ini)
- Your account was locked by an admin (check User List lock status)
- Browser has stale token - clear browser cache and try again

### Q: How do I reset the admin password?
```bash
PYTHONPATH=. python bomiot/server/manage.py shell -c "
from django.contrib.auth import get_user_model
u = get_user_model().objects.get(username='admin')
u.set_password('newpassword')
u.save()
"
```

### Q: The Server tab (CPU, Memory, Disk, Network) is missing.
Start the server with the `IS_LAN=true` environment variable:
```bash
IS_LAN=true PYTHONPATH=. python bomiot/server/manage.py runserver 0.0.0.0:8000
```

### Q: How do I switch from SQLite to MySQL?
1. Edit `awesomewms/setup.ini`:
```ini
[database]
engine = mysql
name = wms_db
user = root
password = your_password
host = 127.0.0.1
port = 3306
```
2. Create the database in MySQL: `CREATE DATABASE wms_db CHARACTER SET utf8mb4;`
3. Re-run migrations: `PYTHONPATH=. python bomiot/server/manage.py migrate`
4. Re-seed data: run seed_api.py and seed_permissions.py
5. Create admin user again
6. Restart the server

### Q: Search is not finding my data.
The search uses case-insensitive partial matching on all text fields. Tips:
- Try fewer characters (e.g. search "wash" instead of "washer")
- Make sure you pressed Enter after typing
- Search only works on text fields, numeric IDs need exact matching

### Q: How do I handle a wrong ASN/DN confirmation?
There is no "undo" in the UI. As an admin, you can:
1. Create a reverse transaction: a DN to offset a wrong ASN, or vice versa
2. Or, as a last resort, directly correct the database records via Django shell

### Q: File upload fails with no error message.
Check:
- File size exceeds file_size limit in setup.ini
- Server disk space is full
- File type restrictions may apply depending on configuration

### Q: How to handle a departing team member?
Options:
1. **Lock account**: Click the lock icon on User List to prevent login but keep data
2. **Reassign team**: Move the user to a team with fewer permissions
3. **Change password**: Reset the password and give it to the replacement colleague

---

## 20. Complete Workflow Example

Here's a complete end-to-end example using sample data:

### Data Setup
```
Supplier: "Shanghai Metals Co." (ID=1)
Customer: "Beijing Assembly Plant" (ID=1)
Goods:     "Steel Bolt M8" (ID=1), Code: "BOLT-M8", Unit: "pcs", Price: 0.25
Goods:     "Steel Nut M8" (ID=2), Code: "NUT-M8", Unit: "pcs", Price: 0.15
Bin:       "A-01-01" (ID=1), Type: shelf, Capacity: 2000
Bin:       "A-01-02" (ID=2), Type: shelf, Capacity: 2000
```

### Purchase Order
```
PO-2026-001: Supplier=Shanghai Metals, Goods=Steel Bolt M8, Qty=1000
```

### Inbound Flow
```
ASN-2026-001: Type=purchase_receipt, Status=pending
  -> Detail: ASN_ID=1, Goods_ID=1, Bin_ID=1, Qty=1000
  -> Detail: ASN_ID=1, Goods_ID=2, Bin_ID=2, Qty=500
  -> [Click Confirm] -> Stock updated:
     Bin A-01-01: Steel Bolt M8 x 1000
     Bin A-01-02: Steel Nut M8 x 500
```

### Outbound Flow
```
DN-2026-001: Type=sales_delivery, Status=pending
  -> Detail: DN_ID=1, Goods_ID=1, Bin_ID=1, Qty=200
  -> [Click Confirm] -> Stock updated:
     Bin A-01-01: Steel Bolt M8 x 800 (was 1000, -200)
```

### Final State Check
Go to **Stock**: verify:
- Bin A-01-01: Steel Bolt M8 = 800
- Bin A-01-02: Steel Nut M8 = 500

Go to **Dashboard**: verify KPI counts reflect the new data.

---

## 21. Keyboard Shortcuts

| Key | Action |
|-----|--------|
| **Enter** | Submit search on list pages |
| **Esc** | Close any open dialog |

---

<div align="center">

**awesomewms - Full-Stack Warehouse Management System**

</div>
