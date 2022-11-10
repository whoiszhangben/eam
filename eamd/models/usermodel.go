package models

type UserModel struct {
	Id   int64  `json:"id"`
	Name string `json:"name"`
}

func (this *UserModel) TableName() string {
	return "user"
}
