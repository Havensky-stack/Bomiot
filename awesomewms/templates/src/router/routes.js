
const routes = [
  {
    path: '/',
    component: () => import('layouts/MainLayout.vue'),
    children: [
      { path: '', name: 'home', component: () => import('pages/IndexPage.vue') },
      { path: 'readme', component: () => import('pages/READMEReader.vue') },
      { path: 'upload', component: () => import('pages/UploadCenter.vue') },
      { path: 'doc', component: () => import('pages/DocCenter.vue') },
      { path: 'table', component: () => import('pages/TableReader.vue') },
      { path: 'user', component: () => import('pages/UserReader.vue') },
      { path: 'team', component: () => import('pages/TeamReader.vue') },
      { path: 'department', component: () => import('pages/DepartmentReader.vue') },
      { path: 'pid', component: () => import('pages/PIDReader.vue') },
      { path: 'cpu', component: () => import('pages/CPUReader.vue') },
      { path: 'memory', component: () => import('pages/MemoryReader.vue') },
      { path: 'disk', component: () => import('pages/DiskReader.vue') },
      { path: 'network', component: () => import('pages/NetworkReader.vue') },
      { path: 'serverecharts', component: () => import('pages/ServerEcharts.vue') },
      { path: 'pidcharts', component: () => import('pages/PIDCharts.vue') },
      { path: 'api', component: () => import('pages/APIReader.vue') },
      { path: 'example', component: () => import('pages/ExampleReader.vue') },
      { path: 'wms-dashboard', component: () => import('pages/WmsDashboard.vue') },
      { path: 'goods', component: () => import('pages/GoodsReader.vue') },
      { path: 'bin', component: () => import('pages/BinReader.vue') },
      { path: 'stock', component: () => import('pages/StockReader.vue') },
      { path: 'asn', component: () => import('pages/ASNReader.vue') },
      { path: 'asn-detail', component: () => import('pages/ASNDetailReader.vue') },
      { path: 'dn', component: () => import('pages/DNReader.vue') },
      { path: 'dn-detail', component: () => import('pages/DNDetailReader.vue') },
      { path: 'supplier', component: () => import('pages/SupplierReader.vue') },
      { path: 'customer', component: () => import('pages/CustomerReader.vue') },
      { path: 'purchase', component: () => import('pages/PurchaseReader.vue') },
    ]
  },
  {
    path: '/404',
    component: () => import('pages/ErrorNotFound.vue')
  },
  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/ErrorNotFound.vue')
  }
]

export default routes
