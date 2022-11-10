package models

import "time"

const (
	TABLE_TYPE_REPAIR      = 1 //维修
	TABLE_TYPE_GOODS       = 2 //物品
	TABLE_TYPE_ORG         = 3 //机构
	TABLE_TYPE_ACCOUNT     = 4 //账户
	TABLE_TYPE_GSORT       = 5 //分类
	TABLE_TYPE_CHILD_GSORT = 6 //子分类
	TABLE_TYPE_VENDOR      = 7 //供应商
	TABLE_TYPE_CONFIG      = 8 //配置文件
)

const (
	OPT_TYPE_ADD    = 1 //增加
	OPT_TYPE_DELETE = 2 //删除
	OPT_TYPE_MODIFY = 3 //修改
	OPT_TYPE_QUERY  = 4 //查询
	OPT_TYPE_LOGIN  = 5 //登录
	OPT_TYPE_IMPORT = 6 //导入
	OPT_TYPE_EXPORT = 7 //导出
	OPT_TYPE_PRINT  = 8 //打印
)

type LogModel struct {
	Id          int64     `json:"id"`
	AccountId   int64     `json:"accountId"  gorm:"column:accountid"`
	OprType     int       `json:"oprType"  gorm:"column:oprtype"`
	Opt         int       `json:"opt"`
	RemoteIp    string    `json:"remoteIp"  gorm:"column:remoteip"`
	Ctime       time.Time `json:"ctime"`
	ClientType  int       `json:"clientType"  gorm:"column:clienttype"`
	Description string    `json:"description"`
}

func (this *LogModel) TableName() string {
	return "log"
}
