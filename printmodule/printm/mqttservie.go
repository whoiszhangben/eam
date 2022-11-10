package printm

import (
	"encoding/json"
	"fmt"
	mqtt "github.com/eclipse/paho.mqtt.golang"
)

type Goods struct {
	GoodsModel []GoodsModel `json:"goods"`
}

var Client *MqttClinent

type HandSubscribeFunc func(topic, payload string)

func Start() {
	ConnectSevice()
	info := make(map[string]interface{})
	info["id"] = MqttSetting.ClientId
	info["name"] = MqttSetting.ClientName
	data, err := json.Marshal(info)
	if err != nil {
		return
	}
	PublishMsg(fmt.Sprintf("eam/register/%v", MqttSetting.ClientId), string(data))
}

func HandPrintMsg(c mqtt.Client, msg mqtt.Message) {
	go func() {
		payload := string(msg.Payload())
		var goods Goods
		err := json.Unmarshal([]byte(payload), &goods)
		if err != nil {
			fmt.Println("unmarshal json error :%v", payload)
			return
		}
		PrintLabel(goods.GoodsModel)
	}()
}
