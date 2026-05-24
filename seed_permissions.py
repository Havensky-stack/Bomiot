import os, sys

project_root = '/home/havensky/code/SoftwareEngineeringFinalProject/Bomiot'
sys.path.insert(0, project_root)
os.environ['DJANGO_SETTINGS_MODULE'] = 'bomiot.server.server.settings'
os.environ['PROJECT_NAME'] = 'awesomewms'
os.environ['DATABASE_TYPE'] = 'sqlite'

import django
django.setup()

from bomiot.server.core.models import Permission

entries = [
    # User management
    {'name': 'Get User List', 'api': 'user/'},
    {'name': 'Create One User', 'api': 'user/create/'},
    {'name': 'Set Permission For User', 'api': 'user/permission/'},
    {'name': 'Change Password', 'api': 'user/changepwd/'},
    {'name': 'Set Team For User', 'api': 'user/team/'},
    {'name': 'Set Department For User', 'api': 'user/department/'},
    {'name': 'Lock & Unlock User', 'api': 'user/lock/'},
    {'name': 'Delete One User', 'api': 'user/delete/'},
    # Department management
    {'name': 'Get Department List', 'api': 'department/'},
    {'name': 'Create Department', 'api': 'department/create/'},
    {'name': 'Change Department', 'api': 'department/change/'},
    {'name': 'Delete Department', 'api': 'department/delete/'},
    # Team management
    {'name': 'Get Team List', 'api': 'team/'},
    {'name': 'Create One Team', 'api': 'team/create/'},
    {'name': 'Set Permission For Team', 'api': 'team/setpermission/'},
    {'name': 'Change Team', 'api': 'team/change/'},
    {'name': 'Delete Team', 'api': 'team/delete/'},
    # Goods
    {'name': 'Get Goods List', 'api': 'goods/'},
    {'name': 'Create Goods', 'api': 'goods/create/'},
    {'name': 'Update Goods', 'api': 'goods/update/'},
    {'name': 'Delete Goods', 'api': 'goods/delete/'},
    # Bin
    {'name': 'Get Bin List', 'api': 'bin/'},
    {'name': 'Create Bin', 'api': 'bin/create/'},
    {'name': 'Update Bin', 'api': 'bin/update/'},
    {'name': 'Delete Bin', 'api': 'bin/delete/'},
    # Stock
    {'name': 'Get Stock List', 'api': 'stock/'},
    {'name': 'Create Stock', 'api': 'stock/create/'},
    {'name': 'Update Stock', 'api': 'stock/update/'},
    {'name': 'Delete Stock', 'api': 'stock/delete/'},
    # Capital
    {'name': 'Get Capital List', 'api': 'capital/'},
    {'name': 'Create Capital', 'api': 'capital/create/'},
    {'name': 'Update Capital', 'api': 'capital/update/'},
    {'name': 'Delete Capital', 'api': 'capital/delete/'},
    # Supplier
    {'name': 'Get Supplier List', 'api': 'supplier/'},
    {'name': 'Create Supplier', 'api': 'supplier/create/'},
    {'name': 'Update Supplier', 'api': 'supplier/update/'},
    {'name': 'Delete Supplier', 'api': 'supplier/delete/'},
    # Customer
    {'name': 'Get Customer List', 'api': 'customer/'},
    {'name': 'Create Customer', 'api': 'customer/create/'},
    {'name': 'Update Customer', 'api': 'customer/update/'},
    {'name': 'Delete Customer', 'api': 'customer/delete/'},
    # ASN
    {'name': 'Get ASN List', 'api': 'asn/'},
    {'name': 'Create ASN', 'api': 'asn/create/'},
    {'name': 'Update ASN', 'api': 'asn/update/'},
    {'name': 'Delete ASN', 'api': 'asn/delete/'},
    # DN
    {'name': 'Get DN List', 'api': 'dn/'},
    {'name': 'Create DN', 'api': 'dn/create/'},
    {'name': 'Update DN', 'api': 'dn/update/'},
    {'name': 'Delete DN', 'api': 'dn/delete/'},
    # Purchase
    {'name': 'Get Purchase List', 'api': 'purchase/'},
    {'name': 'Create Purchase', 'api': 'purchase/create/'},
    {'name': 'Update Purchase', 'api': 'purchase/update/'},
    {'name': 'Delete Purchase', 'api': 'purchase/delete/'},
    # Bar
    {'name': 'Get Bar List', 'api': 'bar/'},
    {'name': 'Create Bar', 'api': 'bar/create/'},
    {'name': 'Update Bar', 'api': 'bar/update/'},
    {'name': 'Delete Bar', 'api': 'bar/delete/'},
    # Fee
    {'name': 'Get Fee List', 'api': 'fee/'},
    {'name': 'Create Fee', 'api': 'fee/create/'},
    {'name': 'Update Fee', 'api': 'fee/update/'},
    {'name': 'Delete Fee', 'api': 'fee/delete/'},
    # Driver
    {'name': 'Get Driver List', 'api': 'driver/'},
    {'name': 'Create Driver', 'api': 'driver/create/'},
    {'name': 'Update Driver', 'api': 'driver/update/'},
    {'name': 'Delete Driver', 'api': 'driver/delete/'},
    # Example
    {'name': 'Get Example List', 'api': 'example/'},
    {'name': 'Create Example', 'api': 'example/create/'},
    {'name': 'Update Example', 'api': 'example/update/'},
    {'name': 'Delete Example', 'api': 'example/delete/'},
]

existing = set(Permission.objects.filter(is_delete=False).values_list('name', flat=True))
count = 0
for entry in entries:
    if entry['name'] not in existing:
        Permission.objects.create(**entry)
        count += 1
print(f'Inserted {count} Permission entries')
print(f'Total Permissions: {Permission.objects.filter(is_delete=False).count()}')
