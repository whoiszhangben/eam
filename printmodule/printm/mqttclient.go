package printm

import (
	"encoding/json"
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

func HandData(client mqtt.Client, msg mqtt.Message) {

}

func ConnectSevice() {
	defer func() {
		if err := recover(); err != nil {
		}
	}()

	fmt.Println(MqttSetting)
	opts := mqtt.NewClientOptions().AddBroker(fmt.Sprintf("tcp://%s:%d", MqttSetting.Host, MqttSetting.Port)).SetClientID(MqttSetting.ClientId)
	if MqttSetting.Account != "" {
		opts.SetUsername(MqttSetting.Account)
	}
	if MqttSetting.Password != "" {
		opts.SetPassword(MqttSetting.Password)
	}

	info := make(map[string]interface{})
	info["id"] = MqttSetting.ClientId
	info["name"] = MqttSetting.ClientName
	data, err := json.Marshal(info)
	if err != nil {
		fmt.Println(err.Error())
		return
	}
	opts.SetWill(fmt.Sprintf("eam/uregister/%v", MqttSetting.ClientId), string(data), 1, true)
	opts.SetCleanSession(true)
	c := mqtt.NewClient(opts)
	if token := c.Connect(); token.Wait() && token.Error() != nil {
		fmt.Println("connect mqtt fail error:%v", err.Error())
		//panic(token.Error())
	}

	fmt.Println("链接打印机：", c.IsConnected())

	if token := c.Subscribe(fmt.Sprintf("eam/print/%v", MqttSetting.ClientId), 0, HandPrintMsg); token.Wait() && token.Error() != nil {
		fmt.Println(token.Error().Error())
		return
	}

	if token := c.Subscribe("eam/queryprint/#", 0, HandQueryPrint); token.Wait() && token.Error() != nil {
		fmt.Println(token.Error().Error())
		return
	}

	fmt.Println("connect mqtt susccess")
	Clinet = c
}

func Close() {
	Clinet.Disconnect(1000 * 1)
}

func AddTopicName(topicName string, function HandSubscribeFunc) {
	if token := Clinet.Subscribe(topicName, 0, HandData); token.Wait() && token.Error() != nil {
		return
	}
}

func PublishMsg(topciName, pubMsg string) {
	Clinet.Publish(topciName, 0, false, pubMsg)
}

func HandQueryPrint(c mqtt.Client, msg mqtt.Message) {
	go func() {

		info := make(map[string]interface{})
		info["id"] = MqttSetting.ClientId
		info["name"] = MqttSetting.ClientName
		data, err := json.Marshal(info)
		if err != nil {
			return
		}
		PublishMsg(fmt.Sprintf("eam/register/%v", MqttSetting.ClientId), string(data))

	}()
}
