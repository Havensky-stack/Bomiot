from django.contrib.auth import get_user_model
from rest_framework.views import APIView
from rest_framework.response import Response
from django.utils import timezone
from datetime import timedelta
from bomiot.server.core.models import (
    Goods, Bin, Stock, ASN, ASNDetail, DN, DNDetail,
    Supplier, Customer, Purchase
)

User = get_user_model()


class DashboardView(APIView):
    def get(self, request):
        today = timezone.now().date()
        week_ago = today - timedelta(days=7)

        total_goods = Goods.objects.filter(is_delete=False).count()
        total_bin = Bin.objects.filter(is_delete=False).count()
        total_stock = Stock.objects.filter(is_delete=False).count()
        total_supplier = Supplier.objects.filter(is_delete=False).count()
        total_customer = Customer.objects.filter(is_delete=False).count()

        asn_today = ASN.objects.filter(
            is_delete=False, created_time__date=today
        ).count()
        dn_today = DN.objects.filter(
            is_delete=False, created_time__date=today
        ).count()

        asn_week = ASN.objects.filter(
            is_delete=False, created_time__date__gte=week_ago
        ).count()
        dn_week = DN.objects.filter(
            is_delete=False, created_time__date__gte=week_ago
        ).count()

        low_stock = []
        for s in Stock.objects.filter(is_delete=False):
            inner = (s.data or {}).get('data', {})
            qty = int(inner.get('qty', 0))
            if qty < 10:
                low_stock.append({
                    'id': s.id,
                    'goods_name': inner.get('goods_name', ''),
                    'bin_code': inner.get('bin_code', ''),
                    'qty': qty,
                })

        return Response({
            'total_goods': total_goods,
            'total_bin': total_bin,
            'total_stock': total_stock,
            'total_supplier': total_supplier,
            'total_customer': total_customer,
            'asn_today': asn_today,
            'dn_today': dn_today,
            'asn_week': asn_week,
            'dn_week': dn_week,
            'low_stock': low_stock[:10],
        })


class ASNConfirmView(APIView):
    def post(self, request):
        asn_id = request.data.get('id')
        if not asn_id:
            return Response({'detail': 'ASN id is required'}, status=400)

        asn = ASN.objects.filter(id=asn_id, is_delete=False).first()
        if not asn:
            return Response({'detail': 'ASN not found'}, status=404)

        asn_data = asn.data or {}
        asn_data['status'] = 'confirmed'
        asn.data = asn_data
        asn.save()

        asn_details = ASNDetail.objects.filter(
            data__data__asn_id=str(asn_id), is_delete=False
        )
        for detail in asn_details:
            d = detail.data or {}
            goods_id = d.get('goods_id')
            bin_id = d.get('bin_id')
            qty = int(d.get('qty', 0))

            existing = Stock.objects.filter(
                data__data__goods_id=goods_id, data__data__bin_id=bin_id, is_delete=False
            ).first()
            if existing:
                ed = existing.data or {}
                inner = ed.get('data', {})
                inner['qty'] = int(inner.get('qty', 0)) + qty
                ed['data'] = inner
                existing.data = ed
                existing.save()
            else:
                Stock.objects.create(data={
                    'data': {
                        'goods_id': goods_id,
                        'bin_id': bin_id,
                        'qty': qty,
                        'goods_name': d.get('goods_name', ''),
                        'bin_code': d.get('bin_code', ''),
                    },
                })

        return Response({'msg': 'ASN confirmed and stock updated'})


class DNConfirmView(APIView):
    def post(self, request):
        dn_id = request.data.get('id')
        if not dn_id:
            return Response({'detail': 'DN id is required'}, status=400)

        dn = DN.objects.filter(id=dn_id, is_delete=False).first()
        if not dn:
            return Response({'detail': 'DN not found'}, status=404)

        dn_data = dn.data or {}
        dn_data['status'] = 'confirmed'
        dn.data = dn_data
        dn.save()

        dn_details = DNDetail.objects.filter(
            data__data__dn_id=str(dn_id), is_delete=False
        )
        for detail in dn_details:
            d = detail.data or {}
            goods_id = d.get('goods_id')
            bin_id = d.get('bin_id')
            qty = int(d.get('qty', 0))

            existing = Stock.objects.filter(
                data__data__goods_id=goods_id, data__data__bin_id=bin_id, is_delete=False
            ).first()
            if existing:
                ed = existing.data or {}
                inner = ed.get('data', {})
                inner['qty'] = max(0, int(inner.get('qty', 0)) - qty)
                ed['data'] = inner
                existing.data = ed
                existing.save()

        return Response({'msg': 'DN confirmed and stock updated'})


class RecentActivityView(APIView):
    def get(self, request):
        limit = int(request.GET.get('limit', 5))

        asns = ASN.objects.filter(is_delete=False).order_by('-created_time')[:limit]
        dns = DN.objects.filter(is_delete=False).order_by('-created_time')[:limit]

        asn_list = []
        for a in asns:
            ad = a.data or {}
            asn_list.append({
                'id': a.id,
                'type': 'asn',
                'type_label': 'Inbound (ASN)',
                'code': ad.get('asn_code', ''),
                'status': ad.get('status', 'pending'),
                'time': a.created_time.strftime('%Y-%m-%d %H:%M'),
            })

        dn_list = []
        for d in dns:
            dd = d.data or {}
            dn_list.append({
                'id': d.id,
                'type': 'dn',
                'type_label': 'Outbound (DN)',
                'code': dd.get('dn_code', ''),
                'status': dd.get('status', 'pending'),
                'time': d.created_time.strftime('%Y-%m-%d %H:%M'),
            })

        combined = sorted(asn_list + dn_list, key=lambda x: x['time'], reverse=True)[:limit]

        return Response({'recent': combined})
