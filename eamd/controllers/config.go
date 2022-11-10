package controllers

import (
	"eamd/conf"
	"eamd/log"
	"eamd/models"
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/go-ini/ini"
)

type Config struct {
	AbsAnswer
}

type ConfigMsg struct {
	Database conf.DataseConf `json:"database"`
	Http     conf.HttpConf   `json:"http"`
	Mqtt     conf.MqttConf   `json:"mqtt"`
	Redis    conf.ReadisConf `json:"redis"`
}

func (this Config) HandQuery(ctx *gin.Context) {
	//this.Success(ctx, map[string]interface{}{"database": conf.DatabaseSetting, "http": conf.HttpSetting, "redis": conf.RedisSetting, "mqtt": conf.MqttSetting})
	this.Success(ctx, map[string]interface{}{"database": conf.DatabaseSetting})
}

func (this Config) HandModify(ctx *gin.Context) {
	var configInfo ConfigMsg
	err := ctx.ShouldBindJSON(&configInfo)
	if err != nil {
		this.AbsAnswer.FailString(ctx, "json格式错误！")
		return
	}

	cfg, err := ini.Load("./eamd.conf")
	if err != nil {
		log.Log.Error("%v", err.Error())
		panic(err.Error())
		return
	}

	/*cfg.Section("http").Key("ListenPort").SetValue(fmt.Sprintf("%v", configInfo.Http.ListenPort))
	cfg.Section("http").Key("Httpdir").SetValue(configInfo.Http.Httpdir)

	cfg.Section("database").Key("Type").SetValue(configInfo.Database.Type)
	cfg.Section("database").Key("User").SetValue(configInfo.Database.User)
	cfg.Section("database").Key("Password").SetValue(configInfo.Database.Password)
	cfg.Section("database").Key("Host").SetValue(configInfo.Database.Host)
	cfg.Section("database").Key("Port").SetValue(fmt.Sprintf("%v", configInfo.Database.Port))
	cfg.Section("database").Key("DbName").SetValue(configInfo.Database.DbName)*/
	cfg.Section("database").Key("BackupPeriod").SetValue(fmt.Sprintf("%v", configInfo.Database.BackupPeriod))
	cfg.Section("database").Key("BackupPath").SetValue(configInfo.Database.BackupPath)

	/*cfg.Section("redis").Key("Host").SetValue(configInfo.Redis.Host)
	cfg.Section("redis").Key("Port").SetValue(fmt.Sprintf("%v", configInfo.Redis.Port))
	cfg.Section("redis").Key("Password").SetValue(configInfo.Redis.Pwssword)

	cfg.Section("mqtt").Key("Host").SetValue(configInfo.Mqtt.Host)
	cfg.Section("mqtt").Key("Port").SetValue(fmt.Sprintf("%v", configInfo.Mqtt.Port))
	cfg.Section("mqtt").Key("Account").SetValue(configInfo.Mqtt.Account)
	cfg.Section("mqtt").Key("Password").SetValue(configInfo.Mqtt.Password)
	cfg.Section("mqtt").Key("ClientId").SetValue(configInfo.Mqtt.ClientId)
	cfg.Section("mqtt").Key("Timeout").SetValue(fmt.Sprintf("%v", configInfo.Mqtt.Timeout))*/
	err = cfg.SaveTo("./eamd.conf")
	conf.Reset()
	this.Ans(ctx, err)
	AddLog(ctx, models.TABLE_TYPE_CONFIG, models.OPT_TYPE_MODIFY, "")
}
