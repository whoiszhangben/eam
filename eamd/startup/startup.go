package startup

import (
	"eamd/conf"
	"eamd/log"
	"eamd/models"
	"eamd/printm"
	"eamd/routers"
	"eamd/tools"
	"fmt"
	"os"
)

func StartUp() {
	if conf.LogsSetting.Isdebug {
		log.InitLog("console", "logs/file.log", conf.LogsSetting.Maxlines, conf.LogsSetting.Maxsize, true)
	} else {
		log.InitLog("file", "logs/file.log", conf.LogsSetting.Maxlines, conf.LogsSetting.Maxsize, true)
	}

	printm.Start()
	models.DBinit()

	err := tools.InitRedis()
	if err != nil {
		log.Log.Error("init readis error :%v", err.Error())
		panic(0)
	}

	InitRedis()
	go routers.RoutreInit()

	tools.BackDb()
}

func InitRedis() {
	//加载机构==
	orgInfo := []models.OrganizationModel{}

	err := models.DB.Find(&orgInfo).Error
	if err != nil {
		log.Log.Error("init orgin error %v", err.Error())
		panic(0)
	}

	tools.Redisdb.Del(tools.REDIS_H_ORG_CODE_ID)
	tools.Redisdb.Del(tools.REDIS_H_ORG_ID_CODE)
	for _, item := range orgInfo {
		if item.Parent != nil {
			orgCode := FindParentOrg(item, orgInfo)
			tools.Redisdb.HSet(tools.REDIS_H_ORG_CODE_ID, orgCode, item.Id)
			tools.Redisdb.HSet(tools.REDIS_H_ORG_ID_CODE, fmt.Sprintf("%v", item.Id), orgCode)
		}
	}

	//加载分类==
	gSort := []models.GSortModel{}
	err = models.DB.Find(&gSort).Error
	if err != nil {
		log.Log.Error("init gSort error %v", err.Error())
		panic(0)
	}

	tools.Redisdb.Del(tools.REDIS_H_GSORT_CODE_ID)
	for _, item := range gSort {
		tools.Redisdb.HSet(tools.REDIS_H_GSORT_CODE_ID, item.Code, item.Id)
		tools.Redisdb.HSet(tools.REDIS_H_GSORT_ID_CODE, fmt.Sprintf("%v", item.Id), item.Code)
	}
}

func FindParentOrg(current models.OrganizationModel, orgInfos []models.OrganizationModel) string {

	if current.Parent == nil {
		return ""
	}
	for _, item := range orgInfos {
		if item.Id == *current.Parent {
			strCode := current.Code
			return FindParentOrg(item, orgInfos) + strCode
		}
	}

	return ""
}

func GetCurrentPath() string {
	pwd, _ := os.Getwd()
	return pwd
}
