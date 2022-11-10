package models

import (
	"database/sql/driver"
	"errors"
	"time"
)

type LocalTime time.Time

const (
	timeFormart = "2006-01-02 15:04:05"
)

func (t *LocalTime) UnmarshalJSON(data []byte) (err error) {
	now, err := time.ParseInLocation(`"`+timeFormart+`"`, string(data), time.Local)
	*t = LocalTime(now)
	return
}

func (t *LocalTime) MarshalJSON() ([]byte, error) {
	b := make([]byte, 0, len(timeFormart)+2)
	b = append(b, '"')
	b = time.Time(*t).AppendFormat(b, timeFormart)
	b = append(b, '"')
	return b, nil
}

func (t *LocalTime) Value() (driver.Value, error) {
	// MyTime 转换成 time.Time 类型
	tTime := time.Time(*t)
	return tTime.Format("2006-01-02 15:04:05"), nil
}

func (t *LocalTime) Scan(v interface{}) error {
	switch vt := v.(type) {
	case time.Time:
		// 字符串转成 time.Time 类型
		*t = LocalTime(vt)
	default:
		return errors.New("类型处理错误")
	}
	return nil
}

func (t *LocalTime) String() string {
	return time.Time(*t).Format(timeFormart)
}

type GoodsModel struct {
	Id               int64             `json:"id"`
	Name             string            `json:"name"`
	Orgid            int64             `json:"orgId" gorm:"column:organizationid"`
	BuyTime          *string           `json:"buyTime"gorm:"column:buytime" `
	Ctime            time.Time         `json:"ctime"`
	Amount           *int64            `json:"amount"`
	Unit             string            `json:"unit"`
	Model            string            `json:"model"`
	Price            float64           `json:"price"`
	GSortId          int64             `json:"gSortId" gorm:"column:gsortid"`
	State            int               `json:"state"`
	Savelocation     string            `json:"savelocation"`
	Custodian        string            `json:"custodian"`
	Description      string            `json:"description"`
	VendorId         *int64            `json:"vendorId" gorm:"column:vendorid"`
	WarrantyPeriod   int               `json:"warrantyPeriod" gorm:"column:warrantyperiod"`
	Pcount           int64             `json:"pcount"`
	ChildGsortid     int64             `json:"childGsortid" gorm:"column:childgsortid"`
	Organization     OrganizationModel `gorm:"foreignKey:organizationid" json:"organization"`
	Vendor           VendorModel       `gorm:"foreignKey:vendorid" json:"vendor"`
	GSortModel       GSortModel        `gorm:"foreignKey:gsortid" json:"gsort"`
	ChildGsort       ChildGsortModel   `gorm:"foreignKey:childgsortid" json:"childGsort"`
	OrganizationName string            `json:"organizationName" gorm:"column:organizationName" `
	BaseOrgName      string            `json:"baseOrgName" gorm:"-"`
	Repair           []RepairModel     `gorm:"foreignKey:goodsid" json:"repair"`
	Fdescription     string            `json:"fdescription"`
}

func (this *GoodsModel) TableName() string {
	return "goods"
}
