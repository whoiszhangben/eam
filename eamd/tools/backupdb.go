package tools

import (
	"eamd/conf"
	"eamd/log"
	"fmt"
	"github.com/go-xorm/xorm"
	"os"
	"time"
)

func BackDb() {
	go func() {
		time.Sleep(time.Second * 60)
		for true {
			if conf.DatabaseSetting.BackupPeriod < 1 {
				conf.DatabaseSetting.BackupPeriod = 1
			}
			bBackup := false
			sTime, err := Redisdb.Get("dbbackup").Result()
			if err != nil {
				log.Log.Error("redis get dbbackup time error :%v", err.Error())
				bBackup = true
			} else {
				loc, _ := time.LoadLocation("Local") //获取时区
				preSaveTime, _ := time.ParseInLocation("2006-01-02 15:04:05", sTime+" 00:00:00", loc)

				if preSaveTime.AddDate(0, 0, conf.DatabaseSetting.BackupPeriod).Before(preSaveTime) {
					bBackup = true
				}
			}

			if bBackup {
				FileExists(conf.DatabaseSetting.BackupPath)
				currentTime := time.Now()
				engine, _ := xorm.NewEngine("mysql", fmt.Sprintf("%v:%v@/%v?charset=utf8", conf.DatabaseSetting.User, conf.DatabaseSetting.Password, conf.DatabaseSetting.DbName))

				fmt.Println(conf.DatabaseSetting.BackupPath + "/a.sql")
				engine.DumpAllToFile(conf.DatabaseSetting.BackupPath + fmt.Sprintf("/%v.sql", currentTime.Format("20060102")))
				engine.Close()
				Redisdb.Set("dbbackup", currentTime.Format("20060102"), time.Hour*24*time.Duration(conf.DatabaseSetting.BackupPeriod+1))
			}
			time.Sleep(time.Hour)
		}
	}()
}

func FileExists(path string) bool {
	_, err := os.Stat(path) //os.Stat获取文件信息
	if err != nil {
		os.MkdirAll(path, 0750)
		return os.IsExist(err)
	}
	return true
}
