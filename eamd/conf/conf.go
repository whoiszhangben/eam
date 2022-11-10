package conf

import (
	"eamd/log"
	"github.com/go-ini/ini"
)

type DataseConf struct {
	Type         string `json:"-"`
	User         string `json:"-"`
	Password     string `json:"-"`
	Host         string `json:"-"`
	Port         int64  `json:"-"`
	DbName       string `json:"-"`
	BackupPeriod int    `json:"backupPeriod" json:"backupPeriod,omitempty"`
	BackupPath   string `json:"backupPath,omitempty"`
}

type HttpConf struct {
	ListenPort int64
	Httpdir    string
}

type LogsConf struct {
	Maxlines int64
	Maxsize  int64
	Isdebug  bool
}

type ReadisConf struct {
	Host     string
	Port     int64
	Pwssword string
}

type MqttConf struct {
	Host     string
	Port     int
	Account  string
	Password string
	ClientId string
	Timeout  int
}

var DatabaseSetting = &DataseConf{}
var HttpSetting = &HttpConf{}
var LogsSetting = &LogsConf{}
var RedisSetting = &ReadisConf{}
var MqttSetting = &MqttConf{}

func init() {
	LoadConf()
}

func LoadConf() {
	cfg, err := ini.Load("./eamd.conf")
	if err != nil {
		log.Log.Error("%v", err.Error())
		panic(err.Error())
		return
	}

	err = cfg.Section("database").MapTo(DatabaseSetting)
	if err != nil {
		log.Log.Error("%v", err.Error())
		panic(err.Error())
		return
	}

	err = cfg.Section("mqtt").MapTo(MqttSetting)
	if err != nil {
		log.Log.Error("%v", err.Error())
		panic(err.Error())
		return
	}

	err = cfg.Section("http").MapTo(HttpSetting)
	if err != nil {
		log.Log.Error("%v", err.Error())
		panic(err.Error())
		return
	}

	err = cfg.Section("log").MapTo(LogsSetting)
	if err != nil {
		log.Log.Error("%v", err.Error())
		panic(err.Error())
		return
	}

	err = cfg.Section("redis").MapTo(RedisSetting)
	if err != nil {
		log.Log.Error("%v", err.Error())
		panic(err.Error())
		return
	}
}

func Reset() {
	LoadConf()
}
