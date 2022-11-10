package controllers

import (
	"eamd/models"
	"eamd/tools"
	"fmt"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"net/http"
)

type OrgInfo struct {
	AbsAnswer
}

func (this OrgInfo) HandAdd(ctx *gin.Context) {

	var info models.OrganizationModel
	err := ctx.ShouldBindJSON(&info)
	if err != nil {
		ctx.JSON(http.StatusOK, gin.H{
			"errcode": 60001,
			"errmsg":  "json格式错误！",
		})
		return
	}

	var count int64
	err = models.DB.Model(&models.OrganizationModel{}).Where("code = ? and parent = ?", info.Code, *info.Parent).Count(&count).Error
	if err != nil {
		this.AbsAnswer.Ans(ctx, err)
		return
	}
	if count > 0 {
		this.AbsAnswer.FailString(ctx, "此分组中已经存在相同的编号！")
		return
	}
	err = models.DB.Create(&info).Error
	if err != nil {
		this.AbsAnswer.Ans(ctx, err)
		return
	}

	tools.Redisdb.HSet(tools.REDIS_H_ORG_ID_CODE, fmt.Sprintf("%v", info.Id), info.Code)
	tools.Redisdb.HSet(tools.REDIS_H_ORG_CODE_ID, info.Code, info.Id)

	this.Success(ctx, info)
	AddLog(ctx, models.TABLE_TYPE_ORG, models.OPT_TYPE_ADD, "")
}

func (this OrgInfo) HandRemove(ctx *gin.Context) {

	var ids map[string][]int
	err := ctx.ShouldBindJSON(&ids)
	if err != nil {
		ctx.JSON(http.StatusOK, gin.H{
			"errcode": 60001,
			"errmsg":  "json格式错误！",
		})
		return
	}

	var dIds []int
	models.DB.Transaction(func(tx *gorm.DB) error {
		var nIds []int
		for _, v := range ids["id"] {
			nIds = append(nIds, v)
			nIds = append(nIds, tools.GetChildOrg(v)...)
			for i := len(nIds) - 1; i >= 0; i-- {
				err = tx.Delete(&models.OrganizationModel{}, nIds[i]).Error
				dIds = append(dIds, nIds[i])
				if err != nil {
					return err
				}
			}
			nIds = nIds[:0]
		}
		return nil
	})
	if err != nil {
		this.AbsAnswer.FailString(ctx, "机构下有资产， 无法删除！")
		return
	}

	for _, v := range dIds {
		code, _ := tools.Redisdb.HGet(tools.REDIS_H_ORG_ID_CODE, fmt.Sprintf("%v", v)).Result()
		tools.Redisdb.HDel(tools.REDIS_H_ORG_ID_CODE, fmt.Sprintf("%v", v))
		tools.Redisdb.HDel(tools.REDIS_H_ORG_CODE_ID, code)
	}
	this.Success(ctx, nil)
	AddLog(ctx, models.TABLE_TYPE_ORG, models.OPT_TYPE_DELETE, "")
}

func (this OrgInfo) HandModify(ctx *gin.Context) {
	var info models.OrganizationModel
	err := ctx.ShouldBindJSON(&info)
	if err != nil {
		ctx.JSON(http.StatusOK, gin.H{
			"errcode": 60001,
			"errmsg":  "json格式错误！",
		})
		return
	}

	var count int64
	err = models.DB.Model(&models.OrganizationModel{}).Where("code = ? and id<>?", info.Code, info.Id).Count(&count).Error
	if err != nil {
		this.AbsAnswer.Ans(ctx, err)
		return
	}
	if count > 0 {
		this.AbsAnswer.FailString(ctx, "此分组中已经存在相同的编号！")
		return
	}

	code, _ := tools.Redisdb.HGet(tools.REDIS_H_ORG_ID_CODE, fmt.Sprintf("%v", info.Id)).Result()
	if code != info.Code {
		tools.Redisdb.HDel(tools.REDIS_H_ORG_CODE_ID, code)
		tools.Redisdb.HSet(tools.REDIS_H_ORG_ID_CODE, fmt.Sprintf("%v", info.Id), info.Code)
		tools.Redisdb.HSet(tools.REDIS_H_ORG_CODE_ID, info.Code, info.Id)
	}

	err = models.DB.Save(&info).Error
	if err != nil {
		this.AbsAnswer.Ans(ctx, err)
		return
	}
	this.Success(ctx, nil)
	AddLog(ctx, models.TABLE_TYPE_ORG, models.OPT_TYPE_MODIFY, "")
}

func (this OrgInfo) HandQuery(ctx *gin.Context) {
	var orgInfo []models.OrganizationModel
	err := models.DB.Find(&orgInfo).Error
	if err != nil {
		this.AbsAnswer.Ans(ctx, err)
		return
	}
	this.Success(ctx, map[string]interface{}{"list": &orgInfo})
}
