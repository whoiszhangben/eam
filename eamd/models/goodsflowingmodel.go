package models

import "time"

type GoodsFlowingModel struct {
	Id             int64     `json:"id"`
	AcountId       int64     `json:"accountId" gorm:"column:accountid"`
	CreateTime     time.Time `json:"createTime" gorm:"column:createtime"`
	GoodsId        int64     `json:"goodsId" gorm:"column:goodsid"`
	User           string    `json:"user"`
	State          int       `json:"state"`
	OrganizationId int64     `json:"organizationId" gorm:"column:organizationid"`
	Savelocation   string    `json:"savelocation"`
	Description    string    `json:"description"`
}

func (this *GoodsFlowingModel) TableName() string {
	return "goodsflowing"
}
