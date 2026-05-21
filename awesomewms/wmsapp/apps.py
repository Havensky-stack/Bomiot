from django.apps import AppConfig


class WmsappConfig(AppConfig):
    name = 'awesomewms.wmsapp'

    def ready(self):
        from bomiot.server.core.signal import bomiot_signals, bomiot_data_signals
        from awesomewms.receiver import WMSReceiver

        receiver = WMSReceiver()

        bomiot_data_signals.connect(receiver.goods_create, sender=None, dispatch_uid='wms_goods_create')
        bomiot_data_signals.connect(receiver.goods_update, sender=None, dispatch_uid='wms_goods_update')
        bomiot_data_signals.connect(receiver.goods_delete, sender=None, dispatch_uid='wms_goods_delete')

        bomiot_data_signals.connect(receiver.bin_create, sender=None, dispatch_uid='wms_bin_create')
        bomiot_data_signals.connect(receiver.bin_update, sender=None, dispatch_uid='wms_bin_update')
        bomiot_data_signals.connect(receiver.bin_delete, sender=None, dispatch_uid='wms_bin_delete')

        bomiot_data_signals.connect(receiver.stock_create, sender=None, dispatch_uid='wms_stock_create')
        bomiot_data_signals.connect(receiver.stock_update, sender=None, dispatch_uid='wms_stock_update')
        bomiot_data_signals.connect(receiver.stock_delete, sender=None, dispatch_uid='wms_stock_delete')

        bomiot_data_signals.connect(receiver.asn_create, sender=None, dispatch_uid='wms_asn_create')
        bomiot_data_signals.connect(receiver.asn_update, sender=None, dispatch_uid='wms_asn_update')
        bomiot_data_signals.connect(receiver.asn_delete, sender=None, dispatch_uid='wms_asn_delete')

        bomiot_data_signals.connect(receiver.dn_create, sender=None, dispatch_uid='wms_dn_create')
        bomiot_data_signals.connect(receiver.dn_update, sender=None, dispatch_uid='wms_dn_update')
        bomiot_data_signals.connect(receiver.dn_delete, sender=None, dispatch_uid='wms_dn_delete')

        bomiot_data_signals.connect(receiver.supplier_create, sender=None, dispatch_uid='wms_supplier_create')
        bomiot_data_signals.connect(receiver.supplier_update, sender=None, dispatch_uid='wms_supplier_update')
        bomiot_data_signals.connect(receiver.supplier_delete, sender=None, dispatch_uid='wms_supplier_delete')

        bomiot_data_signals.connect(receiver.customer_create, sender=None, dispatch_uid='wms_customer_create')
        bomiot_data_signals.connect(receiver.customer_update, sender=None, dispatch_uid='wms_customer_update')
        bomiot_data_signals.connect(receiver.customer_delete, sender=None, dispatch_uid='wms_customer_delete')
