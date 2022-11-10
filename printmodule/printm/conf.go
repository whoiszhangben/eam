package printm

import (
	"github.com/go-ini/ini"
)

type MqttConf struct {
	Host       string
	Port       int
	Account    string
	Password   string
	ClientId   string
	ClientName string
	Timeout    int
}

type Label struct {
	Width  int32
	Height int32
}

var MqttSetting = &MqttConf{}
var LabelSetting = &Label{}

func init() {

	cfg, err := ini.Load("./eam.conf")
	if err != nil {
		panic(err.Error())
		return
	}

	err = cfg.Section("mqtt").MapTo(MqttSetting)
	if err != nil {
		panic(err.Error())
		return
	}

	err = cfg.Section("label").MapTo(LabelSetting)
	if err != nil {
		panic(err.Error())
		return
	}
}
