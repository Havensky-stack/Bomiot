from django.contrib import admin
from bomiot.server.core.models import (
    Goods, Bin, Stock, StockBin, Capital, Supplier, Customer,
    ASN, ASNDetail, DN, DNDetail, Purchase, Bar, Fee, Driver
)


@admin.register(Goods)
class GoodsAdmin(admin.ModelAdmin):
    list_display = ['id', 'project', 'is_delete', 'created_time', 'updated_time']
    list_filter = ['is_delete', 'project']
    search_fields = ['data']


@admin.register(Bin)
class BinAdmin(admin.ModelAdmin):
    list_display = ['id', 'project', 'is_delete', 'created_time', 'updated_time']
    list_filter = ['is_delete', 'project']
    search_fields = ['data']


@admin.register(Stock)
class StockAdmin(admin.ModelAdmin):
    list_display = ['id', 'project', 'is_delete', 'created_time', 'updated_time']
    list_filter = ['is_delete', 'project']
    search_fields = ['data']


@admin.register(StockBin)
class StockBinAdmin(admin.ModelAdmin):
    list_display = ['id', 'project', 'is_delete', 'created_time', 'updated_time']
    list_filter = ['is_delete', 'project']


@admin.register(Capital)
class CapitalAdmin(admin.ModelAdmin):
    list_display = ['id', 'project', 'is_delete', 'created_time', 'updated_time']


@admin.register(Supplier)
class SupplierAdmin(admin.ModelAdmin):
    list_display = ['id', 'project', 'is_delete', 'created_time', 'updated_time']
    search_fields = ['data']


@admin.register(Customer)
class CustomerAdmin(admin.ModelAdmin):
    list_display = ['id', 'project', 'is_delete', 'created_time', 'updated_time']
    search_fields = ['data']


@admin.register(ASN)
class ASNAdmin(admin.ModelAdmin):
    list_display = ['id', 'project', 'is_delete', 'created_time', 'updated_time']
    list_filter = ['is_delete', 'project']
    search_fields = ['data']


@admin.register(ASNDetail)
class ASNDetailAdmin(admin.ModelAdmin):
    list_display = ['id', 'project', 'is_delete', 'created_time']


@admin.register(DN)
class DNAdmin(admin.ModelAdmin):
    list_display = ['id', 'project', 'is_delete', 'created_time', 'updated_time']
    list_filter = ['is_delete', 'project']
    search_fields = ['data']


@admin.register(DNDetail)
class DNDetailAdmin(admin.ModelAdmin):
    list_display = ['id', 'project', 'is_delete', 'created_time']


@admin.register(Purchase)
class PurchaseAdmin(admin.ModelAdmin):
    list_display = ['id', 'project', 'is_delete', 'created_time', 'updated_time']


@admin.register(Bar)
class BarAdmin(admin.ModelAdmin):
    list_display = ['id', 'project', 'is_delete', 'created_time']


@admin.register(Fee)
class FeeAdmin(admin.ModelAdmin):
    list_display = ['id', 'project', 'is_delete', 'created_time']


@admin.register(Driver)
class DriverAdmin(admin.ModelAdmin):
    list_display = ['id', 'project', 'is_delete', 'created_time']
