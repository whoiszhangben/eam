package models

type ChildGsortModel struct {
	Id          int64      `json:"id"`
	Name        string     `json:"name"`
	Code        string     `json:"code"`
	Gsortid     int        `json:"gsortid"`
	Description string     `json:"description"`
	GSort       GSortModel `json:"gsort" gorm:"foreignKey:gsortid"`
	Total       int64      `json:"total" gorm:"-"`
	UseCount    int64      `json:"useCount" gorm:"-"`
	LossCount   int64      `json:"lossCount"  gorm:"-"`
	ScrapCount  int64      `json:"scrapCount" gorm:"-"`
}

type ChildGoodsCount struct {
	State int64 `json:"state"`
	Count int64 `json:"count"`
}

type ChildGsortCodeId struct {
	Id   int64
	Code string
}

func (this *ChildGsortModel) TableName() string {
	return "childgsort"
}
