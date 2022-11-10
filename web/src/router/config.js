import TabsView from '@/layouts/tabs/TabsView'
// import BlankView from '@/layouts/BlankView'
import PageView from '@/layouts/PageView'

// 路由配置
const options = {
  routes: [
    {
      path: '/login',
      name: '登录页',
      component: () => import('@/pages/login')
    },
    {
      path: '*',
      name: '404',
      component: () => import('@/pages/exception/404'),
    },
    {
      path: '/403',
      name: '403',
      component: () => import('@/pages/exception/403'),
    },
    {
      path: '/',
      name: '工作台',
      component: TabsView,
      redirect: '/home',
      children: [
        {
          path: 'home',
          name: '工作台',
          meta: {
            icon: 'home',
            page: {
              closable: false
            }
          },
          component: () => import('@/pages/dashboard/analysis'),
        },
        {
          path: 'assetmgr',
          name: '资产管理',
          meta: {
            icon: 'form',
            page: {
              cacheAble: false
            }
          },
          component: PageView,
          redirect: '/assetmgr/assetlist1',
          children: [
            {
              path: 'assetlist1',
              name: '资产列表(类别)',
              meta: {
                icon: 'ordered-list'
              },
              component: () => import('@/pages/assetmgr/AssetList1'),
            },
            {
              path: 'assetlist2',
              name: '资产列表(明细)',
              meta: {
                icon: 'ordered-list'
              },
              component: () => import('@/pages/assetmgr/AssetList2'),
            },
            {
              path: 'maintainlist',
              name: '维修记录',
              meta: {
                icon: 'unordered-list'
              },
              component: () => import('@/pages/assetmgr/MaintainList')
            },
            {
              path: 'assetlist/maintainlist/:id/:name',
              name: '维修记录',
              meta: {
                highlight: '/assetmgr/assetlist2',
                invisible: true
              },
              component: () => import('@/pages/assetmgr/MaintainList')
            },
            {
              path: 'assetlist/flow/:id/:name',
              name: '资产流水',
              meta: {
                highlight: '/assetmgr/assetlist2',
                invisible: true
              },
              component: () => import('@/pages/assetmgr/FlowList')
            },
            {
              path: 'assetlist/distribute/:id',
              name: '资产分布',
              meta: {
                highlight: '/assetmgr/assetlist1',
                invisible: true
              },
              component: () => import('@/pages/assetmgr/Distribute')
            },
            {
              path: 'assetlist/classifyView/:id',
              name: '资产分类',
              meta: {
                highlight: '/assetmgr/assetlist1',
                invisible: true
              },
              component: () => import('@/pages/assetmgr/ClassifyView')
            },
          ]
        },
        {
          path: 'basedata',
          name: '基础数据',
          meta: {
            icon: 'profile'
          },
          component: PageView,
          redirect: '/basedata/assetclassify',
          children: [
            {
              path: 'assetclassify',
              name: '资产分类',
              meta: {
                icon: 'bars',
              },
              component: () => import('@/pages/basedata/AssetClassify'),
            },
            {
              path: '/assetmgr/basedata/assetclassify/sub/:id',
              name: '资产子分类',
              meta: {
                icon: 'bars',
                highlight: '/basedata/assetclassify',
                invisible: true
              },
              component: () => import('@/pages/basedata/AssetSubClassify'),
            },
            {
              path: 'supplier',
              name: '供应商管理',
              meta: {
                icon: 'contacts'
              },
              component: () => import('@/pages/basedata/VendorManage'),
            },
            {
              path: 'orgmanage',
              name: '机构管理',
              meta: {
                icon: 'apartment'
              },
              component: () => import('@/pages/systemsetting/OrgManage'),
            },
          ]
        },
        {
          path: 'systemsetting',
          name: '系统管理',
          meta: {
            icon: 'setting'
          },
          component: PageView,
          redirect: '/systemsetting/usermanage',
          children: [
            {
              path: 'usermanage',
              name: '用户管理',
              meta: {
                authority: {
                  role: 'admin'
                },
                icon: 'user',
              },
              component: () => import('@/pages/systemsetting/UserManage'),
            },
            {
              path: 'usermanage/add',
              name: '用户新增',
              meta: {
                authority: {
                  role: 'admin'
                },
                invisible: true
              },
              component: () => import('@/pages/systemsetting/User')
            },
            {
              path: 'usermanage/modify/:id',
              name: '用户修改',
              meta: {
                authority: {
                  role: 'admin'
                },
                invisible: true
              },
              component: () => import('@/pages/systemsetting/User')
            },
            {
              path: 'usermanage/detail/:id',
              name: '用户详情',
              meta: {
                authority: {
                  role: 'admin'
                },
                invisible: true
              },
              component: () => import('@/pages/systemsetting/User')
            },
            {
              path: 'password',
              name: '修改密码',
              meta: {
                icon: 'unlock'
              },
              component: () => import('@/pages/systemsetting/Password'),
            },
            {
              path: 'sysparams',
              name: '系统参数',
              meta: {
                icon: 'slack'
              },
              component: () => import('@/pages/systemsetting/ParamsSetting'),
            },
            {
              path: 'logs',
              name: '日志消息',
              meta: {
                authority: {
                  role: 'admin'
                },
                icon: 'file'
              },
              component: () => import('@/pages/systemsetting/SystemLog'),
            },
          ]
        }
      ]
    },
  ]
}

export default options
