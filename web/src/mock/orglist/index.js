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
      code: 'HK',
      name: '宏凯集团',
      description: '总部',
      parent: null,
      updatedAt: '2020/12/31 10:21:30'
    },
    {
      id: 2,
      code: 'SZ',
      name: '深圳总部',
      description: '',
      parent: 1,
      updatedAt: '2021/02/18 09:28:13'
    },
    {
      id: 3,
      code: 'ZJ',
      name: '镇江基地',
      parent: 1,
      description: '',
      updatedAt: '2021/08/31 15:22:47'
    },
    {
        id: 4,
        code: 'YC',
        name: '盐城基地',
        parent: 1,
        description: '',
        updatedAt: '2021/08/31 15:22:47'
    },
    {
        id: 5,
        code: 'JN',
        name: '济宁基地',
        parent: 1,
        description: '',
        updatedAt: '2021/08/31 15:22:47'
      },
    {
      id: 6,
      code: 'A',
      name: '董事办',
      parent: 2,
      description: '',
      updatedAt: '2022/01/15 10:21:30'
    },
    {
      id: 7,
      code: 'W',
      name: '物联网事业部',
      parent: 2,
      description: '',
      updatedAt: '2022/03/03 09:58:30'
    }
  ]
}

Mock.mock(RegExp(`${process.env.VUE_APP_API_BASE_URL}/orglist` + '.*'),'get', ({url}) => {
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
