package models

type OrganizationModel struct {
	Id          int64  `json:"id"`
	Name        string `json:"name"`
	Code        string `json:"code"`
	Parent      *int64 `json:"parent" ,gorm:"column:parent"`
	Isdept      bool   `json:"isdept"`
	Description string `json:"description"`
}

func (this *OrganizationModel) TableName() string {
	return "organization"
}
