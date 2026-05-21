from bomiot_message import msg_message_return, detail_message_return
from bomiot.server.core.models import Goods, Bin, Stock, ASN, ASNDetail, DN, DNDetail
from bomiot.server.core.utils import queryset_to_dict
from django.core.cache import cache
from django.db.models import Q


class WMSReceiver:
    def time_ns(self):
        from time import time_ns
        import random
        return time_ns() + random.randint(0, 100000)

    def goods_create(self, data):
        request_data = data.get('data', {}).get('data', {})
        if not request_data.get('goods_name'):
            language = data.get('request').META.get('HTTP_LANGUAGE', 'en-US')
            return detail_message_return(language, "Goods name is required")
        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "Goods created successfully"
        )

    def goods_update(self, data):
        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "Goods updated successfully"
        )

    def goods_delete(self, data):
        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "Goods deleted successfully"
        )

    def bin_create(self, data):
        request_data = data.get('data', {}).get('data', {})
        if not request_data.get('bin_code'):
            language = data.get('request').META.get('HTTP_LANGUAGE', 'en-US')
            return detail_message_return(language, "Bin code is required")
        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "Bin created successfully"
        )

    def bin_update(self, data):
        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "Bin updated successfully"
        )

    def bin_delete(self, data):
        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "Bin deleted successfully"
        )

    def stock_create(self, data):
        request_data = data.get('data', {}).get('data', {})
        goods_id = request_data.get('goods_id')
        bin_id = request_data.get('bin_id')

        if goods_id:
            goods_exists = Goods.objects.filter(id=goods_id, is_delete=False).exists()
            if not goods_exists:
                language = data.get('request').META.get('HTTP_LANGUAGE', 'en-US')
                return detail_message_return(language, "Goods not found")

        if bin_id:
            bin_exists = Bin.objects.filter(id=bin_id, is_delete=False).exists()
            if not bin_exists:
                language = data.get('request').META.get('HTTP_LANGUAGE', 'en-US')
                return detail_message_return(language, "Bin not found")

        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "Stock created successfully"
        )

    def stock_update(self, data):
        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "Stock updated successfully"
        )

    def stock_delete(self, data):
        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "Stock deleted successfully"
        )

    def asn_create(self, data):
        request_data = data.get('data', {}).get('data', {})
        if not request_data.get('asn_code'):
            language = data.get('request').META.get('HTTP_LANGUAGE', 'en-US')
            return detail_message_return(language, "ASN code is required")
        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "ASN created successfully"
        )

    def asn_update(self, data):
        request_data = data.get('data', {}).get('data', {})
        updated_fields = data.get('updated_fields', {})
        language = data.get('request').META.get('HTTP_LANGUAGE', 'en-US')

        if 'data' in updated_fields and 'status' in updated_fields.get('data', {}):
            new_status = request_data.get('status')
            if new_status == 'confirmed' or new_status == 'received':
                asn_id = request_data.get('id') or data.get('data', {}).get('id')
                if asn_id:
                    asn = ASN.objects.filter(id=asn_id, is_delete=False).first()
                    if asn:
                        asn_details = ASNDetail.objects.filter(
                            data__asn_id=asn_id, is_delete=False
                        )
                        for detail in asn_details:
                            detail_data = detail.data
                            goods_id = detail_data.get('goods_id')
                            bin_id = detail_data.get('bin_id')
                            qty = int(detail_data.get('qty', 0))

                            existing_stock = Stock.objects.filter(
                                data__goods_id=goods_id,
                                data__bin_id=bin_id,
                                is_delete=False
                            ).first()

                            if existing_stock:
                                old_qty = int(existing_stock.data.get('qty', 0))
                                new_stock_data = {**existing_stock.data, 'qty': old_qty + qty}
                                existing_stock.data = new_stock_data
                                existing_stock.save()
                            else:
                                Stock.objects.create(data={
                                    'goods_id': goods_id,
                                    'bin_id': bin_id,
                                    'qty': qty,
                                    'goods_name': detail_data.get('goods_name', ''),
                                    'bin_code': detail_data.get('bin_code', ''),
                                })

        return msg_message_return(language, "ASN updated successfully")

    def asn_delete(self, data):
        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "ASN deleted successfully"
        )

    def dn_create(self, data):
        request_data = data.get('data', {}).get('data', {})
        if not request_data.get('dn_code'):
            language = data.get('request').META.get('HTTP_LANGUAGE', 'en-US')
            return detail_message_return(language, "DN code is required")
        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "DN created successfully"
        )

    def dn_update(self, data):
        request_data = data.get('data', {}).get('data', {})
        updated_fields = data.get('updated_fields', {})
        language = data.get('request').META.get('HTTP_LANGUAGE', 'en-US')

        if 'data' in updated_fields and 'status' in updated_fields.get('data', {}):
            new_status = request_data.get('status')
            if new_status == 'confirmed' or new_status == 'shipped':
                dn_id = request_data.get('id') or data.get('data', {}).get('id')
                if dn_id:
                    dn = DN.objects.filter(id=dn_id, is_delete=False).first()
                    if dn:
                        dn_details = DNDetail.objects.filter(
                            data__dn_id=dn_id, is_delete=False
                        )
                        for detail in dn_details:
                            detail_data = detail.data
                            goods_id = detail_data.get('goods_id')
                            bin_id = detail_data.get('bin_id')
                            qty = int(detail_data.get('qty', 0))

                            existing_stock = Stock.objects.filter(
                                data__goods_id=goods_id,
                                data__bin_id=bin_id,
                                is_delete=False
                            ).first()

                            if existing_stock:
                                old_qty = int(existing_stock.data.get('qty', 0))
                                new_qty = max(0, old_qty - qty)
                                new_stock_data = {**existing_stock.data, 'qty': new_qty}
                                existing_stock.data = new_stock_data
                                existing_stock.save()

        return msg_message_return(language, "DN updated successfully")

    def dn_delete(self, data):
        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "DN deleted successfully"
        )

    def supplier_create(self, data):
        request_data = data.get('data', {}).get('data', {})
        if not request_data.get('supplier_name'):
            language = data.get('request').META.get('HTTP_LANGUAGE', 'en-US')
            return detail_message_return(language, "Supplier name is required")
        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "Supplier created successfully"
        )

    def supplier_update(self, data):
        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "Supplier updated successfully"
        )

    def supplier_delete(self, data):
        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "Supplier deleted successfully"
        )

    def customer_create(self, data):
        request_data = data.get('data', {}).get('data', {})
        if not request_data.get('customer_name'):
            language = data.get('request').META.get('HTTP_LANGUAGE', 'en-US')
            return detail_message_return(language, "Customer name is required")
        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "Customer created successfully"
        )

    def customer_update(self, data):
        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "Customer updated successfully"
        )

    def customer_delete(self, data):
        return msg_message_return(
            data.get('request').META.get('HTTP_LANGUAGE', 'en-US'),
            "Customer deleted successfully"
        )
