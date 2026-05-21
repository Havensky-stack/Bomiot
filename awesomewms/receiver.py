from bomiot_message import msg_message_return, detail_message_return
from bomiot.server.core.models import Goods, Bin, Stock, ASN, ASNDetail, DN, DNDetail
from bomiot.server.core.utils import queryset_to_dict
from django.core.cache import cache
from django.db.models import Q


class WMSReceiver:
    def _lang(self, data):
        request = data.get('request')
        return request.META.get('HTTP_LANGUAGE', 'en-US') if request else 'en-US'

    def time_ns(self, **kwargs):
        from time import time_ns
        import random
        return time_ns() + random.randint(0, 100000)

    def goods_create(self, data, **kwargs):
        request_data = data.get('data', {}).get('data', {})
        if not request_data.get('goods_name'):
            return detail_message_return(self._lang(data), "Goods name is required")
        return msg_message_return(self._lang(data), "Goods created successfully")

    def goods_update(self, data, **kwargs):
        return msg_message_return(self._lang(data), "Goods updated successfully")

    def goods_delete(self, data, **kwargs):
        return msg_message_return(self._lang(data), "Goods deleted successfully")

    def bin_create(self, data, **kwargs):
        request_data = data.get('data', {}).get('data', {})
        if not request_data.get('bin_code'):
            return detail_message_return(self._lang(data), "Bin code is required")
        return msg_message_return(self._lang(data), "Bin created successfully")

    def bin_update(self, data, **kwargs):
        return msg_message_return(self._lang(data), "Bin updated successfully")

    def bin_delete(self, data, **kwargs):
        return msg_message_return(self._lang(data), "Bin deleted successfully")

    def stock_create(self, data, **kwargs):
        request_data = data.get('data', {}).get('data', {})
        goods_id = request_data.get('goods_id')
        bin_id = request_data.get('bin_id')

        if goods_id and not Goods.objects.filter(id=goods_id, is_delete=False).exists():
            return detail_message_return(self._lang(data), "Goods not found")

        if bin_id and not Bin.objects.filter(id=bin_id, is_delete=False).exists():
            return detail_message_return(self._lang(data), "Bin not found")

        return msg_message_return(self._lang(data), "Stock created successfully")

    def stock_update(self, data, **kwargs):
        return msg_message_return(self._lang(data), "Stock updated successfully")

    def stock_delete(self, data, **kwargs):
        return msg_message_return(self._lang(data), "Stock deleted successfully")

    def asn_create(self, data, **kwargs):
        request_data = data.get('data', {}).get('data', {})
        if not request_data.get('asn_code'):
            return detail_message_return(self._lang(data), "ASN code is required")
        return msg_message_return(self._lang(data), "ASN created successfully")

    def asn_update(self, data, updated_fields=None, **kwargs):
        if updated_fields is None:
            updated_fields = data.get('updated_fields', {})
        if updated_fields and 'data' in updated_fields:
            data_updates_raw = updated_fields.get('data', {})
            if isinstance(data_updates_raw, tuple):
                data_updates = data_updates_raw[1]
            else:
                data_updates = data_updates_raw
            if 'status' in data_updates and data_updates['status'] in ('confirmed', 'received'):
                asn_id = data.get('data', {}).get('id')
                if asn_id:
                    request = data.get('request')
                    department = request.auth.department if request and request.auth else 0
                    creater = request.auth.username if request and request.auth else ''
                    project_name = request.META.get('HTTP_PROJECT', 'awesomewms') if request else 'awesomewms'
                    details = ASNDetail.objects.filter(data__data__asn_id=str(asn_id), is_delete=False)
                    for d in details:
                        dd = (d.data or {}).get('data', {})
                        gid = dd.get('goods_id')
                        bid = dd.get('bin_id')
                        q = int(dd.get('qty', 0))
                        ex = Stock.objects.filter(
                            data__data__goods_id=gid, data__data__bin_id=bid,
                            is_delete=False, project=project_name
                        ).first()
                        if ex:
                            ed = ex.data or {}
                            inner = ed.get('data', {})
                            inner['qty'] = int(inner.get('qty', 0)) + q
                            ed['data'] = inner
                            ex.data = ed
                            ex.save()
                        else:
                            Stock.objects.create(data={
                                'data': {
                                    'goods_id': gid, 'bin_id': bid, 'qty': q,
                                    'goods_name': dd.get('goods_name', ''),
                                    'bin_code': dd.get('bin_code', ''),
                                },
                                'department': department,
                                'creater': creater,
                            }, project=project_name)
        return msg_message_return(self._lang(data), "ASN updated successfully")

    def asn_delete(self, data, **kwargs):
        return msg_message_return(self._lang(data), "ASN deleted successfully")

    def dn_create(self, data, **kwargs):
        request_data = data.get('data', {}).get('data', {})
        if not request_data.get('dn_code'):
            return detail_message_return(self._lang(data), "DN code is required")
        return msg_message_return(self._lang(data), "DN created successfully")

    def dn_update(self, data, updated_fields=None, **kwargs):
        if updated_fields is None:
            updated_fields = data.get('updated_fields', {})
        if updated_fields and 'data' in updated_fields:
            data_updates_raw = updated_fields.get('data', {})
            if isinstance(data_updates_raw, tuple):
                data_updates = data_updates_raw[1]
            else:
                data_updates = data_updates_raw
            if 'status' in data_updates and data_updates['status'] in ('confirmed', 'shipped'):
                dn_id = data.get('data', {}).get('id')
                if dn_id:
                    details = DNDetail.objects.filter(data__data__dn_id=str(dn_id), is_delete=False)
                    for d in details:
                        dd = (d.data or {}).get('data', {})
                        gid = dd.get('goods_id')
                        bid = dd.get('bin_id')
                        q = int(dd.get('qty', 0))
                        ex = Stock.objects.filter(data__data__goods_id=gid, data__data__bin_id=bid, is_delete=False).first()
                        if ex:
                            ed = ex.data or {}
                            inner = ed.get('data', {})
                            inner['qty'] = max(0, int(inner.get('qty', 0)) - q)
                            ed['data'] = inner
                            ex.data = ed
                            ex.save()
        return msg_message_return(self._lang(data), "DN updated successfully")

    def dn_delete(self, data, **kwargs):
        return msg_message_return(self._lang(data), "DN deleted successfully")

    def supplier_create(self, data, **kwargs):
        request_data = data.get('data', {}).get('data', {})
        if not request_data.get('supplier_name'):
            return detail_message_return(self._lang(data), "Supplier name is required")
        return msg_message_return(self._lang(data), "Supplier created successfully")

    def supplier_update(self, data, **kwargs):
        return msg_message_return(self._lang(data), "Supplier updated successfully")

    def supplier_delete(self, data, **kwargs):
        return msg_message_return(self._lang(data), "Supplier deleted successfully")

    def customer_create(self, data, **kwargs):
        request_data = data.get('data', {}).get('data', {})
        if not request_data.get('customer_name'):
            return detail_message_return(self._lang(data), "Customer name is required")
        return msg_message_return(self._lang(data), "Customer created successfully")

    def customer_update(self, data, **kwargs):
        return msg_message_return(self._lang(data), "Customer updated successfully")

    def customer_delete(self, data, **kwargs):
        return msg_message_return(self._lang(data), "Customer deleted successfully")
