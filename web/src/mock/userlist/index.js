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
      key: 1,
      code: 'admin',
      name: 'admin',
      role: 1,
      description: '超级管理员，想干什么就干什么',
      updatedAt: '2020/12/31 10:21:30'
    },
    {
      key: 2,
      code: 'user',
      name: 'user',
      role: 2,
      description: '普通用户，授权',
      updatedAt: '2021/02/18 09:28:13'
    },
    {
      key: 3,
      code: 'whoiszhangbne',
      name: '大坤',
      role: 2,
      description: '再普通不过了',
      updatedAt: '2021/08/31 15:22:47'
    }
  ]
}

Mock.mock(RegExp(`${process.env.VUE_APP_API_BASE_URL}/userlist` + '.*'),'get', ({url}) => {
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
