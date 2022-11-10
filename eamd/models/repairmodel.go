package models

import "time"

type RepairModel struct {
	Id             int64     `json:"id"`
	GoodsId        int64     `json:"goodsId" gorm:"column:goodsid"`
	Price          float64   `json:"price"`
	Ctime          time.Time `json:"ctime"`
	Description    string    `json:"description"`
	OrganizationId int64     `json:"organizationId" gorm:"column:organizationid"`
}

type RepairExportModel struct {
	Id             int64     `json:"id"`
	GoodsId        int64     `json:"goodsId" gorm:"column:goodsid"`
	Price          float64   `json:"price"`
	Ctime          time.Time `json:"ctime"`
	Description    string    `json:"description"`
	OrganizationId int64     `json:"organizationId" gorm:"column:organizationid"`
	Gname          string
	Gmodel         string
	Oname          string
	Gsname         string
}

func (this *RepairModel) TableName() string {
	return "repair"
}
