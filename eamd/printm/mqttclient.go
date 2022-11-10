package printm

import (
	"eamd/conf"
	"eamd/log"
	"fmt"
	mqtt "github.com/eclipse/paho.mqtt.golang"
)

var Clinet mqtt.Client

type MqttClinent struct {
	ClinetId      string //mqtt客户端id
	MqttAgentHost string
	MqttAgentPort int64
	Accout        string
	Password      string
}

func ConnectSevice() {
	defer func() {
		if err := recover(); err != nil {
			log.Log.Error("", err)
		}
	}()

	opts := mqtt.NewClientOptions().AddBroker(fmt.Sprintf("tcp://%s:%d", conf.MqttSetting.Host, conf.MqttSetting.Port)).SetClientID(conf.MqttSetting.ClientId)
	if conf.MqttSetting.Account != "" {
		opts.SetUsername(conf.MqttSetting.Account)
	}
	if conf.MqttSetting.Password != "" {
		opts.SetPassword(conf.MqttSetting.Password)
	}

	opts.SetCleanSession(true)
	c := mqtt.NewClient(opts)
	if token := c.Connect(); token.Wait() && token.Error() != nil {
		panic(token.Error())
	}
	log.Log.Debug("connect mqtt success!")

	if token := c.Subscribe("eam/answer/#", 0, HandResult); token.Wait() && token.Error() != nil {
		log.Log.Error(token.Error().Error())
		return
	}

	if token := c.Subscribe("eam/register/#", 0, HandRegisterPrint); token.Wait() && token.Error() != nil {
		log.Log.Error(token.Error().Error())
		panic(0)
		return
	}

	if token := c.Subscribe("eam/uregister/#", 0, HandURegisterPrint); token.Wait() && token.Error() != nil {
		log.Log.Error(token.Error().Error())
		panic(0)
		return
	}
	Clinet = c

	PublishMsg("eam/queryprint/*", "{}")
}

func Close() {
	Clinet.Disconnect(1000 * 1)
}

func PublishMsg(topciName, pubMsg string) {
	Clinet.Publish(topciName, 0, false, pubMsg)
}
