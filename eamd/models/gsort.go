package models

const (
	GOODS_STATE_FREE     = 1 // 闲置
	GOODS_STATE_USE      = 2 // 使用
	GOODS_STATE_RETURN   = 3 // 归还
	GOODS_STATE_LOSS     = 4 // 遗失
	GOODS_STATE_TRANSFER = 5 // 转让
	GOODS_STATE_SCRAP    = 6 // 报废
)

type GSortModel struct {
	Id          int64             `json:"id"`
	Name        string            `json:"name"`
	Code        string            `json:"code"`
	Description string            `json:"description"`
	ChildGsort  []ChildGsortModel `gorm:"foreignKey:gsortid"  json:"childGsort"`
}

func (this *GSortModel) TableName() string {
	return "gsort"
}
