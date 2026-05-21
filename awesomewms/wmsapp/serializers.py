from rest_framework import serializers


class DashboardSerializer(serializers.Serializer):
    total_goods = serializers.IntegerField()
    total_bin = serializers.IntegerField()
    total_stock = serializers.IntegerField()
    total_supplier = serializers.IntegerField()
    total_customer = serializers.IntegerField()
    asn_today = serializers.IntegerField()
    dn_today = serializers.IntegerField()
    asn_week = serializers.IntegerField()
    dn_week = serializers.IntegerField()
    low_stock = serializers.ListField()


class ConfirmSerializer(serializers.Serializer):
    id = serializers.IntegerField(required=True)
