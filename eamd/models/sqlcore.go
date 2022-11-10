package models

import (
	"eamd/conf"
	"eamd/log"
	"fmt"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var DB *gorm.DB

func DBinit() {

	dsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8&parseTime=true&loc=Local",
		conf.DatabaseSetting.User, conf.DatabaseSetting.Password, conf.DatabaseSetting.Host,
		conf.DatabaseSetting.Port, conf.DatabaseSetting.DbName)

	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{
		QueryFields: true, //打印sql
	})

	if err != nil {
		log.Log.Error("%v", "init  database error: %v", err.Error())
		panic(0)
	}

	log.Log.Debug("%v", "open database sucess!")
	DB = db
}
