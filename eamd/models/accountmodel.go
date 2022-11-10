package models

import "time"

type AccountModel struct {
	Id          int64  `json:"id"`
	Name        string `json:"name"`
	Account     string `json:"account"`
	Password    string `json:"password"`
	Role        int
	Description string    `json:"description"`
	Ctime       time.Time `json:"ctime"`
	Enable      bool      `json:"enable"`
	ClientType  int       `json:"clientType" gorm:"-"`
}

type AccountModelApi struct {
	Id          int64     `json:"id"`
	Name        string    `json:"name"`
	Account     string    `json:"account"`
	Role        int       `json:"role"`
	Description string    `json:"description"`
	Ctime       time.Time `json:"ctime"`
}

func (this *AccountModel) TableName() string {
	return "account"
}
