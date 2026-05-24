<div align="center">
  <img src="media/img/logo.png" alt="awesomewms logo" width="200" height="auto" />
  <h1>awesomewms - User Manual</h1>
  <p><strong>Full-Stack Warehouse Management System</strong></p>
</div>

---

## 1. Login & First Access

### Default Account

| Field | Value |
|-------|-------|
| URL | `http://127.0.0.1:8000/` |
| Username | `admin` |
| Password | `admin123` |

The `admin` account is a superuser with unrestricted access to all features.

### Login Steps

1. Open your browser and navigate to `http://127.0.0.1:8000/`
2. Enter your username and password on the login page
3. Click the **Login** button — you will be redirected to the homepage

### What You See After Login

The homepage shows:
- **System Overview**: KPI cards displaying total goods, bins, stock items, suppliers, customers, and weekly inbound/outbound counts
- **Quick Actions**: A grid of shortcut cards to jump directly to any WMS module
- **Recent Activity**: A live timeline of the latest ASN/DN transactions
- **Dashboard Preview**: Today's inbound/outbound summary with a link to the full dashboard

---

## 2. Setting Up Base Data

Before creating any warehouse transactions, configure your base data in this order:

### Step 1 — Create Suppliers

1. Click **Supplier** from the quick actions or the left sidebar menu
2. Click the **New** button (top-right corner)
3. Fill in the form:
   - **Supplier Name**: e.g. "ABC Electronics Ltd."
   - **Contact**: e.g. "John Smith"
   - **Phone**: e.g. "123-456-7890"
   - **Address**: e.g. "123 Industrial Rd, Shanghai"
4. Click **Submit**

### Step 2 — Create Customers

1. Click **Customer** from the quick actions or sidebar menu
2. Click the **New** button
3. Fill in customer contact details (same fields as Supplier)
4. Click **Submit**

### Step 3 — Create Goods (Products)

1. Click **Goods** from the quick actions or sidebar menu
2. Click the **New** button
3. Fill in the form:
   - **Goods Name**: e.g. "Widget A — 10mm"
   - **Goods Code**: e.g. "WGT-001" (unique identifier)
   - **Specification**: e.g. "10mm x 50mm, stainless steel"
   - **Unit**: e.g. "pcs", "kg", "box"
   - **Price**: Unit price (decimal)
   - **Description**: Optional notes
4. Click **Submit**

### Step 4 — Create Bins (Storage Locations)

1. Click **Bin** from the quick actions or sidebar menu
2. Click the **New** button
3. Fill in the form:
   - **Bin Code**: e.g. "A-01-01" (unique location code)
   - **Bin Name**: e.g. "Shelf A, Row 1, Level 1"
   - **Bin Type**: e.g. "shelf", "pallet", "floor"
   - **Capacity**: Maximum quantity this location can hold
4. Click **Submit**

> **Tip**: Use the search box on any list page to filter by keyword. Data refreshes automatically when you switch between pages.

---

## 3. Inbound Operations (ASN)

### Create an Inbound Order

1. Click **ASN** from the quick actions or sidebar menu
2. Click the **New** button
3. Fill in the form:
   - **ASN Code**: e.g. "ASN-2026-001" (your inbound order number)
   - **ASN Type**: e.g. "purchase_receipt", "return", "transfer"
   - **Expected Time**: Expected arrival date/time
   - **Status**: Leave as **pending** (will change after confirmation)
4. Click **Submit**

### Add Inbound Details (Line Items)

1. Click **ASN Detail** in the sidebar menu
2. Click the **New** button
3. Fill in the form:
   - **ASN ID**: Select the inbound order you just created (use the ID number)
   - **Goods ID**: Select the product being received
   - **Bin ID**: Select the storage location where goods will be placed
   - **Quantity**: Number of units received
   - **Batch No**: (Optional) batch/lot number for traceability
4. Click **Submit**
5. Repeat for each product line in the order

### Confirm Receipt (Updates Stock)

1. Go to **ASN** list page
2. Find the ASN you want to confirm
3. Click the **Confirm** button (checkmark icon)
4. The system automatically:
   - Updates stock quantities in the specified bins
   - Creates new stock records if none exist
   - Changes the ASN status to **confirmed**

> **Important**: Stock quantities increase automatically upon ASN confirmation. Make sure your line items are correct before confirming.

---

## 4. Outbound Operations (DN)

### Create an Outbound Order

1. Click **DN** from the quick actions or sidebar menu
2. Click the **New** button
3. Fill in the form:
   - **DN Code**: e.g. "DN-2026-001" (your outbound order number)
   - **DN Type**: e.g. "sales_delivery", "transfer_out", "return_to_supplier"
   - **Expected Time**: Expected shipment date/time
   - **Status**: Leave as **pending**
4. Click **Submit**

### Add Outbound Details (Line Items)

1. Click **DN Detail** in the sidebar menu
2. Click the **New** button
3. Fill in the form:
   - **DN ID**: Select the outbound order you just created
   - **Goods ID**: Select the product being shipped
   - **Bin ID**: Select the storage location to pick from
   - **Quantity**: Number of units to ship
4. Click **Submit**

### Confirm Shipment (Updates Stock)

1. Go to **DN** list page
2. Find the DN you want to confirm
3. Click the **Confirm** button
4. The system automatically:
   - Deducts stock from the specified bins
   - Changes the DN status to **confirmed**

> **Important**: If you try to ship more than the available stock, the system will deduct to zero but not go negative.

---

## 5. Checking Inventory

### View Stock

1. Click **Stock** from the quick actions or sidebar menu
2. The stock list shows all inventory records with:
   - Goods name and bin location
   - Current quantity
   - Which ASN originally created the stock

