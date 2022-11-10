package printm

import (
	"eamd/log"
	"eamd/models"
	"encoding/json"
	"fmt"
	mqtt "github.com/eclipse/paho.mqtt.golang"
)

type PrintClient struct {
	ClientId   string `json:"id"`
	ClientName string `json:"name"`
}

type PrintR struct {
	Id     int    `json:"id"`
	Result bool   `json:"result"`
	ErrMsg string `json:"errMsg"`
}

var Client *MqttClinent
var Clients map[string]PrintClient

func Start() {
	sessionId = &SessionId{
		SessionId: 0,
	}
	sessionInfos = make(map[int64]SessionInfo)
	Clients = make(map[string]PrintClient, 0)
	ConnectSevice()
}

// ---------------------------------发送的---------------------------------
func GetDeviceInfos(gatewayCode string) {

	jsonMap := make(map[string]interface{})
	jsonMap["req"] = "devs"
	jsonMap["rep"] = true
	jsonMap["session"] = sessionId.GetSessionId()

	buff, err := json.Marshal(jsonMap)
	if err != nil {
		log.Log.Error("%v", err)
		return
	}
	topicName := fmt.Sprintf("acs/gwa/%v", gatewayCode)
	PublishMsg(topicName, string(buff))
}

// ------------------------------接收的----------------------------------------
func HandResult(c mqtt.Client, msg mqtt.Message) {
	go func() {
		payload := string(msg.Payload())
		var resultInfo PrintR

		err := json.Unmarshal([]byte(payload), &resultInfo)
		if err != nil {
			fmt.Println("unmarshal json error :%v", payload)
		}
		if resultInfo.Result == true {
			var goods models.GoodsModel
			err = models.DB.Model(&models.GoodsModel{}).Select("id", "pcount").Where("id = ?", resultInfo.Id).First(&goods).Error
			if err != nil {
				log.Log.Error("%v", err.Error())
				return
			}
			goods.Pcount += 1
			models.DB.Select("pcount").Save(&goods)
		}
	}()
}

func HandRegisterPrint(c mqtt.Client, msg mqtt.Message) {
	go func() {
		payload := string(msg.Payload())
		fmt.Println(payload)
		var client PrintClient
		err := json.Unmarshal([]byte(payload), &client)
		if err != nil {
			fmt.Println("unmarshal json error :%v", payload)
		}
		Clients[client.ClientId] = client
	}()
}

func HandURegisterPrint(c mqtt.Client, msg mqtt.Message) {
	go func() {
		payload := string(msg.Payload())
		var client PrintClient
		err := json.Unmarshal([]byte(payload), &client)
		if err != nil {
			fmt.Println("unmarshal json error :%v", payload)
		}
		delete(Clients, client.ClientId)
	}()
}
