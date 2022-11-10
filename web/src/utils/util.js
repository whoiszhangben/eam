import enquireJs from 'enquire.js'
import { enums } from "./enum";

export function isDef(v) {
  return v !== undefined && v !== null
}

/**
 * Remove an item from an array.
 */
export function remove(arr, item) {
  if (arr.length) {
    const index = arr.indexOf(item)
    if (index > -1) {
      return arr.splice(index, 1)
    }
  }
}

export function isRegExp(v) {
  return _toString.call(v) === '[object RegExp]'
}

export function enquireScreen(call) {
  const handler = {
    match: function () {
      call && call(true)
    },
    unmatch: function () {
      call && call(false)
    }
  }
  enquireJs.register('only screen and (max-width: 767.99px)', handler)
}

const _toString = Object.prototype.toString

export function getAssetState(state, type=1) {
  switch (state) {
    case enums.GoodsState.STATE_FREE:
      return "闲置";
    case enums.GoodsState.STATE_USED:
      return "领用";
    case enums.GoodsState.STATE_BACK:
      return "归还";
    case enums.GoodsState.STATE_CEDE:
      if (type === 1) {
        return "领用"
      } else {
        return "转让"
      }
    case enums.GoodsState.STATE_LOSE:
      return "遗失";
    case enums.GoodsState.STATE_SCRAP:
      return "报废";
    default:
      return "--";
  }
}

export function ArrayToTree(arr, parent = null) {
  if (!Array.isArray(arr) || !arr.length) return [];
  let newArr = [];
  arr.forEach((item) => {
    // 判断 当前item.parent 和 传入的parent 是否相等，相等就push 进去
    if (item.parent == parent) {
      newArr.push({
        ...item,
        children: ArrayToTree(arr, item.id),
      });
    }
  });
  return newArr;
}

export function ArrayToTree2(arr, parent = null) {
  if (!Array.isArray(arr) || !arr.length) return [];
  let newArr = [];
  arr.forEach((item) => {
    // 判断 当前item.parent 和 传入的parent 是否相等，相等就push 进去
    if (item.parent == parent && !item.isdept) {
      newArr.push({
        ...item,
        children: ArrayToTree2(arr, item.id),
      });
    }
  });
  return newArr;
}
