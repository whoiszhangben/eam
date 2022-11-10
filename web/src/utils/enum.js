export const enums = {
    ImportState: {
        Fail: 'fail',
        Success: 'success',
        PartialSuccess: 'partialSuccess'
    },
    ImportResult: {
        None: -1,
        Success: 0, // 导入成功
        PartialSuccess: 1, // 导入部分成功
        FileTypeError: 2, // 文件类型错误
        DataNumExceed: 3, // 数据超过限制
        DataColumnError: 4, // 文件展示头信息错误
        SystemError: 5, // 系统错误
        TemplateEmpty: 6, // 模板为空，请填写信息
    },
    GoodsState: {
        STATE_FREE: 1, // 闲置
        STATE_USED: 2, // 领用
        STATE_BACK: 3, // 归还
        STATE_LOSE: 4, // 丢失
        STATE_CEDE: 5, // 转让
        STATE_SCRAP: 6, // 报废
    },
    LogOPType: {
        OPT_TYPE_ADD: 1, //增加
        OPT_TYPE_DELETE: 2, //删除
        OPT_TYPE_MODIFY: 3, //修改
        OPT_TYPE_QUERY: 4, //查询
        OPT_TYPE_LOGIN: 5, //登录
        OPT_TYPE_IMPORT: 6, //导入
        OPT_TYPE_EXPORT: 7, //导出
        OPT_TYPE_PRINT: 8, //打印
    },
    Module: {
        TABLE_TYPE_REPAIR: 1, //维修
        TABLE_TYPE_GOODS: 2, //物品
        TABLE_TYPE_ORG: 3, //机构
        TABLE_TYPE_ACCOUNT: 4, //账户
        TABLE_TYPE_GSORT: 5, //分类
        TABLE_TYPE_CHILD_GSORT: 6, //子分类
        TABLE_TYPE_VENDOR: 7, //供应商
        TABLE_TYPE_CONFIG: 8, //配置文件
    }
}