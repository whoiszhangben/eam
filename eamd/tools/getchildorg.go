package tools

import (
	"eamd/log"
	"eamd/models"
)

func GetChildOrg(orgId int) (ids []int) {

	var tids []int
	err := models.DB.Model(&models.OrganizationModel{}).Select("id").Where("parent= ?", orgId).Find(&tids).Error
	if err != nil {
		log.Log.Error("%v", err)
		return nil
	}
	for _, i := range tids {
		ids = append(ids, i)
		ids = append(ids, GetChildOrg(i)...)
	}
	return
}
