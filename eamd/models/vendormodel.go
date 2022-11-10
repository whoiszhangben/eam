package models

type VendorModel struct {
	Id          int64  `json:"id"`
	Name        string `json:"name"`
	Phone       string `json:"phone"`
	Addr        string `json:"addr"`
	Description string `json:"description"`
}

func (this *VendorModel) TableName() string {
	return "vendor"
}
