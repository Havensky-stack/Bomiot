from django.urls import path
from . import views

urlpatterns = [
    path('dashboard/', views.DashboardView.as_view(), name='wms-dashboard'),
    path('asn/confirm/', views.ASNConfirmView.as_view(), name='wms-asn-confirm'),
    path('dn/confirm/', views.DNConfirmView.as_view(), name='wms-dn-confirm'),
    path('recent/', views.RecentActivityView.as_view(), name='wms-recent'),
]