### Low Stock Warning

- The dashboard and homepage automatically show a **Low Stock Alert** for any item with quantity **below 10 units**
- The warning banner appears at the top of the homepage with a count of affected items
- Click the warning to view the full list on the dashboard

### Stock Movements

Every stock change is triggered by an ASN or DN confirmation. There is no manual stock adjustment — all inventory changes must go through an inbound or outbound order.

---

## 6. Purchase Orders

Purchase orders link suppliers and goods.

1. Click **Purchase** from the quick actions or sidebar menu
2. Click the **New** button
3. Fill in the form:
   - **Purchase Code**: e.g. "PO-2026-001"
   - Select the **Supplier** and **Goods**
   - Enter quantity and any notes
4. Click **Submit**

---

## 7. User & Permission Management

### Permission Model

```
API Endpoint → Permission Entry → Team (granted permissions) → User (joins team, inherits permissions)
```

Permissions are API-level — each CRUD operation on every entity requires a specific permission.

### Creating a Team with Permissions

1. Click **Team** in the sidebar menu (under Standard tab)
2. Click **New Team** → enter a team name → **Submit**
3. Find the new team in the list, click the **shield/lock** icon for **Set Permission**
4. In the dialog, check all permissions this team should have. Common groupings:
   - **Warehouse operators**: ASN, ASN Detail, DN, DN Detail (create, update)
   - **Inventory managers**: Goods, Bin, Stock (all CRUD)
   - **View-only users**: Any entity with just "list" permission
5. Click **Submit**

### Creating a User and Assigning to Team

1. Click **User** in the sidebar menu
2. Click **New User** → enter a username → **Submit** (default password = username)
3. Find the new user → click the **team** icon → select a team → **Submit**
4. Optionally set a **Department** and **change password**
5. The user must **log out and log back in** for permission changes to take effect (JWT-based)

### Locking / Unlocking Users

- Click the **lock/unlock** icon on the user list to prevent a user from logging in
- Locked users cannot access the system

### Pre-configured Permissions

| Category | Permissions Available |
|----------|----------------------|
| User Management | Create, Change Password, Set Team, Set Department, Lock/Unlock, Delete |
| Team Management | Create, Change, Set Permission, Delete |
| Department Management | Create, Change, Delete |
| Goods | Create, Update, Delete, List |
| Bin | Create, Update, Delete, List |
| Stock | Create, Update, Delete, List |
| Supplier | Create, Update, Delete, List |
| Customer | Create, Update, Delete, List |
| ASN | Create, Update, Delete, List |
| ASN Detail | Create, Update, Delete, List |
| DN | Create, Update, Delete, List |
| DN Detail | Create, Update, Delete, List |
| Purchase | Create, Update, Delete, List |

---

## 8. Search & Pagination

### Searching Data

- Every list page has a **search input** on top of the table
- Type a keyword and press **Enter** — the system searches across all text fields of that entity
- Clear the search box and press **Enter** to reset

### Pagination

- Use the **pagination controls** at the bottom of each table
- Adjust **rows per page** to see more or fewer records
- The total count is displayed in the pagination bar

---

## 9. Editing & Deleting Data

### Edit a Record

1. Click the **pencil/edit** icon on any row
2. Modify the fields in the dialog that appears
3. Click **Submit** to save changes

### Delete a Record

1. Click the **trash/delete** icon on any row
2. A confirmation dialog appears — **this action cannot be undone**
3. Click **Submit** to permanently delete the record

> **Important**: The system uses soft-delete internally, but deleted records are hidden from the UI. Contact your administrator if you need to recover deleted data.

---

## 10. System Monitoring (IS_LAN Mode)

When the server is started with `IS_LAN=true`, additional monitoring pages become available under the **Server** tab:

| Page | What It Shows |
|------|---------------|
| CPU | Real-time CPU usage with historical timeline chart |
| Memory | Used/free memory and swap usage with timeline |
| Disk | Disk usage by partition |
| Network | Bytes sent/received tracking with timeline |
| PID | Process-level memory and CPU usage |
| PID Tree | Treemap visualization of process memory usage |
| Dashboard | Combined server health overview |

---

## 11. Keyboard Shortcuts & Tips

- **Enter**: Submit search on list pages
- **Esc**: Close any open dialog
- The sidebar menu collapses automatically on smaller screens — use the hamburger icon to toggle
- Toggle **dark mode** via the theme button in the header toolbar
- Switch languages (**EN / 中文**) via the globe icon in the header toolbar

---

## 12. FAQ

### Q: I can't see some menu items after logging in?
**A**: Your user account may not have the required permissions. Ask your administrator to assign your team the necessary permissions, then log out and log back in.

### Q: Why is the low stock alert flagging items even though I just received them?
**A**: The threshold is hard-coded at **10 units**. Stock below this count triggers the alert. Confirm your ASN to increase stock levels.

### Q: Can I adjust stock manually without creating an ASN or DN?
**A**: No. All stock changes must go through ASN (inbound) or DN (outbound) confirmations. This ensures full audit traceability.

### Q: How do I reset the admin password?
**A**: Run this command on the server:
```bash
PYTHONPATH=. python bomiot/server/manage.py shell -c "
from django.contrib.auth import get_user_model
u = get_user_model().objects.get(username='admin')
u.set_password('newpassword')
u.save()
"
```

### Q: Can I connect to MySQL or PostgreSQL instead of SQLite?
**A**: Yes. Edit `awesomewms/setup.ini` and change the `[database]` section:
```ini
[database]
engine = mysql
name = your_db_name
user = your_db_user
password = your_db_password
host = 127.0.0.1
port = 3306
```

---

<div align="center">

**awesomewms - Full-Stack Warehouse Management System**

</div>
