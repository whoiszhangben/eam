import Mock from 'mockjs'
import '@/mock/extend'
import {parseUrlParams} from '@/utils/request'

// const current = new Date().getTime()

// const source = Mock.mock({
//   'list|20': [{
//     'key|+1': 0,
//     'name': `分类@integer(1,20)`,
//     'code': `${current}-@integer(1,20)`,
//     'description': '这是一段描述',
//     'updatedAt': '@DATETIME',
//   }]
// })

const source = {
  list: [
    {
      id: 1,
      key: 1,
      code: '01',
      name: '建筑类',
      description: '房屋及其他建筑物',
      updatedAt: '2020/12/31 10:21:30'
    },
    {
      id: 2,
      key: 2,
      code: '02',
      name: '生产设备',
      description: '生产用机械设备',
      updatedAt: '2021/02/18 09:28:13'
    },
    {
      id: 3,
      key: 3,
      code: '03',
      name: '运输工具',
      description: '汽车',
      updatedAt: '2021/08/31 15:22:47'
    },
    {
      id: 4,
      key: 4,
      code: '04',
      name: '办公设备',
      description: '电脑、打印机、复印机、投影仪、照相机、服务器等电子信息化办公硬件设施设备',
      updatedAt: '2022/01/15 10:21:30'
    },
    {
      id: 5,
      key: 5,
      code: '05',
      name: '办公家具',
      description: '沙发、办公桌椅、茶几书柜、文件柜、保险柜',
      updatedAt: '2022/03/03 09:58:30'
    },
    {
      id: 6,
      key: 6,
      code: '06',
      name: '电器设备',
      description: '空调、冰箱、洗衣机、电视机、饮水机、风扇',
      updatedAt: '2022/05/12 09:21:30'
    },
    {
      id: 7,
      key: 7,
      code: '07',
      name: '软件应用',
      description: '有价软件',
      updatedAt: '2022/06/22 10:21:30'
    },
    {
      id: 8,
      key: 8,
      code: '08',
      name: '环安设备',
      description: '环境安全类设施设备',
      updatedAt: '2022/10/20 19:27:30'
    }
  ]
}

Mock.mock(RegExp(`${process.env.VUE_APP_API_BASE_URL}/categorylist` + '.*'),'get', ({url}) => {
  const params = parseUrlParams(decodeURI(url))
  let {page, pageSize} = params
  page = eval(page) - 1 || 0
  pageSize = eval(pageSize) || 10

  delete params.page
  delete params.pageSize

  let result = source.list.filter(item => {
    for (let [key, value] of Object.entries(params)) {
      if (item[key] !== value) {
        return false
      }
    }
    return true
  })
  const total = result.length
  console.log("当前列表数据：", result.length)
  if ((page) * pageSize > total) {
    result = []
  } else {
    result = result.slice(page * pageSize, (page + 1) * pageSize)
  }

  return {
    code: 0,
    message: 'success',
    data: {
      page: page + 1,
      pageSize,
      total: result.length,
      list: result
    }
  }
})
